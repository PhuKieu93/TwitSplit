//
//  Utilities.swift
//  BaseProject
//
//  Created by Kieu Minh Phu on 2/22/18.
//  Copyright © 2018 Kieu Minh Phu. All rights reserved.
//

import UIKit
import SwiftyBeaver

let log = SwiftyBeaver.self

class Utilities: NSObject {
    
    class func configSwiftyLog() {
        let console = ConsoleDestination()  // log to Xcode Console
        let file = FileDestination()  // log to default swiftybeaver.log file
        console.format = "$DHH:mm:ss$d $l-$N-$F $C$L: $M '$X'"
        
        log.addDestination(console)
        log.addDestination(file)
    }
}



