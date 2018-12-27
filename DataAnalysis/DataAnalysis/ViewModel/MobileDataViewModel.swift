//
//  MobileDataViewModel.swift
//  DataAnalysis
//
//  Created by Peer Mohamed Thabib on 12/27/18.
//  Copyright © 2018 Peer Mohamed Thabib. All rights reserved.
//

import Foundation

class MobileDataViewModel {
    
    let dataConsumptionService: DataConsumptionService!

    var dataset: Dataset?
    
    init(_ dataConsumptionService: DataConsumptionService = DataConsumptionService()) {
        self.dataConsumptionService = dataConsumptionService
    }
}
