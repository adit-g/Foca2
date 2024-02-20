//
//  TileImage+CoreDataProperties.swift
//  Foca2
//
//  Created by Adit G on 2/16/24.
//
//

import Foundation
import CoreData


extension TileImage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TileImage> {
        return NSFetchRequest<TileImage>(entityName: "TileImage")
    }

    @NSManaged public var storedImage: Data?
    @NSManaged public var date: Date?

    public var wrappedDate: Date {
        date ?? Date()
    }
    
}

extension TileImage : Identifiable {

}
