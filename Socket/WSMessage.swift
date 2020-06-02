//
//  WSMessage.swift
//  CCPSocket
//
//  Created by 123 on 2020/6/2.
//  Copyright © 2020 ccp. All rights reserved.
//


public enum SocketMessage {
    case kline(_ symbol: String, _ interval: String)
    case markets
    case market(_ symbol: String)
    case depth(_ symbol: String)
    case aggTrades(_ symbol: String)
}

extension SocketMessage {
    
    var stream: String {
        switch self {
        case let .kline(symbol, interval):
            return symbol + streamBase + interval
        case .markets:
            return streamBase
        case .market(let symbol), .depth(let symbol), .aggTrades(let symbol):
            return symbol + streamBase
        }
    }
    
    var streamBase: String {
        switch self {
        case .kline:
            return "@kline_"
        case .markets:
            return "!miniTicker@arr@3000ms"
        case .market:
            return "@miniTicker@1000ms"
        case .depth:
            return "@depth"
        case .aggTrades:
            return "@aggTrade"
            
        }
    }
    
    var subcribeInfo: String {
        return "{\"method\":\"SUBSCRIBE\",\"params\":[\"\(stream)\"],\"id\":1}"
    }
    
    var unsubcribeInfo: String {
        return "{\"method\":\"UNSUBSCRIBE\",\"params\":[\"\(stream)\"],\"id\":1}"
    }
    
}

extension SocketMessage: Hashable {}

