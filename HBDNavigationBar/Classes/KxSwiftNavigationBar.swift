//
//  KxSwiftNavigationBar.swift
//  KxSwiftNavigation
//
//  Created by 许亚光 on 2022/3/11.
//  Copyright © 2022 浪里小海豚. All rights reserved.
//

import Foundation
import UIKit

open class KxSwiftNavigationBar: UINavigationBar {
    lazy var fakeView: UIVisualEffectView       = kx_fakeView()
    lazy var shadowImageView: UIImageView       = kx_shadowImageView()
    lazy var backgroundImageView: UIImageView   = kx_backgroundImageView()
}

extension KxSwiftNavigationBar {
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if !self.isUserInteractionEnabled || self.isHidden || self.alpha <= 0.01 {
            return nil
        }

        guard let view = super.hitTest(point, with: event) else {
            return nil
        }

        let viewName = view.className

        if view.isKind(of: self.classForCoder) {
            for subview in self.subviews {
                let subviewName = subview.className
                let array = ["_UINavigationItemButtonView"]
                if array.contains(subviewName) {
                    let convertedPoint = self.convert(point, to: subview)
                    var bounds = subview.bounds
                    if bounds.size.width < 80 {
                        bounds = bounds.insetBy(dx: bounds.size.width - 80, dy: 0)
                    }
                    if bounds.contains(convertedPoint) {
                        return view
                    }
                }
            }
        }

        let array = ["_UINavigationBarContentView", "_UIButtonBarStackView", self.className]
        if array.contains(viewName) {
            if self.backgroundImageView.image != nil {
                if self.backgroundImageView.alpha <= 0.01 {
                    return nil
                }
            } else if (self.fakeView.alpha < 0.01) {
                return nil
            }
        }

        if view.bounds.equalTo(.zero) {
            return nil;
        }

        return view
    }
    
    open override var barTintColor: UIColor? {
        didSet(newValue) {
            guard let lastView = fakeView.subviews.last else {
                return
            }
            lastView.backgroundColor = newValue
            makeSureFakeView()
        }
    }
    
    open override var shadowImage: UIImage? {
        didSet {
            guard let image = shadowImage else {
                self.shadowImageView.backgroundColor =  nil
                return
            }
            self.shadowImageView.image = image
            self.shadowImageView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 77.0/255)
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        fakeView.frame = fakeView.superview?.bounds ?? CGRect(x: 0, y: 0, width: 0, height: 0)
        shadowImageView.frame = CGRect(x: 0, y: shadowImageView.superview?.bounds.height ?? 0, width: shadowImageView.superview?.bounds.width ?? 0, height: 0.5)
        backgroundImageView.frame = backgroundImageView.superview?.bounds ?? CGRect(x: 0, y: 0, width: 0, height: 0)
    }
    
    open override func setBackgroundImage(_ backgroundImage: UIImage?, for barMetrics: UIBarMetrics) {
        backgroundImageView.image = backgroundImage
        makeSureFakeView()
    }
}

extension KxSwiftNavigationBar {
    fileprivate func kx_fakeView() -> UIVisualEffectView {
        super.setBackgroundImage(UIImage(), for: .top, barMetrics: .default)
        let fakeView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        fakeView.isUserInteractionEnabled = false
        fakeView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.subviews.first?.insertSubview(fakeView, at: 0)
        return fakeView
    }
    
    fileprivate func kx_shadowImageView() -> UIImageView {
        super.shadowImage = UIImage()
        let shadowImageView = UIImageView()
        shadowImageView.isUserInteractionEnabled = false
        shadowImageView.contentScaleFactor = 1
        self.subviews.first?.insertSubview(shadowImageView, aboveSubview: fakeView)
        return shadowImageView
    }
    
    fileprivate func kx_backgroundImageView() -> UIImageView {
        let backgroundImageView = UIImageView()
        backgroundImageView.contentScaleFactor = 1
        backgroundImageView.isUserInteractionEnabled = false
        backgroundImageView.contentMode = .scaleToFill
        backgroundImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.subviews.first?.insertSubview(backgroundImageView, aboveSubview: fakeView)
        return backgroundImageView
    }
}

extension KxSwiftNavigationBar {
    fileprivate func makeSureFakeView() {
        UIView.setAnimationsEnabled(false)

        if fakeView.superview == nil {
            subviews.first?.insertSubview(fakeView, at: 0)
            fakeView.frame = fakeView.superview?.bounds ?? CGRect(x: 0, y: 0, width: 0, height: 0)
        }
        
        if shadowImageView.superview == nil {
            subviews.first?.insertSubview(shadowImageView, aboveSubview: fakeView)
            shadowImageView.frame = CGRect(x: 0, y: shadowImageView.superview?.bounds.height ?? 0, width: shadowImageView.superview?.bounds.width ?? 0, height: 0.5)
        }
        
        if backgroundImageView.superview == nil {
            subviews.first?.insertSubview(backgroundImageView, aboveSubview: fakeView)
            backgroundImageView.frame = backgroundImageView.superview?.bounds ?? CGRect(x: 0, y: 0, width: 0, height: 0)
        }
        
        UIView.setAnimationsEnabled(true)
    }
}


