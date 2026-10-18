#!/usr/bin/env python3
"""Generate Updater metadata for an Infinity OTA package."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import tempfile
from urllib.parse import quote


def generate_metadata(package, build_prop):
    parts = package.name.split('-')
    if len(parts) < 3 or not parts[2]:
        raise ValueError("Cannot determine version from package filename")

    properties = {}
    for line in build_prop.read_text().splitlines():
        key, separator, value = line.partition('=')
        if separator:
            properties[key.strip()] = value.strip()
    timestamp = int(properties['ro.build.date.utc'])
    if timestamp < 0:
        raise ValueError("Build timestamp must be nonnegative")

    product = os.environ.get('TARGET_PRODUCT', '')
    if product.startswith('infinity_'):
        product = product[len('infinity_'):]
    device = properties.get('ro.infinity.device') or product
    if not device:
        raise ValueError("Cannot determine device from build.prop or TARGET_PRODUCT")
    android_version = properties.get('ro.infinity.android.version', '15')
    variant = 'vanilla' if 'VANILLA' in parts else 'gapps'
    checksum = hashlib.md5()
    with package.open('rb') as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b''):
            checksum.update(chunk)

    return {'response': [{
        'filename': package.name,
        'download': 'https://sourceforge.net/projects/infinity-x/files/{}/{}/{}/{}'.format(
            quote(device, safe=''), quote(android_version, safe=''), variant, quote(package.name, safe='')),
        'timestamp': timestamp,
        'md5': checksum.hexdigest(),
        'size': package.stat().st_size,
        'version': parts[2],
    }]}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('package', type=Path)
    parser.add_argument('build_prop', type=Path, nargs='?')
    args = parser.parse_args()
    # The build rule supplies PRODUCT_OUT explicitly; keep direct invocation useful.
    build_prop = args.build_prop or args.package.parent / 'system/build.prop'
    try:
        metadata = generate_metadata(args.package, build_prop)
    except (OSError, ValueError, KeyError) as error:
        parser.exit(1, 'Cannot generate OTA metadata: {}\n'.format(error))

    destination = Path(str(args.package) + '.json')
    temporary_path = None
    try:
        with tempfile.NamedTemporaryFile(mode='w', encoding='utf-8', dir=destination.parent,
                                         prefix=destination.name + '.', delete=False) as output:
            temporary_path = output.name
            json.dump(metadata, output, indent=2)
            output.write('\n')
        os.replace(temporary_path, destination)
    finally:
        if temporary_path and os.path.exists(temporary_path):
            os.unlink(temporary_path)


if __name__ == '__main__':
    main()
