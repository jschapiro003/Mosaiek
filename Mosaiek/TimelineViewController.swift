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
    
    @IBOutlet weak var mosaicTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mosaicTable.delegate = self;
        self.mosaicTable.dataSource = self;
        
        self.loadUsersMosaics();
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
    
    
    //#MARK - TableViewDelegate Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return timelineMosaics.count;
        
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:TimelineMosaicCell = tableView.dequeueReusableCellWithIdentifier("timelineMosaicCell", forIndexPath: indexPath) as! TimelineMosaicCell
        
        let mosaicThumbnail:PFFile? = timelineMosaics[indexPath.row]["thumbnail"] as? PFFile;
        
        if let thumbnail = mosaicThumbnail {
            MosaicImage.fileToImage(thumbnail, completion: { (mosaicImage) -> Void in
                if let mosaicImg = mosaicImage {
                    cell.mosaicThumbnailImageView.image = mosaicImg;
                }
                
            })
        }
        
        cell.mosaicName?.text = timelineMosaics[indexPath.row]["name"] as? String;
        cell.mosaicDescription?.text = timelineMosaics[indexPath.row]["description"] as? String;
        
        
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
        
    }

}
