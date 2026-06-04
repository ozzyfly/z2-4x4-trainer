#!/usr/bin/env python3
"""Mint an App Store Connect API JWT (ES256) from a .p8 key.

Reads ASC_KEY_ID, ASC_ISSUER_ID, ASC_KEY_PATH from the environment and prints the token.
No secrets are stored; the .p8 stays wherever ASC_KEY_PATH points (outside the repo).
"""
import base64
import json
import os
import time

from cryptography.hazmat.primitives.asymmetric.utils import decode_dss_signature
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import ec


def b64url(data: bytes) -> str:
    return base64.urlsafe_b64encode(data).rstrip(b"=").decode()


def main() -> None:
    key_id = os.environ["ASC_KEY_ID"]
    issuer = os.environ["ASC_ISSUER_ID"]
    key_path = os.path.expanduser(os.environ["ASC_KEY_PATH"])

    with open(key_path, "rb") as fh:
        key = serialization.load_pem_private_key(fh.read(), password=None)

    now = int(time.time())
    header = {"alg": "ES256", "kid": key_id, "typ": "JWT"}
    payload = {"iss": issuer, "iat": now, "exp": now + 60 * 18,
               "aud": "appstoreconnect-v1"}

    signing_input = (b64url(json.dumps(header, separators=(",", ":")).encode())
                     + "." + b64url(json.dumps(payload, separators=(",", ":")).encode()))

    der_sig = key.sign(signing_input.encode(), ec.ECDSA(hashes.SHA256()))
    r, s = decode_dss_signature(der_sig)
    raw_sig = r.to_bytes(32, "big") + s.to_bytes(32, "big")

    print(signing_input + "." + b64url(raw_sig))


if __name__ == "__main__":
    main()
