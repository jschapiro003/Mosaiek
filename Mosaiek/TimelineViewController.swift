//
//  TimelineViewController.swift
//  Mosaiek
//
//  Created by Jonathan Schapiro on 1/19/16.
//  Copyright © 2016 Jonathan Schapiro. All rights reserved.
//

import UIKit
import SocketIOClientSwift
import MBProgressHUD


protocol NewMosaicDelegate {
    func didCreateNewMosaic(mosaic:PFObject);
}

protocol LikeMosaicDelegate {
    func didLikeMosaic(button:UIButton,tag:Int,addLike:Bool)
}


class TimelineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NewMosaicDelegate, EditMosaicDelegate,LikeMosaicDelegate {
    var mosaicSet: Set<PFObject> = Set()
    var timelineMosaics:[PFObject]  = [];
    var mosaicContributors:[PFObject]? = [];
    var currentMosaic:PFObject?
    var currentLikeButton:UIButton?
    var socket:SocketIOClient?
    let socketHandler = SocketHandler();
    var refreshControl: UIRefreshControl!
    
    @IBOutlet weak var timelineTableView: UITableView!
    
    @IBOutlet weak var mosaicTable: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mosaicTable.delegate = self;
        self.mosaicTable.dataSource = self;
        
        self.mosaicTable.hidden = true;
        
        // Refresh Controls
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Refreshing Mosaics...")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.mosaicTable.addSubview(self.refreshControl)
        
        self.loadUsersMosaics();
        
    }
    
    override func viewDidAppear(animated: Bool) {
        //self.loadUsersMosaics();
    }
    override func viewWillAppear(animated: Bool) {
        currentMosaic = nil;
    }
    
    override func viewDidDisappear(animated: Bool) {
        currentMosaic = nil;
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  
    
    func loadUsersMosaics() {
        let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true);
        loadingNotification.mode = MBProgressHUDMode.Indeterminate
        loadingNotification.labelText = "Loading Mosaics"
        
        Mosaic.getUsersMosaics(PFUser.currentUser()!) { (mosaics) -> Void in
            if let usersMosaics = mosaics {

                print("new mosaics received");
                for (var mosaic = 0; mosaic < usersMosaics.count; mosaic++){
                    if ( !Mosaic.containsMosaic(self.timelineMosaics, mosaic: usersMosaics[mosaic])){
                        self.timelineMosaics.append(usersMosaics[mosaic]);
                    }
                }
                
                
                if (self.timelineMosaics.count > 0) {
                    self.mosaicTable.hidden = false;
                }
                
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true);
                self.refreshControl.endRefreshing()
                
                self.mosaicTable.reloadData();
            }
        }
        
        
    }
    
   
    
    //#MARK - Navigation
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
       
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
            dvc?.likeDelegate = self;
            
            
            if let likeB = self.currentLikeButton {
                dvc?.mainLikeButton = likeB;
            }
            
            
        }
        
        if (segue.identifier == "showCreateMosaic") {
            let dvc = segue.destinationViewController as? NewMosaicViewController;
            dvc?.delegate = self;
        }
        
    }
    
    //#MARK - TableViewDelegate Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1;
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return timelineMosaics.count;
        
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let this = self;
       
        let cell:TimelineMosaicCell = tableView.dequeueReusableCellWithIdentifier("timelineMosaicCell", forIndexPath: indexPath) as! TimelineMosaicCell
        
        
        cell.objectId = timelineMosaics[indexPath.row].objectId;
        
        var mosaicThumbnail: PFFile? = timelineMosaics[indexPath.row]["currentState"] as? PFFile;
        
        if (mosaicThumbnail == nil) {
            mosaicThumbnail = timelineMosaics[indexPath.row]["thumbnail"] as? PFFile;
        }
        
        if let thumbnail = mosaicThumbnail {
            //Memoize!!!!
            MosaicImage.fileToImage(thumbnail, completion: { (mosaicImage) -> Void in
                
                if let mosaicImg = mosaicImage {
                    
                    cell.mosaicThumbnailImageView.image = mosaicImg;
                    
                }
            })
        }
        
        cell.likeButton.enabled = false;
        
        //Like Button Setup
        Mosaic.hasLikedMosaic(timelineMosaics[indexPath.row]) { (liked) -> Void in
            if (liked == true){
                cell.likeButton?.setBackgroundImage(UIImage(named: "likes_filled"), forState:UIControlState.Normal);
                
            } else {
                cell.likeButton?.setBackgroundImage(UIImage(named: "likes"), forState: UIControlState.Normal);
            }
            cell.likeButton.enabled = true;
        }
        
        cell.likeButton?.tag = indexPath.row;
        cell.likeButton?.addTarget(this, action: "likeMosaic:", forControlEvents: UIControlEvents.TouchUpInside);
        
        
        if let likes = timelineMosaics[indexPath.row]["likes"] as? Int{
            
            cell.mosaicLikes?.text = String(likes);
            
        } else {
            
            cell.mosaicLikes?.text = "0";
            
        }
        
        cell.mosaicName?.text = timelineMosaics[indexPath.row]["name"] as? String;
        
        cell.mosaicDescription?.text = timelineMosaics[indexPath.row]["description"] as? String;
        
        if let date = timelineMosaics[indexPath.row].createdAt {
            
            cell.mosaicCreationDate?.text = DateUtil.timeAgoSinceDate(date,numericDates: true);
        }
        
        if let user = timelineMosaics[indexPath.row]["user"]{
            
            if let profileName = user["profileName"] as? String{
                cell.username?.text = profileName;
            }
            
            
            if let userPhoto = user["profilePic"]{
                
                if let url = NSURL(string: userPhoto as! String) {
                    
                    if let data = NSData(contentsOfURL: url) {
                        
                        cell.mosaicOwnerPhoto?.image = UIImage(data: data)
                    }
                }
            }
        }
        

        
        if (cell.mosaicName?.text == nil && cell.mosaicDescription?.text == nil){
            
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
    
    func likeMosaic(sender:UIButton){
        let cell = self.mosaicTable.cellForRowAtIndexPath(NSIndexPath(forRow: sender.tag, inSection: 0)) as! TimelineMosaicCell;
        
        let mosaic = timelineMosaics[sender.tag];
        
        if sender.backgroundImageForState(UIControlState.Normal) == UIImage(named: "likes_filled"){
            cell.mosaicLikes.text = String(Int(cell.mosaicLikes.text!)! - 1);
            sender.setBackgroundImage(UIImage(named: "likes"), forState: UIControlState.Normal);
            Mosaic.removeLike(mosaic, completion: { (success) -> Void in
                if (success){
                    print("like removed");
                }
            })
        } else {
            cell.mosaicLikes.text = String(Int(cell.mosaicLikes.text!)! + 1);
            Mosaic.likeMosaic(mosaic);
            sender.setBackgroundImage(UIImage(named: "likes_filled"), forState: UIControlState.Normal);
        }
       
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! TimelineMosaicCell;

        
        self.currentLikeButton = cell.likeButton;
        
        currentMosaic = timelineMosaics[indexPath.row];
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
        
    }
    
    // MARK: UTILS
    func dateToString(date:NSDate?) -> String{
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = .MediumStyle
        let dateString = dateFormatter.stringFromDate(date!)
        
        return dateString;
    }
    
    //#MARK - New Mosaic Delegate Methods
    
    func didCreateNewMosaic(mosaic:PFObject) {
        
        self.timelineMosaics.insert(mosaic, atIndex: 0);
        self.mosaicTable.hidden = false;
        self.mosaicTable.reloadData();
    }
    
    //#Mark - Edit Mosaic Delegate
    
    func didEditMosaic(mosaicName: String, mosaicDescription: String) {
            //find cell of current mosaic and update values
    }
    
    //#Mark - Like Mosaic Delegate Methods
    func didLikeMosaic(button:UIButton,tag:Int,addLike:Bool){
      
        let cell = self.mosaicTable.cellForRowAtIndexPath(NSIndexPath(forRow: tag, inSection: 0)) as! TimelineMosaicCell;
        
        
        if (addLike == false && button.backgroundImageForState(UIControlState.Normal) == UIImage(named: "likes")){
            
            print("deprecating likes");
            cell.mosaicLikes.text = String(Int(cell.mosaicLikes.text!)! - 1)
            
        } else if (addLike == true && button.backgroundImageForState(UIControlState.Normal) == UIImage(named:"likes_filled")) {
            print("adding a like")
            cell.mosaicLikes.text = String(Int(cell.mosaicLikes.text!)! + 1)
        }
    }
    
    //#MARK - Refresh methods
    func refresh(sender:AnyObject)
    {
        self.loadUsersMosaics();
    }

}
