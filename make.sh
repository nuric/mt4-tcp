#!/bin/bash

# Determine platform to find the directories
PLATFORM=`uname`
if [[ $PLATFORM == *"MINGW64"* ]]
then
  # TDIR - DDIR: Terminal - Data directories
  TDIR=`find /c/Program\ Files*/FxPro*/ -type d -name "FxPro*" | head -n 1`
  TDIR=${TDIR%/} # Remove trailing slash
  DDIR=`find /c/Users/*/Appdata/Roaming/MetaQuotes/Terminal  -name "MQL4" | head -n 1`
  if [[ -z $DDIR ]]; then
    DDIR=$TDIR
  else
    DDIR=`dirname $DDIR` # Get upper profile directory
  fi
  BROWSER=`find /c/Program\ Files*/*Firefox*/ -name "firefox.exe" | head -n 1`
  if [[ -z $BROWSER ]]; then
    BROWSER=`find /c/Program\ Files*/*Google*/ -name "chrome.exe" | head -n 1`
  fi
else
  BROWSER="xdg-open"
  TDIR=`find $HOME/.wine/drive_c/Program\ Files*/ -type d -name "FxPro*" | head -n 1`
  TDIR=${TDIR%/} # Remove trailing slash
  DDIR=$TDIR
  TWRAP="wine"
fi

# Compile the codebase, doesn't recompile if not modified
compile() {
  echo "Compiling..."
  $TWRAP "$TDIR/metaeditor.exe" /compile:"experts/" /log
}

# Moves compiled files into expected folders
move() {
  echo "Copying build to $DDIR"
  cp experts/*.ex4 "$DDIR/MQL4/Experts"
}

# Sync MT4 expert changes back to repo
sync() {
  echo "Syncing folders"
  cp -u experts/*.mq4 $DDIR/MQL4/Experts/
  for f in experts/*.mq4; do
    cp -u $DDIR/MQL4/Experts/`basename $f` experts/
  done
  cp -u include/*.mqh $DDIR/MQL4/Include/
  for f in include/*.mqh; do
    cp -u $DDIR/MQL4/Include/`basename $f` include/
  done
  cp -u libs/*.mq4 $DDIR/MQL4/Libraries/
  for f in libs/*.mq4; do
    cp -u $DDIR/MQL4/Libraries/`basename $f` libs/
  done
}

# Backtest from given terminal
backtest() {
  if [ ! -f $1 ] || [ -z "$1" ]; then
    echo "Configuration file not found: $1"
    return
  fi

  echo "Backtesting $1"
  $TWRAP "$TDIR/terminal.exe" $1

  mv "$DDIR/${1}Report."* report/
  "$BROWSER" "report/${1}Report.htm"
}

# Check for arguments
if [ $# -eq 0 ]
then
  echo "No arguments given, usage:"
  echo "[c]ompile: code in experts/ folder"
  echo "[m]ove: compiled code in experts/ folder to MT4 folders"
  echo "[s]ync: update code changes from MT4 folders"
  echo "[b]acktest <config_name>: run backtest on given expert config"
  echo "[cl]ean: all *.ex4 files inside repo"
  echo
  echo "Detected vars:"
  echo "MQL4 dir: $DDIR"
  echo "Term dir: $TDIR"
  echo "Browser:  $BROWSER"
fi

# idiomatic parameter and option handling in sh
while test $# -gt 0
do
  case "$1" in
    c|compile)
      compile
      ;;
    m|move)
      move
      ;;
    s|sync)
      sync
      ;;
    b|backtest)
      backtest "$2"
      shift
      ;;
    cl|clean)
      echo "Cleaning build files..."
      find -iname "*.ex4" -delete
      ;;
    *)
      echo "Unknown option $1"
      echo "Check usage by running without arguments"
      ;;
  esac
  shift
done
