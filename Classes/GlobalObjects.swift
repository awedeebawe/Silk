//
//  GlobalObjects.swift
//  Pods
//
//  Created by Kai Straßmann on 04.02.16.
//
//

import Foundation

// MARK: - SilkGlobalHeaders
class SilkGlobalHeaders {
    private var allHostsHeaders = [String: String]()
    private var specificHostHeaders = [String: [String: String]]()
    
    func setHeader(name: String, value: String?, forHost host: String?) {
        if let host = host {
            var headers = specificHostHeaders[host] ?? [String: String]()
            headers[name] = value
            specificHostHeaders[host] = headers
        } else {
            allHostsHeaders[name] = value
        }
    }
    
    func setHeaders(headers: [String: String], forHost host: String?) {
        if let host = host {
            specificHostHeaders[host] = headers
        } else {
            allHostsHeaders = headers
        }
    }
    
    func headersForHost(host: String?) -> [String: String] {
        if let host = host {
            if let specificHeaders = specificHostHeaders[host] {
                return specificHeaders.reduce(allHostsHeaders) { (inputDict, e) in
                    var dict = inputDict
                    dict[e.0] = e.1
                    return dict
                }
            } else {
                return allHostsHeaders
            }
        } else {
            return allHostsHeaders
        }
    }
}

// MARK: - SilkGlobalCredentials
class SilkGlobalCredentials {
    private var allHostsCredentials: NSURLCredential?
    private var specificHostCredentials = [String: NSURLCredential]()
    
    func setCredentials(credentials: NSURLCredential?, forHost host: String?) {
        if let host = host {
            specificHostCredentials[host] = credentials
        } else {
            allHostsCredentials = credentials
        }
    }
    
    func credentialsForHost(host: String?) -> NSURLCredential? {
        if let host = host {
            if let specificCredentials = specificHostCredentials[host] {
                return specificCredentials
            } else {
                return allHostsCredentials
            }
        } else {
            return allHostsCredentials
        }
    }
}

// MARK: - SilkMultipartObject
public class SilkMultipartObject {
    private(set) var data: NSData
    private(set) var contentType: String
    private(set) var name: String
    private(set) var fileName: String?
    
    public init(data: NSData, contentType: String, name: String, fileName: String? = nil) {
        self.data = data
        self.contentType = contentType
        self.name = name
        self.fileName = fileName
    }
}