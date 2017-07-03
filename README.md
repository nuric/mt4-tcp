# mt4-tcp
Winsock bindings for [MetaTrader 4](http://www.metatrader4.com/en) platform to create experts that act as servers. Clients can connect from any other program over the network.

## Usage
Example servers are contained within the **experts/** folder which run as servers when loaded into MT4. There are also examples for clients that connect to the server under the **clients/** folder. The experts can be modified to stream any data and the connection is bidirectional over TCP.

The best way is to create a expert server that streams the data you require and executes the commands your client will require. There is **no fixed protocol** because every client might need different data.

We recommend installing the git client on Windows for running the bash scripts. On Linux **wine** is required to run the MT4 terminal. You can mix platforms and run MT4 on Windows and clients elsewhere over the network.

The experts also run for backtesting but create a lot of networking. It is best to backtest locally so the network is not flooded.

## Development
This project is **highly experimental**.  It is aimed to be a microframework for conntecting in and out of MT4. The glue script **make.sh** is used to move files around between the repo and the MT4 expected folders. The library is written in [MQL4](https://docs.mql4.com/).

### Folder Structure
- **include/** contains the socket library functions.
- **experts/** contain different example servers built using the library.
- **clients/** contain example python scripts that connect to the servers.
- **config/** contains configuration for experts for backtesting

## FAQ
- **Why not use make?** The aim is to make the code run out of the box on multiple platforms which might not have make installed, in particular Windows.
- **Why doesn't make.sh backtest work when the MT4 is open?** MT4 only allows one running instance on single client terminal. Either use multi-terminal MT4 or duplicate your entire MT4 profile folder to have a second one. Note that you must check which profile make.sh picks up on, usually the first one.

### Version
0.1.0
