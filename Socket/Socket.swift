//
//  BCSocket.swift
//  CCPSocket
//
//  Created by 123 on 2020/6/2.
//  Copyright © 2020 ccp. All rights reserved.
//

import Starscream


public extension Socket {
    private static var ws: Socket?
    
    static func connect(_ url: String) {
        if ws == nil {
            ws = Socket(url)
        }
        ws?.connect()
    }
    
    static func add(_ subscriber: SocketSubscriberConvertible, for message: SocketMessage) {
        ws?.add(subscriber, for: message)
    }
    
    static func unsubscribe(_ message: SocketMessage) {
        ws?.unsubscribe(message)
    }
}

public class Socket {
    private var ws: WebSocket?
    private var isForceDisconnected = false
    lazy private var observersMap = [SocketMessage : NSHashTable<AnyObject>]()
    private var subscribedMessages = [SocketMessage]()
    private var isConnected = false
    
    init(_ url: String, timeout: TimeInterval = 10) {
        setWS(url, timeout)
    }
    
    private func request(_ url: String, _ timeout: TimeInterval) -> URLRequest? {
        guard let url = URL(string: url) else {
            return nil
        }
        return URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: timeout)
    }
    
    private func setWS(_ url: String, _ timeout: TimeInterval) {
        guard let request = request(url, timeout) else {
            return
        }
        ws = WebSocket(request: request, certPinner: FoundationSecurity(allowSelfSigned: true), compressionHandler: nil)
        ws?.delegate = self
    }
    
    func connect() {
        isForceDisconnected = false
        if isConnected { return }
        ws?.connect()
    }
    
    func add(_ subscriber: SocketSubscriberConvertible, for message: SocketMessage) {
        if !subscribedMessages.contains(message) {
            subcribe(message)
        }
        var newArray = NSHashTable<AnyObject>(options: .weakMemory)
        if let array = observersMap[message] {
            newArray = array
        }
        newArray.add(subscriber)
        observersMap[message] = newArray
    }
    
    func unsubscribe(_ message: SocketMessage) {
        guard let ws = ws else { return }
        ws.write(string: message.unsubcribeInfo, completion: nil)
        observersMap[message] = nil
    }

            
    private func disconnect() {
        isForceDisconnected = true
        ws?.disconnect()
    }
        
    private func subcribe(_ message: SocketMessage) {
        guard let ws = ws else { return }
        if isForceDisconnected { return }
        if !isConnected {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
                self?.subcribe(message)
            }
            return
        }
        ws.write(string: message.subcribeInfo, completion: nil)
        subscribedMessages.append(message)
    }
    
    private func handleMessage(_ text: String) {
        if !text.contains("stream") { return }
        unsubscribeIfNeed()
        guard
            let response = WSResolver.parse(text),
            let message = message(for: response.stream),
            let observers = observersMap[message]?.allObjects as? [SocketSubscriberConvertible]
        else {
            return
        }
        for observer in observers {
            observer.refresh(message: message, response: response.data)
        }        
    }
    
    private func message(for stream: String) -> SocketMessage? {
        for message in subscribedMessages {
            if message.stream == stream {
                return message
            }
        }
        return nil
    }
    
    private func unsubscribeIfNeed() {
        var newSubscribes = [SocketMessage]()
        for messge in subscribedMessages {
            if observersMap[messge] == nil {
                unsubscribe(messge)
                continue
            }
            if observersMap[messge]!.allObjects.isEmpty {
                unsubscribe(messge)
                continue
            }
            newSubscribes.append(messge)
        }
        subscribedMessages = newSubscribes
    }
}

extension Socket: WebSocketDelegate {
    public func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .cancelled:
            isConnected = false
            if isForceDisconnected { return }
            connect()
        case .connected:
            isConnected = true
        case .text(let text):
            handleMessage(text)
        case .disconnected, .error:
            isConnected = false
        default:
            break
        }
    }
}
