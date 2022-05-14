//
//  APIClient.swift
//  TawkUserManager
//
//  Created by Savvycom2021 on 14/05/2022.
//

import Foundation

enum APIError: Error {
    case noData
    case parseFail
    case unknowed
}

class APIService {
    private let session: URLSession
    private let domain: String
    private let networkQueue: OperationQueue
    
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
        let operation = NetworkOperation(session: session, urlRequest: urlRequest) { data, error in
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
        }
        networkQueue.addOperation(operation)
    }
}
