from django.test import SimpleTestCase
from django.urls import reverse


class ScaffoldRoutingTests(SimpleTestCase):
    def test_root_health_check_returns_project_status(self):
        response = self.client.get("/")

        self.assertEqual(response.status_code, 200)
        self.assertEqual(
            response.json(),
            {
                "name": "EasyYan API",
                "status": "ok",
            },
        )

    def test_api_root_lists_placeholder_app_routes(self):
        response = self.client.get(reverse("api-root"))

        self.assertEqual(response.status_code, 200)
        self.assertEqual(
            response.json(),
            {
                "users": "/api/users/",
                "resources": "/api/resources/",
                "subjects": "/api/subjects/",
                "questions": "/api/questions/",
                "practice": "/api/practice/",
                "papers": "/api/papers/",
                "study": "/api/study/",
                "analytics": "/api/analytics/",
            },
        )
