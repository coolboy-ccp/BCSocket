//
//  WSResolver.swift
//  CCPSocket
//
//  Created by 123 on 2020/6/1.
//  Copyright © 2020 ccp. All rights reserved.
//

import UIKit

struct WSResponse {
    let stream: String
    let data: [String : Any]
}

class WSResolver {
    static func parse(_ msg: String) -> WSResponse? {
        guard
            let dic = msg.dictionary(),
            let stream = dic["stream"] as? String,
            let data = dic["data"] as? [String : Any]
        else
        {
            return nil
        }
        return WSResponse(stream: stream, data: data)
    }
}

fileprivate extension String {
    func dictionary() -> [String : Any]? {
        guard let data = data(using: .utf8) else {
            return nil
        }
        do {
            if let dic = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String : Any] {
                return dic
            }
        } catch {}
        
        return nil
    }
}

public extension Dictionary where Key == String {
    
    /// Decode data with special type
    /// - Parameter type: The result type
    /// - Returns: A 'type' model if decode successfully
    func socketDecode<T: Decodable>(type: T.Type) -> T? {
        do {
            let data = try JSONSerialization.data(withJSONObject: self, options: [])
            return try JSONDecoder().decode(type, from: data)
        } catch {
            return nil
        }
    }
}
 
