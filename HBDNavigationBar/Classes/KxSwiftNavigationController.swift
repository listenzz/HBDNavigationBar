//
//  KxSwiftNavigationController.swift
//  KxSwiftNavigation
//
//  Created by 许亚光 on 2022/3/11.
//  Copyright © 2022 浪里小海豚. All rights reserved.
//

import Foundation
import UIKit

open class KxSwiftNavigationController: UINavigationController {
    
    var pan: KxSwiftNavigationRecognizer?
    lazy var fromFakeBar: UIVisualEffectView? = kx_fakeBar()
    lazy var toFakeBar: UIVisualEffectView? = kx_fakeBar()
    
    lazy var fromFakeShadow: UIImageView? = kx_fakeShadow()
    lazy var toFakeShadow: UIImageView? = kx_fakeShadow()
    
    public override var delegate: UINavigationControllerDelegate? {
        didSet {
            if delegate is KxSwiftNavigationRecognizer || pan != nil {
                super.delegate = delegate
            } else {
                pan?.proxyDelegate = delegate
            }
        }
    }

    public override var interactivePopGestureRecognizer: UIGestureRecognizer? {
        return pan
    }
    
    public override var childForStatusBarHidden: UIViewController? {
        return topViewController
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.navigation.barStyle == .black ? .lightContent : .default
    }
    
    public override var childForHomeIndicatorAutoHidden: UIViewController? {
        return topViewController
    }
    
    var fromFakeImageView: UIImageView? = UIImageView()
    var toFakeImageView: UIImageView? = UIImageView()
    weak var poppingViewController: UIViewController?
    
    public override init(rootViewController: UIViewController) {
        super.init(navigationBarClass: KxSwiftNavigationBar.self, toolbarClass: nil)
        viewControllers = [rootViewController]
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        navigationBar.isTranslucent = true
        navigationBar.shadowImage = UINavigationBar.appearance().shadowImage
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.shadowColor = UIColor.clear
            appearance.backgroundColor = UIColor.clear
            appearance.setBackIndicatorImage(UINavigationBar.appearance().backIndicatorImage, transitionMaskImage: UINavigationBar.appearance().backIndicatorTransitionMaskImage)
            navigationBar.scrollEdgeAppearance = appearance
            navigationBar.standardAppearance = appearance.copy()
        }
        pan = KxSwiftNavigationRecognizer(navigationController: self)
        pan?.proxyDelegate = delegate
        delegate = pan
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let _ = transitionCoordinator,
            let topViewController = topViewController {
            updateNavigationBar(for: topViewController)
        }
    }

    func superInteractivePopGestureRecognizer() -> UIGestureRecognizer? {
        return super.interactivePopGestureRecognizer
    }
        
    func showFakeBar(from: UIViewController, to: UIViewController) {
        guard let navigationBar = navigationBar as? KxSwiftNavigationBar else { return  }
        UIView.setAnimationsEnabled(false)
        navigationBar.fakeView.alpha = 0
        navigationBar.shadowImageView.alpha = 0
        navigationBar.backgroundImageView.alpha = 0
        showFakeBar(from: from)
        showFakeBar(to: to)
        UIView.setAnimationsEnabled(true)
    }
    
    func showFakeBar(from: UIViewController) {
        guard let fromFakeImageView = fromFakeImageView,
        let fromFakeShadow  = fromFakeShadow,
        let fromFakeBar = fromFakeBar else { return }
        
        let fakeBarFrame = fakeBarFrame(for: from)
        fromFakeImageView.image = from.navigation.computedBarImage
        fromFakeImageView.alpha = from.navigation.barAlpha
        fromFakeImageView.frame = fakeBarFrame
        from.view .addSubview(fromFakeImageView)
        
        fromFakeBar.subviews.last?.backgroundColor = from.navigation.computedBarTintColor
        fromFakeBar.alpha = (from.navigation.barAlpha == 0 || from.navigation.computedBarImage != nil) ? 0.01 : from.navigation.barAlpha
        
        if from.navigation.barAlpha == 0 || from.navigation.computedBarImage != nil {
            fromFakeBar.subviews.last?.alpha = 0.01
        }
        
        fromFakeBar.frame = fakeBarFrame
        from.view.addSubview(fromFakeBar)
        
        fromFakeShadow.alpha = from.navigation.computedBarShadowAlpha
        fromFakeShadow.frame = fakeShadowFrameWithBarFrame(fromFakeBar.frame)
        from.view.addSubview(fromFakeShadow)
    }
    
    func showFakeBar(to: UIViewController) {
        guard let toFakeImageView = toFakeImageView ,
        let toFakeShadow  = toFakeShadow,
        let toFakeBar = toFakeBar else { return }
        
        let fakeBarFrame = fakeBarFrame(for: to)
        toFakeImageView.image = to.navigation.computedBarImage
        toFakeImageView.alpha = to.navigation.barAlpha
        toFakeImageView.frame = fakeBarFrame
        to.view .addSubview(toFakeImageView)
        
        toFakeBar.subviews.last?.backgroundColor = to.navigation.computedBarTintColor
        toFakeBar.alpha = (to.navigation.barAlpha == 0 || to.navigation.computedBarImage != nil) ? 0.01 : to.navigation.barAlpha
        
        if to.navigation.barAlpha == 0 || to.navigation.computedBarImage != nil {
            toFakeBar.subviews.last?.alpha = 0.01
        }
        
        toFakeBar.frame = fakeBarFrame
        to.view.addSubview(toFakeBar)
        
        toFakeShadow.alpha = to.navigation.computedBarShadowAlpha
        toFakeShadow.frame = fakeShadowFrameWithBarFrame(toFakeBar.frame)
        to.view.addSubview(toFakeShadow)
    }
    
    func clearFake() {
        fromFakeBar?.removeFromSuperview()
        toFakeBar?.removeFromSuperview()
        fromFakeShadow?.removeFromSuperview()
        toFakeShadow?.removeFromSuperview()
        fromFakeImageView?.removeFromSuperview()
        toFakeImageView?.removeFromSuperview()
        
        fromFakeBar = kx_fakeBar()
        toFakeBar = kx_fakeBar()
        fromFakeShadow = kx_fakeShadow()
        toFakeShadow = kx_fakeShadow()
        fromFakeImageView = UIImageView()
        toFakeImageView = UIImageView()
    }
    
    func fakeBarFrame(for vc: UIViewController) -> CGRect {
        guard let back = navigationBar.subviews.first else { return CGRect()}
        var frame = navigationBar.convert(back.frame, to: vc.view)
        frame.origin.x = 0
        if (vc.edgesForExtendedLayout.rawValue & UIRectEdge.top.rawValue) == 0 {
            frame.origin.y = -frame.size.height
        }
        
        if let scrollView = vc.view as? UIScrollView {
            scrollView.clipsToBounds = false
            if scrollView.contentOffset.y == 0 {
                frame.origin.y = -frame.size.height
            }
        }
        
        return frame
    }
    
    func kx_fakeShadow() -> UIImageView {
        if let navigationBar = self.navigationBar as? KxSwiftNavigationBar {
            let shadow = UIImageView(image: navigationBar.shadowImageView.image)
            shadow.backgroundColor = navigationBar.shadowImageView.backgroundColor
            return shadow
        }
        return UIImageView()
    }
    
    func kx_fakeBar() -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: .light))
    }
    
    func checkBackButtonCorrect() {
        if #available(iOS 13.0, *) {
            return
        }
        
        if #available(iOS 11.0, *) {
            guard let coordinator = transitionCoordinator, coordinator.isInteractive == false, let topViewController = topViewController else {
                return
            }
            navigationBar.barStyle = topViewController.navigation.barStyle
            navigationBar.titleTextAttributes = topViewController.navigation.titleTextAttributes
        }
    }
    
}

extension KxSwiftNavigationController: UINavigationBarDelegate {
    
    public func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        if viewControllers.count > 1,
           let topViewController = topViewController,
           topViewController.navigationItem == item {
            if !topViewController.navigation.backInteractive {
                resetSubviewsInNavBar(navigationBar)
                return false
            }
            
        }
        return true
    }
    
    func resetSubviewsInNavBar(_ navBar: UINavigationBar) {
        guard #available(iOS 11, *) else {
            for (_ , element) in navBar.subviews.enumerated() {
                if element.alpha < 1 {
                    UIView.animate(withDuration: 0.25) {
                        element.alpha = 1.0
                    }
                }
            }
            return
        }
    }
    
    public override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        poppingViewController = topViewController
        let array = super.popToViewController(viewController, animated: animated)
        checkBackButtonCorrect()
        return array
    }
    
    public override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        poppingViewController = topViewController
        let array = super.popToRootViewController(animated: animated)
        checkBackButtonCorrect()
        return array
    }
    
    public override func popViewController(animated: Bool) -> UIViewController? {
        poppingViewController = topViewController
        let vc = super.popViewController(animated: animated)
        checkBackButtonCorrect()
        return vc
    }
}

open class KxSwiftNavigationRecognizer: UIScreenEdgePanGestureRecognizer {
    
    weak var proxyDelegate: UINavigationControllerDelegate?
    weak var nav: KxSwiftNavigationController?
    
    convenience init(navigationController: KxSwiftNavigationController) {
        self.init()
        nav = navigationController
        edges = .left
        delegate = self
        addTarget(self, action: #selector(handleNavigationTransition(_:)))
        navigationController.view.addGestureRecognizer(self)
        navigationController.superInteractivePopGestureRecognizer()?.isEnabled = false
    }
    
    @objc
    func handleNavigationTransition(_ pan: UIScreenEdgePanGestureRecognizer) {
        guard let nav = nav else { return }
        if !(self.proxyDelegate?.responds(to: #selector(navigationController(_:interactionControllerFor:))) ?? false) {
            if let target = nav.superInteractivePopGestureRecognizer()?.delegate,
               target.responds(to: #selector(handleNavigationTransition(_:))) {
                target.perform(#selector(handleNavigationTransition(_:)), with: pan)
            }
        }

        if let coordinator = nav.transitionCoordinator,
           let from = coordinator.viewController(forKey: .from),
           let to = coordinator.viewController(forKey: .to),
           (pan.state == .began || pan.state == .changed) {
            
            nav.navigationBar.tintColor = blendColor(from: from.navigation.tintColor ?? UIColor.clear, to: to.navigation.tintColor ?? UIColor.clear, percent: coordinator.percentComplete)
        }
    }
}


extension KxSwiftNavigationRecognizer: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let nav = nav, nav.children.count > 1 else {
            return false
        }
        guard let topVC = nav.topViewController else { return true }
        return topVC.navigation.backInteractive
    }
}


extension KxSwiftNavigationRecognizer: UINavigationControllerDelegate {
    
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let proxyDelegate = proxyDelegate, proxyDelegate.responds(to: #selector(navigationController(_:willShow:animated:))) {
            proxyDelegate.navigationController?(navigationController, willShow: viewController, animated: animated)
        }
        
        if !viewController.navigation.extendedLayoutDidSet {
            adjustLayout(viewController)
            viewController.navigation.extendedLayoutDidSet = true
        }
        
        guard let nav = nav else { return }
        
        if let coordinator = nav.transitionCoordinator {
            showViewController(viewController: viewController, coordinator: coordinator)
        } else {
            if !animated && nav.children.count > 1 {
                let last = nav.children[nav.children.count - 2]
                if shouldShowFake(viewController, from: last, to: viewController) {
                    nav.showFakeBar(from: last, to: viewController)
                    return
                }
            }
            nav.updateNavigationBar(for: viewController)
        }
    }
    
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if let proxyDelegate = proxyDelegate,
            proxyDelegate.responds(to: #selector(navigationController(_:didShow:animated:))) {
            proxyDelegate .navigationController?(navigationController, didShow: viewController, animated: animated)
        }
        guard let nav = nav else { return }
        if !animated {
            nav.updateNavigationBar(for: viewController)
            nav.clearFake()
        }
        nav.poppingViewController = nil
    }
    
    public func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        if let proxyDelegate = proxyDelegate,
           proxyDelegate.responds(to: #selector(navigationControllerSupportedInterfaceOrientations(_:))){
            return  proxyDelegate.navigationControllerSupportedInterfaceOrientations?(navigationController) ?? .portrait
        }
        return .portrait
    }
    
    public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        
        if let proxyDelegate = proxyDelegate,
           proxyDelegate.responds(to: #selector(navigationController(_:interactionControllerFor:))){
            return proxyDelegate.navigationController?(navigationController, interactionControllerFor: animationController)
        }
        
        return nil
    }
    
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let proxyDelegate = proxyDelegate,
           proxyDelegate.responds(to: #selector(navigationController(_:animationControllerFor:from:to:))){
            return proxyDelegate.navigationController?(navigationController, animationControllerFor: operation, from: fromVC, to: toVC)
        }
        return nil
    }
    
    
    func showViewController(viewController: UIViewController, coordinator: UIViewControllerTransitionCoordinator) {
        guard let from = coordinator.viewController(forKey: .from),
              let to = coordinator.viewController(forKey: .to),
              let nav = nav,
              let navigationBar = nav.navigationBar as? KxSwiftNavigationBar else { return }
        
        nav.updateNavigationBarStyle(for: viewController)
        
        coordinator.animate { _ in
            let shouldFake = shouldShowFake(viewController, from: from, to: to)
            if shouldFake {
                nav.updateNavigationBarTinitColor(for: viewController)
                nav.showFakeBar(from: from, to: to)
            } else {
                nav.updateNavigationBar(for: viewController)
                if #available(iOS 13.0, *) , to == viewController {
                    navigationBar.scrollEdgeAppearance?.backgroundColor = viewController.navigation.computedBarTintColor
                    navigationBar.scrollEdgeAppearance?.backgroundImage = viewController.navigation.computedBarImage
                    navigationBar.standardAppearance.backgroundColor = viewController.navigation.computedBarTintColor
                    navigationBar.standardAppearance.backgroundImage = viewController.navigation.computedBarImage
                }
            }
        } completion: { context in
            nav.poppingViewController = nil
            if #available(iOS 13.0, *) {
                navigationBar.scrollEdgeAppearance?.backgroundColor = UIColor.clear
                navigationBar.scrollEdgeAppearance?.backgroundImage = nil
                navigationBar.standardAppearance.backgroundColor = UIColor.clear
                navigationBar.standardAppearance.backgroundImage = nil
            }
            
            if context.isCancelled {
                if to == viewController {
                    nav.updateNavigationBar(for: from)
                }
            } else {
                nav.updateNavigationBar(for: viewController)
            }
            if to == viewController {
                nav.clearFake()
            }
        }
    }
}


//MARK: - UINavigationController
extension UINavigationController {
    func updateNavigationBar(for vc: UIViewController) {
        updateNavigationBarStyle(for: vc)
        updateNavigationBarTinitColor(for: vc)
        updateNavigationBarAlpha(for: vc)
        updateNavigationBarBackground(for: vc)
    }

    func updateNavigationBarStyle(for vc: UIViewController) {
        navigationBar.barStyle = vc.navigation.barStyle
    }
    
    func updateNavigationBarTinitColor(for vc: UIViewController) {
        navigationBar.tintColor = vc.navigation.tintColor
        navigationBar.titleTextAttributes = vc.navigation.titleTextAttributes
        if #available(iOS 13.0, *) {
            navigationBar.scrollEdgeAppearance?.titleTextAttributes = vc.navigation.titleTextAttributes ?? [:]
            navigationBar.standardAppearance.titleTextAttributes = vc.navigation.titleTextAttributes ?? [:]
        }
    }
    
    func updateNavigationBarAlpha(for vc: UIViewController) {
        guard let bar = navigationBar as? KxSwiftNavigationBar else {
            return
        }
        if vc.navigation.computedBarImage != nil {
            bar.fakeView.alpha = 0
            bar.backgroundImageView.alpha = vc.navigation.barAlpha
        } else {
            bar.fakeView.alpha = vc.navigation.barAlpha
            bar.backgroundImageView.alpha = 0
        }
        
        if let bgView = bar.value(forKeyPath: "_backgroundView") as? UIView {
            if vc.navigation.barAlpha == 0 {
                bgView.layer.mask = CALayer()
            } else {
                bgView.layer.mask = nil
            }
        }
        
        bar.shadowImageView.alpha = vc.navigation.computedBarShadowAlpha
    }
    
    func updateNavigationBarBackground(for vc: UIViewController) {
        navigationBar.barTintColor = vc.navigation.computedBarTintColor
        guard let bar = navigationBar as? KxSwiftNavigationBar else {
            return
        }
        bar.barTintColor = vc.navigation.computedBarTintColor
        bar.backgroundImageView.image = vc.navigation.computedBarImage
    }
}




//MARK: - Private Method
fileprivate func fakeShadowFrameWithBarFrame(_ frame: CGRect) -> CGRect {
    return CGRect(x: frame.origin.x, y: frame.size.height + frame.origin.y - 0.5, width: frame.size.width, height: 0.5)
}

fileprivate func blendColor(from: UIColor, to: UIColor, percent: CGFloat) -> UIColor {
    var fromRed: CGFloat = 0.0
    var fromGreen: CGFloat = 0.0
    var fromBlue: CGFloat = 0.0
    var fromAlpha: CGFloat = 0.0
    from.getRed(&fromRed, green: &fromGreen, blue: &fromBlue, alpha: &fromAlpha)
    
    var toRed: CGFloat = 0.0
    var toGreen: CGFloat = 0.0
    var toBlue: CGFloat = 0.0
    var toAlpha: CGFloat = 0.0
    to.getRed(&toRed, green: &toGreen, blue: &toBlue, alpha: &toAlpha)
    
    let newRed = fromRed + (toRed - fromRed) * CGFloat(fminf(1, Float(percent) * 4))
    let newGreen = fromGreen + (toGreen - fromGreen) * CGFloat(fminf(1, Float(percent) * 4))
    let newBlue = fromBlue + (toBlue - fromBlue) * CGFloat(fminf(1, Float(percent) * 4))
    let newAlpha = fromAlpha + (toAlpha - fromAlpha) * CGFloat(fminf(1, Float(percent) * 4))
    return UIColor(red: newRed, green: newGreen, blue: newBlue, alpha: newAlpha)
}

fileprivate func imageEqual(from: UIImage?, to: UIImage?) -> Bool{
    guard let from = from, let to = to else {
        return false
    }
    
    if from == to {
        return true
    }
    
    let dataFrom = from.pngData()
    let dataTo = to.pngData()
    guard let dataFrom = dataFrom, let dataTo = dataTo else { return false }
    return dataFrom == dataTo
}

fileprivate func imageHasAlpha(_ image: UIImage) -> Bool {
    guard let alpha: CGImageAlphaInfo = image.cgImage?.alphaInfo else {
        return false
    }
    
    return (alpha == .first ||
            alpha == .last ||
            alpha == .premultipliedFirst ||
            alpha == .premultipliedLast)
}

fileprivate func shouldShowFake(_ vc: UIViewController, from: UIViewController, to: UIViewController) -> Bool {
    if vc != to {
        return false
    }
    
    if imageEqual(from: from.navigation.computedBarImage, to: to.navigation.computedBarImage) {
        if abs(from.navigation.barAlpha - to.navigation.barAlpha) > 0.1 {
            return true
        }
        return false
    }
    
    if from.navigation.computedBarImage == nil && to.navigation.computedBarImage == nil && from.navigation.computedBarTintColor?.description == to.navigation.computedBarTintColor?.description {
        if abs(from.navigation.barAlpha - to.navigation.barAlpha) > 0.1 {
            return true
        }
        return false
    }
    
    return true
}

fileprivate func colorHasAlpha(_ color: UIColor?) -> Bool {
    guard let color = color else {
        return true
    }
 
    var r: CGFloat = 0
    var g: CGFloat = 0
    var b: CGFloat = 0
    var a: CGFloat = 0
    color.getRed(&r, green: &g, blue: &b, alpha: &a)
    return a < 1.0
}

fileprivate func adjustLayout(_ vc: UIViewController) {
    var isTranslucent = vc.navigation.barHidden || vc.navigation.barAlpha < 1.0
    if !isTranslucent {
        if let image = vc.navigation.computedBarImage {
            isTranslucent = imageHasAlpha(image)
        } else {
            isTranslucent = colorHasAlpha(vc.navigation.computedBarTintColor)
        }
    }
    
    if isTranslucent || vc.extendedLayoutIncludesOpaqueBars {
        vc.edgesForExtendedLayout = [vc.edgesForExtendedLayout, .top]
    } else {
        vc.edgesForExtendedLayout = vc.edgesForExtendedLayout.union(.top)
    }
    
    if vc.navigation.barHidden,
       #available(iOS 11.0, *) {
        let insets = vc.additionalSafeAreaInsets
        let height = vc.navigationController?.navigationBar.bounds.size.height ?? 0
        vc.additionalSafeAreaInsets = UIEdgeInsets(top: -height + insets.top, left: insets.left, bottom: insets.bottom, right: insets.right)
    }
}




