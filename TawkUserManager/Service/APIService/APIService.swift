//
//  APIClient.swift
//  TawkUserManager
//
//  Created by Savvycom2021 on 14/05/2022.
//

import Foundation
import RxSwift

enum APIError: Error {
    case noData
    case parseFail
    case unknowed
    case invalidUrl
    case cancelRequest
}

class APIService {
    private let session: URLSession
    private let domain: String
    private let networkQueue: OperationQueue
    private var operationCount = 0
    private let lock = NSLock()
    
    static let shared: APIService = {
        let domain = "https://api.github.com/"
        let session = URLSession.shared
        let networkQueue = OperationQueue()
        networkQueue.maxConcurrentOperationCount = 1
        return APIService(domain: domain, session: session, networkQueue: networkQueue)
    }()
    
    private init(domain: String, session: URLSession, networkQueue: OperationQueue) {
        self.domain = domain
        self.session = session
        self.networkQueue = networkQueue
    }
    
    func doRequest<T: Codable>(_ request: RequestType, completion: @escaping (Result<T, APIError>) -> Void) {
        guard let urlRequest = request.makeUrlRequest(domain) else {
            completion(.failure(.invalidUrl))
            return
        }
        let operation = NetworkOperation(session: session, urlRequest: urlRequest) { data, error in
            if let _ = error {
                completion(.failure(.unknowed))
            } else if let data = data {
                let decoder = JSONDecoder()
                if let model = try? decoder.decode(T.self, from: data) {
                    completion(.success(model))
                } else {
                    completion(.failure(.parseFail))
                }
            } else {
                completion(.failure(.noData))
            }
        }
        networkQueue.addOperation(operation)
    }
    
    func doRequestArray<T: Codable>(_ request: RequestType, completion: @escaping (Result<[T], APIError>) -> Void) {
        guard let urlRequest = request.makeUrlRequest(domain) else {
            return
        }
        let operation = NetworkOperation(session: session, urlRequest: urlRequest) { [weak self] data, error in
            if let _ = error {
                completion(.failure(.unknowed))
            } else if let data = data {
                let decoder = JSONDecoder()
                if let model = try? decoder.decode([T].self, from: data) {
                    completion(.success(model))
                } else {
                    completion(.failure(.parseFail))
                }
            } else {
                completion(.failure(.noData))
            }
            self?.finishOperation()
        }
        addOperation(operation)
    }
    
    @discardableResult
    func downloadImage(url: String, completion: @escaping (Result<Data, APIError>) -> Void) -> NetworkOperation? {
        guard let url = URL(string: url) else {
            completion(.failure(.invalidUrl))
            return nil
        }
        let operation = NetworkOperation(session: session, urlRequest: URLRequest(url: url)) { [weak self] data, error in
            if let _ = error {
                completion(.failure(.unknowed))
            } else if let data = data {
                completion(.success(data))
            } else {
                completion(.failure(.noData))
            }
            self?.finishOperation()
        }
        addOperation(operation)
        return operation
    }
    
    func haveNoRequesting() -> Bool {
        return operationCount == 0
    }
    
    private func addOperation(_ operation: NetworkOperation) {
        networkQueue.addOperation(operation)
        lock.lock()
        operationCount += 1
        lock.unlock()
    }
    
    private func finishOperation() {
        lock.lock()
        if operationCount > 0 {
            operationCount -= 1
        }
        lock.unlock()
    }
}
