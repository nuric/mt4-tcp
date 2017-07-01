//+------------------------------------------------------------------+
//| Wrapper functions for Winsock                                    |
//+------------------------------------------------------------------+
#include <winsock.mqh>

#define RECV_BUFFER 200
bool socket_isinitialised=False;
//+------------------------------------------------------------------+
//| Initialise winsock by calling WSAStartup                         |
//+------------------------------------------------------------------+
int sock_startup()
  {
// Initialize library
   if(socket_isinitialised)
      return 0;
   WSAData wsaData;
// https://msdn.microsoft.com/en-us/library/windows/desktop/ms742213(v=vs.85).aspx
   int retval=WSAStartup(0x202,wsaData);
   if(retval!=0)
     {
      Print("Socket: WSAStartup() failed with error ",retval);
      return retval;
     }
   Print("Socket: WSAStartup() is OK.");
   socket_isinitialised=True;
   return retval;
  }
//+------------------------------------------------------------------+
//| Create and bind a socket                                         |
//+------------------------------------------------------------------+
int sock_open(string ip_address,ushort port,int socket_type=SOCK_STREAM)
  {
// Initialise library
   if(sock_startup())
      return INVALID_SOCKET;

// Create socket
   int listen_socket=INVALID_SOCKET;
   int protocol = socket_type==SOCK_STREAM ? IPPROTO_TCP : IPPROTO_UDP;
   listen_socket=socket(AF_INET,socket_type,protocol);

   if(listen_socket==INVALID_SOCKET)
     {
      Print("Server: socket() failed with error ",WSAGetLastError());
      return(INVALID_SOCKET);
     }
   Print("Server: socket() is OK.");

// Setup Bind
   sockaddr_in local;
   local.sin_family=AF_INET;
   local.sin_port=htons(port);
   if(StringLen(ip_address)==0)
      local.sin_addr=INADDR_ANY;
   else
     {
      uchar ipaddr[16];
      StringToCharArray(ip_address,ipaddr);
      local.sin_addr=inet_addr(ipaddr);
     }
// Bind
   if(bind(listen_socket,local,sizeof(sockaddr_in))==SOCKET_ERROR)
     {
      Print("Server: bind() failed with error ",WSAGetLastError());
      closesocket(listen_socket);
      return(INVALID_SOCKET);
     }
   Print("Server: bind() is OK");

   if(socket_type==SOCK_STREAM && listen(listen_socket,5)==SOCKET_ERROR)
     {
      Print("Server: listen() failed with error ",WSAGetLastError());
      closesocket(listen_socket);
      return(INVALID_SOCKET);
     }
   Print("Server: listening and waiting connection on port ",port);
   return(listen_socket);
  }
//+------------------------------------------------------------------+
//| Connect to remote server                                         |
//+------------------------------------------------------------------+
int sock_connect(string ip_address,ushort port,int socket_type=SOCK_STREAM)
  {
// Initialise library
   if(sock_startup())
      return INVALID_SOCKET;

// Create socket
   int client_socket=INVALID_SOCKET;
   int protocol = socket_type==SOCK_STREAM ? IPPROTO_TCP : IPPROTO_UDP;
   client_socket=socket(AF_INET,socket_type,protocol);

   if(client_socket==INVALID_SOCKET)
     {
      Print("Client: socket() failed with error ",WSAGetLastError());
      return(INVALID_SOCKET);
     }
   Print("Client: socket() is OK.");
// Setup remote address
   sockaddr_in remote;
   remote.sin_family=AF_INET;
   remote.sin_port=htons(port);
   uchar ipaddr[16];
   StringToCharArray(ip_address,ipaddr);
   remote.sin_addr=inet_addr(ipaddr);
// Connect
   if(connect(client_socket,remote,sizeof(sockaddr_in))==SOCKET_ERROR)
     {
      Print("Client: connect() failed with error ",WSAGetLastError());
      closesocket(client_socket);
      return(INVALID_SOCKET);
     }
   Print("Client: connected to ",ip_address);
   return client_socket;
  }
//+------------------------------------------------------------------+
//| Accept incoming client connection                                |
//+------------------------------------------------------------------+
int sock_accept(int listen_socket)
  {
   int msgsock;
   int fromlen[1]={ sizeof(sockaddr_in) };
   sockaddr_in from;
   msgsock=accept(listen_socket,from,fromlen);
   if(msgsock==INVALID_SOCKET)
     {
      Print("Server: accept() error ",WSAGetLastError());
      WSACleanup();
      return(INVALID_SOCKET);
     }
   Print("Server: accepted connection from ",inet_ntoa(from.sin_addr),", port ",htons(from.sin_port));
   return(msgsock);
  }
//+------------------------------------------------------------------+
//| Receive data from tcp socket checking for close                  |
//+------------------------------------------------------------------+
string sock_receive(int msgsock)
  {
   uchar Buffer[RECV_BUFFER];
   int retval=recv(msgsock,Buffer,ArraySize(Buffer),0);
   Print("Received bytes: ",retval);
   if(retval==SOCKET_ERROR)
     {
      Print("recv() failed: error ",WSAGetLastError());
      closesocket(msgsock);
      return("");
     }
   if(retval==0)
     {
      Print("Server: Client closed connection.\n");
      closesocket(msgsock);
      return("");
     }
   string item=CharArrayToString(Buffer,0,retval);
   Print("Server: recieved -- ",item);
   return(item);
  }
//+------------------------------------------------------------------+
//| Send data on tcp socket                                          |
//+------------------------------------------------------------------+
int sock_send(int msgsock,string msg)
  {
   uchar SendBuffer[];
   ArrayResize(SendBuffer,StringLen(msg));
   StringToCharArray(msg,SendBuffer);
   int ret= send(msgsock,SendBuffer,ArraySize(SendBuffer),0);
   if(ret == SOCKET_ERROR)
      Print("Server: send() failed: error ",WSAGetLastError());
   Print("Server: send() success: ",msg);
   return(ret);
  }
//+------------------------------------------------------------------+
//| Close a given socket                                             |
//+------------------------------------------------------------------+
int sock_close(int socket)
  {
   int r=closesocket(socket);
   if(r)
      Print("Server: cannot close ",socket," socket ",WSAGetLastError());
   return r;
  }
//+------------------------------------------------------------------+
//| Close all sockets in given fd_set                                |
//+------------------------------------------------------------------+
int sock_closefds(fd_set &set)
  {
   int r=0;
   for(uint i=0;i<set.fd_count;i++)
     {
      r|=sock_close(set.fd_array[i]);
     }
   return r;
  }
//+------------------------------------------------------------------+
//| Cleanup the winsock library                                      |
//+------------------------------------------------------------------+
void sock_cleanup()
  {
   if(!socket_isinitialised)
      WSACleanup();
  }
//+------------------------------------------------------------------+
