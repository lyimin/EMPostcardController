//
//  PostcardTestViewController.swift
//  EMPostcardControllerDemo
//
//  Created by EamonLiang on 2019/9/9.
//  Copyright © 2019 EamonLiang. All rights reserved.
//

import UIKit

class PostcardTestViewController: UIViewController {

    deinit {
        print("[%@ delloc]", NSStringFromClass(PostcardTestViewController.self))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let r: CGFloat = CGFloat(arc4random() % 255);
        let g: CGFloat = CGFloat(arc4random() % 255);
        let b: CGFloat = CGFloat(arc4random() % 255);
        view.backgroundColor = UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: 0.8)
        
        let pushBtn = UIButton(type: .system)
        pushBtn.setTitle("PUSH", for: .normal)
        pushBtn.addTarget(self, action: #selector(onPushBtnPress), for: .touchUpInside)
        view.addSubview(pushBtn)
        pushBtn.snp.makeConstraints { (make) in
            make.center.equalTo(view)
        }
        
        let popBtn = UIButton(type: .system)
        popBtn.setTitle("POP", for: .normal)
        popBtn.addTarget(self, action: #selector(onPopBtnPress), for: .touchUpInside)
        view.addSubview(popBtn)
        popBtn.snp.makeConstraints { (make) in
            make.centerX.equalTo(pushBtn.snp.centerX)
            make.top.equalTo(pushBtn.snp.bottom).offset(32)
        }
    }
    
    @objc private func onPushBtnPress() {
        
        let vc = PostcardTestViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func onPopBtnPress() {
        
        if self.navigationController!.viewControllers.count <= 1 {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
