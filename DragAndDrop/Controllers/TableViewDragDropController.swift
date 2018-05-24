//
//  TableViewDragDropController.swift
//  DrapAndDrop
//
//  Created by Dave on 5/23/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import UIKit
import MobileCoreServices

class TableViewDragDropController: UITableViewController {
    
    var model = TableViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dropDelegate = self
        tableView.dragDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// DataSouce and delegate methods
//
extension TableViewDragDropController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.planets.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = model.planets[indexPath.row]
        return cell
     }
    
    // Allow rows to be moved. This is not part of drag or drop
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        model.moveItem(at: sourceIndexPath.row, to: destinationIndexPath.row)
    }
}

// Drag delegate
//
extension TableViewDragDropController: UITableViewDragDelegate {
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return model.dragItem(for: indexPath)
    }
}

// Drop Delegate
//
extension TableViewDragDropController: UITableViewDropDelegate {
    
    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        return model.canHandle(session)
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        if tableView.hasActiveDrag {
            if session.items.count > 1 {
                return UITableViewDropProposal(operation: .cancel)
            } else {
                // .move is only available for dragging within a single app
                //
                return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
            }
        } else {
            // Multi-tasking drag which allows more than one string to be added
            //
            return UITableViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        let destinationIndexPath: IndexPath
        
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            // Use the last indexPath of the TableView
            //
            let section = tableView.numberOfSections - 1
            let row = tableView.numberOfRows(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }
        
        coordinator.session.loadObjects(ofClass: NSString.self, completion: { items in
            if let stringItems = items as? [String] {
                var indexPaths = [IndexPath]()
                for (index, item) in stringItems.enumerated() {
                    let indexPath = IndexPath(row: destinationIndexPath.row + index, section: destinationIndexPath.section)
                    self.model.addPlanet(item, at: indexPath.row)
                    indexPaths.append(indexPath)
                }
                tableView.insertRows(at: indexPaths, with: .fade)
            }
        })
    }
}





















