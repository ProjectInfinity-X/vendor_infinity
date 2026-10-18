#!/usr/bin/env python3

import base64
import sys

def main():
    with open(sys.argv[1], 'rb') as cert_file:
        certificate = cert_file.read().split(b"-----BEGIN CERTIFICATE-----", 1)[1]
    certificate = certificate.split(b"-----END CERTIFICATE-----", 1)[0]
    print(base64.b64decode(certificate).hex())


if __name__ == "__main__":
    main()
