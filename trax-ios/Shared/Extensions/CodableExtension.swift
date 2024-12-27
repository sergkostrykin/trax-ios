//
//  CodableExtension.swift
//  trax-ios
//
//  Created by Sergiy Kostrykin on 23/12/2024.
//

import Foundation

extension Encodable {
    var jsonString: String? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return String(decoding: data, as: UTF8.self)
    }

    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else {
            return nil
        }
        
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }

    func encoded() -> Data? {
        return try? JSONEncoder().encode(self)
    }
}

extension Data {
    var jsonDictionary: [String: Any]? {
        return (try? JSONSerialization.jsonObject(with: self, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
    
    func decoded<T: Decodable>() -> T? {
        return try? JSONDecoder().decode(T.self, from: self)
    }
}

extension Dictionary {
    var json: Data? {
        try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
    }
}
