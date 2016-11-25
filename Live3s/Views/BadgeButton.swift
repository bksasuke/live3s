//
//  BadgeButton.swift
//  Live3s
//
//  Created by phuc on 12/30/15.
//  Copyright © 2015 com.phucnguyen. All rights reserved.
//

import UIKit

class BadgeButton: UIButton {
    fileprivate var badgeLabel: UILabel
    var badgeString: String? {
        didSet {
            setupBadgeViewWithString(badgeText: badgeString)
        }
    }
    
    var badgeEdgeInsets: UIEdgeInsets? {
        didSet {
            setupBadgeViewWithString(badgeText: badgeString)
        }
    }
    
    var badgeBackgroundColor = UIColor.red {
        didSet {
            badgeLabel.backgroundColor = badgeBackgroundColor
        }
    }
    
    var badgeTextColor = UIColor.white {
        didSet {
            badgeLabel.textColor = badgeTextColor
        }
    }
    
    override init(frame: CGRect) {
        badgeLabel = UILabel()
        super.init(frame: frame)
        // Initialization code
        setupBadgeViewWithString(badgeText: "")
    }
    
    required init?(coder aDecoder: NSCoder) {
        badgeLabel = UILabel()
        super.init(coder: aDecoder)
        setupBadgeViewWithString(badgeText: "")
    }
    
    func initWithFrame(frame: CGRect, withBadgeString badgeString: String, withBadgeInsets badgeInsets: UIEdgeInsets) -> AnyObject {
        
        badgeLabel = UILabel()
        badgeEdgeInsets = badgeInsets
        setupBadgeViewWithString(badgeText: badgeString)
        return self
    }
    
    fileprivate func setupBadgeViewWithString(badgeText: String?) {
        badgeLabel.clipsToBounds = true
        badgeLabel.text = badgeText
        badgeLabel.font = UIFont.systemFont(ofSize: 9)
        badgeLabel.textAlignment = .center
        badgeLabel.sizeToFit()
        let badgeSize = badgeLabel.frame.size
    
        let width = 18.0
        let height = 18.0
        var vertical: Double?, horizontal: Double?
        if let badgeInset = self.badgeEdgeInsets {
            vertical = Double(badgeInset.top) - Double(badgeInset.bottom)
            horizontal = Double(badgeInset.left) - Double(badgeInset.right)
            
            let x = (Double(bounds.size.width) - 10 + horizontal!)
            let y = -(Double(badgeSize.height) / 2) - 10 + vertical!
            badgeLabel.frame = CGRect(x: x, y: y, width: width, height: height)
        } else {
            let x = self.frame.width - CGFloat((width / 1.5))
            let y = CGFloat((height/2))
            badgeLabel.frame = CGRect(x: x, y: y, width: CGFloat(width), height: CGFloat(height))
        }
        
        setupBadgeStyle()
        addSubview(badgeLabel)
        
        badgeLabel.isHidden = badgeText != nil ? false : true
    }
    
    fileprivate func setupBadgeStyle() {
        badgeLabel.textAlignment = .center
        badgeLabel.backgroundColor = badgeBackgroundColor
        badgeLabel.textColor = badgeTextColor
        badgeLabel.layer.cornerRadius = 5
    }
}
