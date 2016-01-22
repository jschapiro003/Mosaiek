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
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        print("hi there")
        self.friendsTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "friendCell")
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
        print(self.users)
        if let dataSource = self.users {
            print("data source", dataSource.count)
            return dataSource.count;
            
        } else {
            return 1;
        }
       
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = self.friendsTable.dequeueReusableCellWithIdentifier("friendCell")! as UITableViewCell
        
        print("adding a tableview cell",cell)
        
        if let allUsers = self.users {
            cell.textLabel?.text = allUsers[indexPath.row].username
        } else {
            cell.textLabel?.text = "Sorry no Users :("
        }
        
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }

}
