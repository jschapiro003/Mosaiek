//
//  NewMosaicViewController.swift
//  Mosaiek
//
//  Created by Jonathan Schapiro on 1/19/16.
//  Copyright © 2016 Jonathan Schapiro. All rights reserved.
//

import UIKit
import MobileCoreServices

class NewMosaicViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var mosaicName: UITextField!

    @IBOutlet weak var mosaicDescription: UITextField!
    
    @IBOutlet weak var mosaicImage: UIImageView!
    
    var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        print("Welcome to the new mosaic view controller")
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
    
    // Submit Form Actions
    
    @IBAction func inviteContributors(sender: AnyObject) {
        
        let formName = self.mosaicName.text!;
        let formDescription = self.mosaicDescription.text!;
        var formImageThumbnail:UIImage?
        
        if let formImage = self.mosaicImage.image {
             formImageThumbnail = self.generateThumbnail(formImage);
        }
        
        
        print(formName,formDescription,formImageThumbnail)
        self.performSegueWithIdentifier("showAddContributorsViewController", sender: self)
    }
    
    func generateThumbnail(image:UIImage) -> UIImage{
        
        return image;
    }
    
    //ImagePickerDelegate Methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            print("image picker finished",pickedImage)
            self.mosaicImage.image = pickedImage
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("image picker cancelled")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
   

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
