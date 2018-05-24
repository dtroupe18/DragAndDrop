//
//  CollectionViewController.swift
//  DragAndDrop
//
//  Created by Dave on 5/24/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import UIKit
import MobileCoreServices

class CollectionDragDropViewController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    
    var model = CollectionViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.dropDelegate = self
        collectionView.dragDelegate = self
        collectionView.dragInteractionEnabled = true
        
        // Register the Xib for our cell
        //
        let nib = UINib.init(nibName: "ImageCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "Cell")
        
        if let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flow.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
            let width = UIScreen.main.bounds.size.width
            // let height = UIScreen.main.bounds.size.height
            flow.itemSize = CGSize(width: width / 2.0, height: width / 2.0)
            flow.minimumInteritemSpacing = 0
            flow.minimumLineSpacing = 0
        }
    }
    
    // This method moves a cell from source indexPath to destination indexPath within the same collection view.
    // It works for only 1 item. If multiple items selected, no reordering happens.
    //
    private func reorderItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView) {
        
        let items = coordinator.items
        if items.count == 1, let item = items.first, let sourceIndexPath = item.sourceIndexPath {
            var dIndexPath = destinationIndexPath
            if dIndexPath.row >= collectionView.numberOfItems(inSection: 0) {
                dIndexPath.row = collectionView.numberOfItems(inSection: 0) - 1
            }
            
            collectionView.performBatchUpdates({
                
                // self.items2.remove(at: sourceIndexPath.row)
                // self.items2.insert(item.dragItem.localObject as! String, at: dIndexPath.row)
                
                
                collectionView.deleteItems(at: [sourceIndexPath])
                collectionView.insertItems(at: [dIndexPath])
            })
            
            coordinator.drop(items.first!.dragItem, toItemAt: dIndexPath)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// ColelctionView datasource and delegate
//
extension CollectionDragDropViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.planets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImageCell
        cell.imageView.image = model.planets[indexPath.row]
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor.white.cgColor
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        model.moveItem(at: sourceIndexPath.row, to: destinationIndexPath.row)
    }
    
    // Recalculate cell size on orientation change
    //
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        guard let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        flow.invalidateLayout()
        flow.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        let width = UIScreen.main.bounds.size.width
        flow.itemSize = CGSize(width: width / 2.0, height: width / 2.0)
        flow.minimumInteritemSpacing = 0
        flow.minimumLineSpacing = 0
    }
}

// Drag delegate
//
extension CollectionDragDropViewController: UICollectionViewDragDelegate {
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return model.dragItem(for: indexPath)
    }
}

// Drop delegate
//
extension CollectionDragDropViewController: UICollectionViewDropDelegate {
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return model.canHandle(session)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        
        if collectionView.hasActiveDrag {
            if session.items.count > 1 {
                return UICollectionViewDropProposal(operation: .cancel)
            } else {
                // .move is only available for dragging within a single app
                //
                return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
            }
        } else {
            // Multi-tasking drag which allows more than image string to be added
            //
            return UICollectionViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        
        let destinationIndexPath: IndexPath
        
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            // Use the last indexPath of the collectionView
            //
            let section = collectionView.numberOfSections - 1
            let row = collectionView.numberOfItems(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }
        
        
        let items = coordinator.items
        for item in items {
            
            if let sourceIndexPath = item.sourceIndexPath, coordinator.proposal.operation == .move {
                // .move operation
                //
                collectionView.performBatchUpdates({
                    model.moveItem(at: sourceIndexPath.row, to: destinationIndexPath.row)
                    collectionView.deleteItems(at: [sourceIndexPath])
                    collectionView.insertItems(at: [destinationIndexPath])
                })
                coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
            } else if coordinator.proposal.operation == .copy {
                item.dragItem.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { (newImage, error) in
                    if let image = newImage as? UIImage {
                        
                        if coordinator.proposal.operation == .copy {
                            self.model.addPlanet(image, at: destinationIndexPath.row)
                            DispatchQueue.main.async {
                                collectionView.insertItems(at: [destinationIndexPath])
                            }
                        } else if coordinator.proposal.operation == .move {
                            
                        }
                    }
                })
            }
        }
    }
}
