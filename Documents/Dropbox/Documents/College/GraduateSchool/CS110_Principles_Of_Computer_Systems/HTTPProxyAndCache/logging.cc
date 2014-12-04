/* 
 * File: logging.cc
 * Basic logging functionality
 */ 

#include <functional>
#include <iostream>
#include <stdio.h>
#include <thread>
#include <atomic>
#include <cmath>
#include <mutex>

#include "ostreamlock.h"
#include "logging.h"

static unsigned long long logNum;
static std::mutex overflowMutex;

void log(const std::string& logMessage){
  if(LOGGING_ENABLED == 1){

    overflowMutex.lock();
    if(logNum > pow(2, sizeof(unsigned long long)*8))
      logNum = 0;

    logNum++;
    std::hash<std::thread::id>  hash;
    size_t threadID = hash(std::this_thread::get_id());
    std::cout << oslock << "::[LOG #" << logNum << " :: TID (" 
	      << threadID%1000 << ")]:: " << logMessage << "  ::[END LOG #" 
	      << logNum << "]:: " << std::endl << osunlock;    
    overflowMutex.unlock();
  }
}
