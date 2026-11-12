import http.server
import json
import os
import pathlib
import socketserver

state_path=pathlib.Path(os.environ['BOOTSTRAP_TEST_STATE'])
port=int(os.environ['BOOTSTRAP_TEST_PORT'])


class Handler(http.server.BaseHTTPRequestHandler):
    def log_message(self, *args):
        pass

    def respond(self,status,body):
        encoded=json.dumps(body).encode()
        self.send_response(status)
        self.send_header('Content-Type','application/json')
        self.send_header('Content-Length',str(len(encoded)))
        self.end_headers()
        self.wfile.write(encoded)

    def state(self):
        return json.loads(state_path.read_text(encoding='utf-8-sig'))

    def authorized(self,state):
        return self.headers.get('Authorization')=='Bearer '+state.get('token','')

    def do_GET(self):
        state=self.state()
        if not self.authorized(state):
            self.respond(401,{'error':'unauthorized'})
        elif self.path=='/readyz':
            ready=state.get('running',False)
            self.respond(200 if ready else 503,{'ready':ready,'package_version':state.get('version')})
        else:
            self.respond(404,{'error':'unknown route'})

    def do_POST(self):
        state=self.state()
        if not self.authorized(state):
            self.respond(401,{'error':'unauthorized'})
            return
        length=int(self.headers.get('Content-Length','0'))
        if length>65536:
            self.respond(413,{'error':'fixture limit'})
            return
        body=self.rfile.read(length)
        if self.path=='/v1/shutdown':
            self.respond(200,{'shutting_down':True})
        elif self.path=='/v1/process':
            payload=json.loads(body)
            if payload.get('reconstruction_config',{}).get('output_policy')!='verified_typed':
                self.respond(400,{'error':'verified policy was not requested'})
                return
            failed=state.get('version') in state.get('fail_quality',[])
            self.respond(200,{'complete':True,'source':'local value: number = 42\nreturn value\n','validation':{'required_passed':not failed,'syntax':'passed','compilation':'passed','strict_analysis':'passed','meaningful_typing':{'passed':not failed}}})
        else:
            self.respond(404,{'error':'unknown route'})


class Server(socketserver.ThreadingMixIn,http.server.HTTPServer):
    daemon_threads=True


Server(('127.0.0.1',port),Handler).serve_forever()
