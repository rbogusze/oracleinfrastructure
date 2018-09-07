from locust import HttpLocust, TaskSet

def api_1(l):
    l.client.get("/api/copy/global/en")

def api_2(l):
    l.client.get("/api/countries/global/en")

def api_3(l):
    l.client.get("/api/destinations/global/en")

def api_4(l):
    l.client.get("/api/lh-id/login/url")

def api_5(l):
    l.client.get("/api/lh-id/registration/url")

def api_6(l):
    l.client.get("/api/me")


class UserBehavior(TaskSet):
    tasks = {api_1: 1, api_2: 1, api_3: 1, api_4: 1, api_5: 1, api_6: 1}

class WebsiteUser(HttpLocust):
    task_set = UserBehavior
    min_wait = 0
    max_wait = 0
