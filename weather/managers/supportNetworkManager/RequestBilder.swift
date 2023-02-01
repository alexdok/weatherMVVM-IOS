//
//  RequestBilder.swift
//  weather
//
//  Created by алексей ганзицкий on 01.02.2023.
//

import Foundation

protocol RequestBuilder {
    func createRequestFrom(url: String, params: [String: String]) -> URLRequest?
}

class RequestBuilderImpl: RequestBuilder {
    func createRequestFrom(url: String, params: [String: String]) -> URLRequest? {

        guard var url = URL(string: url) else { return nil }
        url = url.appendingQueryParameters(params)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
      
        return request
    }
}
