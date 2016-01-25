//
//  InvitationsViewController.swift
//  Mosaiek
//
//  Created by Jonathan Schapiro on 1/19/16.
//  Copyright © 2016 Jonathan Schapiro. All rights reserved.
//

import UIKit

class InvitationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var invitationsTable: UITableView!
    
    var notifications:Array<PFObject>?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Welcome to the invitations viewcontroller")
        
        self.invitationsTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.invitationsTable.delegate = self;
        self.invitationsTable.dataSource = self;
    
        getNotifications();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func getNotifications(){
        
        User.getNotificiations { (notifications: Array<PFObject>?) -> Void in
            
            if let userNotifications = notifications {
                self.notifications = userNotifications;
                self.invitationsTable.reloadData();
            }
            
        }
        
    }
    
    
    //#MARK - TableViewDelegate Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let dataSource = self.notifications {
            
           return dataSource.count;
            
        } else {
            return 1;
        }
        
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        
        
        if let invitations = self.notifications{
            cell.textLabel?.text = invitations[indexPath.row]["description"] as? String;
            
        } else {
            cell.textLabel?.text = "You do not have any invitations";
        }
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
        
    }


}
