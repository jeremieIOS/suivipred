//
//  Rapport+CoreDataProperties.swift
//  
//
//  Created by Jeremie Chaine on 08/06/2017.
//
//

import Foundation
import CoreData


extension Rapport {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Rapport> {
        return NSFetchRequest<Rapport>(entityName: "Rapport")
    }

    @NSManaged public var coursb: Int16
    @NSManaged public var date: NSDate?
    @NSManaged public var duration: Int16
    @NSManaged public var publication: Int16
    @NSManaged public var video: Int16
    @NSManaged public var visite: Int16

}
