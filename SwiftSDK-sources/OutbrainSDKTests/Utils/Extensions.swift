//
//  Extensions.swift
//  OutbrainSDK
//
//  Created by Leonid Lemesev on 12/11/2024.
//

import Foundation


extension Data {
    
    static func loadJSON(from filename: String) -> Data? {
        
        guard let url = Bundle(for: OBRequestHandlerTests.self).url(forResource: filename, withExtension: "json") else {
            print("Failed to locate JSON file: \(filename).json")
            return nil
        }
        
        do {
            // Load the data from the file
            let data = try Data(contentsOf: url)
            return data
        } catch {
            print("Failed to load JSON data: \(error.localizedDescription)")
            return nil
        }
    }
}


extension HTTPURLResponse {
    
    static func valid() -> HTTPURLResponse {
        return HTTPURLResponse(url: URL(string: "https://mv.outbrain.com")!,
                               statusCode: 200,
                               httpVersion: nil,
                               headerFields: nil)!
    }
    
    static func invalid(code: Int) -> HTTPURLResponse {
        return HTTPURLResponse(url: URL(string: "https://mv.outbrain.com")!,
                               statusCode: code,
                               httpVersion: nil,
                               headerFields: nil)!
    }
}

