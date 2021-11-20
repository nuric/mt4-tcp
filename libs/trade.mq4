//+------------------------------------------------------------------+
//|                                                        trade.mq4 |
//|                                                            nuric |
//|                                 https://github.com/nuric/mt4-tcp |
//+------------------------------------------------------------------+
//+ Change History                                                   +
//+ Version   Description                                            +
//+ -------   -----------                                            +
//+ 1.00      Initial version                                        +
//+ 1.01      Added symbol as a parameter                            +
//+           Added new methods: GetAvailableInstruments             +
//+           and GetLastTick                                        +
//+ 1.20       Added symbol parameter for Buy and Sell methods       +
//+ 1.21       Implemented GetAvailableInstruments                   +
//+ 1.22       Add GetLastTick                                       +
//+ 1.23       Add SendTrade                                         +
//+                                                                  +
//+                                                                  +
//+------------------------------------------------------------------+
#property library
#property copyright "nuric"
#property link      "https://github.com/nuric/mt4-tcp"
#property version   "1.23"
#property strict
#include <JAson.mqh>

//+------------------------------------------------------------------+
//+ Send Trade                                                       +
//+------------------------------------------------------------------+
int SendTrade(string symbol,int type,double lots,double price,double stoploss,double takeprofit,string comment) export
{
   if(!IsTradeAllowed()) return -1;
   return OrderSend(symbol,type,lots,price,0,stoploss,takeprofit,comment);
}

//+------------------------------------------------------------------+
//| Get Last Tick                                                    |
//+------------------------------------------------------------------+
string GetLastTick(string symbol) export
{
      MqlTick last_tick; 
      
      CJAVal msg;
      
      //--- 
      if(SymbolInfoTick(symbol,last_tick)) 
      { 
         msg["symbol"] = symbol;
         msg["time"] =  TimeToString(last_tick.time);
         msg["bid"] = DoubleToString(last_tick.bid);
         msg["ask"] = DoubleToString(last_tick.ask);
         msg["volume"] = DoubleToString(last_tick.volume);
         return msg.Serialize();
      } 
      
      msg["error"] = GetLastError();
      return msg.Serialize();
}

//+------------------------------------------------------------------+
//| Get Available Instruments                                        |
//+------------------------------------------------------------------+
string GetAvailableInstruments(bool inMarketWatch=true) export
{
   int count = SymbolsTotal(inMarketWatch);

   CJAVal msg;
      
   for (int i=0; i < count; i++) {
      msg[i] = SymbolName(i,inMarketWatch);
   }

   return msg.Serialize();
}
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
int Buy(string symbol, double lots=0.01,double stoploss=0,double takeprofit=0) export
  {
// Check context and place the order
   if(!IsTradeAllowed()) return -1;
   return OrderSend(symbol,OP_BUY,lots,Ask,3,stoploss,takeprofit);
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
   return Buy(OrderSymbol(),lots, stoploss, takeprofit);
  }
//+------------------------------------------------------------------+
//| Place a sell order, return ticket                                |
//+------------------------------------------------------------------+
int Sell(string symbol,double lots=0.01,double stoploss=0,double takeprofit=0) export
  {
   if(!IsTradeAllowed()) return -1;
   return OrderSend(symbol,OP_SELL,lots,Bid,3,stoploss,takeprofit);
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
   return Sell(OrderSymbol(),lots, stoploss, takeprofit);
  }
//+------------------------------------------------------------------+
