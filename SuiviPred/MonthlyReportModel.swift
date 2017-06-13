//
//  MonthlyReportModel.swift
//  PredAppTor
//
//  Created by Jeremie Chaine on 04/04/2017.
//  Copyright © 2017 Jeremie Chaine. All rights reserved.
//

import Foundation

class MonthlyReportModel {
    
    var picto = ""
    var title = ""
    var value = 0
    
    init(picto: String, title : String, value : Int) {
        self.picto = picto
        self.title = title
        self.value = value
    }
}
