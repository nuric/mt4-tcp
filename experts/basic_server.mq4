//+------------------------------------------------------------------+
//|                                                 basic_server.mq4 |
//|                                                            nuric |
//|                                 https://github.com/nuric/mt4-tcp |
//+------------------------------------------------------------------+
#property copyright   "nuric"
#property link        "https://github.com/nuric/mt4-tcp"
#property version     "1.00"
#property description "Single client server that pushes tick data."
#property strict

#include <socket.mqh>

input ushort server_port=7777;
input string server_ip="0.0.0.0";
int server_socket=INVALID_SOCKET,msg_socket=INVALID_SOCKET;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   if(!IsDllsAllowed())
     {
      Print("Require DLL imports.");
      return(INIT_FAILED);
     }
   server_socket=socket_open(server_ip,server_port);
   if(server_socket==INVALID_SOCKET)
      return(INIT_FAILED);
   msg_socket=sock_accept(server_socket);
   if(msg_socket==INVALID_SOCKET)
      return(INIT_FAILED);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   sock_close(msg_socket);
   sock_close(server_socket);
   sock_cleanup();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   string bid_string=DoubleToString(Bid, Digits);
   Print("Sending: ",Bid);
   sock_send(msg_socket,bid_string);
   // Blocking receive
   string resp=sock_receive(msg_socket);
   if(StringLen(resp)==0 || IsStopped()) 
     {
      Print("Client closed connection.");
      ExpertRemove();
      return; // return as export remove doesn't immediately terminate
     }
   Print("Received: ",resp);
  }
//+------------------------------------------------------------------+
