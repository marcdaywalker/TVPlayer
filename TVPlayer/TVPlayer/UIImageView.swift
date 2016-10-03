//
//  UIImageView.swift
//  TVPlayer
//
//  Created by Madriz on 24/9/16.
//  Copyright © 2016 MMApps. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    func loadImageFromUrl(url: URL?){
        
        // Create Url from string
        if let url = url {
        
        // Download task:
        // - sharedSession = global NSURLCache, NSHTTPCookieStorage and NSURLCredentialStorage objects.
        let task = URLSession(configuration: URLSessionConfiguration.default).dataTask(with: url) { (responseData, responseUrl, error) -> Void in
            // if responseData is not null...
            if let data = responseData{
                
                // execute in UI thread
                DispatchQueue.main.async(execute: { 
                    self.image = UIImage(data: data)
                })
            }
        }
        
        // Run task
        task.resume()
    }
    }
}
