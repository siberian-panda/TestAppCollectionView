//
//  ResourceRequestController.swift
//  TestAppCollection
//
//  Created by Artem Farafonov on 18.10.2021.
//

import UIKit

protocol ResourceRequestControllerDelegate: NSObject {
    
    func resourceRequestController(_ controller: ResourceRequestController, didLoadResource data: Data, for index: Int)
    func resourceRequestController(_ controller: ResourceRequestController, didFailToLoadResourceFor index: Int, error: NSError)
    
}

class ResourceRequestController: NSObject {

    public weak var delegate: ResourceRequestControllerDelegate?
    
    private var requestQueue = OperationQueue()
    private var activeTask: URLSessionDataTask?
    private var tasksArray: [URLSessionDataTask] = []
    private var requestedIndexes: [Int] = []
    
    override init() {
        super.init()
        
        requestQueue.name = "\(Bundle.main.bundleIdentifier ?? "com.TestApp").ResourceRequestQueue"
        requestQueue.maxConcurrentOperationCount = 1
        requestQueue.qualityOfService = .utility
    }
    
    public func loadResource(for itemIndex: Int) {
        guard !requestedIndexes.contains(itemIndex) else {
            return
        }
        requestedIndexes.append(itemIndex)
        requestQueue.addOperation {
            self._loadResource(for: itemIndex)
        }
    }
    
    private func _loadResource(for itemIndex: Int) {
        let apiString = "https://source.unsplash.com/"
        let size = "800x600"
        let category = "cars"
        let urlString = "\(apiString)\(size)/?\(category)"
        let url = URL.init(string: urlString)
        var request = URLRequest.init(url: url!)
        request.httpMethod = "GET"
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        let session = URLSession.init(configuration: .default,
                                      delegate: nil,
                                      delegateQueue: nil)
        let task = session.dataTask(with: request) {(data, response, error) in
            defer {
                self.requestedIndexes.removeFirst()
                if let nextTask = self.tasksArray.first {
                    self.tasksArray.removeFirst()
                    self.activeTask = nextTask
                    self.activeTask?.resume()
                } else {
                    self.activeTask = nil
                }
            }
            guard error == nil else {
                self._sendDidFailToLoad(for: itemIndex, error: error! as NSError)
                return
            }
            guard (response as! HTTPURLResponse).statusCode == 200 else {
                self._sendDidFailToLoad(for: itemIndex,
                                        error: NSError.error(with: "Error response code",
                                                           code: (response as! HTTPURLResponse).statusCode))
                return
            }
            guard let data = data, UIImage.init(data: data) != nil else {
                self._sendDidFailToLoad(for: itemIndex,
                                        error: NSError.error(with: "Invalid response data", code: 1))
                return
            }
            self._sendDidLoad(data: data, for: itemIndex)
        }
        if activeTask == nil {
            activeTask = task
            activeTask?.resume()
        } else {
            tasksArray.append(task)
        }
    }
    
    private func _sendDidLoad(data: Data, for itemIndex: Int) {
        guard let delegate = self.delegate else {
            return
        }
        delegate.resourceRequestController(self, didLoadResource: data, for: itemIndex)
    }
    
    private func _sendDidFailToLoad(for itemIndex: Int, error: NSError) {
        guard let delegate = self.delegate else {
            return
        }
        delegate.resourceRequestController(self, didFailToLoadResourceFor: itemIndex, error: error)
    }
    
}
