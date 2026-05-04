import unittest

from agent.controlix_agent import create_app
from werkzeug.exceptions import TooManyRequests


class SecurityTestCase(unittest.TestCase):
    def setUp(self) -> None:
        self.app = create_app()
        self.client = self.app.test_client()
        self.headers = {"X-Controlix-Key": self.app.config["SETTINGS"].secret_key}

    def test_allows_cgnat_shared_space(self) -> None:
        response = self.client.get(
            "/health",
            headers=self.headers,
            environ_base={"REMOTE_ADDR": "100.64.0.1"},
        )
        self.assertEqual(response.status_code, 200)

    def test_blocks_global_addresses(self) -> None:
        response = self.client.get(
            "/health",
            headers=self.headers,
            environ_base={"REMOTE_ADDR": "8.8.8.8"},
        )
        self.assertEqual(response.status_code, 403)

    def test_parses_forwarded_for_with_port(self) -> None:
        response = self.client.get(
            "/health",
            headers={**self.headers, "X-Forwarded-For": "192.168.1.10:51234"},
        )
        self.assertEqual(response.status_code, 200)

    def test_parses_bracketed_ipv6_forwarded_for(self) -> None:
        response = self.client.get(
            "/health",
            headers={**self.headers, "X-Forwarded-For": "[fd00::1]:1234"},
        )
        self.assertEqual(response.status_code, 200)

    def test_propagates_retry_after_header(self) -> None:
        @self.app.get("/_test_rate_limit")
        def _rate_limit():
            raise TooManyRequests("Rate limited.", retry_after=7)

        response = self.client.get(
            "/_test_rate_limit",
            headers=self.headers,
            environ_base={"REMOTE_ADDR": "127.0.0.1"},
        )
        self.assertEqual(response.status_code, 429)
        self.assertEqual(response.headers.get("Retry-After"), "7")


if __name__ == "__main__":
    unittest.main()
