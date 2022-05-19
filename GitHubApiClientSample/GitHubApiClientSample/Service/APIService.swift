//
//  APIService.swift
//  GitHubApiClientSample
//
//  Created by satoutakeshi on 2020/01/28.
//  Copyright © 2020 satoutakeshi. All rights reserved.
//

import Foundation
import Combine

protocol APIRequestType {
    associatedtype Response: Decodable
    
    var path: String { get }
    var queryItems: [URLQueryItem]? { get }
}

protocol APIServiceType {
    func request<Request>(with request: Request) -> AnyPublisher<Request.Response, APIServiceError> where Request: APIRequestType
}

final class APIService: APIServiceType {
    
    private let baseURLString: String
    init(baseURLString: String = "https://api.github.com") {
        self.baseURLString = baseURLString
    }
    
    func request<Request>(with request: Request) -> AnyPublisher<Request.Response, APIServiceError> where Request: APIRequestType {
        
        guard let pathURL = URL(string: request.path, relativeTo: URL(string: baseURLString)) else {
            return Fail(error: APIServiceError.invalidURL).eraseToAnyPublisher()
        }
        
        var urlComponents = URLComponents(url: pathURL, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = request.queryItems
        var request = URLRequest(url: urlComponents.url!)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let decorder = JSONDecoder()
        decorder.keyDecodingStrategy = .convertFromSnakeCase
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { data, urlResponse in data }  // mapでレスポンスデータのストリームに変換
            .mapError { _ in APIServiceError.responseError }  // エラーが起きたらAPIServiceError.responseErrorを返す
            .decode(type: Request.Response.self, decoder: decorder)  // デコード
            .mapError({ (error) -> APIServiceError in
                APIServiceError.parseError(error)
            })
            .receive(on: RunLoop.main)  // ストリームを会陰スレッドに流れるように変換
            .eraseToAnyPublisher()
    }
    
    // Concurrencyで書くと以下の通り？(動作未検証)
    
    func request<Request>(with request: Request) async throws -> Request.Response where Request: APIRequestType {
        guard let pathURL = URL(string: request.path, relativeTo: URL(string: baseURLString)) else {
            throw APIServiceError.invalidURL
        }
        
        var urlComponents = URLComponents(url: pathURL, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = request.queryItems
        var request = URLRequest(url: urlComponents.url!)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let decorder = JSONDecoder()
        decorder.keyDecodingStrategy = .convertFromSnakeCase
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw APIServiceError.responseError }
        do {
            return try decorder.decode(Request.Response.self, from: data)
        } catch {
            throw APIServiceError.parseError(error)
        }
    }
    
}
