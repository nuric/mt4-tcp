"""Simple TCP client for test server to include symbol."""
import socket
import sys

TCP_IP = "127.0.0.1"
TCP_PORT = 7779
BUFFER_SIZE = 2048

# Connect to the test server
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((TCP_IP, TCP_PORT))

# Get all supported symbols (aka instruments)
data = s.recv(BUFFER_SIZE).decode("ascii")
s.send("A 1".encode("ascii"))
print("Got:", data)
sys.stdout.flush()

# Get final data and gracefully close connection
print("Got:", s.recv(BUFFER_SIZE).decode("ascii"))
s.close()
