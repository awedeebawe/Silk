import Foundation

public class ChainedRequest: CompoundRequest {
    private var requests = [HttpRequest]()
    private var requestIndex = 0
    
    override public func add(request: HttpRequest) -> Self {
        super.add(request)
        requests.append(request)
        return self
    }
    
    public func then(request: HttpRequest) -> Self {
        add(request)
        return self
    }
    
    private func executeNext() {
        if requestIndex < requests.count {
            let request = requests[requestIndex]
            let originalSuccessClosure = request.successClosure
            let originalErrorClosure = request.errorClosure
            
            request.completion({ [weak self] body, data, response, context in
                if let weakSelf = self {
                    originalSuccessClosure?(body: body, data: data, response: response, request: weakSelf)
                    weakSelf.requestIndex++
                    weakSelf.executeNext()
                }
            }, error: { [weak self] error, body, data, response, context in
                if let weakSelf = self {
                    originalErrorClosure?(error: error, body: body, data: data, response: response, request: weakSelf)
                    if weakSelf.ignoreErrors {
                        weakSelf.requestIndex++
                        weakSelf.executeNext()
                    } else {
                        weakSelf.errorClosure?(error: error, body: body, data: data, response: response, request: weakSelf)
                        weakSelf.manager.unregisterRequest(weakSelf)
                        weakSelf.requests.removeAll(keepCapacity: false)
                    }
                }
            }).execute()
        } else {
            successClosure?(body: "", data: NSData(), response: NSURLResponse(), request: self)
            manager.unregisterRequest(self)
        }
    }
    
    override public func execute() -> Bool {
        if !super.execute() {
            return false
        }
        
        executeNext()
        
        manager.registerRequest(self)
        return true
    }
    
    override public func cancel() {
        for request in requests {
            request.cancel()
        }
        super.cancel()
    }
}