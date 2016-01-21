//
//  NewMosaicViewController.swift
//  Mosaiek
//
//  Created by Jonathan Schapiro on 1/19/16.
//  Copyright © 2016 Jonathan Schapiro. All rights reserved.
//

import UIKit
import MobileCoreServices



protocol GenerateNewMosaicDelegate {
    func contributorsAddedToMosaic()
}

class NewMosaicViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate,GenerateNewMosaicDelegate {
    
    @IBOutlet weak var mosaicName: UITextField!

    @IBOutlet weak var mosaicDescription: UITextField!
    
    @IBOutlet weak var mosaicImage: UIImageView!
    
    var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewSetup()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewSetup(){
        
        //add gesture recognizer to mosaicImageView
        let mosaicImageViewTap = UITapGestureRecognizer()
        mosaicImageViewTap.addTarget(self, action: "loadMosaicImage")
        mosaicImage.addGestureRecognizer(mosaicImageViewTap)
        mosaicImage.userInteractionEnabled = true
        
    }
    
    func loadMosaicImage(){
        //lazy instantiation of imagePicker
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
            
            self.imagePicker = UIImagePickerController()
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.Camera;
            self.imagePicker.mediaTypes = [kUTTypeImage as String]
            self.imagePicker.allowsEditing = false
            
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
            
        } else if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary){
            
            print("we going to the photo library")
            self.imagePicker = UIImagePickerController()
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
            self.imagePicker.mediaTypes = [kUTTypeImage as String]
            self.imagePicker.allowsEditing = false
            
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
            
        } else {
            
            print("You can't take no pics"); //generate uialertview
        }
        
    }
    
    //MARK: - Submit Form Actions
    
    @IBAction func inviteContributors(sender: AnyObject) {
        
        let formName = self.mosaicName.text!;
        let formDescription = self.mosaicDescription.text!;
        var formImageThumbnail:NSData?
        var formImage:NSData?
        
        if let formImageHiRez = self.mosaicImage.image {
            
            formImage = self.generateJPEG(formImageHiRez);
            formImageThumbnail = self.generateThumbnail(formImageHiRez);
            
        }
        
        let mosaic = Mosaic(mosaicName: formName,mosaicDescription: formDescription,mosaicImage: formImage,mosaicImageThumbnail: formImageThumbnail,mosaicCreator:  PFUser.currentUser());
        
        if (self.validMosaic(mosaic)){
            self.performSegueWithIdentifier("showAddContributorsViewController", sender: self)
        } else {
            //alert no good
            print("form not valid")
        }
        
    }
    
    func generateJPEG(image:UIImage) -> NSData {
        
        return UIImageJPEGRepresentation(image, 0.8)!;
    }
    
    func generateThumbnail(image:UIImage) -> NSData{
        let imageData = UIImageJPEGRepresentation(image, 0.0) //lowest quality
        return imageData!;
    }
    
    func validMosaic (mosaic:Mosaic) -> Bool {
        if (mosaic.mosaicName != nil && mosaic.mosaicDescription != nil && mosaic.mosaicImage != nil && mosaic.mosaicImageThumbnail != nil){
            return true;
        }
        //check that each property has a value
        return false;
    }
    
    //MARK: - ImagePickerDelegate Methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            print("image picker finished",pickedImage)
            self.mosaicImage.image = pickedImage
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //MARK: - Generate New Mosaic Delegate Methods
    func contributorsAddedToMosaic(){
        print("saving mosaic to parse")
    }
    
   

    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "showAddContributorsViewController"){
            
            let dvc = segue.destinationViewController as! AddContributorsViewController;
            dvc.delegate = self;
            
        } else {
            print("no go")
        }
    }
    

}
