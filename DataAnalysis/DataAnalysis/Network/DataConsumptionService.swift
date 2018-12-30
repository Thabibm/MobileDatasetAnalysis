//
//  DataConsumptionService.swift
//  DataAnalysis
//
//  Created by Peer Mohamed Thabib on 12/26/18.
//  Copyright © 2018 Peer Mohamed Thabib. All rights reserved.
//

import Foundation

/*
 * Enum type to return success and failure of API response
 */
public enum Result {
    case success(Dataset)
    case failure(String)
}

/*
 * API call on success convert the data in to struct model returns the result
 */
class DataConsumptionService {
    
    private var apiEndPoint = "https://data.gov.sg/api/action/datastore_search?resource_id=a807b7ab-6cad-4aa6-87d0-e283a7353a0f"
    
    func getDataConsumptionList(complete: @escaping (_ result: Result)->() ) {
        
        let url = URL(string: apiEndPoint)!
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30.0)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            DispatchQueue.main.async(execute: {
                if data == nil {
                    complete(Result.failure("Communication error from GET \(url) :\n\(error?.localizedDescription ??  "No data received")"))
                    return
                }
                                
                do {
                    let resultList = try JSONDecoder().decode(ResultList.self, from: data!)
                    complete(Result.success(resultList.resultList))
                } catch {
                    complete(Result.failure("Unable to parse JSON response \(error)"))
                }
            })
        }
        
        task.resume()
    }
}
