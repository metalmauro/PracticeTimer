//
//  BellCollectionViewCell.swift
//  PracticeTimer
//
//  Created by Matthew Mauro on 2017-03-03.
//  Copyright © 2017 Matthew Mauro. All rights reserved.
//

import UIKit

class BellCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imag: UIImageView!
    var soundString:String?
    
    @IBOutlet weak var selectionImage: UIImageView!
    
    func configure(_ sound:String,_ image:UIImage){
        self.soundString = sound
        self.imag.image = image
    }
}
