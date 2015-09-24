//
//  AlreadyAnsweredQuestionsCollectionViewCell.swift
//  QuppledV5
//
//  Created by Jamie Charry on 8/20/15.
//  Copyright (c) 2015 Jamie Charry. All rights reserved.
//

import UIKit

class AlreadyAnsweredQuestionsCollectionViewCell: UICollectionViewCell {
    
    var answerLabel: UILabel!
    var chosenAnswer: Int!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        answerLabel = UILabel(frame: self.bounds)
        answerLabel.textAlignment = NSTextAlignment.Center
        self.addSubview(answerLabel)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    var answerText: String? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        answerLabel.text = answerText!
    }
    
    
}
