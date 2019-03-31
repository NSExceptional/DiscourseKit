//
//  Data+Networking.swift
//  DiscourseKit
//
//  Created by Tanner on 3/31/19.
//  Copyright © 2019 Tanner Bennett. All rights reserved.
//

import Foundation

public extension Data {
    init(with boundary: String, key: String, forString value: String) {
        var boundaryData = Data()
        boundaryData.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".utf8Data)
        boundaryData.append("\r\n--\(boundary)\r\n".utf8Data)
        
        self = boundaryData
    }
    
    init(with boundary: String, key: String, forData value: Data) {
        var boundaryData = Data()
        boundaryData.append("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(key)\"\r\n".utf8Data)
        boundaryData.append("Content-Type: application/octet-stream\r\n\r\n".utf8Data)
        boundaryData.append(value)
        boundaryData.append("\r\n--\(boundary)\r\n".utf8Data)
        
        self = boundaryData
    }
}
