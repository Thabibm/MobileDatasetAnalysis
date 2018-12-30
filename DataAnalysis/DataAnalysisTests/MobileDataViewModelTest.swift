//
//  MobileDataViewModelTest.swift
//  DataAnalysisTests
//
//  Created by Peer Mohamed Thabib on 12/29/18.
//  Copyright © 2018 Peer Mohamed Thabib. All rights reserved.
//

import XCTest
import RealmSwift
@testable import DataAnalysis

class MockDataConsumptionService: DataConsumptionService {
    
    var complete: ((Result) -> ())!
    var dataItems: Dataset!
    var isItemsFetchCalled: Bool = false
    
    init(_ dataItems: Dataset) {
        self.dataItems = dataItems
    }
    
    override func getDataConsumptionList(complete: @escaping (Result) -> ()) {
        isItemsFetchCalled = true
        self.complete = complete
    }
    
    func fetchSuccess() {
        complete(Result.success(dataItems))
    }
    
    func fetchFailure() {
        complete(Result.failure("Invalid data"))
    }
}

class MockViewModel: MobileDataViewModel {
    
    var modelObjectList: [MobileDataObject]!
    var failureMessage: String!
    
    override func fetchMobileDataConsumption() {
        dataConsumptionService.getDataConsumptionList { [weak self] (result) in
            switch result {
            case .success(let resultItems):
                self?.failureMessage = ""
                self?.modelObjectList = self?.processResponseData(resultItems)
                break
                
            case .failure(let message):
                self?.failureMessage = message
                self?.modelObjectList = nil
                break
            }
            
            self?.updateHandler()
        }
    }
    
    override func numberOfRowsToBeDisplayed() -> Int {
        return modelObjectList?.count ?? 0
    }
    
    override func dataAtIndexPath(_ indexPath: IndexPath) -> MobileDataObject {
        return modelObjectList[indexPath.row]
    }
}

class MobileDataViewModelTest: XCTestCase {
    
    var dataset: Dictionary<String, Any>?
    var resultList: ResultList!
    var filteredDataSet: [MobileDataObject]!
    var mockDataConsumptionService: MockDataConsumptionService!
    var mockMobileDataViewModel: MockViewModel!
    var isReloadCalled = false
    var testRealm: Realm!

    //MARK: Unit test configuration methods
    
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
                        "volume_of_mobile_data": "0.012635",
                        "quarter": "2007-Q1",
                        "_id": 11
                    ],
                    [
                        "volume_of_mobile_data": "0.029992",
                        "quarter": "2007-Q2",
                        "_id": 12
                    ],
                    [
                        "volume_of_mobile_data": "0.053584",
                        "quarter": "2007-Q3",
                        "_id": 13
                    ],
                    [
                        "volume_of_mobile_data": "0.100934",
                        "quarter": "2007-Q4",
                        "_id": 14
                    ],
                    [
                        "volume_of_mobile_data": "0.171586",
                        "quarter": "2008-Q1",
                        "_id": 15
                    ],
                    [
                        "volume_of_mobile_data": "0.248899",
                        "quarter": "2008-Q2",
                        "_id": 16
                    ],
                    [
                        "volume_of_mobile_data": "0.439655",
                        "quarter": "2008-Q3",
                        "_id": 17
                    ],
                    [
                        "volume_of_mobile_data": "0.683579",
                        "quarter": "2008-Q4",
                        "_id": 18
                    ],
                    [
                        "volume_of_mobile_data": "1.066517",
                        "quarter": "2009-Q1",
                        "_id": 19
                    ],
                    [
                        "volume_of_mobile_data": "1.357248",
                        "quarter": "2009-Q2",
                        "_id": 20
                    ],
                    [
                        "volume_of_mobile_data": "1.695704",
                        "quarter": "2009-Q3",
                        "_id": 21
                    ],
                    [
                        "volume_of_mobile_data": "2.109516",
                        "quarter": "2009-Q4",
                        "_id": 22
                    ],
                    [
                        "volume_of_mobile_data": "2.3363",
                        "quarter": "2010-Q1",
                        "_id": 23
                    ],
                    [
                        "volume_of_mobile_data": "2.777817",
                        "quarter": "2010-Q2",
                        "_id": 24
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
        
        let datasetJSONData = try! JSONSerialization.data(withJSONObject: dataset!, options: .prettyPrinted)
        resultList = try! JSONDecoder().decode(ResultList.self, from: datasetJSONData)
        
        testRealm = try! Realm(
            configuration: Realm.Configuration(inMemoryIdentifier: "Test_DB")
        )
        mockDataConsumptionService = MockDataConsumptionService.init(resultList.resultList)
        mockMobileDataViewModel = MockViewModel.init(mockDataConsumptionService, realm: testRealm)
        
        mockMobileDataViewModel.updateHandler = {
            self.isReloadCalled = true
        }
    }

    override func tearDown() {
        
        mockMobileDataViewModel.clearCache()
        
        isReloadCalled = false
        mockDataConsumptionService.isItemsFetchCalled = false
        mockDataConsumptionService = nil
        mockMobileDataViewModel = nil
        dataset = nil
        resultList = nil
        
        super.tearDown()
    }
    
    //MARK: Test cases
    
    func testInit() {
        XCTAssertEqual(mockMobileDataViewModel.numberOfRowsToBeDisplayed(), 0)
    }
    
    func testDataFetchSuccess() {
        mockMobileDataViewModel.fetchMobileDataConsumption()
        mockDataConsumptionService.fetchSuccess()
        
        filteredDataSet = mockMobileDataViewModel.processResponseData(resultList.resultList)
        
        XCTAssertTrue(mockDataConsumptionService.isItemsFetchCalled)
        XCTAssertTrue(isReloadCalled)
        
        let mobileConsumptionData = mockMobileDataViewModel.dataAtIndexPath(IndexPath.init(row: 0, section: 0))
        XCTAssertEqual( mobileConsumptionData.year, filteredDataSet[0].year)
    }
    
    func testDataFetchFailure() {
        mockMobileDataViewModel.fetchMobileDataConsumption()
        mockDataConsumptionService.fetchFailure()
        
        XCTAssertGreaterThan(mockMobileDataViewModel.failureMessage.count, 0)
        XCTAssertTrue(isReloadCalled)
        XCTAssertEqual(mockMobileDataViewModel.numberOfRowsToBeDisplayed(), 0)
        XCTAssertNil(mockMobileDataViewModel.modelObjectList)
    }
    
    func testMobileConsumptionDataSource() {
        testDataFetchSuccess()
        
        var index = 0
        for consumptionData in filteredDataSet {
            let consumptionDataDetails = mockMobileDataViewModel.dataAtIndexPath(IndexPath.init(row: index, section: 0))
            XCTAssertEqual(consumptionData.year, consumptionDataDetails.year)
            XCTAssertEqual(consumptionData.totalVolumeConsumed, consumptionDataDetails.totalVolumeConsumed)
            XCTAssertEqual(consumptionData.isVolumeDecreasedYear, consumptionDataDetails.isVolumeDecreasedYear)
            
            XCTAssertGreaterThan(consumptionData.quarterlyDataObjects.count , 0)
            XCTAssertGreaterThan(consumptionDataDetails.quarterlyDataObjects.count , 0)
            
            var subIndex = 0
            for quaterlyData in consumptionData.quarterlyDataObjects {
                let quaterlyDataDetails = consumptionDataDetails.quarterlyDataObjects[subIndex]
                XCTAssertEqual(quaterlyData.quarter, quaterlyDataDetails.quarter)
                XCTAssertEqual(quaterlyData.hasConsumptionDecreased, quaterlyDataDetails.hasConsumptionDecreased)
                XCTAssertEqual(quaterlyData.id, quaterlyDataDetails.id)
                XCTAssertEqual(quaterlyData.volumeData, quaterlyDataDetails.volumeData)
                subIndex = subIndex + 1
            }
            
            index = index + 1
        }
    }
    
    func testDataProcessing() {
        testDataFetchSuccess()
        
        for data in filteredDataSet {
            XCTAssertGreaterThanOrEqual(Int(data.year)!, YEAR_LOWER_LIMIT)
            XCTAssertLessThanOrEqual(Int(data.year)!, YEAR_UPPER_LIMIT)
        }
        
        XCTAssertEqual(mockMobileDataViewModel.numberOfRowsToBeDisplayed(), 3)
        
        let quaterlyData = filteredDataSet!.first!.quarterlyDataObjects.first
        let volumeString = mockMobileDataViewModel.getVolumeDisplayString(Double(quaterlyData!.volumeData) ?? 0)
        if volumeString.contains(".") {
            let stringArray = volumeString.components(separatedBy: ".")
            let decimalPrecision = stringArray.last
            XCTAssertTrue(decimalPrecision!.count == 2)
        }
        
        XCTAssertEqual(mockMobileDataViewModel.getQuaterlyDisplayData(filteredDataSet[0]).count, 5)
    }
    
    //MARK: Realm test cases
    
    func testRealmSaveAndFetch() {
        testDataFetchSuccess()
        
        let existingCount = testRealm.objects(MobileDataObject.self).count
        XCTAssertEqual(existingCount, 0)
        
        mockMobileDataViewModel.cacheMobileDataObjects(filteredDataSet)
        XCTAssertEqual(testRealm.objects(MobileDataObject.self).count, 3)
    }
    
    func testRealmClearCache() {
        testRealmSaveAndFetch()
        
        mockMobileDataViewModel.clearCache()
        XCTAssertEqual(testRealm.objects(MobileDataObject.self).count, 0)
    }
}
