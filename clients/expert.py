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
    self.socketf = None

  def connect(self):
    """Try to connect to the server."""
    log.info("Connecting to %s", (self.ip_address, self.port))
    self.socket.connect((self.ip_address, self.port))
    self.socketf = self.socket.makefile()

  def talk(self, msg):
    """Exchange message in a blocking manner."""
    self.socket.send(bytes(msg, "ascii"))
    resp = self.socketf.readline().strip('\0\n')
    while not resp or resp[0] != msg[0]:
      log.debug("Waiting on correct answer for %s", msg)
      resp = self.socketf.readline().strip('\0\n')
    return resp

  def close(self, ticket):
    """Close the given order ticket."""
    log.info("Closing order: %s", ticket)
    cmd = "C "+str(ticket)
    return bool(int(self.talk(cmd).split()[1]))

  def buy(self):
    """Send a buy command to the server get order ticket."""
    log.info("Buying")
    return int(self.talk("B").split()[1])

  def sell(self):
    """Send a sell command to the server get order ticket."""
    log.info("Selling")
    return int(self.talk("S").split()[1])

  def run(self):
    """Start processing updates forever."""
    self.connect()
    log.info("Starting update loop.")
    for line in self.socketf:
      # Expecting <tick> update
      update = float(line.strip('\0\n'))
      self.ontick(update)
    self.socket.close()

  def ontick(self, update):
    """Process update from server."""
    raise NotImplementedError("Tick on base Expert.")
