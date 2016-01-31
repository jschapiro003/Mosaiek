//
//  AddFriendsViewController.swift
//  Mosaiek
//
//  Created by Jonathan Schapiro on 1/21/16.
//  Copyright © 2016 Jonathan Schapiro. All rights reserved.
//

import UIKit

class AddFriendsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var friendsTable: UITableView!
    
    var users:Array<User>?
    var friendsToAdd:Array<User>? = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.friendsTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.friendsTable.delegate = self;
        self.friendsTable.dataSource = self;
        
        User.loadAllUsers({ (users) -> Void in
            self.users = users;
            self.friendsTable.reloadData()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    
    //#MARK - TableViewDelegate Methods
    
     func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let dataSource = self.users {
            
            return dataSource.count;
            
        } else {
            return 1;
        }
       
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        
        
        if let allUsers = self.users {
            cell.accessoryType = .Checkmark
            cell.textLabel?.text = allUsers[indexPath.row].username;
            
            
        } else {
            cell.textLabel?.text = "Sorry no Users :("
        }
        
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
        
        //let cell = tableView.cellForRowAtIndexPath(indexPath);
        
        let friend = users?[indexPath.row];
        
        if let friendToAdd = friend {
            
            self.friendsToAdd?.append(friendToAdd);
            
        }
        
        
    }
    
    //#MARK - IBActions
    
    @IBAction func saveFriends(sender: AnyObject) {
        
        if let friendsToSave = self.friendsToAdd {
            User.saveFriends(friendsToSave, completion: { (success) -> Void in
                print(success);
            })
        }
        
        self.navigationController?.popToRootViewControllerAnimated(true);
    }

}
