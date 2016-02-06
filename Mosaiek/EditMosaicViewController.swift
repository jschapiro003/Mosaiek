//
//  EditMosaicViewController.swift
//  Mosaiek
//
//  Created by Jonathan Schapiro on 1/19/16.
//  Copyright © 2016 Jonathan Schapiro. All rights reserved.
//

import UIKit

class EditMosaicViewController: UIViewController {
    
    var mosaic:PFObject?
    var delegate:EditMosaicDelegate?
    
    @IBOutlet weak var editName: UITextField!
    
    @IBOutlet weak var editDescription: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let mosaicToEdit = self.mosaic {
            self.setupView();
        }
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func setupView(){
        if let name = self.mosaic!["name"]{
            self.editName.text = name as? String;
        }
        
        if let description = self.mosaic!["description"] {
            self.editDescription.text = description as? String;
        }
    }
    
    @IBAction func editMosaic(sender: AnyObject) {
        
        if (self.mosaic != nil && self.editDescription.text != nil && self.editName.text != nil){
            Mosaic.editMosaic(self.mosaic!, mosaicName: self.editName.text!, mosaicDescription: self.editDescription.text!, completion: { (success) -> Void in
                //call delegate method to update timelinedetailview text labels
                print("edited mosaic",success);
                if (success == true){
                    self.delegate?.didEditMosaic(self.editName.text!, mosaicDescription: self.editDescription.text!);
                }
            })
        }
        if let navController = self.navigationController {
            navController.popViewControllerAnimated(true)
        }
        
    }
   

}
