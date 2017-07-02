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
   bool CloseOrder(int ticket);
   int Buy(double lots=0.01,double stoploss=0,double takeprofit=0);
   int SingleBuy(int ticket,double lots=0.01,double stoploss=0,double takeprofit=0);
   int Sell(double lots=0.01,double stoploss=0,double takeprofit=0);
   int SingleSell(int ticket,double lots=0.01,double stoploss=0,double takeprofit=0);
 #import
//+------------------------------------------------------------------+
