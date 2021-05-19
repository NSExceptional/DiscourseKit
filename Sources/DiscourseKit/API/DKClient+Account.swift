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
    func login(_ username: String, _ password: String) -> DKResponse<Void> {
        // We could use a tuple instead, but Swift won't let
        // you write a tuple with one element in it :(
        struct PreAuth { let csrf: String? }
        
        return self.get(from: .preAuth).tryMap { (preauth: PreAuth) in
            // Bail if we didn't get the CSRF token
            guard let csrf = preauth.csrf else {
                throw ResponseParser.error(
                    "Failed to get CSRF token for login",
                    code: 123 //parser.response?.statusCode ?? 1
                )
            }
            
            self.csrf = csrf
        }
        .mapError { return $0 as! DKError }
        .flatMap { _ -> DKResponse<Void> in
            let params = ["login": username, "password": password]
            return self.post(params, to: .login)
        }
        .eraseToAnyPublisher()
    }
}
