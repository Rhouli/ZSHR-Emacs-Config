/**
 * File: request-handler.h
 * -----------------------
 * Defines the HTTPRequestHandler class, which fully proxies and
 * services a single client request.  
 */

#ifndef _http_request_handler_
#define _http_request_handler_

#include <socket++/sockstream.h> // for sockbuf, iosockstream
#include <utility>
#include <string>

#include "request.h"
#include "response.h"
#include "blacklist.h"
#include "cache.h"

class HTTPRequestHandler {
 public:
  HTTPRequestHandler();
  void serviceRequest(const std::pair<int, std::string>& connection) throw();
  void setProxy(const std::string& proxyServer, 
				    const unsigned short proxyPortNum);
  ~HTTPRequestHandler();
  
private:
  HTTPResponse executeRequest(const HTTPRequest& request);
  void fetchResponse(const HTTPRequest &request, HTTPResponse& response);
  bool devourRequest(HTTPRequest &request, HTTPResponse& response,
		     iosockstream &ss, const std::string& clientIPAddress);
  const std::string blackListFile = "blocked-domains.txt";
  const std::string defaultProtocol = "HTTP/1.1";
  std::string proxyServer;
  unsigned short proxyPortNum;
  bool usingProxy;
  HTTPBlacklist blacklist;
  HTTPCache cache;
};

#endif
