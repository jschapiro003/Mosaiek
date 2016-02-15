//
//  AddMoreContributorsViewController.swift
//  Mosaiek
//
//  Created by Jonathan Schapiro on 2/12/16.
//  Copyright © 2016 Jonathan Schapiro. All rights reserved.
//

import UIKit

class AddMoreContributorsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var addMoreContributorsTable: UITableView!
    
    var friends:[PFObject] = [];
    var mosaic:PFObject?
    
    var contributorsToAdd:[PFObject] = [];
   
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.addMoreContributorsTable.delegate = self
        self.addMoreContributorsTable.dataSource = self
        self.loadPotentialContributors()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadPotentialContributors(){
        
        User.loadAllFriends { (friends:Array<PFObject>?) -> Void in
            
            if let allFriends = friends {
                
                self.friends = allFriends;
                self.addMoreContributorsTable.reloadData()
            }
        }
    }
    
    
    //#MARK - TableViewDelegate Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        
            return self.friends.count;
        
        
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("addMoreContributorCell", forIndexPath: indexPath) as! AddMoreContributorsCell
        
        cell.userInteractionEnabled = false;
        
        if let detailedMosaic = self.mosaic {
            Mosaic.isContributor(detailedMosaic, user: self.friends[indexPath.row], completion: { (contributor) -> Void in
                if (contributor == true){
                    cell.accessoryType = .Checkmark
                } else {
                    cell.userInteractionEnabled = true;
                }
                
            })
        }
        
            if let friendImage = self.friends[indexPath.row]["profilePic"] as? String {
                
                if let url = NSURL(string: friendImage ) {
                    
                    if let data = NSData(contentsOfURL: url) {
                        
                        cell.contributorImage?.image = UIImage(data: data)
                        
                    }
                }

                    
            }
                
            if let profileName = self.friends[indexPath.row] ["profileName"] as? String {
                
                cell.contributorName.text = profileName;
            }
            
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
        
        let cell: AddMoreContributorsCell = tableView.cellForRowAtIndexPath(indexPath)! as! AddMoreContributorsCell;
        
        let contributor = self.friends[indexPath.row];
        
        if (cell.accessoryType == .None) {
            cell.accessoryType = .Checkmark;
            self.addContributor(contributor);
            
        } else if (cell.accessoryType == .Checkmark) {
            
            cell.accessoryType = .None
            self.removeContributor(contributor, index: self.indexOfContributor(contributor));
            
        } else {
            return;
        }
        
        
    }
    
    func addContributor(contributor:PFObject){
        if (self.contributorExists(contributor) == false){
            self.contributorsToAdd.append(contributor);
        }
    }
    
    func removeContributor(contributor:PFObject,index:Int){
        if (self.contributorExists(contributor) == true){
            if (index > -1){
                self.contributorsToAdd.removeAtIndex(index);
            }
        }
    }
    
    func contributorExists(target:PFObject)-> Bool{
        
        var found = false;
        for (var i = 0; i < self.contributorsToAdd.count; i++){
            if (self.contributorsToAdd[i] == target){
                found = true;
            }
        }
        return found;
    }
    
    func indexOfContributor(contributor:PFObject) -> Int{
        var index = -1;
        for (var i = 0; i < self.contributorsToAdd.count; i++){
            if (self.contributorsToAdd[i] == contributor){
                index = i;
            }
        }
        return index;
    }
    
    //#MARK - IBAction
    
    @IBAction func addMoreContributors(sender: AnyObject) {
        if (self.contributorsToAdd.count > 0) {
            if let mos = self.mosaic {
                Mosaic.addContributors(mos.objectId, contributors: self.contributorsToAdd as NSArray as! Array<PFUser>);
            }
            self.navigationController?.popViewControllerAnimated(true);
        }
    }

}
