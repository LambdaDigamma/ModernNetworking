//
//  URLSessionLoader.swift
//
//
//  Created by Lennart Fischer on 06.01.21.
//

import Foundation

public protocol URLSessioning: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessioning {}

public final class URLSessionLoader: HTTPLoader {

    public init(_ session: URLSession = .shared) {
        self.session = session
    }

    public init(session: any URLSessioning) {
        self.session = session
    }
    private let session: any URLSessioning

    public override func load(_ request: HTTPRequest) async -> HTTPResult {
        let urlRequest: URLRequest
        do {
            urlRequest = try makeURLRequest(from: request)
        } catch let error as HTTPError {
            return .failure(error)
        } catch {
            return .failure(HTTPError(.invalidRequest(.invalidBody), request, nil, error))
        }

        do {
            let (data, response) = try await session.data(for: urlRequest)
            guard let httpURLResponse = response as? HTTPURLResponse else {
                return .failure(HTTPError(.invalidResponse, request))
            }

            return .success(HTTPResponse(request, httpURLResponse, data))
        } catch is CancellationError {
            return .failure(HTTPError(.cancelled, request))
        } catch let error as URLError {
            return .failure(HTTPError(mapErrorCode(error), request, nil, error))
        } catch {
            return .failure(HTTPError(.unknown, request, nil, error))
        }
    }

    private func makeURLRequest(from request: HTTPRequest) throws -> URLRequest {
        guard let url = request.url else {
            throw HTTPError(.invalidRequest(.invalidURL), request)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.name
        urlRequest.cachePolicy = request.cachePolicy

        for (header, value) in request.headers {
            urlRequest.addValue(value, forHTTPHeaderField: header)
        }

        if request.body.isEmpty == false {
            for (header, value) in request.body.additionalHeaders {
                urlRequest.addValue(value, forHTTPHeaderField: header)
            }

            urlRequest.httpBody = try request.body.encode()
        }

        return urlRequest
    }

    private func mapErrorCode(_ error: URLError) -> HTTPError.Code {
        switch error.code {
            case .badURL:
                return .invalidRequest(.invalidURL)
            case .cancelled:
                return .cancelled
            case .secureConnectionFailed, .serverCertificateHasBadDate, .serverCertificateUntrusted, .serverCertificateHasUnknownRoot, .serverCertificateNotYetValid, .clientCertificateRejected, .clientCertificateRequired:
                return .insecureConnection
            case .cannotConnectToHost, .cannotFindHost, .networkConnectionLost, .notConnectedToInternet, .timedOut, .dnsLookupFailed, .resourceUnavailable:
                return .cannotConnect
            default:
                return .unknown
        }
    }

}
