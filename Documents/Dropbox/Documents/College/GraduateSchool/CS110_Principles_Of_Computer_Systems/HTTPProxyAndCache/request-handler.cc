/**
 * File: request-handler.cc
 * ------------------------
 * Provides the implementation for the HTTPRequestHandler class.
 */

#include <sys/types.h>
#include <netdb.h>
#include <unistd.h>
#include "client-socket.h"
#include "request-handler.h"
#include "logging.h"

using namespace std;


HTTPRequestHandler::HTTPRequestHandler(): proxyServer(string()), proxyPortNum(0), 
					  usingProxy(false), blacklist(blackListFile){ }

HTTPRequestHandler::~HTTPRequestHandler(){ }

/*
 * Service the clients request
 */
void HTTPRequestHandler::serviceRequest(const pair<int, string>& connection) throw() {
  int clientfd = connection.first;
  const string clientIPAddress = connection.second;

  sockbuf sb(clientfd);
  iosockstream ss(&sb);

  // read in request 
  HTTPRequest request(this->usingProxy);  
  HTTPResponse response;

  if(this->devourRequest(request, response, ss, clientIPAddress) == true){
  log("CLIENT REQUESTING >>[ " + request.getMethod() + " " +
      request.getServer() + " ]<<");
    if(this->blacklist.serverIsAllowed(request.getServer()) == false){
      // check if server name is on blacklist
      log("FORBIDDEN CONTENT: " + request.getServer() + " is on the black list");
      response.buildResponse(403, "Forbidden Content", request.getProtocol());    
    }else
      this->fetchResponse(request, response);
  }

  // Response  
  ss << response;
  ss.flush();
  log("RESPONSEDED to REQUEST >>[ " + request.getMethod() + " " + request.getServer() + " ]<<");
}

/* 
 * Forward request to the appropriate server
 */
HTTPResponse HTTPRequestHandler::executeRequest(const HTTPRequest& request){
  int serverfd = 0;
  if(this->usingProxy == false)
    serverfd = createClientSocket(request.getServer(), request.getPort());
  else
    serverfd = createClientSocket(this->proxyServer, this->proxyPortNum);

  if(serverfd == kClientSocketError){
    log("Can not connect to SERVER... BAD REQUEST");
    HTTPResponse response;
    response.buildResponse(400, "Bad Request", this->defaultProtocol);
    return response;
  }

  sockbuf sb(serverfd);
  iosockstream ss(&sb);

  ss << request;
  ss.flush();

  // build response
  HTTPResponse serverResponse;
  serverResponse.ingestResponseHeader(ss);
  serverResponse.ingestPayload(ss);

  return serverResponse;
}

/*
 * Fetch response either from cache or server
 */
void HTTPRequestHandler::fetchResponse(const HTTPRequest &request, HTTPResponse& response){
  this->cache.handleMutex(request, LOCK); 
  if(this->cache.containsCacheEntry(request, response) == true){
    // check catch for cached request
    log("CACHE: Response for request >>[ " + request.getMethod() + " " +
    	request.getServer() + " " + request.getPath() + " ]<< was loaded from cache.");
  }else{
    // fetch response
    log("REQUESTING RESPONSE to >>[ " + request.getMethod() + " " +
    	request.getServer() + " " + request.getPath() + " ]<<");
    response = this->executeRequest(request);
    log("RECEIVED RESPONSE to >>[ " + request.getMethod() + " " +
	request.getServer() + " " + request.getPath() + " ]<<");
    if(this->cache.shouldCache(request, response) == true){      
      this->cache.cacheEntry(request, response);
      log("CACHED response to request >>[ " + request.getMethod() + " " +
      	  request.getServer() + " " + request.getPath() + " ]<<"); 
    }	
  }
  this->cache.handleMutex(request, UNLOCK);
} 

/*
 * Devour the request and handle any errors
 */
bool HTTPRequestHandler::devourRequest(HTTPRequest &request,
				       HTTPResponse &response,
				       iosockstream &ss, 
				       const string& clientIPAddress){
  // ingest the request line
  try{
    request.ingestRequestLine(ss);
  } catch(HTTPBadRequestException){
    log("BAD REQUEST from " + clientIPAddress);
    response.buildResponse(400, "Bad Request", this->defaultProtocol);
    return false;
  }

  // ingest the header and exit if cyclical
  request.ingestHeader(ss, clientIPAddress);
  if(request.isCyclical()){
    log("GATEWAY TIMEOUT cyclical request");
    response.buildResponse(504, "Gateway Timeout", this->defaultProtocol);
    return false ;
  }

  // ingest the payload if method is not HEAD
  if(request.getMethod().compare("HEAD") != 0)
    request.ingestPayload(ss);

  return true;
}

void HTTPRequestHandler::setProxy(const std::string& proxyServer, 
				  const unsigned short proxyPortNum){
  this->proxyServer = proxyServer; 
  this->proxyPortNum = proxyPortNum;
  this->usingProxy = true;
}

