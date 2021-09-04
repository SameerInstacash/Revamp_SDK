//
//  DateTime.swift
//  InstaCashSDK
//
//  Created by Sameer Khan on 02/08/21.
//

import UIKit

func findTimeDiff(testLeftTimeStr: String, currentTimeStr: String) -> Int64 {
    
    let timeformatter = DateFormatter()
    timeformatter.dateFormat = "dd/MM/yyyy HH:mm"

    guard let time1 = timeformatter.date(from: testLeftTimeStr),
        let time2 = timeformatter.date(from: currentTimeStr) else { return 0 }

    //You can directly use from here if you have two dates

    let interval = time2.timeIntervalSince(time1)
    let hour = interval / 3600
    //let minute = interval.truncatingRemainder(dividingBy: 3600) / 60
    
    return Int64(hour)
}

func getCurrentTime() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd/MM/yyyy HH:mm"
    //let someDateTime = formatter.date(from: "2016/10/08 22:31")
    let currentTime = formatter.string(from: Date())
    return currentTime
}


