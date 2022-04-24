//
//  KxSwiftNavigation.swift
//  KxSwiftNavigation
//
//  Created by 许亚光 on 2022/3/11.
//  Copyright © 2022 浪里小海豚. All rights reserved.
//

import Foundation
import UIKit

public struct KxSwiftNavigation<Base> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol KxSwiftNavigationCompatible: AnyObject {
    associatedtype CompatibleType
    var navigation: CompatibleType { get set }
}

extension KxSwiftNavigationCompatible {
    public var navigation: KxSwiftNavigation<Self> {
        get { return KxSwiftNavigation(self) }
        set { }
    }
}

fileprivate func getAssociateObj<T>(_ obj: AnyObject, _ key: UnsafeRawPointer, _ defaultValue: T? = nil) -> T? {
    guard let value = objc_getAssociatedObject(obj, key) as? T else {
        return defaultValue
    }
    return value
}

fileprivate struct RuntimeKey {
    static let tintColor                = UnsafeRawPointer.init(bitPattern: "NAVIGATION_TINTCOLOR".hashValue)
    static let barTintColor             = UnsafeRawPointer.init(bitPattern: "NAVIGATION_BARTINTCOLOR".hashValue)
    static let barStyle                 = UnsafeRawPointer.init(bitPattern: "NAVIGATION_BARSTYLE".hashValue)
    static let barImage                 = UnsafeRawPointer.init(bitPattern: "NAVIGATION_BARIMAGE".hashValue)
    static let barAlpha                 = UnsafeRawPointer.init(bitPattern: "NAVIGATION_BARALPHA".hashValue)
    static let barHidden                = UnsafeRawPointer.init(bitPattern: "NAVIGATION_BARHIDDEN".hashValue)
    static let barShadownHidden         = UnsafeRawPointer.init(bitPattern: "NAVIGATION_BARSHADOWNHIDDEN".hashValue)
    static let barShadownAlpha          = UnsafeRawPointer.init(bitPattern: "NAVIGATION_BARSHADOWNALPHA".hashValue)
    static let titleTextAttributes      = UnsafeRawPointer.init(bitPattern: "NAVIGATION_TITLETEXTATTRIBUTES".hashValue)
    static let backInteractive          = UnsafeRawPointer.init(bitPattern: "NAVIGATION_BACKINTERACTIVE".hashValue)
    static let swipeBackEnabled         = UnsafeRawPointer.init(bitPattern: "NAVIGATION_SWIPBACKENABLED".hashValue)
    static let clickBackEnabled         = UnsafeRawPointer.init(bitPattern: "NAVIGATION_CLICKBACKENABLED".hashValue)
    static let extendedLayoutDidSet     = UnsafeRawPointer.init(bitPattern: "NAVIGATION_EXTENDEDLAYOUTDIDSET".hashValue)
    static let computedBarImage         = UnsafeRawPointer.init(bitPattern: "NAVIGATION_CONPUTERBARIMAGE".hashValue)
    static let computedBarTintColor     = UnsafeRawPointer.init(bitPattern: "NAVIGATION_COMPUTERBARTINTCOLOR".hashValue)
    static let computedBarShadowAlpha   = UnsafeRawPointer.init(bitPattern: "NAVIGATION_COMPUTERBARSHADOWALPHA".hashValue)
    static let blackBarStyle            = UnsafeRawPointer.init(bitPattern: "NAVIGATION_BLACKBARSTYLE".hashValue)
}

extension UIViewController: KxSwiftNavigationCompatible {}

public extension KxSwiftNavigation where Base: UIViewController  {
    
    var barStyle: UIBarStyle {
        get {
            assert(!(base is UINavigationController), "UINavigationController can't use this property")
            return getAssociateObj(base, RuntimeKey.barStyle!, UINavigationBar.appearance().barStyle)!
        }
        set {
            assert(!(base is UINavigationController), "UINavigationController can't use this property")
            objc_setAssociatedObject(base, RuntimeKey.barStyle!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var barTintColor: UIColor? {
        get {
            assert(!(base is UINavigationController), "UINavigationController can't use this property")
            return getAssociateObj(base, RuntimeKey.barTintColor!)
        }
        set {
            assert(!(base is UINavigationController), "UINavigationController can't use this property")
            objc_setAssociatedObject(base, RuntimeKey.barTintColor!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var barImage: UIImage? {
        get {
            assert(!(base is UINavigationController), "UINavigationController can't use this property")
            return getAssociateObj(base, RuntimeKey.barImage!)
        }
        set {
            assert(!(base is UINavigationController), "UINavigationController can't use this property")
            objc_setAssociatedObject(base, RuntimeKey.barImage!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var tintColor: UIColor? {
        get {
            assert(!(base is UINavigationController), "UINavigationController can't use this property")
            return getAssociateObj(base, RuntimeKey.tintColor!)
        }
        set {
            assert(!(base is UINavigationController), "UINavigationController can't use this property")
            objc_setAssociatedObject(base, RuntimeKey.tintColor!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var titleTextAttributes: [NSAttributedString.Key : Any]? {
        get {
            assert(!(base is UINavigationController), "UINavigationController can't use this property")
            if let obj: [NSAttributedString.Key : Any]? = getAssociateObj(base, RuntimeKey.titleTextAttributes!) {
                return obj
            }
            if let attributes = UINavigationBar.appearance().titleTextAttributes {
                guard attributes[.foregroundColor] != nil else {
                    var mtArr = attributes
                    var keyValue = [NSAttributedString.Key.foregroundColor: UIColor.white]
                    if barStyle != .black {
                        keyValue = [NSAttributedString.Key.foregroundColor: UIColor.black]
                    }
                    mtArr.merge(keyValue) {oldKeyValue,_ in
                        return oldKeyValue
                    }
                    return mtArr
                }
                return attributes
            }
            
            if barStyle == .black {
                return [.foregroundColor : UIColor.white]
            } else {
                return [.foregroundColor : UIColor.black]
            }
        }
        set {
            assert(!(base is UINavigationController), "UINavigationController can't use this property")
            objc_setAssociatedObject(base, RuntimeKey.titleTextAttributes!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var extendedLayoutDidSet: Bool {
        get {
            assert(!(base is UINavigationController), "UINavigationController can't use this property")
            return getAssociateObj(base, RuntimeKey.extendedLayoutDidSet!, false)!
        }
        set {
            objc_setAssociatedObject(base, RuntimeKey.extendedLayoutDidSet!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var barAlpha: Double {
        get {
            assert(!(base is UINavigationController), "UINavigationController can't use this property")
            if barHidden {
                return 0
            }
            return  getAssociateObj(base, RuntimeKey.barAlpha!, 1.0)!
        }
        set {
            assert(!(base is UINavigationController), "UINavigationController can't use this property")
            objc_setAssociatedObject(base, RuntimeKey.barAlpha!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var barHidden: Bool {
        get {
            assert(!(base is UINavigationController), "UINavigationController can't use this property")
            return getAssociateObj(base, RuntimeKey.barHidden!, false)!
        }
        set {
            assert(!(base is UINavigationController), "UINavigationController can't use this property")
            if newValue == true {
                base.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: UIView())
                base.navigationItem.titleView = UIView()
            } else {
                base.navigationItem.leftBarButtonItem = nil
                base.navigationItem.titleView = nil
            }
            objc_setAssociatedObject(base, RuntimeKey.barHidden!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var barShadowHidden: Bool {
        get {
            assert(!(base is UINavigationController), "UINavigationController can't use this property")
            return getAssociateObj(base, RuntimeKey.barShadownHidden!, false)!
        }
        set {
            objc_setAssociatedObject(base, RuntimeKey.barShadownHidden!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var barShadowAlpha: Double {
        get {
            assert(!(base is UINavigationController), "UINavigationController can't use this property")
            if barShadowHidden || barHidden || barAlpha == 0 {
                return 0.0
            }
            return getAssociateObj(base, RuntimeKey.barShadownAlpha!, 1.0)!
        }
        set {
            assert(!(base is UINavigationController), "UINavigationController can't use this property")
            objc_setAssociatedObject(base, RuntimeKey.barShadownAlpha!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var backInteractive: Bool {
        get {
            assert(!(base is UINavigationController), "UINavigationController can't use this property")
            return getAssociateObj(base, RuntimeKey.backInteractive!, true)!
        }
        set {
            objc_setAssociatedObject(base, RuntimeKey.backInteractive!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var computedBarImage: UIImage? {
        get {
            assert(!(base is UINavigationController), "UINavigationController can't use this property")
            guard let image = barImage else {
                if barTintColor != nil {
                    return nil
                }
                return UINavigationBar.appearance().backgroundImage(for: .default)
            }
            return image
        }
        set {
            assert(!(base is UINavigationController), "UINavigationController can't use this property")
        }
    }
    
    var computedBarShadowAlpha: Double {
        get {
            assert(!(base is UINavigationController), "UINavigationController can't use this property")
            if barShadowHidden {
                return 0
            }
            return barAlpha
        }
        set {
            assert(!(base is UINavigationController), "UINavigationController can't use this property")
        }
    }
    
    var computedBarTintColor: UIColor? {
        get {
            assert(!(base is UINavigationController), "UINavigationController can't use this property")
            if barHidden {
                return .clear
            }
            
            if barImage != nil {
                return nil
            }
            
            if let color = barTintColor {
                return color
                
            } else {
                if UINavigationBar.appearance().backgroundImage(for: .default) != nil {
                    return nil
                } else {
                    if let color = UINavigationBar.appearance().barTintColor {
                        return color
                    } else {
                        if UINavigationBar.appearance().barStyle == .default {
                            return UIColor(red: 247/255.0, green: 247/255.0, blue: 247/255.0, alpha: 0.8)
                        } else {
                            return UIColor(red: 28/255.0, green: 28/255.0, blue: 28/255.0, alpha: 0.729)
                        }
                    }
                }
            }
        }
        set {
            assert(!(base is UINavigationController), "UINavigationController can't use this property")
        }
    }
}

public extension KxSwiftNavigation where Base: UIViewController  {
    
    func setNeedsUpdateNavigationBar() {
        assert(!(base is UINavigationController), "UINavigationController can't use this method")
        guard let nav = base.navigationController as? KxSwiftNavigationController else {
            return
        }
        if base == nav.topViewController {
            nav.updateNavigationBar(for: base)
            nav.setNeedsStatusBarAppearanceUpdate()
        }
    }
}


public extension NSObject {
    
    @nonobjc var className: String {
        return String(describing: type(of: self))
    }
    
    @nonobjc static var className: String {
        return String(describing: Self.self)
    }
}
