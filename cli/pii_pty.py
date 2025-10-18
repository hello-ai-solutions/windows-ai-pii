#!/usr/bin/env python3
import os, pty, sys, select, json, urllib.request

API = "https://kzve09lj7b.execute-api.ap-southeast-2.amazonaws.com/prod/detect-pii"

def sanitize(txt):
    try:
        r = urllib.request.Request(API, data=json.dumps({"text": txt}).encode(),
                                   headers={"Content-Type":"application/json"})
        return json.loads(urllib.request.urlopen(r, timeout=1.5).read().decode()).get("sanitizedText", txt)
    except Exception:
        return txt

def main():
    argv = [sanitize(a) for a in sys.argv[1:]]
    pid, fd = pty.fork()
    if pid == 0:
        os.execvp(argv[0], [argv[0]] + argv[1:])
    
    input_buffer = ""
    
    while True:
        r,_,_ = select.select([fd, sys.stdin], [], [])
        if fd in r:
            data = os.read(fd, 8192)
            if not data: break
            os.write(sys.stdout.fileno(), data)
        if sys.stdin in r:
            data = os.read(sys.stdin.fileno(), 8192)
            if not data: break
            
            try:
                s = data.decode(errors="ignore")
                input_buffer += s
                
                # Process complete lines
                while '\n' in input_buffer:
                    line, input_buffer = input_buffer.split('\n', 1)
                    if line.strip():
                        line = sanitize(line)
                    line += '\n'
                    os.write(fd, line.encode())
                
            except Exception:
                os.write(fd, data)

if __name__ == "__main__":
    main()
