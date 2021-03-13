//
//  PrintLoader.swift
//
//
//  Created by Lennart Fischer on 06.01.21.
//

import Foundation


public class PrintLoader: HTTPLoader {
    
    public override func load(_ request: HTTPRequest, completion: @escaping HTTPResultHandler) {
        
        print("Loading \(request)")
        super.load(request, completion: { result in
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
            
            completion(result)
        })
        
    }
    
}
