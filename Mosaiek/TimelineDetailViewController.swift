//
//  TimelineDetailViewController.swift
//  Mosaiek
//
//  Created by Jonathan Schapiro on 1/19/16.
//  Copyright © 2016 Jonathan Schapiro. All rights reserved.
//

import UIKit
import MobileCoreServices
import Social

protocol EditMosaicDelegate {
    func didEditMosaic(mosaicName:String,mosaicDescription:String);
}

class TimelineDetailViewController: UIViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIScrollViewDelegate, EditMosaicDelegate {

    var detailedMosaic:PFObject?
    
    @IBOutlet weak var mosaicImage: UIImageView!
    
    @IBOutlet weak var mosaicImages: UIScrollView!
    
    @IBOutlet weak var mosaicLikes: UILabel!
    
    @IBOutlet weak var mosaicLIkesButton: UIButton!
    @IBOutlet weak var mosaicContributors: UILabel!
    
    @IBOutlet weak var mosaicName: UILabel!
    
    @IBOutlet weak var mosaicDescription: UILabel!
    
    @IBOutlet weak var mosaicUserPic: UIImageView!
    
    @IBOutlet weak var mosaicLastUpdatedAt: UILabel!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    var imagePicker: UIImagePickerController!
    
    @IBOutlet weak var editMosaic: UIBarButtonItem!
    
    @IBOutlet weak var socialMediaShareView: UIView!
    
    
    // scrollview arrays
    var mosaicScrollImages:[UIImage] = [];
    var mosaicScrollViews:[UIImageView?] = [];
    
    //mosaicImageDataStructure
    var mosaicImageList: [PFObject] = [];
    var currentMosaicImage: PFObject?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(self.detailedMosaic);
        self.setupView();
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupScrollView(){
        
        mosaicImages.delegate = self;
        
        let pageCount = mosaicScrollImages.count;
        pageControl.currentPage = 0;
        pageControl.numberOfPages = pageCount
        
        for _ in 0..<pageCount {
            mosaicScrollViews.append(nil)
        }
        
        let pagesScrollViewSize = mosaicImages.frame.size
        
        mosaicImages.contentSize = CGSize(width: pagesScrollViewSize.width * CGFloat(mosaicScrollImages.count),
            height: pagesScrollViewSize.height)
        
        loadVisiblePages()
        
    }
    
    func setupView(){
        
        let this = self;
        
        if let mosaic = self.detailedMosaic{
            
            //isOwner?
            
            Mosaic.isOwner(mosaic, completion: { (owner) -> Void in
                if (owner == true){
                    self.editMosaic.enabled = true;
                }
            });
            
            if let name = mosaic["name"]{
                self.mosaicName?.text = name as? String;
            }
            
            if let description = mosaic["description"]{
                self.mosaicDescription?.text = description as? String;
                
            } else { //user contributes to mosaic
                
                if let contributedMosaic = mosaic["mosaic"] as? PFObject{
                    
                    if let name = contributedMosaic["name"]{
                        self.mosaicName?.text = name as? String;
                    }
                    
                    if let description = contributedMosaic["description"] as? String{
                        self.mosaicDescription?.text = description;
                    }
                    
                    if let imageFile = contributedMosaic["image"] as? PFFile{
                        
                        MosaicImage.fileToImage(imageFile, completion: { (mosaicImage) -> Void in
                            
                            if let image = mosaicImage {
                                
                                self.mosaicImage.image = image;
                                
                            }
                        })
                    }
                }
                
                if let contributedUser = mosaic["user"] as? PFObject {
                    if let image = contributedUser["profilePic"] as? String {
                        if let url = NSURL(string: image) {
                            if let data = NSData(contentsOfURL: url) {
                                mosaicUserPic.image = UIImage(data: data)
                            }
                        }

                    }
                }
                
                if let contributedUpatedAt = mosaic.updatedAt {
                    
                    mosaicLastUpdatedAt?.text = "Last Updated: " + dateToString(contributedUpatedAt);
                }
                
            }
            
            if let upadatedAt = mosaic.updatedAt {
                
                mosaicLastUpdatedAt?.text = "Last Updated: " +  DateUtil.timeAgoSinceDate(upadatedAt,numericDates: true);
            }
            
            if let user = mosaic["user"] as? PFObject {
                
                if let userImage = user["profilePic"] as? String{
                    
                    if let url = NSURL(string: userImage) {
                        
                        if let data = NSData(contentsOfURL: url) {
                            
                            mosaicUserPic.image = UIImage(data: data)
                            
                        }
                    }

                }
            }
            
            if let imageFile = mosaic["image"] as? PFFile {
                
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

            
            // Mosaic info has been loaded now get MosaicImages
            
            MosaicImage.getCurrentMosaicImages(mosaic, completion: { (mosaicImages:Array<PFObject>?) -> Void in
                
                if let detailedMosaic = mosaicImages{
                    
                    this.setupGestureRecognizer();
                    
                    for mosaicImage in detailedMosaic{
                        
                        let mosaicImg = mosaicImage; //placeholder for mosaicImage
                        
                        
                        if let thumbnail = mosaicImage["thumbnail"] as? PFFile{
                            
                            MosaicImage.fileToImage(thumbnail, completion: { (mosaicImage) -> Void in
                                
                                if let scrollviewImage = mosaicImage{
                                    
                                    this.mosaicImageList.append(mosaicImg); // both of these lists get populated at same time
                                    this.mosaicScrollImages.append(scrollviewImage);
                                    
                                    this.setupScrollView()
                                    
                                }
                            })
                        }
                    }
                }
                
            })
            
        }
    }
    
    // MARK:Gesture Recognizer 
    
    func setupGestureRecognizer() {
        
        //add gesture recognizer to mosaicImageView
        let mosaicImageViewTap = UITapGestureRecognizer()
        mosaicImageViewTap.addTarget(self, action: "detailImageTapped")
        mosaicImages.addGestureRecognizer(mosaicImageViewTap)
        mosaicImages.userInteractionEnabled = true
        
    }
    
    func detailImageTapped() {
        
        if self.mosaicImageList.count > self.pageControl.currentPage {
            let currentMosaic = self.mosaicImageList[self.pageControl.currentPage];
            self.currentMosaicImage = currentMosaic;
            
            self.performSegueWithIdentifier("showMosaicImage", sender: self); // pass mosaicImage to next view
        }
       
    }

    
    
    // #MARK - IBActions
    

    @IBAction func contributeToMosaic(sender: AnyObject) {
        
        self.loadMosaicImage();
    }
    
    @IBAction func likeMosaic(sender: AnyObject) {
        print(self.mosaicLIkesButton.alpha);
        if (self.mosaicLIkesButton.alpha == 1.0){
            print("liking mosaic");
            if let mosaic = self.detailedMosaic {
                
                Mosaic.likeMosaic(mosaic);
                self.mosaicLIkesButton.alpha = 0.5;
                self.mosaicLikes.text = String(Int(self.mosaicLikes!.text!)! + 1);
            } else {
                return;
            }
        }
       
    }
    
    @IBAction func shareOnSocialMedia(sender: AnyObject) {
        if (self.socialMediaShareView.hidden == true){
            self.socialMediaShareView.hidden = false;
        } else {
            self.socialMediaShareView.hidden = true;
        }
        
    }
    
    @IBAction func shareMosaicOnFB(sender: AnyObject) {
        print("sharing image on fb");
        if let image = self.mosaicImage.image {
            if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
                let fbShare:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook);
                fbShare.setInitialText("Check out this photo mosaic I made on Mosaiek");
                fbShare.addImage(image);
                
                self.presentViewController(fbShare, animated: true, completion: nil);
            }
        }
        
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
    
    

    // MARK: - Scrollview methods
    
    func loadPage(page:Int){
        
        if page < 0 || page >= mosaicScrollImages.count {
            // If it's outside the range of what you have to display, then do nothing
            return
        }
        
        // 1
        if let pageView = mosaicScrollViews[page] {
            // Do nothing. The view is already loaded.
            
        } else {
            
            var frame = mosaicImages.bounds
            frame.origin.x = frame.size.width * CGFloat(page)
            frame.origin.y = 0.0
            
           
            let newPageView = UIImageView(image: mosaicScrollImages[page])
            newPageView.contentMode = .ScaleToFill
            newPageView.frame = frame
            mosaicImages.addSubview(newPageView)
            
           
            mosaicScrollViews[page] = newPageView
        }
    }
    
    func purgePage(page:Int){
        
        if page < 0 || page >= mosaicScrollImages.count {
            // If it's outside the range of what you have to display, then do nothing
            return
        }
        
        // Remove a page from the scroll view and reset the container array
        if let pageView = mosaicScrollViews[page] {
            
            pageView.removeFromSuperview()
            mosaicScrollViews[page] = nil
        }
    }
    
    func loadVisiblePages(){
        
        // First, determine which page is currently visible
        let pageWidth = mosaicImages.frame.size.width
        let page = Int(floor((mosaicImages.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0)))
       
        // Update the page control
        pageControl.currentPage = page
        
        // Work out which pages you want to load
        let firstPage = page - 1
        let lastPage = page + 1
        
        // Purge anything before the first page
        for var index = 0; index < firstPage; ++index {
            purgePage(index)
        }
        
        // Load pages in our range
        for index in firstPage...lastPage {
            loadPage(index)
        }
        
        // Purge anything after the last page
        for var index = lastPage+1; index < mosaicScrollImages.count; ++index {
            purgePage(index)
        }
    }
    
    // MARK: ScrollviewDelegate methods
    
    func scrollViewDidScroll(scrollView: UIScrollView!) {
        // Load the pages that are now on screen
        loadVisiblePages()
    }
    
    // MARK: UTILS
    func dateToString(date:NSDate?) -> String{
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = .MediumStyle
        let dateString = dateFormatter.stringFromDate(date!)
        
        return dateString;
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showMosaicImage") {
            
            let dvc = segue.destinationViewController as! TimelineDetailCommentViewController;
            
            if let currentMosaic = self.currentMosaicImage {
                dvc.mosaicImage = currentMosaic;
                
            }
            
        }
        
        if (segue.identifier == "showEditMosaic") {
            let dvc = segue.destinationViewController as! EditMosaicViewController;
            if let currentMosaic = self.detailedMosaic {
                dvc.delegate = self;
                dvc.mosaic = currentMosaic;
            }
        }
        
        
    }
    
    // EditMosaic Delegate Methods 
    
    func didEditMosaic(mosaicName: String, mosaicDescription: String) {
        self.mosaicName?.text = mosaicName;
        self.mosaicDescription?.text = mosaicDescription;
    }

}
