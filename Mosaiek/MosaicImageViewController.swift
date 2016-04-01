//
//  MosaicImageViewController.swift
//  Mosaiek
//
//  Created by Jonathan Schapiro on 3/28/16.
//  Copyright © 2016 Jonathan Schapiro. All rights reserved.
//

import UIKit

class MosaicImageViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate {
    
    let reuseIdentifier = "cell" // also enter this string as the cell identifier in the storyboard
    
    var mosaicImages:[UIImage] = [];
    
    @IBOutlet weak var mosaicImageCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    

    
    // MARK: - UICollectionViewDataSource protocol
    
    // tell the collection view how many cells to make
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.mosaicImages.count
    }
    
    // make a cell for each cell index path
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! MosaicImageCell
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        
        cell.mosaicImage.image = self.mosaicImages[indexPath.row];
        
        cell.backgroundColor = UIColor.whiteColor() // make cell more visible in our example project
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
    }
}
