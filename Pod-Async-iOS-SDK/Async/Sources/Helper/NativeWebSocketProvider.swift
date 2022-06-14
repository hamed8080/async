//
//  NativeWebSocketProvider.swift
//  FanapPodAsyncSDK
//
//  Created by Hamed Hosseini on 10/20/21.
//

import Foundation

@available(iOS 13.0, *)
class NativeWebSocketProvider : NSObject , WebSocketProvider , URLSessionDelegate , URLSessionWebSocketDelegate{
    
    weak var delegate                       : WebSocketProviderDelegate?
    private weak var socket                 : URLSessionWebSocketTask?  = nil
    private var timeout                     : TimeInterval!
    private var url                         : URL!
    private(set) var isConnected            : Bool                      = false
    private var logger                      : Logger
    
    init(url:URL,timeout:TimeInterval ,logger:Logger) {
        self.timeout        = timeout
        self.url            = url
        self.logger         = logger
        super.init()
    }
    
    // do not move create socket to init method because if you want to reconnect it never connect again
    public func connect() {
        let configuration                        = URLSessionConfiguration.default
        let urlSession                           = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue())
        var urlRequest                           = URLRequest(url: url,timeoutInterval: timeout)
        urlRequest.networkServiceType            = .responsiveData
        socket                                   = urlSession.webSocketTask(with: urlRequest)
        socket?.resume()
        readMessage()
    }
    
    func send(data: Data) {
        if isConnected{
            socket?.send(.data(data)) { [weak self] error in
                self?.handleError(error)
            }
            sendPing()
        }
    }
    
    func send(text: String) {
        if isConnected{
            socket?.send(.string(text)) { [weak self] error in
                self?.handleError(error)
            }
            sendPing()
        }
    }
    
    private func readMessage() {
        socket?.receive { [weak self] result in
            guard let self = self else{return}
            switch result {
            case .failure(_):
                break
            case .success(let message):
                switch message {
                case .data(let data):
                    self.delegate?.webSocketDidReciveData(self, didReceive: data)
                case .string(let string):
                    self.delegate?.webSocketDidReciveData(self, didReceive: string.data(using: .utf8)!)
                @unknown default:
                    self.logger.log(title:"un implemented case found in NativeWebSocketProvider")
                }
                self.readMessage()
            }
        }
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        isConnected = true
        delegate?.webSocketDidConnect(self)
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        if let reason = reason {
            logger.log(title: String(data: reason, encoding: .utf8) ?? "")
        }
        isConnected = false
    }
    
    ///never call delegate?.webSocketDidDisconnect in this method it leads to close next connection
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            handleError(error)
        }
    }
    
    func sendPing() {
        socket?.sendPing {[weak self] (error) in
            if let error = error {
                print("Sending PING failed: \(error)")
            }
            Timer.scheduledTimer(withTimeInterval: 10, repeats: true) {[weak self] timer in
                if let self = self{
                    self.sendPing()
                }else{
                    timer.invalidate()
                }
            }
        }
    }
    
    
    /// Force to close conection by Client
    func closeConnection() {
        socket?.cancel(with: .goingAway, reason: nil)
    }
    
    /// we need to check if error code is one of the 57 , 60 , 54 timeout no network and internet offline to notify delegate we disconnected from internet
    private func handleError(_ error:Error?){
        if let error = error as NSError?{
            if error.code == 57  || error.code == 60 || error.code == 54{
                isConnected = false
                closeConnection()
                delegate?.webSocketDidDisconnect(self, error)
            }else{
                delegate?.webSocketReceiveError(error)
            }
        }
    }
}
