//
//  AddContributorsViewController.swift
//  Mosaiek
//
//  Created by Jonathan Schapiro on 1/19/16.
//  Copyright © 2016 Jonathan Schapiro. All rights reserved.
//

import UIKit

class AddContributorsViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    var delegate:GenerateNewMosaicDelegate?
    
    var contributors = [] //current users friends
    var contributorsToAdd:Array<PFUser>? = []//requests for contributors to mosaic
    
    @IBOutlet weak var contributorsTable: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // have spinner spin until mosaic is successfuly saved - if you try to add contributors before it is saved, you have a problem
        
        self.contributorsTable.delegate = self;
        self.contributorsTable.dataSource = self;
        
        self.loadContributors();
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadContributors(){
        //get friends of current user from parse
        User.loadAllFriends { (friends: Array<PFObject>?) -> Void in
           
            if let contributorList = friends {
                
                self.contributors = contributorList;
                
            }
            
            self.contributorsTable.reloadData()
        }
    }
    
    
    //#MARK - TableViewDelegate Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.contributors.count;
        
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("addContributorsCell", forIndexPath: indexPath) as! AddContributorsCell
        
        
        if let username = self.contributors[indexPath.row]["profileName"] as? String {
            
            cell.friendName?.text = username;
            
        }
        
        if let image = self.contributors[indexPath.row]["profilePic"] as? String {
            
            if let url = NSURL(string: image) {
                
                if let data = NSData(contentsOfURL: url) {
                    
                    cell.friendImage?.image = UIImage(data: data)
                    
                }
            }
        }
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell: AddContributorsCell = tableView.cellForRowAtIndexPath(indexPath)! as! AddContributorsCell
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
        
        let contributor = self.contributors[indexPath.row];
        
        if (cell.accessoryType == .None) {
            print("adding friend");
            
            cell.accessoryType = .Checkmark
            
            if self.containedInContributorsToAdd(contributor as! PFUser) == false {
                self.contributorsToAdd?.append(contributor as! PFUser);
            }
        
        } else {
           
            print("removing friend");
            cell.accessoryType = .None
            self.removeContributorToAdd(contributor as! PFUser);
        }
        
        print(self.contributorsToAdd)
    }
    
    
    //#MARK - IBActions
    
    @IBAction func addContributors(sender: AnyObject) {
        
        if let delegateSet = self.delegate {
            
            if (self.contributorsToAdd != nil){
                
                delegateSet.contributorsAddedToMosaic(self.contributorsToAdd!) //pass contributors to add
                
            }
            
            self.navigationController?.popToRootViewControllerAnimated(true);
        }
    }
    
    func containedInContributorsToAdd(targetContributor:PFUser) -> Bool {
        var found = false;
        
        if var contributors = self.contributorsToAdd {
            
            for var i = 0; i < contributors.count; i++ {
                
                if (contributors[i] == targetContributor) {
                    found = true;
                }
            }
            
        }
        
        return found;
        
    }
    
    func removeContributorToAdd(targetContributor:PFUser) {
        print("attemtping to remove friend");
        if var contributors = self.contributorsToAdd {
            
            for var i = 0; i < contributors.count; i++ {
                
                if (contributors[i] == targetContributor) {
                    print("friend found");
                    contributors.removeAtIndex(i);
                    print(contributors);
                }
            }
        }
        
    }

}
