//+------------------------------------------------------------------+
//|                                                        trade.mqh |
//|                                                            nuric |
//|                                 https://github.com/nuric/mt4-tcp |
//+------------------------------------------------------------------+
#property copyright "nuric"
#property link      "https://github.com/nuric/mt4-tcp"
#property strict
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| EX4 imports                                                      |
//+------------------------------------------------------------------+
 #import "trade.ex4"
   string GetLastTick(string symbol);
   string GetAvailableInstruments(bool inMarketWatch);
   bool CloseOrder(int ticket);
   int Buy(string symbol,double lots=0.01,double stoploss=0,double takeprofit=0);
   int SingleBuy(int ticket,double lots=0.01,double stoploss=0,double takeprofit=0);
   int Sell(string symbol,double lots=0.01,double stoploss=0,double takeprofit=0);
   int SingleSell(int ticket,double lots=0.01,double stoploss=0,double takeprofit=0);
 #import
//+------------------------------------------------------------------+
