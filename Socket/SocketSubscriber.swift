//
//  SocketSubscriber.swift
//  CCPSocket
//
//  Created by 123 on 2020/6/2.
//  Copyright © 2020 ccp. All rights reserved.
//

import UIKit


public protocol SocketSubscriberConvertible: AnyObject {
    func refresh(socket: Socket, message: SocketMessage, response: [String : Any])
}

public class SocketPoolSubscriber<T: Decodable>: SocketSubscriberConvertible {
      
    private let message: SocketMessage
    private var messageHandler: ((Socket, T) -> ())?
    
    public init(_ message: SocketMessage) {
        self.message = message
    }
    
    public func subcribe(_ url: String, messageHandler: @escaping (Socket, T) -> ()) {
        SocketPool.add(self, for: message, for: url)
        self.messageHandler = messageHandler
    }
    
    public func unscribe(_ url: String) {
        SocketPool.unsubscribe(message, for: url)
    }
    
    public func subcribe(_ socket: Socket, messageHandler: @escaping (Socket, T) -> ()) {
        SocketPool.add(self, for: message, for: socket)
        self.messageHandler = messageHandler
    }
    
    public func unscribe(_ socket: Socket) {
        SocketPool.unsubscribe(message, for: socket)
    }
    
    public func refresh(socket: Socket, message: SocketMessage, response: [String : Any]) {
        if message == self.message {
            guard let model = response.socketDecode(type: T.self) else {
                return
            }
            messageHandler?(socket, model)
        }
        
    }
}
