//+------------------------------------------------------------------+
//|                                                        trade.mq4 |
//|                                                            nuric |
//|                                 https://github.com/nuric/mt4-tcp |
//+------------------------------------------------------------------+
#property library
#property copyright "nuric"
#property link      "https://github.com/nuric/mt4-tcp"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Close given order ticket                                         |
//+------------------------------------------------------------------+
bool CloseOrder(int ticket) export
  {
   if(!IsTradeAllowed() || !OrderSelect(ticket,SELECT_BY_TICKET))
      return false;
   double price=OrderType()==OP_BUY ? Bid : Ask;
   return OrderClose(OrderTicket(),OrderLots(),price,3);
  }
//+------------------------------------------------------------------+
//| Place a buy order, return ticket                                 |
//+------------------------------------------------------------------+
int Buy(double lots=0.01,double stoploss=0,double takeprofit=0) export
  {
// Check context and place the order
   if(!IsTradeAllowed()) return -1;
   return OrderSend(Symbol(),OP_BUY,lots,Ask,3,stoploss,takeprofit);
  }
//+------------------------------------------------------------------+
//| Buy only if given ticket is not live, close ticket if needed     |
//+------------------------------------------------------------------+
int SingleBuy(int ticket,double lots=0.01,double stoploss=0,double takeprofit=0) export
  {
// Is the current ticket already a buy order?
   if(!IsTradeAllowed() || (OrderSelect(ticket,SELECT_BY_TICKET) && OrderCloseTime()==0 && OrderType()==OP_BUY))
      return -1; // The last order is still alive
// If it is a sell order then close it as we want to buy now
   if(OrderCloseTime()==0 && OrderType()==OP_SELL)
      CloseOrder(ticket);
   return Buy(lots, stoploss, takeprofit);
  }
//+------------------------------------------------------------------+
//| Place a sell order, return ticket                                |
//+------------------------------------------------------------------+
int Sell(double lots=0.01,double stoploss=0,double takeprofit=0) export
  {
   if(!IsTradeAllowed()) return -1;
   return OrderSend(Symbol(),OP_SELL,lots,Bid,3,stoploss,takeprofit);
  }
//+------------------------------------------------------------------+
//| Sell only if given ticket is not live, close ticket if needed    |
//+------------------------------------------------------------------+
int SingleSell(int ticket,double lots=0.01,double stoploss=0,double takeprofit=0) export
  {
   if(!IsTradeAllowed() || (OrderSelect(ticket,SELECT_BY_TICKET) && OrderCloseTime()==0 && OrderType()==OP_SELL))
      return -1;
   if(OrderCloseTime()==0 && OrderType()==OP_BUY)
      CloseOrder(ticket);
   return Sell(lots, stoploss, takeprofit);
  }
//+------------------------------------------------------------------+
