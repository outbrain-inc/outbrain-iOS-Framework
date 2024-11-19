//
//  OBRequestUrlBuilder.swift
//  OutbrainSDK
//
//  Created by Leonid Lemesev on 11/11/2024.
//


struct OBRequestUrlBuilder: OBRequestUrlBuilderProtocol {
    
    let request: OBRequest
    let urls: OBRequestURLProtocol
    
    
    init(request: OBRequest) {
        self.request = request
        self.urls = OBRequestURLs()
    }
}

