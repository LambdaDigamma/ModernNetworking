//
//  PrintLoader.swift
//
//
//  Created by Lennart Fischer on 06.01.21.
//

import Foundation


public class PrintLoader: HTTPLoader {
    
#if DEBUG
    private let enabled: Bool = false
#else
    private let enabled: Bool = false
#endif
    
    public override func load(_ request: HTTPRequest, completion: @escaping HTTPResultHandler) {
        
        if self.enabled {
            print("Loading \(request)")
        }
            
        super.load(request, completion: { result in
            
            if self.enabled {
                
                print("Loaded: \(request)")
                print("Reeceived result: \(result)")
                switch result {
                    case .success(let response):
                        guard let data = response.body else { return }
                        print(String(decoding: data, as: UTF8.self))
                    case .failure(let error):
                        print("Failed with error:")
                        print(error)
                        print(error.underlyingError ?? "")
                }
                
            }
                
            completion(result)
        })
        
    }
    
    public override func load(_ request: HTTPRequest) async -> HTTPResult {
        
        if self.enabled {
            print("Loading \(request)")
        }
        
        let result = await super.load(request)
        
        if self.enabled {
            
            print("Loaded: \(request)")
            print("Received result: \(result)")
            
            switch result {
                case .success(let response):
                    guard let data = response.body else { break }
                    print(String(decoding: data, as: UTF8.self))
                case .failure(let error):
                    print("Failed with error:")
                    print(error)
                    print(error.underlyingError ?? "")
            }
            
        }
            
        return result
    }
    
}
