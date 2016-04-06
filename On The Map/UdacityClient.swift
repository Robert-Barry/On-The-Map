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
    
    // MARK: Reusable client functions
    
    // MARK: Get
    
    func taskForGETMethod(apiName: String, method: String, var parameters: [String:AnyObject], completionHandlerForGET: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        print("Task for GET method called")
        
        // Build the request
        let request = buildRequest(apiName, method: method, parameters: parameters)
        
        // Build the task
        let task = buildTask(apiName, request: request, completionHandler: completionHandlerForGET)
        
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
        let task = buildTask(apiName, request: request, completionHandler: completionHandlerForPOST)
        
        task.resume()
        
        return task
        
    }
    
    // MARK: Put
    
    func taskForPUTMethod(apiName: String, method: String, var parameters: [String:AnyObject], jsonBody: String, completionHandlerForPUT: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        print("Task for PUT method called")
        
        // Build the request
        let request = buildRequest(apiName, method: method, parameters: parameters)
        request.HTTPMethod = "PUT"
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        // Build the task
        let task = buildTask(apiName, request: request, completionHandler: completionHandlerForPUT)
        
        task.resume()
        
        return task
        
    }
    
    // MARK: Delete
    
    func taskForDELETEMethod(method: String, parameters: [String:AnyObject], completionHandlerForDELETE: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        print("Task for DELETE method called")
        
        // Build the request
        let request = buildRequest(UdacityConstants.UdacityApi, method: method, parameters: parameters)
        request.HTTPMethod = "DELETE"
        
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }

        let task = buildTask(UdacityConstants.UdacityApi, request: request, completionHandler: completionHandlerForDELETE)
        
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
    
    func buildTask(apiName: String, request: NSMutableURLRequest, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
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
            self.convertDataWithCompletionHandler(apiName, data: data, completionHandlerForConvertData: completionHandler)
        }
        
        return task
        
    }
    
    // given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(apiName: String, data: NSData, completionHandlerForConvertData: (result: AnyObject!, error: NSError?) -> Void) {
        
        print("Converting data to json...")
        
        var newData = data

        if apiName == UdacityConstants.UdacityApi {
            newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
        }
        
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