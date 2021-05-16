//
//  DKClient+Account.swift
//  DiscourseKit
//
//  Created by Tanner on 4/5/19.
//  Copyright © 2019 Tanner Bennett. All rights reserved.
//

import Foundation
import Networking
import Combine

public extension DKClient {
    private func login(_ username: String, _ password: String, completion: @escaping DKVoidableBlock) {
        self.get(from: .preAuth) { parser in
            guard self.callbackIfError(parser, completion) else { return }
            
            if let csrf = parser.JSONDictionary?["csrf"] as? String {
                // We got the token, now we actually log in
                self.csrf = csrf
                
                let params = ["login": username, "password": password]
                self.post(params, to: .login, callback: { parser in
                    completion(parser.error)
                })
            } else {
                // We didn't get the token
                completion(ResponseParser.error(
                    "Failed to get CSRF token for login",
                    code: parser.response?.statusCode ?? 1
                ))
            }
        }
    }
    
    func login(_ username: String, _ password: String) -> AnyPublisher<Void, Error> {
        Future { promise in
            self.login(username, password) { error in
                if let error = error { promise(.failure(error)) }
                else { promise(.success(())) }
            }
        }
        .eraseToAnyPublisher()
    }
}
