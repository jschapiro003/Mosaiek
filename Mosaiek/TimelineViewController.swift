//
//  TimelineViewController.swift
//  Mosaiek
//
//  Created by Jonathan Schapiro on 1/19/16.
//  Copyright © 2016 Jonathan Schapiro. All rights reserved.
//

import UIKit


class TimelineViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("Welcome to the timeline ", PFUser.currentUser()?.username)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
