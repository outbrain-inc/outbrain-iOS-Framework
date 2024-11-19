//
//  MockUrlProtocol.swift
//  OutbrainSDK
//
//  Created by Leonid Lemesev on 12/11/2024.
//

import Foundation


class MockUrlProtocol: URLProtocol {
    
    static var mockResponses: [String: (Data?, URLResponse?, Error?)] = [:]
    static var calledHosts: [String] = []
    
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let url = request.url, let host = url.host else {
            return
        }
        
        
        MockUrlProtocol.calledHosts.append(host)
        
        // Retrieve the mock response
        if let (data, response, error) = MockUrlProtocol.mockResponses[host] {
            if let error = error {
                client?.urlProtocol(self, didFailWithError: error)
            } else {
                if let response = response {
                    client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                }
                if let data = data {
                    client?.urlProtocol(self, didLoad: data)
                }
            }
        }
        client?.urlProtocolDidFinishLoading(self)
    }
    
    
    override func stopLoading() {
        
    }
}
