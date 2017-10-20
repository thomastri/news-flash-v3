//
//  Article.swift
//  NewsFlash
//
//  Created by Thomas Le on 9/24/17.
//  Copyright © 2017 Thomas Le. All rights reserved.
//
import Foundation
import ObjectMapper

class Article : Mappable {
    
    var summary : String = ""
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    // maps news API json to objects
    func mapping(map: Map) {
        summary <- map["sm_api_content"]
    }
}
