//
//  Model.swift
//  DrapAndDrop
//
//  Created by Dave on 5/23/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import UIKit
import MobileCoreServices

struct Model {
    
    // Makes the setter for the var private, but the getter remains public
    //
    private(set) var planets: [String] = [
        "Mercury",
        "Venus",
        "Earth",
        "Mars",
        "Jupiter",
        "Saturn",
        "Uranus",
        "Neptune",
        "Pluto"
    ]
    
    // Model owns the data so it must make any manipulations
    // Mark this function with mutating for we can modify our data
    //
    mutating func moveItem(at startIndex: Int, to endIndex: Int) {
        if startIndex != endIndex {
            let planet = planets[startIndex]
            planets.remove(at: startIndex)
            planets.insert(planet, at: endIndex)
        }
    }
    
    // Add another planet to our data model
    //
    mutating func addPlanet(_ planet: String, at index: Int) {
        planets.insert(planet, at: index)
    }
    
    // Method for drag
    //
    func dragItem(for indexPath: IndexPath) -> [UIDragItem] {
        // We need to do 4 things in this method
        //  1. Determine what string is being copied (dragged)
        //  2. Convert the string to Data
        //  3. Place the data inside an NSItemProvider and mark it as a plain text string so other apps know what it is
        //  4. Place that item inside a UIDragItem so it can be used for drag and drop by UIKit
        let planet = planets[indexPath.row]
        guard let data = planet.data(using: .utf8) else { return [] }
        let itemProvider = NSItemProvider(item: data as NSData, typeIdentifier: kUTTypePlainText as String)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        return [dragItem]
    }
    
    // Method for drop
    //
    func canHandle(_ session: UIDropSession) -> Bool {
        // Only works with strings
        //
        return session.canLoadObjects(ofClass: NSString.self)
    }
}
