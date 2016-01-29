//
//  TimelineDetailViewController.swift
//  Mosaiek
//
//  Created by Jonathan Schapiro on 1/19/16.
//  Copyright © 2016 Jonathan Schapiro. All rights reserved.
//

import UIKit

class TimelineDetailViewController: UIViewController {

    var detailedMosaic:PFObject?
    
    @IBOutlet weak var mosaicImage: UIImageView!
    
    @IBOutlet weak var mosaicImages: UIScrollView!
    
    @IBOutlet weak var mosaicLikes: UILabel!
    
    @IBOutlet weak var mosaicContributors: UILabel!
    
    @IBOutlet weak var mosaicName: UILabel!
    
    @IBOutlet weak var mosaicDescription: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView();
        // Do any additional setup after loading the view.
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
            
            
            if let user = mosaic["user"]{
                
            }
            
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
