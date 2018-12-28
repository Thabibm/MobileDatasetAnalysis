//
//  MobileDataViewModel.swift
//  DataAnalysis
//
//  Created by Peer Mohamed Thabib on 12/27/18.
//  Copyright © 2018 Peer Mohamed Thabib. All rights reserved.
//

import Foundation
import RealmSwift

private let YEAR_LOWER_LIMIT = 2008
private let YEAR_UPPER_LIMIT = 2018

class MobileDataViewModel {
    
    let dataConsumptionService: DataConsumptionService!
    
    private var dataset: Results<MobileDataObject>?
    private var realm = try! Realm()
    
    var updateHandler: () -> Void = {}
    
    
    init(_ dataConsumptionService: DataConsumptionService = DataConsumptionService()) {
        self.dataConsumptionService = dataConsumptionService
    }
    
    
    func displayWarning(message: String) {
        WarningManager.createAndPushWarning(message: message, cancel: "OK")
    }
}


extension MobileDataViewModel {
    
    func loadMobileConsumptionData() {
        dataset = getSavedMobileData()
        if dataset?.count == 0 {
            fetchMobileDataConsumption()
            return
        }
        
        updateHandler()
    }
    
    
    func fetchMobileDataConsumption() {
        dataConsumptionService.getDataConsumptionList { (result) in
            switch result {
            case .success(let resultItems):
                self.clearCache()
                self.processResponseData(resultItems)
                break
                
            case .failure(let message):
                self.displayWarning(message: message)
                break
            }
            
            self.updateHandler()
        }
    }
    
    
    func processResponseData(_ dataSet: Dataset) {
        
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
                    cacheMobileDataObject(dataObject!)
                }
                
                lastYear = year
                dataObject = MobileDataObject()
                dataObject!.year = String(year)
            }
            
            dataObject!.totalVolumeConsumed = dataObject!.totalVolumeConsumed + Double(data.volumeData)!
            let quaterlyData = data.managedObject()
            quaterlyData.quarter = quaterName
            
            if dataObject?.quarterlyDataObjects.count != 0 {
                let previousQuaterData = dataObject?.quarterlyDataObjects.last
                if Double(previousQuaterData!.volumeData)! > Double(quaterlyData.volumeData)! {
                    dataObject!.isVolumeDecreasedYear = true
                    quaterlyData.hasConsumptionDecreased = true
                }
            }
            
            dataObject!.quarterlyDataObjects.append(quaterlyData)
        }
        
        if lastYear <= YEAR_UPPER_LIMIT {
            dataList.append(dataObject!)
            cacheMobileDataObject(dataObject!)
        }
        
        dataset = getSavedMobileData()
    }
    
    
    func cacheMobileDataObject(_ data: MobileDataObject) {
        try! realm.write {
            realm.add(data)
        }
    }
    
    
    func getSavedMobileData() -> Results<MobileDataObject> {
        return realm.objects(MobileDataObject.self)
    }
    
    
    func clearCache() {
        
        if dataset == nil || dataset?.count == 0 {
            return
        }
        
        for data in dataset! {
            try! realm.write {
                realm.delete(data)
            }
        }
    }
}
