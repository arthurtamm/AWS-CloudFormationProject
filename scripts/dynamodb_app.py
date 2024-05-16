import boto3
from jinja2 import Template
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import urlparse, parse_qs
import subprocess

TABLE_NAME = "MyApplicationData"

class RequestHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path.startswith('/create_user'):
            query_components = parse_qs(urlparse(self.path).query)
            user_name = query_components.get('user', [''])[0]
            if user_name:
                self.create_user(user_name)
            self.send_response(302)
            self.send_header('Location', '/')
            self.end_headers()
        elif self.path.startswith('/list_users'):
            self.send_response(200)
            self.send_header('Content-type', 'text/html; charset=utf-8')
            self.end_headers()
            users_html = self.list_users()
            self.wfile.write(users_html.encode())
        elif self.path.startswith('/start_stress'):
            self.start_stress()
            self.send_response(302)
            self.send_header('Location', '/')
            self.end_headers()
        elif self.path.startswith('/stop_stress'):
            self.stop_stress()
            self.send_response(302)
            self.send_header('Location', '/')
            self.end_headers()
        else:
            self.send_response(200)
            self.send_header('Content-type', 'text/html; charset=utf-8')
            self.end_headers()
            with open('./index.html', 'r') as f:
                self.wfile.write(f.read().encode())

    def create_user(self, user_name):
        dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
        table = dynamodb.Table(TABLE_NAME)
        table.put_item(Item={'id': user_name})

    def list_users(self):
        dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
        table = dynamodb.Table(TABLE_NAME)
        response = table.scan()
        users = response.get('Items', [])
        template = Template("""
            <html>
            <head>
                <title>Database Users</title>
                <link rel='stylesheet' type='text/css' href='style.css'>
                <meta charset='utf-8'>
            </head>
            <body>
                <div class='container'>
                    <h1>Database Users</h1>
                    <ul>
                    {% for user in users %}
                        <li>{{ user['id'] }}</li>
                    {% endfor %}
                    </ul>
                    <a class='btn' href='/'>Back</a>
                </div>
            </body>
            </html>
        """)
        return template.render(users=users)

    def start_stress(self):
        # Inicia o processo de stress
        subprocess.Popen(['stress', '--cpu', '4', '--timeout', '600'])

    def stop_stress(self):
        # Encerra todos os processos de stress
        subprocess.call(['pkill', 'stress'])

if __name__ == '__main__':
    server_address = ('', 5050)
    httpd = HTTPServer(server_address, RequestHandler)
    print('Starting server...')
    httpd.serve_forever()