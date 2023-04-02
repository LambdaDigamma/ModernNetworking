//
//  HTTPResult.swift
//
//
//  Created by Lennart Fischer on 06.01.21.
//

import Foundation

public extension HTTPResult {
    
    func decoding<M: Model>(_ model: M.Type, completion: @escaping (Result<M, HTTPError>) -> Void) {
        
        DispatchQueue.global().async {
            
            let result = self.flatMap { response -> Result<M, HTTPError> in
                
                guard let data = response.body else {
                    return .failure(HTTPError(.invalidResponse, request, response, nil))
                }
                
                do {
                    let decoder = M.decoder
                    let model = try decoder.decode(M.self, from: data)
                    return .success(model)
                } catch let error as DecodingError {
                    
                    if #available(iOS 14.0, *) {
                        Logging.logger.info("Decoding failed: \(error.localizedDescription, privacy: .public) \(error.errorDescription ?? "", privacy: .public) \(error.failureReason ?? "", privacy: .public)")
                        Logging.logger.info("")
                        print(error)
                        print(error.failureReason ?? "")
                    }
                    
                    let error = HTTPError(.decodingError, request, response, error)
                    return .failure(error)
                    
                } catch {
                    return .failure(HTTPError(.unknown, request, response, error))
                }
            }
            
            DispatchQueue.main.async {
                completion(result)
            }
            
        }
        
    }
    
    func decoding<M: Model>(_ model: M.Type) async throws -> M {
        
        guard let data = response?.body else {
            throw HTTPError(.invalidResponse, request, response, nil)
        }
        
        do {
            
            let decoder = M.decoder
            let model = try decoder.decode(M.self, from: data)
            
            return model
            
        } catch let error as DecodingError {
            
            if #available(iOS 14.0, *) {
                Logging.logger.info("Decoding failed: \(error.localizedDescription, privacy: .public) \(error.errorDescription ?? "", privacy: .public) \(error.failureReason ?? "", privacy: .public)")
                Logging.logger.info("")
                print(error)
                print(error.failureReason ?? "")
            }
            
            throw HTTPError(.decodingError, request, response, error)
            
        } catch {
            throw HTTPError(.unknown, request, response, error)
        }
        
    }
    
}
