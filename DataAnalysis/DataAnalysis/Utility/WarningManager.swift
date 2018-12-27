//
//  WarningManager.swift
//  DataAnalysis
//
//  Created by Peer Mohamed Thabib on 12/27/18.
//  Copyright © 2018 Peer Mohamed Thabib. All rights reserved.
//

import UIKit

class WarningManager: NSObject {
    
    class func createAndPushWarning(message: String, cancel: String) {
        let alertControl = WarningManager.createAlertControl(message: message)
        alertControl.addAction(UIAlertAction(title: cancel, style: .default, handler: nil))
        self.displayAlertControl(alert: alertControl)
    }
    
    class func createAndPushWarning(message: String, buttons : [(title: String, callBack:(() -> Void)?)]?) {
        let alertControl = WarningManager.createAlertControl(message: message)
        if (buttons != nil) {
            for item in buttons! {
                alertControl.addAction(UIAlertAction(title: item.title, style: .default, handler: { (action) in
                    if (item.callBack != nil) {
                        item.callBack!()
                    }
                }))
            }
        }
        self.displayAlertControl(alert: alertControl)
    }
    
    //Mark: Private Methods
    
    private class func createAlertControl(message: String) -> UIAlertController {
        return UIAlertController.init(title: NSLocalizedString("DataAnalysis", comment: ""), message: message, preferredStyle: .alert)
    }
    
    private class func displayAlertControl(alert: UIAlertController) {
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated: true, completion: nil)
    }

}
