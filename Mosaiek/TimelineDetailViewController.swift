//
//  TimelineDetailViewController.swift
//  Mosaiek
//
//  Created by Jonathan Schapiro on 1/19/16.
//  Copyright © 2016 Jonathan Schapiro. All rights reserved.
//

import UIKit
import MobileCoreServices

class TimelineDetailViewController: UIViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIScrollViewDelegate {

    var detailedMosaic:PFObject?
    
    @IBOutlet weak var mosaicImage: UIImageView!
    
    @IBOutlet weak var mosaicImages: UIScrollView!
    
    @IBOutlet weak var mosaicLikes: UILabel!
    
    @IBOutlet weak var mosaicContributors: UILabel!
    
    @IBOutlet weak var mosaicName: UILabel!
    
    @IBOutlet weak var mosaicDescription: UILabel!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    var imagePicker: UIImagePickerController!
    
    // scrollview arrays
    var mosaicScrollImages:[UIImage] = [];
    var mosaicScrollViews:[UIImageView] = [];
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView();
        self.setupScrollView();
        // Do any additional setup after loading the view.
    }
    
    func setupScrollView(){
        
    }
    
    func setupView(){
        if let mosaic = self.detailedMosaic{
            
            if let name = mosaic["name"]{
                self.mosaicName?.text = name as? String;
            }
            
            if let description = mosaic["description"]{
                self.mosaicDescription?.text = description as? String;
                
            } else {
                //user contributes to mosaic
                if let contributedMosaic = mosaic["mosaic"] as? PFObject{
                    if let name = contributedMosaic["name"]{
                        self.mosaicName.text = name as? String;
                    }
                    
                    if let description = contributedMosaic["description"]{
                        self.mosaicDescription.text = description as? String;
                    }
                    
                    if let imageFile = contributedMosaic["image"] as? PFFile{
                        MosaicImage.fileToImage(imageFile, completion: { (mosaicImage) -> Void in
                            if let image = mosaicImage {
                                self.mosaicImage.image = image;
                            }
                        })
                    }
                }
            }
            
            if let imageFile = mosaic["image"] as? PFFile{
                MosaicImage.fileToImage(imageFile, completion: { (mosaicImage) -> Void in
                    if let image = mosaicImage {

                        self.mosaicImage.image = image;
                    }
                })
            }
            
            if let contributors = mosaic["contributors"]{
                self.mosaicContributors.text = String(contributors);
            } else {
                self.mosaicContributors.text = "0";
            }
            
            if let likes = mosaic["likes"]{
                self.mosaicLikes?.text = String(likes);
            } else {
                self.mosaicLikes?.text = "0";
            }
            
            
           // if let user = mosaic["user"]{
                
            //}
            
            // Mosaic info has been loaded now get MosaicImages
            
            MosaicImage.getCurrentMosaicImages(mosaic, completion: { (mosaicImages:Array<PFObject>?) -> Void in
                if let detailedMosaic = mosaicImages{
                    for mosaicImage in detailedMosaic{
                        if let thumbnail = mosaicImage["thumbnail"] as? PFFile{
                            MosaicImage.fileToImage(thumbnail, completion: { (mosaicImage) -> Void in
                                if let scrollviewImage = mosaicImage{
                                    print(scrollviewImage);
                                }
                            })
                        }
                    }
                }
            })
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // #MARK - IBActions
    

    @IBAction func contributeToMosaic(sender: AnyObject) {
        
        self.loadMosaicImage();
    }
    
    // #MARK - Image Picker
    
    func loadMosaicImage(){
        //lazy instantiation of imagePicker
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
            
            self.imagePicker = UIImagePickerController()
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.Camera;
            self.imagePicker.mediaTypes = [kUTTypeImage as String];
            
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
    
    //MARK: - ImagePickerDelegate Methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            print("image picker finished",pickedImage)
            if let mosaic = detailedMosaic {
                MosaicImage.saveImageToMosaic(mosaic, image: pickedImage, completion: { (success) -> Void in
                    //set as current image in scrollview
                    //begin background process to mosaic'ify
                    print("Mosaic Image Sucessfully saved: ", success);
                })
            }
            
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
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
