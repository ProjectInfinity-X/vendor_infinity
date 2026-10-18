#!/bin/bash
exec python3 "$(dirname "$0")/generate_ota_info.py" "$@"
