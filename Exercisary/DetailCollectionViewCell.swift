//
//  DetailCollectionViewCell.swift
//  Exercisary
//
//  Created by 유영재 on 2023/06/13.
//

import UIKit

class DetailCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var markerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var kindLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        memoLabel.layer.borderColor = UIColor.lightGray.cgColor
        memoLabel.layer.borderWidth = 0.7
        memoLabel.layer.cornerRadius = 20
        
        markerView.layer.cornerRadius = 5
    }
}
