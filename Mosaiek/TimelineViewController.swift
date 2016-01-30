//
//  TimelineViewController.swift
//  Mosaiek
//
//  Created by Jonathan Schapiro on 1/19/16.
//  Copyright © 2016 Jonathan Schapiro. All rights reserved.
//

import UIKit


class TimelineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var timelineMosaics = [];
    var currentMosaic:PFObject?
    
    @IBOutlet weak var mosaicTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mosaicTable.delegate = self;
        self.mosaicTable.dataSource = self;
        
        self.loadUsersMosaics();
    }
    
    
    override func viewDidDisappear(animated: Bool) {
        currentMosaic = nil;
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func loadUsersMosaics() {
        Mosaic.getUsersMosaics(PFUser.currentUser()!) { (mosaics) -> Void in
            if let usersMosaics = mosaics {
                self.timelineMosaics = usersMosaics;
                
                self.mosaicTable.reloadData();
            }
        }
    }
    
    
    //#MARK - Navigation
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        print("segueing")
        print(identifier)
        if (identifier == "showInvitations"){
            return true;
        } else if (identifier == "showCreateMosaic") {
            return true;
        } else if (identifier == "showDetailTimelineView"){
            if currentMosaic == nil{
                return false;
            } else {
                return true;
            }
        } else {
            return false;
        }
        
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showDetailTimelineView"){
            let dvc = segue.destinationViewController as? TimelineDetailViewController;
            dvc?.detailedMosaic = currentMosaic;
            print("preparing")
        }
    }
    
    //#MARK - TableViewDelegate Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return timelineMosaics.count;
        
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:TimelineMosaicCell = tableView.dequeueReusableCellWithIdentifier("timelineMosaicCell", forIndexPath: indexPath) as! TimelineMosaicCell
        
        currentMosaic = timelineMosaics[indexPath.row] as? PFObject;
        
        let mosaicThumbnail:PFFile? = timelineMosaics[indexPath.row]["thumbnail"] as? PFFile;
        
        if let thumbnail = mosaicThumbnail {
            //Memoize!!!!
            MosaicImage.fileToImage(thumbnail, completion: { (mosaicImage) -> Void in
                if let mosaicImg = mosaicImage {
                    cell.mosaicThumbnailImageView.image = mosaicImg;
                }
                
            })
        }
        
        if let user = timelineMosaics[indexPath.row]["user"]{
            if let userInfo = user {
                if (userInfo["profileName"] != nil){
                    if let name = userInfo["profileName"]{
                        cell.username?.text = name as? String;
                    }
                }
                
            }
            if let userPhoto = user!["profilePic"]{
                if let url = NSURL(string: userPhoto as! String) {
                    if let data = NSData(contentsOfURL: url) {
                        cell.mosaicOwnerPhoto?.image = UIImage(data: data)
                    }        
                }
            }
        } 
        
        if let likes = timelineMosaics[indexPath.row]["likes"] as? Int{
            
            cell.mosaicLikes?.text = String(likes);
        } else {
            cell.mosaicLikes?.text = "0";
        }
        
        cell.mosaicName?.text = timelineMosaics[indexPath.row]["name"] as? String;
        
        cell.mosaicDescription?.text = timelineMosaics[indexPath.row]["description"] as? String;
        
        if cell.mosaicName?.text == nil && cell.mosaicDescription?.text == nil{
            if let contributorMosaic = timelineMosaics[indexPath.row]["mosaic"] as? PFObject{
                if let contributorMosaicName = contributorMosaic["name"]{
                    cell.mosaicName?.text = contributorMosaicName as? String;
                }
                
                if let contributorMosaicDescription = contributorMosaic["description"]{
                    cell.mosaicDescription?.text = contributorMosaicDescription as? String;
                }
            }
        }
        
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        currentMosaic = timelineMosaics[indexPath.row] as? PFObject;
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
        
    }

}
