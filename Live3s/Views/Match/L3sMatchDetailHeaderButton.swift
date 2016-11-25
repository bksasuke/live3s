//
//  L3sMatchDetailHeaderButton.swift
//  Live3s
//
//  Created by phuc on 12/11/15.
//  Copyright © 2015 com.phucnguyen. All rights reserved.
//

import UIKit

@objc protocol L3sMatchDetailHeaderButtonDelegate: NSObjectProtocol {
    func didTapButton(_ button: L3sMatchDetailHeaderButton)
}

@IBDesignable
class L3sMatchDetailHeaderButton: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    var delegate: L3sMatchDetailHeaderButtonDelegate?
    
    @IBInspectable var selected: Bool = false {
        didSet {
            backgroundView.isHidden = !selected
            if selected {
                icon.image = iconSelected
                title.textColor = UIColor.white
            } else {
                icon.image = iconImage
                title.textColor = HEADER_BACKGROUND_COLOR
            }
        }
    }
    
    @IBInspectable var titleText: String? {
        didSet {
            title.text = AL0604.localization(titleText!)
        }
    }
    
    @IBInspectable var iconImage: UIImage? {
        didSet {
            icon.image = iconImage
        }
    }
    
    var iconSelected: UIImage?
    

    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var icon: UIImageView!
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit() -> UIView {
        func nibName() -> String {
            return type(of: self).description().components(separatedBy: ".").last!
        }
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName(), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(view)
        backgroundView.image = UIImage(named: "bg_tabbar.png")
        let tap = UITapGestureRecognizer(target: self, action: #selector(L3sMatchDetailHeaderButton.didTapHandle(_:)))
        addGestureRecognizer(tap)
        return view
    }

    func didTapHandle(_ tap: UITapGestureRecognizer) {
        delegate?.didTapButton(self)
    }
}
