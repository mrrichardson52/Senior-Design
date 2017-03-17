//
//  DataResponse.swift
//  HexoskinBreathing
//
//  Created by Matthew Richardson on 1/26/17.
//  Copyright © 2017 Matthew Richardson. All rights reserved.
//

import UIKit

enum JSONParsingError: Error {
    case parsingError(String);
}

class DataResponse: NSObject {
    
    var returnedData: [String: [(Double, Double)]]!;
    
    init(json: Any) throws {
        let jsonArray = json as? [Any];
        if jsonArray == nil {
            throw JSONParsingError.parsingError("Parsing json as array resulted in error.");
        }
        let jsonDictionary = jsonArray?[0] as? [String: Any];
        if jsonDictionary == nil {
            throw JSONParsingError.parsingError("Creating dictionary from the json array resulted in error.");
        }
        let dataDictionary = jsonDictionary?["data"] as? [String: [Any]];
        if dataDictionary == nil {
            throw JSONParsingError.parsingError("Removing data dictionary from jsonDictionary resulted in error.");
        }
        
        returnedData = [:];
        let keys = dataDictionary?.keys;
        for key in keys! {
            // get array of tuples (each tuple is stored as an array in the json)
            let datapoints = (dataDictionary?[key])! as [Any];
            var datapointTuples = [(Double, Double)]();
            for datapoint in datapoints {
                let point = datapoint as? [Any];
                datapointTuples.append(((point?[0] as? Double)!, (point?[1] as? Double)!));
            }
            returnedData[key] = datapointTuples;
        }
    }
    
    static func convertTimestamp(stamp: Double) -> Date {
        return Date(timeIntervalSince1970: stamp/256);
    }
    
    func printData() {
        
        for key in returnedData.keys {
            
            // print out all the data for analysis
            print("Data points for key #\(key):");
            for tuple in returnedData[key]! {
//                var date = Date(timeIntervalSince1970: tuple.0/256);
                print("(\(tuple.0), \(tuple.1))");
            }
            print();
        }
        
    }

}
