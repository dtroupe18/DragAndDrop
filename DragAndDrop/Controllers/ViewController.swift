//
//  ViewController.swift
//  DrapAndDrop
//
//  Created by Dave on 5/23/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIDropInteractionDelegate, UIDragInteractionDelegate {
    
    // Class allows for drag and drop between images views as well as when multi-tasking (iPad only)
    //
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var bottomImageView: UIImageView!
    @IBOutlet weak var tableViewButton: UIBarButtonItem!
    @IBOutlet weak var collectionViewButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topImageView.isUserInteractionEnabled = true
        bottomImageView.isUserInteractionEnabled = true
        topImageView.image = #imageLiteral(resourceName: "topImagejpg")
        bottomImageView.image = #imageLiteral(resourceName: "bottomImagejpg")
        
        let drop = UIDropInteraction(delegate: self)
        let topDrag = UIDragInteraction(delegate: self)
        let bottomDrag = UIDragInteraction(delegate: self)
        
        self.view.addInteraction(drop)
        topDrag.isEnabled = true
        bottomDrag.isEnabled = true
        topImageView.addInteraction(topDrag)
        bottomImageView.addInteraction(bottomDrag)
    }

    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        if session.location(in: self.view).y <= self.topImageView.frame.maxY {
            guard let image = topImageView.image else { return [] }
            let provider = NSItemProvider(object: image)
            let item = UIDragItem(itemProvider: provider)
            return [item]
        } else {
            guard let image = bottomImageView.image else { return [] }
            let provider = NSItemProvider(object: image)
            let item = UIDragItem(itemProvider: provider)
            return [item]
        }
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        // This method tells the delegate it can request the item provider data from the session’s drag items.
        //
        for dragItem in session.items {
            dragItem.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { object, error in
                guard error == nil else { return print("Failed to load our dragged item") }
                guard let draggedImage = object as? UIImage else { print("object not UIImage"); return }

                DispatchQueue.main.async {
                    if session.location(in: self.view).y <= self.topImageView.frame.maxY {
                        self.topImageView.image = draggedImage
                    } else {
                        self.bottomImageView.image = draggedImage
                    }
                }
            })
        }
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        // This method tells the delegate that the drop session has changed. In this case,
        // we want to copy the items if the session has updated.
        //
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        //This method check to see if the view can handle the session’s drag items.
        // In this scenario, we want the view to accept images as the drag item.
        //
        return session.canLoadObjects(ofClass: UIImage.self)
    }
    
    @IBAction func pressedTableViewButton(_ sender: UIBarButtonItem) {
        let sb: UIStoryboard = UIStoryboard(name: "TableViewDragDrop", bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "TableViewDragDropVC") as? TableViewDragDropController {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func pressedCollectionView(_ sender: UIBarButtonItem) {
        let sb: UIStoryboard = UIStoryboard(name: "CollectionViewDragDrop", bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "CollectionDragDropVC") as? CollectionDragDropViewController {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

