//
//  TransversesFunctions.swift
//  SuiviPred
//
//  Created by Jeremie Chaine on 12/06/2017.
//  Copyright © 2017 Jeremie Chaine. All rights reserved.
//

import Foundation

class TransversesFunctions {
    
    let numberFormatter = NumberFormatter()
    
    func minutesToHoursMinutesFormatedLabel (minutes : Int) ->(String) {
        let hours = minutes/60
        let leftMinutes = minutes % 60
        numberFormatter.minimumIntegerDigits = 2
        numberFormatter.numberStyle = .decimal
        return self.numberFormatter.string(from: NSNumber(value: hours))! + "h" + self.numberFormatter.string(from: NSNumber(value: leftMinutes))!
    }


}
