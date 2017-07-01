//+------------------------------------------------------------------+
//| Winsock bindings for MQL4                                        |
//+------------------------------------------------------------------+
// Addresses
#define INADDR_ANY       0x00000000
#define INADDR_LOOPBACK  0x7f000001
#define INADDR_BROADCAST 0xffffffff
#define INADDR_NONE      0xffffffff

// Socket fucntions errors
#define INVALID_SOCKET 0
#define SOCKET_ERROR   -1

// Adress Families
#define AF_UNSPEC      0
#define AF_INET        2

// Types
#define SOCK_STREAM    1
#define SOCK_DGRAM     2

// Protocols
#define IPPROTO_TCP    6
#define IPPROTO_UDP    17

#define WSADESCRIPTION_LEN  256
#define WSASYS_STATUS_LEN   128
//+------------------------------------------------------------------+
//| https://msdn.microsoft.com/en-us/library/windows/desktop/ms740496(v=vs.85).aspx
//+------------------------------------------------------------------+
struct WSAData
  {
   ushort            wVersion;
   ushort            wHighVersion;
   char              szDescription[WSADESCRIPTION_LEN+1];
   char              szSystemStatus[WSASYS_STATUS_LEN+1];
   ushort            iMaxSockets;
   ushort            iMaxUdpDg;
   int               lpVendorInfo;
  };
//+------------------------------------------------------------------+
//| https://msdn.microsoft.com/en-us/library/windows/desktop/ms740496(v=vs.85).aspx
//+------------------------------------------------------------------+
struct sockaddr
  {
   ushort            sa_family;
   char              sa_data[14];
  };
//+------------------------------------------------------------------+
//| https://msdn.microsoft.com/en-us/library/windows/desktop/ms738571(v=vs.85).aspx
//+------------------------------------------------------------------+
struct in_addr
  {
   uchar             s_b[4];
  };
//+------------------------------------------------------------------+
//| https://msdn.microsoft.com/en-us/library/windows/desktop/ms740496(v=vs.85).aspx
//+------------------------------------------------------------------+
struct sockaddr_in
  {
   short             sin_family;
   ushort            sin_port;
   uint              sin_addr;
   char              sin_zero[8];
  };
//+------------------------------------------------------------------+
//| File Descriptor Sets                                             |
//+------------------------------------------------------------------+
#define FD_SETSIZE 16
//+------------------------------------------------------------------+
//| https://msdn.microsoft.com/en-us/library/windows/desktop/ms737873(v=vs.85).aspx
//+------------------------------------------------------------------+
struct fd_set
  {
   uint              fd_count;
   int               fd_array[FD_SETSIZE];
  };
//+------------------------------------------------------------------+
//| From fd_set remove item                                          |
//+------------------------------------------------------------------+
void fd_clear(int item,fd_set &set)
  {
// Linear search and remove by shift
   for(uint i=0;i<set.fd_count;i++)
     {
      if(set.fd_array[i]==item)
        {
         // Shift elements
         while(i<set.fd_count-1)
           {
            set.fd_array[i]=set.fd_array[i+1];
            i++;
           }
         set.fd_count--;
        }
     }
  }
//+------------------------------------------------------------------+
//| From fd_set remove item at given index                           |
//+------------------------------------------------------------------+
void fd_clearat(uint index,fd_set &set)
  {
   if(index>=set.fd_count) return;
// Shift elements
   while(index<set.fd_count-1)
     {
      set.fd_array[index]=set.fd_array[index+1];
      index++;
     }
   set.fd_count--;
  }
//+------------------------------------------------------------------+
//| Check if item is in fd_set                                       |
//+------------------------------------------------------------------+
bool fd_isset(int item,fd_set &set)
  {
// Linear search with return on first hit
   for(uint i=0;i<set.fd_count;i++)
      if(set.fd_array[i]==item) return true;
   return false;
  }
//+------------------------------------------------------------------+
//| Add item to fd_set, return false on success true on failure      |
//+------------------------------------------------------------------+
bool fd_add(int item,fd_set &set)
  {
// Return true on failure following winsock conventions
   if(fd_isset(item, set)) return false;
   if(set.fd_count>=FD_SETSIZE) return true;
   set.fd_array[set.fd_count]=item;
   set.fd_count++;
   return false;
  }
//+------------------------------------------------------------------+
//| Clear file descriptor set                                        |
//+------------------------------------------------------------------+
void fd_zero(fd_set &set)
  {
   set.fd_count=0;
  }
//+------------------------------------------------------------------+
//| https://msdn.microsoft.com/en-us/library/windows/desktop/ms740560(v=vs.85).aspx
//+------------------------------------------------------------------+
struct timeval
  {
   long              tv_sec;
   long              tv_usec;
  };
//+------------------------------------------------------------------+
//| Convert IPv4 address into dotted string notation                 |
//+------------------------------------------------------------------+
string inet_ntoa(int addr)
  {
   string buff[4];
   buff[0] = IntegerToString(addr & 0xFF);
   buff[1] = IntegerToString((addr>>8) & 0xFF);
   buff[2] = IntegerToString((addr>>16) & 0xFF);
   buff[3] = IntegerToString((addr>>24) & 0xFF);
   return buff[0] + "." + buff[1] + "." + buff[2] + "." + buff[3];
  }
//+------------------------------------------------------------------+
//| https://msdn.microsoft.com/en-us/library/windows/desktop/ms741394(v=vs.85).aspx
//+------------------------------------------------------------------+
#import "Ws2_32.dll"
int WSAStartup(int cmd,WSAData &wsadata);
int WSACleanup();
int WSAGetLastError();
int socket(int af,int type,int protocol);
int bind(int socket,sockaddr_in &address,int address_len);
int listen(int socket,int backlog);
int select(int nfds,fd_set &readfds,int writefds,int exceptfds,timeval &timeout);
int connect(int socket,sockaddr_in &address,int address_len);
int accept(int socket,sockaddr_in &address,int &address_len[]);
int send(int socket,uchar &buffer[],int length,int flags);
int sendto(int socket,uchar &message[],int length,int flags,sockaddr_in &dest_addr,int dest_len);
int recv(int socket,uchar &buffer[],int length,int flags);
int recvfrom(int socket,uchar &buffer[],int length,int flags,sockaddr_in &address,int &address_len[]);
int closesocket(int socket);
int gethostbyname(uchar &name[]);
int inet_addr(uchar &addr[]);
//string inet_ntoa(int addr); // Cannot deal with returning pointers to arrays in mql4
ulong htonl(ulong hostlong);
ushort htons(ushort hostshort);
#import
//+------------------------------------------------------------------+
