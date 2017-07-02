"""Base for client based experts."""
import logging
import socket
import sys

log = logging.getLogger(__name__)


class Expert(object):
  """Basic expert with no trading logic."""
  def __init__(self, ip_address, port):
    self.ip_address = ip_address
    self.port = port
    self.buffer_size = 1024
    self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

  def connect(self):
    """Try to connect to the server."""
    log.info("Connecting to %s", (self.ip_address, self.port))
    self.socket.connect((self.ip_address, self.port))

  def talk(self, msg):
    """Exchange message in a blocking manner."""
    self.socket.send(bytes(msg, "ascii"))
    return self.socket.recv(self.buffer_size) \
               .decode("ascii").rstrip(' \t\r\n\0')

  def close(self, ticket):
    """Close the given order ticket."""
    log.info("Closing order: %s", ticket)
    cmd = "C "+str(ticket)
    return bool(int(self.talk(cmd)))

  def buy(self):
    """Send a buy command to the server get order ticket."""
    log.info("Buying")
    return int(self.talk("B"))

  def sell(self):
    """Send a sell command to the server get order ticket."""
    log.info("Selling")
    return int(self.talk("S"))

  def run(self):
    """Start processing updates forever."""
    self.connect()
    log.info("Starting update loop.")
    while True:
      try:
        update = self.socket.recv(self.buffer_size) \
                     .decode("ascii").rstrip(' \t\r\n\0')
        self.ontick(update)
        sys.stdout.flush()
      except(KeyboardInterrupt, EOFError, SystemExit):
        break
    self.socket.close()

  def ontick(self, update):
    """Process update from server."""
    raise NotImplementedError("Tick on base Expert.")
