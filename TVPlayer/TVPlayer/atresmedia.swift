//
//  atresmedia.swift
//  TVPlayer
//
//  Created by Madriz on 19/9/16.
//  Copyright © 2016 MMApps. All rights reserved.
//

import Foundation

struct atresmedia {
    
    func getCategories (items: @escaping ([Item]?) -> Swift.Void) {
        
        var allItems = [Item]()
        
        if let url = URL(string: "https://servicios.atresplayer.com/api/mainMenu") {
            let session = URLSession(configuration: URLSessionConfiguration.default).synchronousDataTaskWithURL(url: url)
            if let data = session.0 {
                
                if let json = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String: AnyObject]],
                    let dic = json.first,
                    let menuItems = dic["menuItems"] as? [[String: AnyObject]] {
                    
                    menuItems.forEach({ (menuItem) in
                        if let _itemId = menuItem["idSection"] as? Double,
                            let _itemTitle = menuItem["title"] as? String,
                            let _itemImageURL = menuItem["urlImage"] as? String {
                            
                            let str = _itemImageURL.replacingOccurrences(of: ".jpg", with: "04.jpg")
                            let url = URL(string: str)
                            
                            
                            let item = Item(itemId: _itemId, itemContentPk: nil, itemDesc: "", itemTitle: _itemTitle, itemType: .category, itemImageURL: url, itemSubcategories: nil)
                            allItems.append(item)
                        
                        }
                    })
                }
            }
        }
        items(allItems)
    }
    
    func getProgrammesForItem (item: Item, items: @escaping ([Item]?) -> Swift.Void) {
        
        var allItems = [Item]()
        
        if let url = URL(string: "https://servicios.atresplayer.com/api/categorySections/\(item.itemId)") {
            let session = URLSession(configuration: URLSessionConfiguration.default).synchronousDataTaskWithURL(url: url)
            if let data = session.0 {
                
                if let json = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String: AnyObject]] {
                    
                    json.forEach({ (sections) in
                        if let section = sections["section"] as? [String: AnyObject],
                            let _itemId = section["idSection"] as? Double,
                            let _itemTitle = section["title"] as? String,
                            let _itemImageURL = section["urlImage"] as? String,
                            let _itemDesc = section["storyline"] as? String,
                            let _subcategories = section["subCategories"] as? [[String: AnyObject]]{
                        
                            let str = _itemImageURL.replacingOccurrences(of: ".jpg", with: "04.jpg")
                            let url = URL(string: str)
                            
                            var subcategories = [(Double, String)]()
                            
                            _subcategories.forEach({ (subcategory) in
                                if let _name = subcategory["name"] as? String,
                                let _idSection = subcategory["idSection"] as? Double {
                                    subcategories.append((_idSection, _name))
                                }
                            })
                            
                            
                            let item = Item(itemId: _itemId, itemContentPk: nil, itemDesc: _itemDesc, itemTitle: _itemTitle, itemType: .program, itemImageURL: url, itemSubcategories: subcategories)
                            allItems.append(item)
  
                        }
                    })
                }
            }
        }
        items(allItems)
    }

    func getEpisodesForItem (item: Item, items: @escaping ([Item]?) -> Swift.Void) {
        
        var allItems = [Item]()
        
        if let subcategories = item.itemSubcategories {
            subcategories.forEach({ (subcategory) in
                if let url = URL(string: "https://servicios.atresplayer.com/api/episodes/\(subcategory.0)") {
                    let session = URLSession(configuration: URLSessionConfiguration.default).synchronousDataTaskWithURL(url: url)
                    if let data = session.0 {
                        
                        if let json = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject],
                            let episodes = json["episodes"] as? [[String: AnyObject]]{
                            
                            episodes.forEach({ (_episode) in
                                if let episode = _episode["episode"] as? [String: AnyObject],
                                    let type = episode["type"] as? String,
                                    let _itemId = episode["sectionId"] as? Double,
                                    let _itemTitle = episode["name"] as? String,
                                    let _itemImageURL = episode["urlImage"] as? String,
                                    let _itemContentPk = episode["contentPk"] as? String,
                                    let _itemDesc = episode["storyline"] as? String,
                                    type == "FREE"{
                                    
                                    let str = _itemImageURL.replacingOccurrences(of: ".jpg", with: "04.jpg")
                                    let url = URL(string: str)
                                    
                                    let item = Item(itemId: _itemId, itemContentPk: _itemContentPk, itemDesc: _itemDesc, itemTitle: _itemTitle, itemType: .episode, itemImageURL: url, itemSubcategories: nil)
                                    allItems.append(item)
                                    
                                }
                            })
                        }
                    }
                }
            })
        }
        
        
        items(allItems)
    }
    
    func getEpisodeDetailsForItem (item: Item, path: @escaping (String?) -> Swift.Void) {
        
        guard let episode = item.itemContentPk else { return }
        
        let token = d(episode, s1: "QWtMLXs414Yo+c#_+Q#K@NN)")
        
        let strURL = "https://servicios.atresplayer.com/api/urlVideo/\(episode)/android_phone/\(token)"
        let escapedString = strURL.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
        
        if let url = URL(string: escapedString!) {
            
            let session = URLSession(configuration: URLSessionConfiguration.default).synchronousDataTaskWithURL(url: url)
            if let data = session.0 {
                if let b = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary {
                    if b["resultDes"] as? String ?? "KO" == "OK" {
                        let stURL = b.value(forKeyPath: "resultObject.es") as? String
                        path(stURL)
                    }
                }
            }
        }
        
    }
}

extension atresmedia {
    func getApiTime () -> Int {
        if let url = URL(string: "https://servicios.atresplayer.com/api/admin/time") {
            let session = URLSession(configuration: URLSessionConfiguration.default).synchronousDataTaskWithURL(url: url)
            if let data = session.0 {
                
                if let b = String(data: data, encoding: String.Encoding.utf8), let rdo = CLong(b) {
                    return rdo / 1000
                }
            }
        }
        
        return -1
        
    }
    
    func d(_ s: String, s1: String) -> String {
        let l = 30000 + getApiTime()
        let s2 = e(s+String(l), s1: s1)
        return String("\(s)|\(String(l))|\(s2)")
    }
    
    func e(_ s: String, s1: String) -> String {
        let a = s.md5(s1)
        return hexdigest(a)
    }
    
    fileprivate func hexdigest(_ data: Data) -> String {
        var hex = String()
        let bytes = (data as NSData).bytes.bindMemory(to: CUnsignedChar.self, capacity: data.count)
        for i: Int in 0 ..< data.count {
            hex += String(format: "%02x", bytes[i])
        }
        return hex
    }
}

