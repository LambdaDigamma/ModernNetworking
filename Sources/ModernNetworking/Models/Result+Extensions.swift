//
//  Result+Extensions.swift
//  24doors
//
//  Created by Lennart Fischer on 19.07.20.
//  Copyright © 2020 LambdaDigamma. All rights reserved.
//

import Foundation


public extension HTTPResult {
    
    func decoding<M: Model>(_ model: M.Type, completion: @escaping (Result<M, HTTPError>) -> Void) {
        
        DispatchQueue.global().async {
            
            let result = self.flatMap { response -> Result<M, HTTPError> in
                
                guard let data = response.body else {
                    return .failure(HTTPError(code: .invalidResponse, request: request, response: response, underlyingError: nil))
                }
                
                do {
                    let decoder = M.decoder
                    let model = try decoder.decode(M.self, from: data)
                    return .success(model)
                } catch let e as DecodingError {
                    
                    let error = HTTPError(code: .decodingError, request: request, response: response, underlyingError: e)
                    
                    return .failure(error)
                    
                } catch {
                    return .failure(HTTPError(code: .unknown, request: request, response: response, underlyingError: error))
                }
            }
            
            DispatchQueue.main.async {
                completion(result)
            }
            
        }
        
    }
    
}
