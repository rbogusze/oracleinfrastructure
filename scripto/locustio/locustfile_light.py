from locust import HttpLocust, TaskSet

def ok(l):
    l.client.get("/ok")

def error(l):
    l.client.get("/error")

def api(l):
    l.client.get("/api")

def apis(l):
    l.client.get("/api?API_SECRET=alamakota")

def heavy(l):
    l.client.get("/api/heavy")


class UserBehavior(TaskSet):
    tasks = {ok: 3, error: 1, api: 1, apis: 1}

class WebsiteUser(HttpLocust):
    task_set = UserBehavior
    min_wait = 0
    max_wait = 0
