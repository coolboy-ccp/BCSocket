//
//  SocketSubscriber.swift
//  CCPSocket
//
//  Created by 123 on 2020/6/2.
//  Copyright © 2020 ccp. All rights reserved.
//

import UIKit

public protocol SocketSubscriberConvertible: AnyObject {
    func refresh(message: SocketMessage, response: [String : Any])
}

public class SocketSubscriber<T: Decodable>: SocketSubscriberConvertible {
  
    private let message: SocketMessage
    private var messageHandler: ((T) -> ())?
    
    public init(_ message: SocketMessage) {
        self.message = message
    }
    
    public func subcribe(messageHandler: @escaping (T) -> ()) {
        Socket.add(self, for: message)
        self.messageHandler = messageHandler
    }
    
    public func unscribe() {
        Socket.unsubscribe(message)
    }
    
    public func refresh(message: SocketMessage, response: [String : Any]) {
          if message == self.message {
              guard let model = response.socketDecode(type: T.self) else {
                  return
              }
              messageHandler?(model)
          }
      }
}
