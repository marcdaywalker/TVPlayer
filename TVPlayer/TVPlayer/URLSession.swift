//
//  NSURLSession.swift
//  TVPlayer
//
//  Created by Madriz on 20/9/16.
//  Copyright © 2016 MMApps. All rights reserved.
//

import Foundation

extension URLSession {
    
    func synchronousDataTaskWithURL (url: URL) -> (Data?, URLResponse?, Error?) {
        var data: Data?
        var response: URLResponse?
        var error: Error?
        
        let mutableRequest = NSMutableURLRequest(url: url)
        mutableRequest.addValue("Dalvik/1.6.0 (Linux; U; Android 4.3; GT-I9300 Build/JSS15J", forHTTPHeaderField: "User-Agent")
        let request: URLRequest = mutableRequest.copy() as! URLRequest
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let sessionDataTask = dataTask(with: request) { (_data, _response, _error) in
            data = _data
            response = _response
            error = _error
            semaphore.signal()
        }
        
        sessionDataTask.resume()
        semaphore.wait()
        
        return (data, response, error)
    }
    
}
