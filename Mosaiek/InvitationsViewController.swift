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
        
        //self.invitationsTable.registerClass(InvitationCell.self, forCellReuseIdentifier: "invitationCell")
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
        
        let cell:InvitationCell = tableView.dequeueReusableCellWithIdentifier("invitationCell", forIndexPath: indexPath) as! InvitationCell
        
        
        if let invitations = self.notifications{
            if invitations.count > 0 {
                cell.notificationDescriptionLabel?.text = invitations[indexPath.row]["description"] as? String;
            } else {
                cell.notificationDescriptionLabel?.text = "You do not have any invitations";
            }
            
            
        } else {
            cell.notificationDescriptionLabel?.text = "You do not have any invitations";
        }
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
        
    }
    
    //#MARK - IBActions
    
    
    @IBAction func acceptInvitation(sender: AnyObject) {
        
        var indexPath: NSIndexPath!
        
        //get indexPath of button clicked
        if let button = sender as? UIButton {
            if let superview = button.superview {
                if let cell = superview.superview as? InvitationCell {
                    indexPath = self.invitationsTable.indexPathForCell(cell)
                }
            }
        }
        
        //modify notification of that specific rows (indexPath.row)
        if let notificationList = self.notifications{
            let notificationType = notificationList[indexPath.row]["type"];
            
            notificationList[indexPath.row]["status"] = 1;//notification has been seen
            
            notificationList[indexPath.row].saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                if (error != nil){
                    print("error:",error);
                } else {
                    print("success: ",success);
                    
                    //depending on type, update contributors table or friends table
                    if (notificationType as! Int == 0){
                        
                        print("updating a friendship");
                        let notificationFriend = notificationList[indexPath.row]["sender"];
                        
                        if let friend = notificationFriend {
                            User.confirmFriendRequest(PFUser.currentUser()!, friend:friend as! PFObject);
                        }
                        
                        //consider adding another column to notifications
                        
                        
                    } else if (notificationType as! Int == 1){
                        
                        print("updating a contribution");
                        //consider adding another column to notification
                        let notificationMosaic = notificationList[indexPath.row]["mosaic"];
                        
                        if let mosaic = notificationMosaic {
                            
                            Mosaic.updateMosaicContributor(PFUser.currentUser()!, mosaic: mosaic as! PFObject);
                        }
                        
                    } else {
                        
                        return;
                    }
                }
            })
            
            self.navigationController?.popToRootViewControllerAnimated(true);
        }
        print("accepting invitation",indexPath.row);
    }
    


}
