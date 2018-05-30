//
//  TimeIntervalExtension.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 30.05.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

extension TimeInterval {
    var miliseconds: Int64 {
        let splittedTimeInterval = modf(self)
        let miliseconds = 1000*Int64(splittedTimeInterval.0) + Int64(1000*splittedTimeInterval.1)
        return miliseconds
    }
}
