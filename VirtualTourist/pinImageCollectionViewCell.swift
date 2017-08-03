//
//  pinImageCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Raxit Cholera on 6/26/17.
//  Copyright © 2017 Raxit Cholera. All rights reserved.
//

import UIKit

class pinImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        layer.borderColor = UIColor.white.cgColor
        layer.cornerRadius = 5.0
        layer.borderWidth = 1.0
    }
    func bindCell(image: UIImage?)
    {
        activityView.startAnimating()
        if image != nil
        {
            activityView.isHidden = true
        }
        else
        {
            activityView.isHidden = false
        }
        imageView.image = image
    }
    
}
