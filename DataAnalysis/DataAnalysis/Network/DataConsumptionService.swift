//
//  DataConsumptionService.swift
//  DataAnalysis
//
//  Created by Peer Mohamed Thabib on 12/26/18.
//  Copyright © 2018 Peer Mohamed Thabib. All rights reserved.
//

import Foundation

public enum Result {
    case success(Dataset)
    case failure(String)
}


class DataConsumptionService {
    
    private var apiEndPoint = "https://data.gov.sg/api/action/datastore_search?resource_id=a807b7ab-6cad-4aa6-87d0-e283a7353a0f"
    
    func getDataConsumptionList(complete: @escaping (_ result: Result)->() ) {
        
        let url = URL(string: apiEndPoint)!
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30.0)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            DispatchQueue.main.async(execute: {
                if data == nil {
//                    print("Communication error from GET \(url) :\n\(error?.localizedDescription ?? "No data received")")
                    complete(Result.failure("Communication error from GET \(url) :\n\(error?.localizedDescription ??  "No data received")"))
                    return
                }
                                
                do {
                    let resultList = try JSONDecoder().decode(ResultList.self, from: data!)
//                    print("Results from GET \(url) :\n\(resultList.resultList)")
                    complete(Result.success(resultList.resultList))
                } catch {
//                    print("Unable to parse JSON response \(error)")
                    complete(Result.failure("Unable to parse JSON response \(error)"))
                }
            })
        }
        
        task.resume()
    }
}
