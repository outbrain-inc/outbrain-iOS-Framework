//
//  OBQueueManager.swift
//  OutbrainSDK
//
//  Created by Dror Seltzer on 20/06/2023.
//

import Foundation

class OBQueueManager {
    // singleton
    static let shared = OBQueueManager()
    private let odbFetchQueue: OperationQueue
    
    public var operationCount: Int {
        return odbFetchQueue.operationCount
    }
    
    // we are using OS queue to perform synchronous requests - one at a time
    private init() {
        odbFetchQueue = OperationQueue()
        odbFetchQueue.name = "com.outbrain.sdk.odbFetchQueue"
        odbFetchQueue.maxConcurrentOperationCount = 1
    }
    
    // add a request to odb queue
    func enqueueFetchRecsRequest(_ fetchTask: @escaping () -> Void) {
        odbFetchQueue.addOperation {
            fetchTask()
        }
    }
    
}
