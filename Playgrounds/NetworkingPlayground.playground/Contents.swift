//: Networking Playground

import PlaygroundSupport
import ModernNetworking


public class API {
    
    private let loader: HTTPLoader
    
    public init(loader: HTTPLoader = URLSessionLoader()) {
        
        let modifier = ModifyRequestLoader { request in
            
            var copy = request
            
            copy.headers.updateValue("application/json; charset=utf-8", forKey: "Accept")
            
            if (copy.host ?? "").isEmpty {
                copy.host = "jsonplaceholder.typicode.com"
            }
            
            if copy.path.hasPrefix("/") == false {
                copy.path = "/api/v1" + copy.path
            }
            
            return copy
            
        }
        
        let resetGuard = ResetGuardLoader()
        let applyEnvironment = ApplyEnvironmentLoader(environment: .general)
        
        if let newLoader = resetGuard --> applyEnvironment --> modifier --> loader {
            self.loader = newLoader
        } else {
            self.loader = loader
        }
        
    }
    
    public func sendRequest(_ request: HTTPRequest) {
        
        loader.load(request) { (result) in
            result.decoding([ToDo].self, completion: { (result) in
                print(try? result.get())
            })
        }
        
    }
    
}

extension ServerEnvironment {
    
    public static let general = ServerEnvironment(host: "jsonplaceholder.typicode.com")
    
}

let api = API()

var r = HTTPRequest()
r.path = "/todos"

api.sendRequest(r)

