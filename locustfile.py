from locust import HttpUser, task, between, TaskSet

class UserBehavior(TaskSet):
    @task(2)
    def view_main_page(self):
        # Acessar a página principal
        self.client.get("/")

    @task(3)
    def create_user(self):
        # Criar um usuário fictício
        self.client.get("/create_user", params={"user": "testuser"})

    @task(1)
    def list_users(self):
        # Listar usuários
        self.client.get("/list_users")

class WebsiteUser(HttpUser):
    tasks = [UserBehavior]
    wait_time = between(1, 10)
    host = "http://infra--myloa-njuue7br5suz-1307007364.us-east-1.elb.amazonaws.com/"
