//
//  PostcardTransition.swift
//  PostcardControllerDemo
//
//  Created by EamonLiang on 2019/9/4.
//  Copyright © 2019 EamonLiang. All rights reserved.
//

import UIKit
import SnapKit


/// 转场动画的模式
public enum PostcardTransitionMode {
    case present
    case dismiss
    case push
    case pop
}


open class PostcardTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    /// 转场动画时长
    open var duration: TimeInterval = 0.3
    
    /// 转场动画模式
    open var mode: PostcardTransitionMode = .present
    
    /// maskView
    private weak var transitionMaskView: UIView!
    
    
    //MARK: >> UIViewControllerAnimatedTransitioning
    //------------------------------------------------------------------------
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        
        let fromVC = transitionContext.viewController(forKey: .from)!
        let toVC   = transitionContext.viewController(forKey: .to)!
        
        fromVC.beginAppearanceTransition(false, animated: true)
        toVC.beginAppearanceTransition(true, animated: true)
        
        switch mode {
        case .present:
            presentTransition(context: transitionContext, fromVC: fromVC, toVC: toVC, containerView: containerView)
            break
        case .dismiss:
            dismissTransition(context: transitionContext, fromVC: fromVC, toVC: toVC, containerView: containerView)
            break
        case .push:
            pushTransition(context: transitionContext, fromVC: fromVC, toVC: toVC, containerView: containerView)
            break
        case .pop:
            popTransition(context: transitionContext, fromVC: fromVC, toVC: toVC, containerView: containerView)
            break
        }
    }
}


//MARK: >> Private Methods
//------------------------------------------------------------------------

extension PostcardTransition {
    
    private func presentTransition(context: UIViewControllerContextTransitioning,  fromVC: UIViewController, toVC: UIViewController, containerView: UIView) {
        
        let nav = toVC as! PostcardNavigationController
        let postcardVC = nav.topViewController as! PostcardContainerViewController
        
        // bg mask
        let maskView = UIView()
        maskView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.64)
        containerView.addSubview(maskView)
        maskView.snp.updateConstraints { (make) in
            make.edges.equalToSuperview()
        }
        transitionMaskView = maskView
        
        // nav
        containerView.addSubview(nav.view)
        nav.view.frame = context.finalFrame(for: toVC)
        nav.view.snp.updateConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        // postcard
        let marginTop = nav.postcardMarginTop
        let translateH = nav.view.bounds.height - marginTop
        let postcardT = CGAffineTransform(translationX: 0, y: translateH)
        
        var shouldSnap = false
        var snapT = CGAffineTransform.identity
        if nav.viewControllers.count > 1 {
            shouldSnap = true
            
            let snapWidth: CGFloat  = nav.view.frame.width
            let snapOffset: CGFloat = 12
            let snapScale: CGFloat  = fmin(1.0, fmax(0, 1.0 - (snapOffset / snapWidth)))
            
            let sT = CGAffineTransform(scaleX: snapScale, y: snapScale)
            let tT = CGAffineTransform(translationX: 0, y: 0-snapOffset*2)
            snapT = sT.concatenating(tT)
        }
        
        // animation: init
        maskView.alpha = 0
        postcardVC.postcardView.transform = postcardT
        if shouldSnap {
            postcardVC.postcardSnapView.isHidden = false
            postcardVC.postcardSnapView.alpha = 0
            postcardVC.postcardSnapView.transform = .identity
            postcardVC.backgroundMaskView.isHidden = false
            postcardVC.backgroundMaskView.alpha = 0
        }
        
        // animation: run
        UIView.animate(withDuration: transitionDuration(using: context), delay: 0, options: .curveEaseOut, animations: {
            
            maskView.alpha = 1
            postcardVC.postcardView.transform = .identity

        }) { (finished) in
            let cancelled = context.transitionWasCancelled
            if shouldSnap && !cancelled {
                UIView .animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
                    
                    postcardVC.postcardSnapView.alpha = 1
                    postcardVC.postcardSnapView.transform = snapT
                    postcardVC.backgroundMaskView.alpha = 1

                }, completion: { (finished) in
                    // >> end
                    context.completeTransition(!cancelled)
                })
            }
            else {
                // >> end
                context.completeTransition(!cancelled)
            }
        }
    }
    
    private func dismissTransition(context: UIViewControllerContextTransitioning,  fromVC: UIViewController, toVC: UIViewController, containerView: UIView) {
        
        let nav = fromVC as! UINavigationController
        let postcardVC = nav.topViewController as! PostcardContainerViewController
        
        // init
        let postcardFinalT = CGAffineTransform(translationX: 0, y: postcardVC.postcardView.frame.height)
        
        // animation: run
        UIView.animate(withDuration: transitionDuration(using: context), delay: 0, options: .curveEaseIn, animations: {
            
            self.transitionMaskView.alpha  = 0
            postcardVC.postcardView.transform = postcardFinalT
            postcardVC.postcardSnapView.transform = postcardFinalT
        }) { (finished) in
            let cancelled = context.transitionWasCancelled
            // >> end
            context.completeTransition(!cancelled)
        }
    }
    
    private func pushTransition(context: UIViewControllerContextTransitioning,  fromVC: UIViewController, toVC: UIViewController, containerView: UIView) {
        
        let fromPostcard = fromVC as! PostcardContainerViewController
        let toPostcard   = toVC as! PostcardContainerViewController
        
        // 2. to postcard
        containerView.addSubview(toPostcard.view)
        
        // scale transform
        let offset: CGFloat = 12
        let ff: CGRect = fromPostcard.postcardView.frame
        let scale: CGFloat = 1 - (offset / ff.size.width)
        
        let fT1 = CGAffineTransform(scaleX: scale, y: scale)
        let fT2 = CGAffineTransform(translationX: 0, y: -offset*2)
        let fT  = fT1.concatenating(fT2)
        let tT  = CGAffineTransform(translationX: 0, y: ff.size.height)
        
        // animation: init
        fromPostcard.postcardMaskView.isHidden = false;
        fromPostcard.postcardMaskView.alpha = 0;
        fromPostcard.postcardView.transform = .identity;
        
        toPostcard.backgroundMaskView.isHidden = false;
        toPostcard.backgroundMaskView.alpha = 0;
        toPostcard.postcardView.transform = tT;
        
        // animation: run
        UIView.animate(withDuration: transitionDuration(using: context) / 2, delay: transitionDuration(using: context) / 2, options: .curveEaseOut, animations: {
            fromPostcard.postcardMaskView.alpha = 1;
            toPostcard.backgroundMaskView.alpha = 1;
        }, completion: nil)
        
        UIView.animate(withDuration: transitionDuration(using: context), delay: 0, options: .curveEaseOut, animations: {
            fromPostcard.postcardView.transform = fT;
            toPostcard.postcardView.transform = .identity;
        }) { (finished) in
            let cancelled = context.transitionWasCancelled
            
            fromPostcard.postcardMaskView.isHidden = true;
            fromPostcard.postcardMaskView.alpha = 0;
            
            toPostcard.postcardSnapView.isHidden = false;
            toPostcard.postcardSnapView.alpha = 1;
            toPostcard.postcardSnapView.transform = fT;
            
            // >> end
            fromVC.endAppearanceTransition()
            toVC.endAppearanceTransition()
            context.completeTransition(!cancelled)
        }
    }
    
    private func popTransition(context: UIViewControllerContextTransitioning,  fromVC: UIViewController, toVC: UIViewController, containerView: UIView) {
        
        let fromPostcard = fromVC as! PostcardContainerViewController
        let toPostcard = toVC as! PostcardContainerViewController
        
        // to postcard
        containerView.insertSubview(toPostcard.view, belowSubview: fromPostcard.view)
        
        // scale
        let offset: CGFloat = 12
        let ff: CGRect = fromPostcard.postcardView.frame
        let scale = 1 - (offset / ff.size.width)
        
        let fT  = CGAffineTransform(translationX: 0, y: ff.size.height)
        let tT1 = CGAffineTransform(scaleX: scale, y: scale)
        let tT2 = CGAffineTransform(translationX: 0, y: -offset*2)
        let tT  = tT1.concatenating(tT2)
        
        // animation: init
        fromPostcard.postcardView.transform = .identity
        fromPostcard.postcardSnapView.isHidden = true
        fromPostcard.postcardSnapView.alpha = 0
        fromPostcard.backgroundMaskView.isHidden = false
        fromPostcard.backgroundMaskView.alpha = 1
        
        toPostcard.postcardView.transform = tT
        toPostcard.postcardMaskView.isHidden = false
        toPostcard.postcardMaskView.alpha = 1
        
        // animation: run
        UIView.animate(withDuration: transitionDuration(using: context) / 2, delay: 0, options: .curveEaseIn, animations: {
            fromPostcard.backgroundMaskView.alpha = 0
            toPostcard.postcardMaskView.alpha = 0
        }, completion: nil)
        
        UIView.animate(withDuration: transitionDuration(using: context), delay: 0, options: .curveEaseIn, animations: {
            fromPostcard.postcardView.transform = fT
            toPostcard.postcardView.transform = .identity
        }) { (finished) in
            let cancelled = context.transitionWasCancelled
            
            fromPostcard.postcardView.transform = .identity
            fromPostcard.postcardSnapView.isHidden = false
            fromPostcard.postcardSnapView.alpha = 1
            fromPostcard.backgroundMaskView.isHidden = false
            fromPostcard.backgroundMaskView.alpha = 1
            
            toPostcard.postcardMaskView.isHidden = true
            toPostcard.postcardMaskView.alpha = 0
            
            // >> end
            fromVC.endAppearanceTransition()
            toVC.endAppearanceTransition()
            context.completeTransition(!cancelled)
        }
    }
}
