//
//  ViewController.swift
//  PostcardControllerDemo
//
//  Created by EamonLiang on 2019/9/4.
//  Copyright © 2019 EamonLiang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        let pushBtn = UIButton(type: .system)
        pushBtn.setTitleColor(.red, for: .normal)
        pushBtn.setTitle("presentTextVC", for: .normal)
        pushBtn.addTarget(self, action: #selector(onPushBtnPress), for: .touchUpInside)
        view.addSubview(pushBtn)
        pushBtn.snp.makeConstraints { (make) in
            make.center.equalTo(view)
        }
    }
    
    @objc private func onPushBtnPress() {
        let testVC = PostcardTestViewController()
        let nav = PostcardNavigationController(rootViewController: testVC)
        present(nav, animated: true, completion: nil)
    }
}

