"""Example trade expert."""
from collections import deque
from expert import Expert


class MACDExpert(Expert):
  """An example simple trade expert."""
  def __init__(self, ip_address, port, short_period=120, long_period=260):
    super().__init__(ip_address, port)
    self.past_short= deque(maxlen=short_period)
    self.past_long= deque(maxlen=long_period)
    self.ticket = -1
    self.order_type = None

  def ontick(self, update):
    """MACD style moving average logic."""
    self.past_short.appendleft(update)
    self.past_long.appendleft(update)
    # Calculate averages
    short_avg = sum(self.past_short)/len(self.past_short)
    long_avg = sum(self.past_long)/len(self.past_long)
    # Basic logic
    if short_avg > long_avg:
      # We want to buy
      if self.ticket > 0 and self.order_type == 'S' and self.close(self.ticket):
        self.ticket = -1
      if self.ticket < 0:
        self.ticket = self.buy()
        self.order_type = 'B'
    elif short_avg < long_avg:
      # We want to sell
      if self.ticket > 0 and self.order_type == 'B' and self.close(self.ticket):
        self.ticket = -1
      if self.ticket < 0:
        self.ticket = self.sell()
        self.order_type = 'S'

if __name__ == '__main__':
  import logging
  # Enable debug
  logging.basicConfig(level=logging.DEBUG)
  expert = MACDExpert("127.0.0.1", 7777)
  expert.run()
