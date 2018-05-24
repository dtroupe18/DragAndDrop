//
//  CollectionViewModel.swift
//  DragAndDrop
//
//  Created by Dave on 5/24/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import UIKit
import MobileCoreServices

struct CollectionViewModel {
    
    // Makes the setter for the var private, but the getter remains public
    //
    private(set) var planets: [UIImage] = [
        #imageLiteral(resourceName: "Mercury"),
        #imageLiteral(resourceName: "Venus"),
        #imageLiteral(resourceName: "Earth"),
        #imageLiteral(resourceName: "Mars"),
        #imageLiteral(resourceName: "Jupiter"),
        #imageLiteral(resourceName: "Saturn"),
        #imageLiteral(resourceName: "Uranus"),
        #imageLiteral(resourceName: "Neptune"),
        #imageLiteral(resourceName: "Pluto"),
        #imageLiteral(resourceName: "Proxima Centauri b") // Proxima Centauri b
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
    mutating func addPlanet(_ planet: UIImage, at index: Int) {
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
        let planetImage = planets[indexPath.row]
        let itemProvider = NSItemProvider(object: planetImage)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        return [dragItem]
    }
    
    // Method for drop
    //
    func canHandle(_ session: UIDropSession) -> Bool {
        // Only works with strings
        //
        return session.canLoadObjects(ofClass: UIImage.self)
    }
}
