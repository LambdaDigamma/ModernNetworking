//
//  ResetGuardLoader.swift
//
//
//  Created by Lennart Fischer on 06.01.21.
//

import Dispatch


public class ResetGuardLoader: HTTPLoader {

    private var isResetting = SynchronizedBarrier(false)
    
    public override func load(_ request: HTTPRequest, completion: @escaping HTTPResultHandler) {

        if isResetting.value == false {
            super.load(request, completion: completion)
        } else {
            let error = HTTPError(.resetInProgress, request)
            completion(.failure(error))
        }

    }

    public override func reset(with group: DispatchGroup) {

        if isResetting.value == true { return }
        guard let next = nextLoader else { return }

        group.enter()
        isResetting.value { $0 = true }
        next.reset {
            self.isResetting.value { $0 = false }
            group.leave()
        }

    }

    public override func load(_ request: HTTPRequest) async -> HTTPResult {
        
        if isResetting.value == false {
            return await super.load(request)
        } else {
            let error = HTTPError(.resetInProgress, request)
            return .failure(error)
        }
        
    }
    
}
