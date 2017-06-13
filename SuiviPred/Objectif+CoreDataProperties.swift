//
//  Objectif+CoreDataProperties.swift
//  
//
//  Created by Jeremie Chaine on 08/06/2017.
//
//

import Foundation
import CoreData


extension Objectif {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Objectif> {
        return NSFetchRequest<Objectif>(entityName: "Objectif")
    }

    @NSManaged public var hour: Int16
    @NSManaged public var month: NSDate?

}
