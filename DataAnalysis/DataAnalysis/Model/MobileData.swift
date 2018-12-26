//
//  DataModel.swift
//  DataAnalysis
//
//  Created by Peer Mohamed Thabib on 12/26/18.
//  Copyright © 2018 Peer Mohamed Thabib. All rights reserved.
//

import Foundation
import UIKit

struct ResultList: Codable {
    var dataset: Dataset
    
    enum CodingKeys: String, CodingKey {
        case dataset = "result"
    }
}

struct Dataset: Codable {
    var mobileDataList: [MobileData]
    
    enum CodingKeys: String, CodingKey {
        case mobileDataList = "records"
    }
}

struct MobileData: Codable {
    var id: Int8
    var quarter: String
    var volumeData: Double
    
    enum CodingKeys: String, CodingKey {
        case volumeData = "volume_of_mobile_data", id = "_id", quarter = "quarter"
    }
    
}
