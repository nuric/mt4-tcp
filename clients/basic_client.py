"""Simple TCP client for test server."""
import socket
import sys

TCP_IP = "127.0.0.1"
TCP_PORT = 7777
BUFFER_SIZE = 1024

# Connect to the test server
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((TCP_IP, TCP_PORT))

# Get 20 ticks and quit
for i in range(20):
  data = s.recv(BUFFER_SIZE).decode("ascii")
  s.send("OK".encode("ascii"))
  print("Got:", data)
  sys.stdout.flush()

# Get final data and gracefully close connection
print("Got:", s.recv(BUFFER_SIZE).decode("ascii"))
s.close()
