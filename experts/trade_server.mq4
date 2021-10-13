//+------------------------------------------------------------------+
//|                                                 trade_server.mq4 |
//|                                                            nuric |
//|                                 https://github.com/nuric/mt4-tcp |
//+------------------------------------------------------------------+
#property copyright "nuric"
#property link      "https://github.com/nuric/mt4-tcp"
#property version   "1.00"
#property description "Select trade server that pushes bar data."
#property strict

#include <socket.mqh>
#include <trade.mqh>

input ushort server_port=7777;
input string server_ip="0.0.0.0";
int server_socket=INVALID_SOCKET;
fd_set sockets;
timeval timeout={0,100}; // 100 microseconds
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
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
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   sock_closefds(sockets);
   sock_cleanup();
  }
//+------------------------------------------------------------------+
//| Incoming request handler                                         |
//+------------------------------------------------------------------+
void handle(string request,int client_socket)
  {
//Check client connection close
   if(StringLen(request)==0)
     {
      fd_clear(client_socket,sockets);
      return;
     }
// What does the client want
   Print("Executing command: ",request);
   string cmds[];
   int argc=StringSplit(request,' ',cmds);
   if(argc<=0) return; // Nothing to process
   string r="U\n"; // Unknown command
   switch(StringGetChar(cmds[0],0))
     {
      case 'A':
         r="A "+(GetAvailableInstruments(StrToInteger(cmds[1]) ? true : false))+"\n";
         break;
      case 'T':
         r="T "+(GetLastTick(cmds[1]))+"\n";
         break;
      case 'C':
         r="C "+(CloseOrder(StrToInteger(cmds[1])) ? "1" : "0")+"\n";
         break;
      case 'B':
         r="B "+IntegerToString(Buy(cmds[1]))+"\n"; break;
      case 'S':
         r="S "+IntegerToString(Sell(cmds[1]))+"\n"; break;
      default:
         Print("Unknown command: ",request); break;
     }
   sock_send(client_socket,r); // Respond back to the client
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   fd_set readsockets=sockets;
// nfds parameter ignored, just passing 1
// https://msdn.microsoft.com/en-us/library/windows/desktop/ms740141(v=vs.85).aspx
   if(select(1,readsockets,NULL,NULL,timeout)==SOCKET_ERROR)
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
         handle(sock_receive(readsockets.fd_array[i]),readsockets.fd_array[i]);
     }
// Send bar updates
   if(Volume[0]>1) return;
   string bar_string=StringFormat("%u;%.5f;%.5f;%.5f;%.5f;%u\n", TimeSeconds(Time[1]), Open[1], High[1], Low[1], Close[1], Volume[1]);
// Skip first socket that is server_socket
   for(uint i=1;i<sockets.fd_count;i++)
      sock_send(sockets.fd_array[i],bar_string);
  }
//+------------------------------------------------------------------+
