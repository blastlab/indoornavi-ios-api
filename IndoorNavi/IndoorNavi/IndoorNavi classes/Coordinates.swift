//
//  Coordinates.swift
//  IndoorNavi
//
//  Created by Michał Pastwa on 30.05.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import UIKit

public struct Coordinates {
    
    public var x: Int
    public var y: Int
    public var tagID: Int
    public var date: Date
    
    /**
     *  Initializes Coordinates structure.
     *
     *  - Parameters:
     *      - x: Short ID of the tag that entered or left given area.
     *      - y: Specifies when tag appeared in given area.
     *      - tagID: Area's ID.
     *      - date: Area's name.
     */
    public init(x: Int, y: Int, tagID: Int, date: Date) {
        self.x = x
        self.y = y
        self.tagID = tagID
        self.date = date
    }
}
