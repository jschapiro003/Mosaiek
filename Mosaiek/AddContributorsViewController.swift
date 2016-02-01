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
        
        self.contributorsTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        
        
        if let username = self.contributors[indexPath.row]["profileName"] as? String {
            cell.textLabel?.text = username;
        }
            
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
        
        let contributor = self.contributors[indexPath.row];
        
        self.contributorsToAdd?.append(contributor as! PFUser);

        print(self.contributorsToAdd?.count)
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
    
    

}
