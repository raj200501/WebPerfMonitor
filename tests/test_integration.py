import unittest

from web_perf_monitor.integration import WebhookClient

from tests.helpers import WebhookHandler, available_port, start_server, stop_server


class IntegrationTests(unittest.TestCase):
    def test_webhook_delivery(self):
        port = available_port()
        server = start_server(WebhookHandler, port)

        client = WebhookClient(f"http://127.0.0.1:{port}/webhook")
        result = client.send("{}")

        self.assertTrue(result.success)
        self.assertEqual(result.status_code, 200)
        stop_server(server)


if __name__ == "__main__":
    unittest.main()
