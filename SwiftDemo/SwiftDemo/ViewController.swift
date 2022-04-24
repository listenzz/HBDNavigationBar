//
//  ViewController.swift
//  SwiftDemo
//
//  Created by 许亚光 on 2022/4/24.
//

import UIKit
import HBDNavigationBar

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        navigationItem.title = "我是标题"
        
        let pushButton = UIButton(type: .custom)
        pushButton.frame = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height/2)
        pushButton.titleLabel?.font = .systemFont(ofSize: 22)
        pushButton.setTitle("Push", for: .normal)
        pushButton.setTitleColor(.blue, for: .normal)
        pushButton.addTarget(self, action: #selector(pushButtonAciton), for: .touchUpInside)
        view.addSubview(pushButton)
        
        let presentButton = UIButton(type: .custom)
        presentButton.frame = CGRect(x: 0, y: view.bounds.size.height/2, width: view.bounds.size.width, height: view.bounds.size.height/2)
        presentButton.titleLabel?.font = .systemFont(ofSize: 22)
        presentButton.setTitle("Present", for: .normal)
        presentButton.setTitleColor(.blue, for: .normal)
        presentButton.addTarget(self, action: #selector(presentButtonAciton), for: .touchUpInside)
        view.addSubview(presentButton)
        
        navigation.barStyle = .black
        navigation.barTintColor = .random
        navigation.tintColor = .white
        navigation.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17),
                                          NSAttributedString.Key.foregroundColor: UIColor.white]
        
        let backItem = UIBarButtonItem()
        backItem.title = title
        navigationItem.backBarButtonItem = backItem
        
        if self.presentingViewController != nil {
            let dismissItem = UIBarButtonItem(title: "Dismiss", style: .plain, target: self, action: #selector(dismissButtonAction))
            navigationItem.rightBarButtonItem = dismissItem
        }
    }
    

}

extension ViewController {
    
    @objc func pushButtonAciton(_ sender: UIButton) {
        let vc = ViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func presentButtonAciton(_ sender: UIButton) {
        let vc = NavigationController(rootViewController: ViewController())
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    @objc func dismissButtonAction(_ sender: UIButton) {
        if self.presentationController != nil {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}

extension UIColor {
    
    static var random: UIColor {
        return UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1.0)
    }
    
}
