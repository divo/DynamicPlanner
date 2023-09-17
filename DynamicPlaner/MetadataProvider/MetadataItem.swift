//
//  MetadataItem.swift
//  Markdown Planner
//
//  Created by Steven Diviney on 17/09/2023.
//

import UIKit

// MetadataItem is a wrapper of NSMetadataItem.
// When users rename an item, nsMetadataItem is the same, but the URL is different.
// Use url.path to implement Hashable and Equatable because only url.path is visible.
//
struct MetadataItem: Hashable {
    let nsMetadataItem: NSMetadataItem?
    let url: URL
    
    static func == (lhs: MetadataItem, rhs: MetadataItem) -> Bool {
        return lhs.url.path == rhs.url.path
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(url.path)
    }
}
