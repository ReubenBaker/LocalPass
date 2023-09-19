//
//  AccountTestDataService.swift
//  LocalPass
//
//  Created by Reuben on 17/08/2023.
//

import Foundation

class AccountTestDataService {
    static let accounts: [Account] = [
        Account(name: "Apple", username: "apple@apple.com", password: "apple", url: "apple.com", otpSecret: "apple"),
        Account(name: "Google", username: "google@google.com", password: "google", url: "google.com", otpSecret: "google"),
        Account(name: "GitHub", username: "github@github.com", password: "github", url: "github.com", otpSecret: "github"),
        Account(name: "Stack Overflow", username: "stackoverflow@stackoverflow.com", password: "stackoverflow", url: "stackoverflow.com", otpSecret: "stackoverflow"),
        Account(name: "LeetCode", username: "leetcode@leetcode.com", password: "leetcode", url: "leetcode.com", otpSecret: "leetcode"),
        Account(name: "X", username: "x@x.com", password: "x", url: "x.com", otpSecret: "x"),
        Account(name: "Reddit", username: "reddit@reddit.com", password: "reddit", url: "reddit.com", otpSecret: "reddit"),
        Account(name: "Spotify", username: "spotify@spotify.com", password: "spotify", url: "spotify.com", otpSecret: "spotify"),
        Account(name: "Outlook", username: "outlook@outlook.com", password: "outlook", url: "outlook.com", otpSecret: "outlook"),
        Account(name: "Netflix", username: "netflix@netflix.com", password: "netflix", url: "netflix.com", otpSecret: "netflix"),
    ]
}
