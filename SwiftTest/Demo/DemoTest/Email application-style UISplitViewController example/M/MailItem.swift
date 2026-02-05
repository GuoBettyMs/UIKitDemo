//
//  MailItem.swift
//  SwiftTest
//
//  Created by user on 2026/2/5.
//
//数据模型

import Foundation

struct MailItem: Identifiable {
    let id: Int
    let title: String
    let subtitle: String
    let date: String
    var isUnread: Bool
}
