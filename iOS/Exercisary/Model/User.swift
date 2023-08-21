//
//  User.swift
//  Exercisary
//
//  Created by 유영재 on 2023/08/10.
//

import Foundation

struct UserInfo {
    var userId: String
    var userName: String
    var password: String
}

class User {
    var userInfo: UserInfo
    
    init(userInfo: UserInfo) {
        self.userInfo = userInfo
    }
}
