"""Host-only regressions: python3 -m unittest discover -s build/tools/tests -v."""

import ast
import base64
from collections import Counter
from contextlib import redirect_stdout
import importlib.util
import io
from itertools import product
import json
import os
from pathlib import Path
import re
import runpy
import shutil
import subprocess
import sys
import tempfile
import types
import unittest
from unittest import mock


TOOLS = Path(__file__).resolve().parents[1]
ROOT = TOOLS.parents[1]


def load_tool(name):
    spec = importlib.util.spec_from_file_location(name, TOOLS / (name + '.py'))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


merge = load_tool('merge_dtbs')
repopick = load_tool('repopick')


def load_roomservice():
    # Keep the command-line discovery out of these isolated dependency tests.
    tree = ast.parse((TOOLS / 'roomservice.py').read_text())
    definitions = [node for node in tree.body
                   if isinstance(node, (ast.Import, ast.ImportFrom, ast.FunctionDef))]
    module = types.ModuleType('roomservice')
    exec(compile(ast.Module(body=definitions, type_ignores=[]), 'roomservice.py', 'exec'), module.__dict__)
    module.dryrun = False
    return module


class CertificateTests(unittest.TestCase):
    def test_real_certificate_is_plain_hex(self):
        cert = ROOT / 'build/target/product/security/infinity.x509.pem'
        result = subprocess.run([sys.executable, str(TOOLS / 'getb64key.py'), str(cert)],
                                capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        content = cert.read_bytes().split(b'-----BEGIN CERTIFICATE-----')[1].split(b'-----END CERTIFICATE-----')[0]
        self.assertEqual(result.stdout.strip(), base64.b64decode(content).hex())

    def test_pem_surrounding_text_is_ignored(self):
        with tempfile.TemporaryDirectory() as directory:
            cert = Path(directory) / 'test.pem'
            cert.write_bytes(b'ignored header\n-----BEGIN CERTIFICATE-----\nAQID\n-----END CERTIFICATE-----\nignored footer\n')
            result = subprocess.check_output([sys.executable, str(TOOLS / 'getb64key.py'), str(cert)], text=True)
            self.assertEqual(result.strip(), '010203')


class OtaTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.directory = Path(self.temporary.name) / 'custom out' / 'shared_device'
        self.directory.mkdir(parents=True)
        self.package = self.directory / 'Project_Infinity-X-2.9-device-20261018-VANILLA-UNOFFICIAL.zip'
        self.package.write_bytes(b'OTA data')
        self.prop = self.directory / 'system/build.prop'
        self.prop.parent.mkdir()
        self.prop.write_text('ro.build.date.utc=1792281600\nro.infinity.device=actual_device\n'
                             'ro.infinity.android.version=15\nro.vendor.build.date.utc=123\n')

    def run_generator(self, *args):
        return subprocess.run([sys.executable, str(TOOLS / 'generate_ota_info.py'),
                               str(self.package), *map(str, args)], capture_output=True, text=True)

    def test_custom_out_and_shared_device(self):
        result = self.run_generator()
        self.assertEqual(result.returncode, 0, result.stderr)
        metadata = json.loads(Path(str(self.package) + '.json').read_text())['response'][0]
        self.assertEqual(metadata['timestamp'], 1792281600)
        self.assertEqual(metadata['size'], 8)
        self.assertEqual(metadata['md5'], 'a6807c457a15caabcc4ae4f92ccda8a9')
        self.assertEqual(metadata['version'], '2.9')
        self.assertIn('/actual_device/15/vanilla/', metadata['download'])

    def test_gapps_with_explicit_build_prop(self):
        self.package = self.package.with_name(self.package.name.replace('VANILLA', 'GAPPS'))
        self.package.write_bytes(b'OTA data')
        alternate = self.directory / 'explicit.prop'
        self.prop.rename(alternate)
        result = self.run_generator(alternate)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('/gapps/', json.loads(Path(str(self.package) + '.json').read_text())['response'][0]['download'])

    def test_json_and_url_escape_filename(self):
        name = 'Project_Infinity-X-2.9-device with space-VANILLA-UNOFFICIAL.zip'
        if os.name != 'nt':
            name = name.replace('with space', 'with "quotes"')
        self.package = self.package.with_name(name)
        self.package.write_bytes(b'OTA data')
        self.assertEqual(self.run_generator().returncode, 0)
        metadata = json.loads(Path(str(self.package) + '.json').read_text())['response'][0]
        self.assertEqual(metadata['filename'], name)
        self.assertIn('%20', metadata['download'])

    def test_invalid_timestamp_preserves_existing_json(self):
        output = Path(str(self.package) + '.json')
        output.write_text('previous valid metadata')
        for properties in ('ro.build.date.utc=invalid\n', 'ro.vendor.build.date.utc=123\n'):
            with self.subTest(properties=properties):
                self.prop.write_text(properties)
                self.assertNotEqual(self.run_generator().returncode, 0)
                self.assertEqual(output.read_text(), 'previous valid metadata')

    def test_missing_package_and_properties_fail(self):
        self.package.unlink()
        self.assertNotEqual(self.run_generator().returncode, 0)
        self.package.write_bytes(b'OTA data')
        self.prop.unlink()
        self.assertNotEqual(self.run_generator().returncode, 0)
        self.assertFalse(Path(str(self.package) + '.json').exists())


def ids(*values):
    return frozenset((value,) for value in values)


class DeviceTreeTests(unittest.TestCase):
    def test_split_covers_every_device_once(self):
        # Includes the cross combinations omitted by combinations_with_replacement.
        full = merge.DeviceTreeInfo(ids(1, 2), ids(3, 4), ids(5, 6), {'extra': ids(7, 8)})
        partial = merge.DeviceTreeInfo(ids(1), ids(3), ids(5), {'extra': ids(7)})
        pieces = full - partial
        coverage = Counter()
        for piece in pieces:
            coverage.update(product(piece.plat_id, piece.board_id, piece.pmic_id, piece.extra_ids['extra']))
        expected = Counter(product(full.plat_id, full.board_id, full.pmic_id, full.extra_ids['extra']))
        self.assertEqual(coverage, expected)
        self.assertEqual(len(pieces), 16)
        self.assertIn(partial, pieces)

    def test_single_changed_dimension_is_partitioned(self):
        full = merge.DeviceTreeInfo(ids(1), ids(2, 3), None)
        pieces = full - merge.DeviceTreeInfo(ids(1), ids(2), None)
        self.assertEqual(len(pieces), 2)

    def test_equality_is_symmetric_and_reflexive(self):
        specific = merge.DeviceTreeInfo(ids(1), ids(2), None)
        wildcard = merge.DeviceTreeInfo(ids(1), None, None)
        self.assertEqual(specific == wildcard, wildcard == specific)
        self.assertNotEqual(specific, wildcard)
        empty = merge.DeviceTreeInfo(None, None, None)
        self.assertEqual(empty, empty)

    def test_hash_ignores_extra_key_insertion_order(self):
        first = merge.DeviceTreeInfo(ids(1), None, None, {'a': ids(2), 'b': ids(3)})
        second = merge.DeviceTreeInfo(ids(1), None, None, {'b': ids(3), 'a': ids(2)})
        self.assertEqual(first, second)
        self.assertEqual(hash(first), hash(second))
        self.assertEqual(len({first, second}), 1)

    def test_extra_keys_distinguish_filenames(self):
        first = merge.InnerMergedDeviceTree('base.dtb', ids(1), None, None, {'extra': ids(2)})
        second = merge.InnerMergedDeviceTree('base.dtb', ids(1), None, None, {'extra': ids(3)})
        self.assertNotEqual(first.get_name(), second.get_name())

    def test_filenames_are_stable_across_python_processes(self):
        code = '''
import sys
sys.path.insert(0, sys.argv[1])
from merge_dtbs import InnerMergedDeviceTree
print(InnerMergedDeviceTree('base.dtb', frozenset({(1,)}), None, None,
                          {'extra': frozenset({(2,)})}).get_name())
'''
        names = [subprocess.check_output([sys.executable, '-c', code, str(TOOLS)], text=True,
                                         env=dict(os.environ, PYTHONHASHSEED=str(seed)))
                 for seed in (1, 2)]
        self.assertEqual(names[0], names[1])

    def test_successive_merges_keep_exact_coverage(self):
        def tree(name, plat, board):
            result = object.__new__(merge.DeviceTree)
            merge.DeviceTreeInfo.__init__(result, plat, board, None)
            result.filename = name
            return result
        merged = merge.MergedDeviceTree(tree('base.dtb', ids(1, 2), ids(3, 4)))
        self.assertTrue(merged.merged_dt_try_add(tree('first.dtbo', ids(1), ids(3, 4))))
        self.assertTrue(merged.merged_dt_try_add(tree('second.dtbo', ids(1, 2), ids(3))))
        coverage = Counter()
        for part in merged.merged_devicetrees:
            for plat, board in product(part.plat_id, part.board_id):
                coverage[(plat, board)] += 1
                expected = set()
                if plat == (1,):
                    expected.add('first.dtbo')
                if board == (3,):
                    expected.add('second.dtbo')
                self.assertEqual({tp.filename for tp in part.techpacks}, expected)
        self.assertEqual(coverage, Counter(product(ids(1, 2), ids(3, 4))))

    def test_empty_and_whitespace_fdt_properties(self):
        tree = object.__new__(merge.DeviceTree)
        tree.filename = 'mock.dtb'
        for output, expected in ((b'\n', None), (b'1  2\t3\n', [1, 2, 3])):
            with self.subTest(output=output), mock.patch.object(merge.subprocess, 'run',
                    return_value=types.SimpleNamespace(returncode=0, stdout=output)):
                self.assertEqual(tree.get_prop('/', 'property'), expected)


class RepopickTests(unittest.TestCase):
    def args(self, **overrides):
        return types.SimpleNamespace(**dict({'pull': True, 'gerrit': 'https://review.lineageos.org',
                                             'verbose': False, 'quiet': True}, **overrides))

    def test_failed_pull_is_not_success_when_commit_exists(self):
        item = {'project_path': '.', 'revision': 'revision',
                'fetch': {'ssh': {'ref': 'ref', 'url': 'ssh://host/project'}}}
        with mock.patch.object(repopick, 'commit_exists', return_value=True), \
                mock.patch.object(repopick.subprocess, 'call', return_value=1), \
                redirect_stdout(io.StringIO()):
            with self.assertRaises(SystemExit):
                repopick.do_git_fetch_pull(self.args(), item)

    def test_worker_failures_reach_main_and_fetch_failure_prevents_pick(self):
        review = {'number': 1, 'project': 'test', 'branch': 'main', 'status': 'NEW',
                  'subject': 'test', 'change_id': 'I1', 'current_revision': 'rev',
                  'revisions': {'rev': {'_number': 1, 'fetch': {}}}}
        manifest = '<manifest><default revision="main"/><project name="test" path="test"/></manifest>'
        def command_output(command, **kwargs):
            return manifest if command[:2] == ['repo', 'manifest'] else '1'

        for stage in ('fetch', 'pick'):
            with self.subTest(stage=stage), \
                    mock.patch.object(sys, 'argv', ['repopick', '-c', '0', '1']), \
                    mock.patch.dict(os.environ, {}, clear=True), \
                    mock.patch.object(repopick.os.path, 'isdir', return_value=True), \
                    mock.patch.object(repopick, 'fetch_query', return_value=[review]), \
                    mock.patch.object(repopick.subprocess, 'check_output', side_effect=command_output), \
                    mock.patch.object(repopick, 'do_git_fetch_pull', side_effect=SystemExit(7) if stage == 'fetch' else None), \
                    mock.patch.object(repopick, 'apply_change', side_effect=SystemExit(8)) as pick:
                with self.assertRaises(SystemExit) as error:
                    repopick.main()
                self.assertEqual(error.exception.code, 7 if stage == 'fetch' else 8)
                if stage == 'fetch':
                    pick.assert_not_called()


class RoomserviceTests(unittest.TestCase):
    def setUp(self):
        self.roomservice = load_roomservice()

    def test_dependency_cycle_terminates(self):
        dependencies = {
            'device/a/lineage.dependencies': '[{"target_path":"device/b"}]',
            'device/b/lineage.dependencies': '[{"target_path":"device/a"}]',
        }
        def open_dependency(path, *args):
            return io.StringIO(dependencies[path])
        with mock.patch.object(self.roomservice.os.path, 'exists', side_effect=lambda p: p in dependencies), \
                mock.patch.object(self.roomservice.os.path, 'isdir', return_value=True), \
                mock.patch.object(self.roomservice, 'is_in_manifest', return_value=True), \
                mock.patch('builtins.open', side_effect=open_dependency), redirect_stdout(io.StringIO()):
            self.roomservice.fetch_dependencies('device/a')

    def test_manifest_lookup_uses_argument(self):
        self.roomservice.device = 'wrong_global'
        manifest = '<manifest><project name="LineageOS/android_device_vendor_target" path="device/vendor/target"/></manifest>'
        with mock.patch.object(self.roomservice.glob, 'glob', return_value=['manifest.xml']), \
                mock.patch.object(self.roomservice.ElementTree, 'parse',
                                  return_value=self.roomservice.ElementTree.ElementTree(
                                      self.roomservice.ElementTree.fromstring(manifest))):
            self.assertEqual(self.roomservice.get_from_manifest('target'), 'device/vendor/target')

    def test_dry_run_never_syncs_or_writes_manifest_and_keeps_auth(self):
        mirror = b'<manifest><project name="LineageOS/android_device_vendor_target"/></manifest>'
        branches = b'[{"name":"test-branch"}]'
        requests = []
        def response(request, **kwargs):
            requests.append(request)
            return io.BytesIO(branches if '/branches' in request.full_url else mirror)
        with tempfile.TemporaryDirectory() as directory:
            previous = os.getcwd()
            self.addCleanup(os.chdir, previous)
            os.chdir(directory)
            Path('.repo').mkdir()
            Path('.repo/manifest.xml').write_text('<manifest><default revision="test-branch"/></manifest>')
            with mock.patch.object(sys, 'argv', ['roomservice', 'infinity_target']), \
                    mock.patch.dict(os.environ, {'ROOMSERVICE_DRYRUN': 'true'}), \
                    mock.patch('netrc.netrc') as credentials, \
                    mock.patch('urllib.request.urlopen', side_effect=response), \
                    mock.patch('subprocess.run') as sync, redirect_stdout(io.StringIO()):
                credentials.return_value.authenticators.return_value = ('test-user', None, 'test-password')
                with self.assertRaises(SystemExit) as result:
                    runpy.run_path(str(TOOLS / 'roomservice.py'), run_name='__main__')
                self.assertIn(result.exception.code, (None, 0))
                sync.assert_not_called()
            self.assertFalse(Path('.repo/local_manifests').exists())
            branch_request = next(request for request in requests if '/branches' in request.full_url)
            self.assertEqual(branch_request.get_header('Authorization'),
                             'Basic ' + base64.b64encode(b'test-user:test-password').decode())
            os.chdir(previous)

    def test_failed_dependency_sync_stops_recursion(self):
        dependencies = '[{"target_path":"device/b","repository":"android_device_b","branch":"main"}]'
        with mock.patch.object(self.roomservice.os.path, 'exists', return_value=True), \
                mock.patch.object(self.roomservice.os.path, 'isdir', return_value=False), \
                mock.patch.object(self.roomservice, 'is_in_manifest', return_value=False), \
                mock.patch.object(self.roomservice, 'add_to_manifest'), \
                mock.patch('builtins.open', return_value=io.StringIO(dependencies)), \
                mock.patch.object(self.roomservice.subprocess, 'run',
                                  side_effect=subprocess.CalledProcessError(1, ['repo', 'sync'])), \
                redirect_stdout(io.StringIO()):
            with self.assertRaises(subprocess.CalledProcessError):
                self.roomservice.fetch_dependencies('device/a')


@unittest.skipUnless(os.environ.get('BUILD_TOOLS_BASH') or shutil.which('bash'), 'Bash required')
class EnvsetupTests(unittest.TestCase):
    def run_function(self, name, body):
        source = (ROOT / 'build/envsetup.sh').read_text()
        function = re.search(r'^function ' + name + r'\(\)\n\{.*?^\}', source, re.M | re.S).group()
        shell = os.environ.get('BUILD_TOOLS_BASH') or shutil.which('bash')
        return subprocess.run([shell, '-c', function + '\n' + body], capture_output=True, text=True)

    def test_mk_timer_preserves_argument_boundaries(self):
        result = self.run_function('mk_timer', '''
check_args() { [ "$#" -eq 2 ] && [ "$1" = 'a b' ] && [ "$2" = '*' ]; }
mk_timer check_args 'a b' '*'
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_omnom_stops_after_failed_build(self):
        result = self.run_function('omnom', '''
brunch() { return 5; }
eat() { echo SHOULD_NOT_INSTALL; }
omnom 'test device'
''')
        self.assertEqual(result.returncode, 5)
        self.assertNotIn('SHOULD_NOT_INSTALL', result.stdout)

    def test_infinity_remote_uses_configured_username(self):
        result = self.run_function('infinityremote', '''
git() {
  case "$*" in
    'config --get remote.github.projectname') echo vendor_infinity ;;
    'config --get review.review.infinity.org.username') echo alice ;;
    'remote add infinity '*) printf '%s\\n' "$*" ;;
  esac
}
infinityremote
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('ssh://alice@review.infinity.org:29418/vendor_infinity', result.stdout)

    def test_eat_does_not_wait_for_device_without_package(self):
        result = self.run_function('eat', '''
OUT=$(mktemp -d)
adb() { echo SHOULD_NOT_CALL_ADB; }
eat
status=$?
rmdir "$OUT"
exit "$status"
''')
        self.assertEqual(result.returncode, 1)
        self.assertNotIn('SHOULD_NOT_CALL_ADB', result.stdout)

    def test_eat_accepts_current_package_name_and_rejects_wrong_device(self):
        result = self.run_function('eat', '''
OUT=$(mktemp -d)
mkdir "$OUT/path with spaces"
OUT="$OUT/path with spaces"
touch "$OUT/Project_Infinity-X-2.9-device-VANILLA-UNOFFICIAL.zip"
INFINITY_BUILD=device
adb() {
  case "$*" in
    'shell getprop ro.infinity.device') echo other_device ;;
    'sideload '*) echo SHOULD_NOT_INSTALL ;;
  esac
}
eat
status=$?
rm "$OUT/Project_Infinity-X-2.9-device-VANILLA-UNOFFICIAL.zip"
rmdir "$OUT" "$(dirname "$OUT")"
exit "$status"
''')
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertIn('does not appear to be', result.stdout)
        self.assertNotIn('SHOULD_NOT_INSTALL', result.stdout)


if __name__ == '__main__':
    unittest.main()
