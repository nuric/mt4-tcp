//+------------------------------------------------------------------+
//|                                                select_server.mq4 |
//|                                                            nuric |
//|                                 https://github.com/nuric/mt4-tcp |
//+------------------------------------------------------------------+
#property copyright "nuric"
#property link      "https://github.com/nuric/mt4-tcp"
#property version   "1.00"
#property description "Multi client select server that pushes tick data."
#property strict

#include <socket.mqh>

input ushort server_port=7777;
input string server_ip="0.0.0.0";
int server_socket=INVALID_SOCKET;
fd_set sockets;
timeval timeout={2,0}; // 2 seconds
int maxsocket=0;
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
// Create the server socket
   server_socket=sock_open(server_ip,server_port);
   if(server_socket==INVALID_SOCKET)
      return(INIT_FAILED);
   fd_zero(sockets);
   fd_add(server_socket,sockets);
   maxsocket=server_socket;
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
//sock_closefds(sockets);
   sock_close(server_socket);
   sock_cleanup();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   fd_set readsockets=sockets;
   if(select(maxsocket+1,readsockets,NULL,NULL,timeout)==SOCKET_ERROR)
     {
      Print("Server: select error ",WSAGetLastError());
      return;
     }
// Process incoming requests
   for(uint i=0;i<readsockets.fd_count;i++)
     {
      if(readsockets.fd_array[i]==server_socket)
        {
         // Accept new connection
         int msg_socket= sock_accept(server_socket);
         if(msg_socket!=INVALID_SOCKET)
            fd_add(msg_socket,sockets);
        }
      else
        {
         // Guaranteed receive
         string resp=sock_receive(readsockets.fd_array[i]);
         if(StringLen(resp)==0)
           {
            fd_clearat(i,sockets);
            Print("Client closed connection.");
           }
         Print("Received: ",resp);
        }
     }
// Send tick updates
   string bid_string=DoubleToString(Bid,Digits);
   Print("Sending: ",Bid);

   for(uint i=1;i<sockets.fd_count;i++)
     {
      sock_send(sockets.fd_array[i],bid_string);
     }
  }
//+------------------------------------------------------------------+
