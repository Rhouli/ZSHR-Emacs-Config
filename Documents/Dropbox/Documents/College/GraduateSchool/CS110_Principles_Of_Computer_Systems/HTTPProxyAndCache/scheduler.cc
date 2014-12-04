/**
 * File: scheduler.cc
 * ------------------
 * Presents the implementation of the HTTPProxyScheduler class.
 */

#include <utility>
#include "scheduler.h"

using namespace std;

static const int threadPoolSize = 16;
HTTPProxyScheduler::HTTPProxyScheduler(): threadpool(threadPoolSize) {}

void HTTPProxyScheduler::scheduleRequest(int clientfd, const string& clientIPAddress) {
  auto connection = make_pair(clientfd, clientIPAddress);
  this->threadpool.schedule([this, connection]() {
      this->requestHandler.serviceRequest(connection);
    });
}

void HTTPProxyScheduler::setRequestProxy(const std::string& proxyServer, const unsigned short proxyPortNum){
  this->requestHandler.setProxy(proxyServer, proxyPortNum);
}
