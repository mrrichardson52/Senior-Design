//
//  ApiHelper.swift
//  HexoskinBreathing
//
//  Created by Matthew Richardson on 11/5/16.
//  Copyright © 2016 Matthew Richardson. All rights reserved.
//

import UIKit

class ApiHelper: NSObject {
    
    // Function used to patch new redirect urls to the user's account
    static func patchRedirectUri(clientId: String, clientSecret: String, clientIdNumber: String, redirectUri: String) {
        
        print("MRRApiHelper patching function");
        
        // first we need to get a token
        let request = generateRequest(url: "https://api.hexoskin.com/api/connect/oauth2/token/",
                                      parameters: ["grant_type" : "client_credentials",
                                                   "client_id" : clientId,
                                                   "client_secret" : clientSecret,
                                                   "scope" : "readwrite"],
                                      httpMethod: "POST",
                                      headers: [:]);
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            print("first completion handler");
            
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
            
            do {
                let dataDictionary = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String:Any];
                let token = dataDictionary["access_token"] as! String;
                
                // using the token, patch the redirect uri
                var request = generateRequest(url: "https://api.hexoskin.com/api/oauthclient/\(clientIdNumber)/", httpMethod: "PATCH", headers: ["Authorization" : "Bearer \(token)", "Content-Type" : "application/json"]);
                
                // add the redirect uris to the body of the request
                let dictionary = ["redirect_uris" : redirectUri];
                do {
                    let json = try JSONSerialization.data(withJSONObject: dictionary);
                    request.httpBody = json;
                } catch {
                    print("error converting to json");
                }
                
                // now initiate the request
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data, error == nil else {                                                 // check for fundamental networking error
                        print("error=\(error)")
                        return
                    }
                    
                    if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                        print("statusCode should be 200, but is \(httpStatus.statusCode)")
                        print("response = \(response)")
                    }
                    
                    let responseString = String(data: data, encoding: .utf8)
                    print("responseString = \(responseString!)")
                    
                    do {
                        let dataDictionary = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String:Any];
                        print(dataDictionary.description);
                        
                    } catch let error as NSError {
                        print(error);
                    }
                }
                task.resume()
                
                
            } catch let error as NSError {
                print(error);
            }
        }
        task.resume();
        
    }
    
    static func authorizeUser(clientId: String) {
        
        // convert the parameter dictionary into a parameter query string
        let parameters = ["response_type" : "token", "client_id" : clientId, "scope" : "readonly", "state" : "mrr state string"];
        let parameterString = parameters.stringFromHttpParameters();
        
        // construct the url
        let url = "https://api.hexoskin.com/api/connect/oauth2/auth/?" + parameterString;
        
        // open the url in safari
        UIApplication.shared.open(URL(string: url)!);
        
    }
    
    static func generateRequest(url: String, parameters: [String : String] = [:], query: [String : String] = [:], httpMethod: String = "GET", headers: [String : String] = [:]) -> URLRequest {
                
        // create the request

        var urlString = url;
        if !query.isEmpty {
            urlString.append("?");
            urlString.append(query.stringFromHttpParameters());
        }
//        var request = URLRequest(url: URL(string: urlString)!);
        var request = URLRequest(url: URL(string: urlString)!, cachePolicy: .reloadIgnoringCacheData)
        request.httpMethod = httpMethod;
        
        if !parameters.isEmpty {
            let parameterString = parameters.stringFromHttpParameters();
            request.httpBody = parameterString.data(using: .utf8);
        }
        
        
        // add headers
        for (headerLabel, value) in headers {
            request.setValue(value, forHTTPHeaderField: headerLabel);
        }
        
        return request;
    }
    
    
}

extension String {
    
    /// Percent escapes values to be added to a URL query as specified in RFC 3986
    ///
    /// This percent-escapes all characters besides the alphanumeric character set and "-", ".", "_", and "~".
    ///
    /// http://www.ietf.org/rfc/rfc3986.txt
    ///
    /// :returns: Returns percent-escaped string.
    
    func addingPercentEncodingForURLQueryValue() -> String? {
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        
        return self.addingPercentEncoding(withAllowedCharacters: allowedCharacters)
    }

}

extension Dictionary {
    
    /// Build string representation of HTTP parameter dictionary of keys and objects
    ///
    /// This percent escapes in compliance with RFC 3986
    ///
    /// http://www.ietf.org/rfc/rfc3986.txt
    ///
    /// :returns: String representation in the form of key1=value1&key2=value2 where the keys and values are percent escaped
    
    func stringFromHttpParameters() -> String {
        let parameterArray = self.map { (key, value) -> String in
            let percentEscapedKey = (key as! String).addingPercentEncodingForURLQueryValue()!
            let percentEscapedValue = (value as! String).addingPercentEncodingForURLQueryValue()!
            return "\(percentEscapedKey)=\(percentEscapedValue)"
        }
        
        return parameterArray.joined(separator: "&")
    }
    
}
