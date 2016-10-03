//
//  Item.swift
//  TVPlayer
//
//  Created by Madriz on 23/9/16.
//  Copyright © 2016 MMApps. All rights reserved.
//

import Foundation

enum ItemsType {
    case channel
    case category
    case program
    case episode
}


struct Item {
    let itemId: Double
    let itemContentPk: String?
    let itemDesc: String
    let itemTitle: String
    let itemType: ItemsType
    let itemImageURL: URL?
    let itemSubcategories: [(Double,String)]?
}
