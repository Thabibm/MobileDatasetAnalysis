//
//  MobileDataObject.swift
//  DataAnalysis
//
//  Created by Peer Mohamed Thabib on 12/27/18.
//  Copyright © 2018 Peer Mohamed Thabib. All rights reserved.
//

import UIKit
import RealmSwift



public protocol Persistable {
    associatedtype ManagedObject: RealmSwift.Object
    init(managedObject: ManagedObject)
    func managedObject() -> ManagedObject
}

final class QuaterlyDataObject: Object {
    @objc dynamic var id: Int8 = 0
    @objc dynamic var quarter = ""
    @objc dynamic var volumeData = ""
    @objc dynamic var hasConsumptionDecreased = false
}

final class MobileDataObject: Object {
    @objc dynamic var year = ""
    @objc dynamic var totalVolumeConsumed: Double = 0
    @objc dynamic var isVolumeDecreasedYear = false
    let quarterlyDataObjects = List<QuaterlyDataObject>()
}
