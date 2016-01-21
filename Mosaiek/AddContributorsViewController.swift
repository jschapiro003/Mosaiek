//
//  AddContributorsViewController.swift
//  Mosaiek
//
//  Created by Jonathan Schapiro on 1/19/16.
//  Copyright © 2016 Jonathan Schapiro. All rights reserved.
//

import UIKit

class AddContributorsViewController: UIViewController {
    
    var delegate:GenerateNewMosaicDelegate?
    
    var contributors = [] //current users friends
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Welcome to the new add contributors view controller")
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadContributors(){
        //get friends of current user from parse
    }
    
    
    @IBAction func addContributors(sender: AnyObject) {
        if let delegateSet = self.delegate {
            delegateSet.contributorsAddedToMosaic() //pass contributors to add
            self.navigationController?.popToRootViewControllerAnimated(true);
        }
    }
    
    

}
