//
//  LoadingView.swift
//  Live3s
//
//  Created by phuc on 12/10/15.
//  Copyright © 2015 com.phucnguyen. All rights reserved.
//

import Foundation
import UIKit
import NVActivityIndicatorView

class LoadingView: UIView {
    static let sharedInstance = LoadingView(frame: CGRect.zero)
    
    fileprivate var imageView: NVActivityIndicatorView!
    fileprivate var label: UILabel!
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createView()
    }
    override init(frame: CGRect) {
        let aframe = UIScreen.main.bounds
        super.init(frame: aframe)
        createView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.center = center
        bringSubviewToFront(imageView)
    }
    
    func showTextInView(_ inView: UIView, text: String) {
        frame = inView.bounds
        layoutSubviews()
        label.text = text
        inView.addSubview(self)
    }
    
    func hideText() {
        self.removeFromSuperview()
    }
    
    func showLoadingView(_ inview: UIView) {
        frame = inview.bounds
        layoutSubviews()
        inview.addSubview(self)
        imageView.startAnimation()
    }
    
    func hideLoadingView() {
        self.removeFromSuperview()
        imageView.stopAnimation()
    }
    
    fileprivate func createView() {
        autoresizingMask = [.flexibleHeight, .flexibleWidth]
        isUserInteractionEnabled = true
        let rect = CGRect(x: 0, y: 0, width: 80, height: 80)
        let type = NVActivityIndicatorType.BallScale
        imageView = NVActivityIndicatorView(frame: rect, type: type, color: UIColor.orangeColor(), padding: 10)
        imageView.backgroundColor = UIColor(white: 0, alpha: 0.8)
        imageView.layer.shadowOffset = CGSize(width: 2, height: 2)
        imageView.layer.shadowColor = UIColor.blackColor().CGColor
        imageView.layer.cornerRadius = 5
        imageView.center = center
        addSubview(imageView)
        label = UILabel(frame: bounds)
        label.autoresizingMask = [.flexibleHeight, .flexibleHeight]
        label.textAlignment = .center
        addSubview(label)
    }
}
