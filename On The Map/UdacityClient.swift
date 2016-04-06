//
//  UdacityClient.swift
//  On The Map
//
//  Client and convenience functions for Udacity and Parse APIs
//
//  Created by Robert Barry on 4/5/16.
//  Copyright © 2016 Robert Barry. All rights reserved.
//

import Foundation

class UdacityClient: NSObject {
    
    // shared session
    var session = NSURLSession.sharedSession()
    
    
    
    // MARK: Login functions
    
    // Begin the authentication process
    func authenticate(jsonBody: String, completionHandlerForAuth: (success: Bool, errorString: String?) -> Void) {
        
        print("Authenticating...")
        
        // Begin completion handler chain for the authentication process
        getSessionAndUdacityIds(jsonBody) { (success, sessionId, udacityId, errorString) in
            
            if success {
                
                // Save the session ID and Udacity ID
                UdacityResources.sharedInstance().sessionId = sessionId
                UdacityResources.sharedInstance().udacityId = udacityId
                
                // Get the user name
                self.getUserName() { success, firstName, lastName, errorString in
                    
                    if success {
                        
                        // Save the user's first and last name
                        UdacityResources.sharedInstance().firstName = firstName
                        UdacityResources.sharedInstance().lastName = lastName
                        
                    }
                    completionHandlerForAuth(success: success, errorString: errorString)
                }
            } else {
                completionHandlerForAuth(success: success, errorString: errorString)
            }
        }
    }

    // Login using Udacity credentials
    private func getSessionAndUdacityIds(jsonBody: String, completionHandlerForIds: (success: Bool, sessionId: String?, udacityId: String?, errorString: String?) -> Void) {
        
        print("Getting session and Udacity IDs")
        
        // Creat empty parameters
        let parameters = [String: AnyObject]()
        
        // POST to get the session ID and Udacity ID in 1 request
        taskForPOSTMethod(UdacityConstants.UdacityApi, method: UdacityConstants.UdacitySession, parameters: parameters, jsonBody: jsonBody) { results, error in
            
            if let error = error {
                
                print(error)
                completionHandlerForIds(success: false, sessionId: nil, udacityId: nil, errorString: "There was an error retrieving your account information. Please try again.")
                
            } else {
                
                // Chain of unwrapping optionals from the results
                if let accountDict = results["account"] as? [String:AnyObject] {
                    if let udacityId = accountDict["key"] as? String {
                        if let sessionDict = results["session"] as? [String:AnyObject] {
                            if let sessionId = sessionDict["id"] as? String {
                                // If the unwrapping chain is successful, end the chain
                                completionHandlerForIds(success: true, sessionId: sessionId, udacityId: udacityId, errorString: nil)
                            } else {
                                completionHandlerForIds(success: false, sessionId: nil, udacityId: nil, errorString: "There was an error retrieving your account information. Please try again.")
                                print("There was an error unwrapping ID")
                            }
                        } else {
                            completionHandlerForIds(success: false, sessionId: nil, udacityId: nil, errorString: "There was an error retrieving your account information. Please try again.")
                            print("There was an error unwrapping session.")
                        }
                    } else {
                        completionHandlerForIds(success: false, sessionId: nil, udacityId: nil, errorString: "There was an error retrieving your account information. Please try again.")
                        print("There was an error unwrapping key.")
                    }
                } else {
                    completionHandlerForIds(success: false, sessionId: nil, udacityId: nil, errorString: "There was an error retrieving your account information. Please try again.")
                    print("There was an error unwrapping results.")
                }

            }
            
        }}
    
    // Get the first and last name of the Udacity user
    private func getUserName(completionHandlerForUserName: (success: Bool, firstName: String?, lastName: String?, errorString: String?) -> Void) {
        
        print("Getting user name")
        
        // Creat empty parameters
        let parameters = [String: AnyObject]()
        
        // Unwrap the Udacity ID to use in the taskForGETMethod method argument
        guard let udacityId = UdacityResources.sharedInstance().udacityId else {
            print("Error getting user ID")
            return
        }
        
        // GET the user's first and last names
        taskForGETMethod(UdacityConstants.UdacityApi, method: (UdacityConstants.UdacityUsers + "/" + udacityId), parameters: parameters) {
            results, error in
            
            if let error = error {
                print(error)
                completionHandlerForUserName(success: false, firstName: nil, lastName: nil, errorString: "There was an error retrieving your account information. Please try again.")
                
            } else {
                
                // Chain of unwrapping optionals from the results
                if let userDict = results["user"] as? [String:AnyObject] {
                    if let firstName = userDict["first_name"] as? String {
                        if let lastName = userDict["last_name"] as? String {
                            // If the unwrapping chain is successful, end the chain
                            completionHandlerForUserName(success: true, firstName: firstName, lastName: lastName, errorString: nil)
                        } else {
                            completionHandlerForUserName(success: false, firstName: nil, lastName: nil, errorString: "There was an error retrieving your account information. Please try again.")
                            print("There was an error unwrapping last_name.")
                        }
                    } else {
                        completionHandlerForUserName(success: false, firstName: nil, lastName: nil, errorString: "There was an error retrieving your account information. Please try again.")
                        print("There was an error unwrapping first_name.")
                    }
                } else {
                    completionHandlerForUserName(success: false, firstName: nil, lastName: nil, errorString: "There was an error retrieving your account information. Please try again.")
                    print("There was an error unwrapping results.")
                }
            }
        }
    }

    
    
    // MARK: Reusable client functions
    
    // MARK: Get
    
    func taskForGETMethod(apiName: String, method: String, var parameters: [String:AnyObject], completionHandlerForGET: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        print("Task for GET method called")
        
        // Build the request
        let request = buildRequest(apiName, method: method, parameters: parameters)
        
        // Build the task
        let task = buildTask(request, completionHandler: completionHandlerForGET)
        
        task.resume()
        
        return task
        
    }
    
    // MARK: Post
    
    func taskForPOSTMethod(apiName: String, method: String, var parameters: [String:AnyObject], jsonBody: String, completionHandlerForPOST: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        print("Task for POST method called")
        
        // Build the request
        let request = buildRequest(apiName, method: method, parameters: parameters)
        request.HTTPMethod = "POST"
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        // Build the task
        let task = buildTask(request, completionHandler: completionHandlerForPOST)
        
        task.resume()
        
        return task
        
    }
    
    // MARK: Helper functions
    
    func buildRequest(apiName: String, method: String, var parameters: [String:AnyObject]) -> NSMutableURLRequest {
        
        print("Building the request...")
        
        // Create a request
        var request: NSMutableURLRequest
        
        // Is it the Parse or Udacity API?
        if apiName == UdacityConstants.UdacityApi {
            
            request = NSMutableURLRequest(URL: URLFromParameters(UdacityConstants.ApiScheme, apiHost: UdacityConstants.UdacityApiHost, apiPath: UdacityConstants.UdacityApiPath, parameters: parameters, withPathExtension: method))
            
            // Is it a POST request?
            if UdacityResources.sharedInstance().method == "POST" {
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            
        } else {
            
            request = NSMutableURLRequest(URL: URLFromParameters(UdacityConstants.ApiScheme, apiHost: UdacityConstants.ParseApiHost, apiPath: UdacityConstants.ParseApiPath, parameters: parameters, withPathExtension: method))
            
            request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
            
        }
        
        return request
        
    }
    
    func buildTask(request: NSMutableURLRequest, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        print("Building the task...")
        
        // Create a task
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func sendError(error: String) {
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandler(result: nil, error: NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            // Guard statementsto check check that the data is valid
            
            // GUARD: Was there an error?
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            // GUARD: Did we get a successfull 2xx response?
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx: \((response as? NSHTTPURLResponse)?.statusCode))")
                return
            }
            
            // GUARD: Was the data returned
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            // Convert the data to json
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandler)
        }
        
        return task
        
    }
    
    // given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(data: NSData, completionHandlerForConvertData: (result: AnyObject!, error: NSError?) -> Void) {
        
        print("Converting data to json...")
        
        let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(result: nil, error: NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }

        completionHandlerForConvertData(result: parsedResult, error: nil)
    }
    
    // Creates a URL for use in a request
    func URLFromParameters(apiScheme: String, apiHost: String, apiPath: String, parameters: [String:AnyObject], withPathExtension: String? = nil) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = apiScheme
        components.host = apiHost
        components.path = apiPath + (withPathExtension ?? "")
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.URL!
    }
    
    // Create a singleton
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
    
}