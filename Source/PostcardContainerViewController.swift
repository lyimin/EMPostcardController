//
//  PostcardContainerViewController.swift
//  PostcardControllerDemo
//
//  Created by EamonLiang on 2019/9/4.
//  Copyright © 2019 EamonLiang. All rights reserved.
//

import UIKit


internal class PostcardContainerViewController: UIViewController {
    
    //MARK: >> Getter
    //------------------------------------------------------------------------
    
    var containerMarginTop: CGFloat {
        get {
            var top: CGFloat = 24
            if let nav = self.navigationController, nav is PostcardNavigationController {
                let nav = self.navigationController as! PostcardNavigationController
                top = nav.postcardMarginTop
            }
            return top
        }
    }
    
    var containerCornerRadius: CGFloat {
        get {
            var cornerRadius: CGFloat = 13
            if let nav = self.navigationController, nav is PostcardNavigationController {
                let nav = self.navigationController as! PostcardNavigationController
                cornerRadius = nav.postcardCornerRadius
            }
            return cornerRadius
        }
    }
    
    weak var postcardNavController: PostcardNavigationController?
    var contentViewController: UIViewController!
    var contentDetectScrollView: UIScrollView?
    var contentInteractiveBarStyle: NSInteger!
    
    //MARK: >> Private Properties
    //------------------------------------------------------------------------
    
    internal lazy var topBarView: UIView = {
        
        var topBarView = UIView()
        return topBarView
    }()
    
    internal lazy var postcardView: UIView = {
        
        var postcardView = UIView()
        postcardView.layer.masksToBounds = true
        postcardView.layer.cornerRadius = containerCornerRadius
        postcardView.backgroundColor = .white
        return postcardView
    }()
    
    internal lazy var interactiveBarView: UIView = {
        
        var interactiveBarView = UIView()
        return interactiveBarView
    }()
    
    internal lazy var interactiveBarArrowView: UIImageView = {
        var arrowView = UIImageView()
        arrowView.contentMode = .scaleAspectFit
        arrowView.image = UIImage(named: "control_interactive_down_arrow_black")
        return arrowView
    }()
    
    internal lazy var containerView: UIView = {
        
        var containerView = UIView()
        containerView.backgroundColor = .white
        return containerView
    }()
    
    internal lazy var postcardMaskView: UIView = {
        
        var postcardMaskView = UIView()
        postcardMaskView.alpha = 0
        postcardMaskView.backgroundColor = UIColor.white
        postcardMaskView.isHidden = true
        return postcardMaskView
    }()
    
    internal lazy var postcardSnapView: UIView = {
        
        var postcardSnapView = UIView()
        postcardSnapView.layer.masksToBounds = true
        postcardSnapView.layer.cornerRadius = containerCornerRadius
        postcardSnapView.backgroundColor = .white
        postcardSnapView.alpha = 0
        postcardSnapView.isHidden = true
        return postcardSnapView
    }()
    
    internal lazy var backgroundMaskView: UIView = {
        
        var backgroundMaskView = UIView()
        backgroundMaskView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.64)
        backgroundMaskView.alpha = 0
        backgroundMaskView.isHidden = true
        return backgroundMaskView
    }()
    
    //MARK: >> Life Cycle
    //------------------------------------------------------------------------
    
    deinit {
        print("[%@ delloc]", NSStringFromClass(PostcardContainerViewController.self))
        
        contentDetectScrollView?.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // postcard View
        view.addSubview(postcardView)
        postcardView.snp.updateConstraints { (make) in
            make.top.equalTo(view).offset(containerMarginTop)
            make.left.right.equalTo(view)
            make.bottom.equalTo(view).offset(containerCornerRadius)
        }
        
        // topbar View
        view.addSubview(topBarView)
        topBarView.snp.updateConstraints { (make) in
            make.top.left.right.equalTo(view)
            make.bottom.equalTo(postcardView.snp.top)
        }
        
        let topTap = UITapGestureRecognizer(target: self, action: #selector(onTopTapGesture(gesture:)))
        topBarView.addGestureRecognizer(topTap)
        
        // container View
        postcardView.addSubview(containerView)
        containerView.snp.updateConstraints { (make) in
            make.top.left.right.equalTo(postcardView)
            make.bottom.equalTo(postcardView.snp.bottom).offset(-containerCornerRadius)
        }
        
        // interactive bar
        postcardView.addSubview(interactiveBarView)
        interactiveBarView.snp.updateConstraints { (make) in
            make.top.left.right.equalTo(postcardView)
            make.height.equalTo(28)
        }
        
        // interactive bar arrow
        interactiveBarView.addSubview(interactiveBarArrowView)
        interactiveBarArrowView.snp.updateConstraints { (make) in
            make.size.equalTo(CGSize(width: 25, height: 8))
            make.center.equalTo(interactiveBarView)
        }
        
        // content view controller
        addChild(contentViewController)
        containerView.addSubview(contentViewController.view)
        contentViewController.view.snp.updateConstraints { (make) in
            make.edges.equalTo(containerView)
        }
        
        // postcard mask
        postcardView.addSubview(postcardMaskView)
        postcardMaskView.snp.updateConstraints { (make) in
            make.edges.equalTo(postcardView)
        }
        
        // postcard snap
        view.insertSubview(postcardSnapView, belowSubview: postcardView)
        postcardSnapView.snp.updateConstraints { (make) in
            make.top.equalTo(view).offset(containerMarginTop)
            make.left.right.equalTo(view)
            make.bottom.equalTo(view).offset(containerCornerRadius)
        }
        
        // background mask
        view.insertSubview(backgroundMaskView, belowSubview: postcardView)
        backgroundMaskView.snp.updateConstraints { (make) in
            make.edges.equalTo(view)
        }
        
        // >> config
        onControllingConfiguration()
    }
    
    convenience init(withController viewController: UIViewController) {
        self.init()
        contentViewController = viewController
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}


//MARK: >> Private Methods
//------------------------------------------------------------------------

extension PostcardContainerViewController {
    
    @objc fileprivate func onInteractivePanGesture(gesture: UIPanGestureRecognizer) {
        
        guard let nav = postcardNavController else {
            print("error nav = nil")
            return
        }
        // 手势pop时，会调用popViewController方法，nav的childVC数量会-1
        if nav.viewControllers.count > 1 {
            nav.interactivePop(withPanGestureRecognizer: gesture)
        }
        else {
            if nav.isPopGestureActive {
                nav.interactivePop(withPanGestureRecognizer: gesture)
            }
            else {
                nav.interactiveDismiss(withPanGestureRecognizer: gesture)
            }
        }
        
    }
    
    @objc fileprivate func onTopTapGesture(gesture: UITapGestureRecognizer) {
        children.forEach {
            if $0 is PostcardNavigationControlling {
                let vc = $0 as! PostcardNavigationControlling
                let nav = navigationController as! PostcardNavigationController
                vc.didTappedOnTopBarAtPostcard?(nav: nav)
            }
        }
    }
    
    fileprivate func onControllingConfiguration() {
        
        if contentViewController is PostcardNavigationControlling {
            
            let pvc = contentViewController as! PostcardNavigationControlling
            let nav = navigationController as! PostcardNavigationController
            postcardNavController = nav
            
            // styleBar
            if let style = pvc.preferredInteractiveBarStyleAtPostcard?(nav: nav) {
                
                switch style {
                case .white:
                    interactiveBarArrowView.image = UIImage(named: "control_interactive_down_arrow_white")
                    interactiveBarArrowView.isHidden = false
                    break
                case .black:
                    interactiveBarArrowView.image = UIImage(named: "control_interactive_down_arrow_black")
                    interactiveBarArrowView.isHidden = false
                    break
                default :
                    interactiveBarArrowView.isHidden = true
                    break
                }
            }
            
            // scrollView
            let scrollView = pvc.scrollViewShouldDetectAtPostcard?(nav: nav)
            contentDetectScrollView = scrollView
            if let scrollView = scrollView {
                scrollView.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
            }
            
            // disimiss view
            let dismissTransitionView = pvc.dismissInteractiveTransitionViewAtPostcard?(nav: nav)
            if let transitionView = dismissTransitionView {
                transitionView.isUserInteractionEnabled = true
                let interactivePan = UIPanGestureRecognizer(target: self, action: #selector(onInteractivePanGesture(gesture:)))
                transitionView.addGestureRecognizer(interactivePan)
            }
        }
    }
        
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentOffset" {
            
            let value = change![NSKeyValueChangeKey.newKey] as! NSValue
            let offset = value.cgPointValue
            if offset.y > 0 {
                let y: CGFloat = offset.y * -1
                let ty: CGFloat = fmin(0, fmax(-28, y))
                interactiveBarView.transform = CGAffineTransform(translationX: 0, y: ty)
            }
            else {
                interactiveBarView.transform = .identity
            }
        }
        else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}

