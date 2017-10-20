//
//  SummaryModel.swift
//  DailyFeed
//
//  Created by Thomas Le on 10/19/17.
//  Copyright © 2017 trianz. All rights reserved.
//

import Foundation
import ObjectMapper

class SummaryModel : Mappable {
    
    var summary : String = ""
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    // maps news API json to objects
    func mapping(map: Map) {
        summary <- map["sm_api_content"]
    }
    
}
