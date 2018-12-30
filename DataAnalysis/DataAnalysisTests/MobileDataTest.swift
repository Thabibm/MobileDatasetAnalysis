//
//  MobileDataTest.swift
//  DataAnalysisTests
//
//  Created by Peer Mohamed Thabib on 12/29/18.
//  Copyright © 2018 Peer Mohamed Thabib. All rights reserved.
//

import UIKit
@testable import DataAnalysis

import XCTest

class MobileDataTest: XCTestCase {
    
    var dataset: Dictionary<String, Any>?

    override func setUp() {
        super.setUp()
            
        dataset = [
            "help": "https://data.gov.sg/api/3/action/help_show?name=datastore_search",
            "success": true,
            "result": [
                "resource_id": "a807b7ab-6cad-4aa6-87d0-e283a7353a0f",
                "fields": [
                    [
                        "type": "int4",
                        "id": "_id"
                    ],
                    [
                        "type": "text",
                        "id": "quarter"
                    ],
                    [
                        "type": "numeric",
                        "id": "volume_of_mobile_data"
                    ]
                ],
                "records": [
                    [
                        "volume_of_mobile_data": "0.000384",
                        "quarter": "2004-Q3",
                        "_id": 1
                    ],
                    [
                        "volume_of_mobile_data": "0.000543",
                        "quarter": "2004-Q4",
                        "_id": 2
                    ],
                    [
                        "volume_of_mobile_data": "0.00062",
                        "quarter": "2005-Q1",
                        "_id": 3
                    ],
                    [
                        "volume_of_mobile_data": "0.000634",
                        "quarter": "2005-Q2",
                        "_id": 4
                    ],
                    [
                        "volume_of_mobile_data": "0.000718",
                        "quarter": "2005-Q3",
                        "_id": 5
                    ]
                ],
                "_links": [
                    "start": "/api/action/datastore_search?limit=5&resource_id=a807b7ab-6cad-4aa6-87d0-e283a7353a0f",
                    "next": "/api/action/datastore_search?offset=5&limit=5&resource_id=a807b7ab-6cad-4aa6-87d0-e283a7353a0f"
                ],
                "total": 56,
                "limit": 5
            ]
        ]
    }

    override func tearDown() {
        dataset = nil
        super.tearDown()
    }

    func testModelData() {
        let datasetJSONData = try! JSONSerialization.data(withJSONObject: dataset!, options: .prettyPrinted)
        let datasetItems = try! JSONDecoder().decode(ResultList.self, from: datasetJSONData)
        XCTAssertEqual(datasetItems.resultList.mobileDataList.count, 5)
        
        var i = 0
        let records = dataset!["result"] as! [String : Any]
        for data in records["records"] as! [[String : Any]] {
            let quaterlyData = datasetItems.resultList.mobileDataList[i]
            XCTAssertEqual(quaterlyData.id, Int8(Int(data["_id"] as! Int)))
            XCTAssertEqual(quaterlyData.volumeData, data["volume_of_mobile_data"] as! String)
            XCTAssertEqual(quaterlyData.quarter, data["quarter"] as! String)
            i = i+1
        }
    }
        

}
