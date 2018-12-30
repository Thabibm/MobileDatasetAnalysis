//
//  MobileDataViewModel.swift
//  DataAnalysis
//
//  Created by Peer Mohamed Thabib on 12/27/18.
//  Copyright © 2018 Peer Mohamed Thabib. All rights reserved.
//

import Foundation
import RealmSwift

public let YEAR_LOWER_LIMIT = 2008
public let YEAR_UPPER_LIMIT = 2018

/*
 * MobileDataViewModel
 */

class MobileDataViewModel {
    
    // Public vatiables
    let dataConsumptionService: DataConsumptionService!
    var updateHandler: () -> Void = {} // Called when ever there is a change in view model
    
    // private variables
    private var dataset: Results<MobileDataObject>?
    private var realm: Realm!
    
    /*
     * Gets service class instance and realm instace as parameters
     * No arguments passed then default instance will be initialized
     */
    init(_ dataConsumptionService: DataConsumptionService = DataConsumptionService(), realm: Realm = try! Realm()) {
        self.dataConsumptionService = dataConsumptionService
        self.realm = realm
    }
    
    /*
     * Displays warning alert with message and cancel button title as OK
     */
    func displayWarning(message: String) {
        WarningManager.createAndPushWarning(message: message, cancel: "OK")
    }
}

//MARK: Data Presentation Methods

extension MobileDataViewModel {
    
    /*
     * Returns the data count if no data available then default returns 0
     */
    @objc func numberOfRowsToBeDisplayed() -> Int {
        return dataset?.count ?? 0
    }
    
    /*
     * Returns the mobile object model based on the given index
     */
    @objc func dataAtIndexPath(_ indexPath: IndexPath) -> MobileDataObject {
        return dataset![indexPath.row]
    }
    
    /*
     * Returns the double data as string with 2 decimal precision
     */
    func getVolumeDisplayString(_ totalVolume: Double) -> String {
        return String(format: "%.2f", totalVolume)
    }
    
    /*
     * Returns array of strings with 5 object count
     * Array Structure
     * [Q1 \n\n [data], Q2 \n\n [data], Q3 \n\n [data], Q4 \n\n [data], [Quater name] faced decrease in consumption!]
     * if quaterly data not availabel then "N/A" will be appended
     */
    func getQuaterlyDisplayData(_ mobileData: MobileDataObject) -> [String] {
        var displayData: [String] = [String]()
        var quaterDecreaseString = ""
        for index in 0...3 {
            let quaterName = "Q" + "\(index + 1)"
            let result = mobileData.quarterlyDataObjects.filter { $0.quarter.lowercased() == quaterName.lowercased() }
            let quaterlyResult = result.first
            var volumeDisplayString = "N/A"
                
            if quaterlyResult != nil {
                volumeDisplayString = getVolumeDisplayString(Double(quaterlyResult!.volumeData) ?? 0)
                
                if quaterlyResult!.hasConsumptionDecreased {
                    quaterDecreaseString = quaterlyResult!.quarter + " faced decrease in consumption!"
                }
            }
            
            displayData.append(quaterName + "\n\n" + volumeDisplayString)
        }
        
        displayData.append(quaterDecreaseString)
        return displayData
    }
}


//MARK: Data Cache Methods

extension MobileDataViewModel {
    
    /*
     * Loads data from realm if no data available then api request will be initiated
     */
    func loadMobileConsumptionData() {
        dataset = getSavedMobileData()
        if dataset?.count == 0 {
            fetchMobileDataConsumption()
            return
        }
        
        updateHandler()
    }
    
    /*
     * Api request
     */
    @objc func fetchMobileDataConsumption() {
        dataConsumptionService.getDataConsumptionList { [weak self] (result) in
            switch result {
            case .success(let resultItems):
                self?.clearCache()
                let dataList = self?.processResponseData(resultItems)
                self?.cacheMobileDataObjects(dataList!)
                self?.dataset = self?.getSavedMobileData()
                break
                
            case .failure(let message):
                self?.displayWarning(message: message)
                break
            }
            
            self?.updateHandler()
        }
    }
    
    /*
     * Process response struct and filter the data based on upper and lower Year limit
     * Converts struct to realm model object
     * Returns array of Realm model object
     */
    func processResponseData(_ dataSet: Dataset) -> [MobileDataObject] {
        
        var dataList: [MobileDataObject] = [MobileDataObject]()
        var lastYear = 0
        var dataObject: MobileDataObject? = nil
        
        for data in dataSet.mobileDataList {
            let yearDetailsArray = data.quarter.components(separatedBy: "-")
            let year = Int(yearDetailsArray[0]) ?? 0
            let quaterName = yearDetailsArray[1]
            
            if year < YEAR_LOWER_LIMIT {
                continue
            }
            
            if year > YEAR_UPPER_LIMIT {
                break
            }
            
            if lastYear != year {
                
                if lastYear <= YEAR_UPPER_LIMIT && dataObject != nil {
                    dataList.append(dataObject!)
                }
                
                lastYear = year
                dataObject = MobileDataObject()
                dataObject!.year = String(year)
            }
            
            dataObject!.totalVolumeConsumed = dataObject!.totalVolumeConsumed + Double(data.volumeData)!
            let quaterlyData = data.managedObject()
            quaterlyData.quarter = quaterName
            
            if dataObject!.quarterlyDataObjects.count != 0 {
                let previousQuaterData = dataObject?.quarterlyDataObjects.last
                if Double(previousQuaterData!.volumeData)! > Double(quaterlyData.volumeData)! {
                    dataObject!.isVolumeDecreasedYear = true
                    quaterlyData.hasConsumptionDecreased = true
                }
            }
            
            dataObject!.quarterlyDataObjects.append(quaterlyData)
        }
        
        if lastYear <= YEAR_UPPER_LIMIT && dataObject != nil {
            dataList.append(dataObject!)
        }
        
        
        return dataList
    }
    
    /*
     * Saves data in realm database
     */
    func cacheMobileDataObjects(_ dataList: [MobileDataObject]) {
        for data in dataList {
            try! realm.write {
                realm.add(data)
            }
        }
    }
    
    /*
     * Retrive data from realm database
     */
    func getSavedMobileData() -> Results<MobileDataObject> {
        return realm.objects(MobileDataObject.self)
    }
    
    /*
     * Delete all the data from realm database
     */
    func clearCache() {
        try! realm.write {
            realm.deleteAll()
        }
    }
}
