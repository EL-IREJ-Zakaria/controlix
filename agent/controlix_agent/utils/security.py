from __future__ import annotations

import ipaddress
import secrets

from flask import Request
from werkzeug.exceptions import Forbidden, Unauthorized


def ensure_lan_request(request: Request) -> None:
    forwarded_for = request.headers.get("X-Forwarded-For", "")
    remote_address = forwarded_for.split(",")[0].strip() if forwarded_for else request.remote_addr
    if not remote_address:
        raise Forbidden("Unable to determine the client IP address.")

    try:
        address = ipaddress.ip_address(remote_address)
    except ValueError as error:
        raise Forbidden("The client IP address is invalid.") from error

    if not (address.is_private or address.is_loopback):
        raise Forbidden("Controlix only accepts requests from the local network.")


def ensure_authorized(request: Request, expected_secret: str) -> None:
    payload = request.get_json(silent=True) or {}
    candidate = request.headers.get("X-Controlix-Key") or payload.get("secret_key")
    provided_secret = candidate.strip() if isinstance(candidate, str) else ""

    if not provided_secret or not secrets.compare_digest(provided_secret, expected_secret):
        raise Unauthorized("Invalid or missing shared secret key.")
