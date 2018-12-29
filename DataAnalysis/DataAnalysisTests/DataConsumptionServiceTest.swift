//
//  DataConsumptionServiceTest.swift
//  DataAnalysisTests
//
//  Created by Peer Mohamed Thabib on 12/29/18.
//  Copyright © 2018 Peer Mohamed Thabib. All rights reserved.
//

import XCTest
@testable import DataAnalysis

class DataConsumptionServiceTest: XCTestCase {
    
    var dataConsumptionService: DataConsumptionService?

    override func setUp() {
        super.setUp()
        dataConsumptionService = DataConsumptionService()
    }

    override func tearDown() {
        super.tearDown()
        dataConsumptionService = nil
    }

    func testDataConsumptionFetch() {
        let apiService = dataConsumptionService

        let expect = XCTestExpectation(description: "callback")
        apiService!.getDataConsumptionList(complete: { (result) in
            expect.fulfill()
            if case .success(let responseItems) = result {
                XCTAssertTrue(responseItems.mobileDataList.count > 0)
            } else {
                XCTFail("Invalid response")
            }
        })
        wait(for: [expect], timeout: 3.1)
    }

}
