//
//  PostcardNavigationController.swift
//  EMPostcardControllerDemo
//
//  Created by EamonLiang on 2019/9/4.
//  Copyright © 2019 EamonLiang. All rights reserved.
//

import UIKit


/// 顶部导航栏的箭头样式
///
/// - none: 无
/// - black: 黑色往下箭头
/// - white: 白色往下箭头
@objc public enum PostcardInteractiveBarStyle: Int {
    
    case none
    case black
    case white
}

@objc public protocol PostcardNavigationControlling {
    
    /// 点击顶部topBar
    ///
    /// - Parameter nav: 导航栏
    @objc optional func didTappedOnTopBarAtPostcard(nav: PostcardNavigationController)

    /// 顶部箭头
    ///
    /// - Parameter nav: 导航栏
    /// - Returns: 返回顶部箭头按钮样式
    @objc optional func preferredInteractiveBarStyleAtPostcard(nav: PostcardNavigationController) -> PostcardInteractiveBarStyle

    
    /// 注：如果该控制器有scrollView或者其子类。需要传入scrollView或其子类做手势交互
    ///
    /// - Parameter nav: 导航栏
    /// - Returns: 内容页面的scrollView或其子类
    @objc optional func scrollViewShouldDetectAtPostcard(nav: PostcardNavigationController) -> UIScrollView?
    
    
    /// 注：如果该controller支持手势交互关闭。需要传入view做手势交互
    ///
    /// - Parameter nav: 导航栏
    /// - Returns: 做手势交互的view
    @objc optional func dismissInteractiveTransitionViewAtPostcard(nav: PostcardNavigationController) -> UIView?
}

protocol InteractiveTransitionDriver {
    var dismissDriver: UIPercentDrivenInteractiveTransition? { get }
}


/// 手势交互动作
enum InteractiveEventAction {
    
    case pop    (state: State, dir: Direction)
    case dismiss(state: State, dir: Direction)
    case present(state: State, dir: Direction)
    
    /// 手势完成状态
    enum State {
        case finished
        case cancelled
    }
    
    /// 手势最后一刻在滑动的方向
    enum Direction {
        case down
        case up
    }
    
    /// 动画参数
    struct InteractiveAnimationParameter {
        var completionSpeed: CGFloat = 0.75
        var completionCurve: UIView.AnimationCurve = .easeInOut
        var finished: Bool = true
    }
    
    func paramter() -> InteractiveAnimationParameter {
        switch self {
            
        case .dismiss(let state, let dir),
             .pop    (let state, let dir):
            var paramter = InteractiveAnimationParameter()
            paramter.completionCurve = dir == .down ? .easeIn : .easeOut
            paramter.finished = dir == .down
            paramter.completionSpeed = state == .finished ? 0.75 : dir == .down ? 1 : 0.45
            return paramter
        default:
            return InteractiveAnimationParameter()
        }
    }
}

typealias InteractiveState = InteractiveEventAction.State
typealias InteractiveDirection = InteractiveEventAction.Direction
typealias InteractiveParameter = InteractiveEventAction.InteractiveAnimationParameter

open class PostcardNavigationController: UINavigationController {
    
    //MARK: >> Setter
    //------------------------------------------------------------------------
    
    /// 卡片post出来距离顶部的距离
    /// 默认是24 + 安全区域高度
    open var postcardMarginTop: CGFloat = 24 + DeviceUtil.safeAreaTopHeight
    
    /// 卡片顶部的圆角大小
    open var postcardCornerRadius: CGFloat = 13
    
    /// 手势关闭卡片的临界点  [0, 1]
    open var progsThreshold: CGFloat = 0.3
    
    /// 是否支持手势交互转场
    open var dismissInteractiveEnable: Bool = true
    open var presentInteractiveEnable: Bool = true
    
    
    //MARK: >> Private Properties
    //------------------------------------------------------------------------
    
    /// 转场动画类
    private var transition: PostcardTransition!
    
    /// 手势
    private var dismissTransition: UIPercentDrivenInteractiveTransition?
    private var presentTransition: UIPercentDrivenInteractiveTransition?
    private var popTransition:     UIPercentDrivenInteractiveTransition?
    
    //MARK: >> Life Cycle
    //------------------------------------------------------------------------
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        // hidden bar
        setNavigationBarHidden(true, animated: false)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        
        // transition
        transition = PostcardTransition()
        modalPresentationStyle = .custom
        transitioningDelegate = self
        delegate = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("[%@ delloc]", NSStringFromClass(PostcardNavigationController.self))
    }
    
    open override var prefersStatusBarHidden: Bool {
        return false
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: >> override
    //------------------------------------------------------------------------
    
    open override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        let container = PostcardContainerViewController(withController: viewController)
        super.pushViewController(container, animated: animated)
    }
    
    open override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        let containers = viewControllers.map { (viewController) -> PostcardContainerViewController in
            let container = PostcardContainerViewController(withController: viewController)
            return container
        }
        super.setViewControllers(containers, animated: animated)
    }
}


//MARK: >> UINavigationControllerDelegate, UIViewControllerTransitioningDelegate
//------------------------------------------------------------------------

extension PostcardNavigationController: UINavigationControllerDelegate, UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        transition.mode = .present;
        return transition;
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        transition.mode = .dismiss
        return transition
    }
    
    public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        
        if transition.mode == .present {
            return presentTransition
        }
        return nil
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        
        if transition.mode == .dismiss {
            return dismissTransition
        }
        return nil
    }
    
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        // push
        if operation == .push {
            transition.mode = .push
            return transition
        }
            
        // pop
        else if operation == .pop {
            transition.mode = .pop
            return transition
        }
        return nil
    }
    
    public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        
        if transition.mode == .pop {
            return popTransition
        }
        return nil
    }
}


//MARK: >> Interactive Events
//------------------------------------------------------------------------

extension PostcardNavigationController {
    
    public func interactiveDismiss(withPanGestureRecognizer pan: UIPanGestureRecognizer) {
        
        switch pan.state {
            
        // BUG: 不执行began方法
        case .began:
            dismissTransition = UIPercentDrivenInteractiveTransition()
            // >> dismiss
            dismiss(animated: true, completion: nil)
            break
            
        case .changed:
            let point = pan.translation(in: pan.view)
            var progs: CGFloat = point.y / pan.view!.superview!.bounds.height
            progs = fmin(1, fmax(0, progs))
            
            // >> update BUG:不执行began方法
            if let tran = dismissTransition {
                tran.update(progs)
            }
            else {
                dismissTransition = UIPercentDrivenInteractiveTransition()
                dismiss(animated: true, completion: nil)
            }
            break
            
        case .cancelled, .ended:
            // >> progs
            let point = pan.translation(in: pan.view)
            var progs: CGFloat = point.y / pan.view!.superview!.bounds.height
            progs = fmin(1, fmax(0, progs))
            
            let velocityY = pan.velocity(in: view).y
            handleInteractiveEvent(handler: dismissTransition!, progs: progs, velocityY: velocityY)
            // >> reset
            dismissTransition = nil
            break
            
        default:
            break
        }
    }
    
    public func interactivePop(withPanGestureRecognizer pan: UIPanGestureRecognizer) {
        
        switch pan.state {
        case .began:
            popTransition = UIPercentDrivenInteractiveTransition()
            // >> pop
            popViewController(animated: true)
            print("began pop")
            break
            
        case .changed:
            let point = pan.translation(in: pan.view)
            var progs: CGFloat = point.y / pan.view!.superview!.bounds.height
            progs = fmin(1, fmax(0, progs))
            // >> update
            popTransition?.update(progs)
            print("changed pop")
            break
            
        case .cancelled, .ended:
            // >> progs
            let point = pan.translation(in: pan.view)
            var progs: CGFloat = point.y / pan.view!.superview!.bounds.height
            progs = fmin(1, fmax(0, progs))
            
            let velocityY = pan.velocity(in: view).y
            handleInteractiveEvent(handler: popTransition!, progs: progs, velocityY: velocityY)
            // >> reset
            popTransition = nil
            print("end pop")
            break
            
        default:
            break
        }
    }
    
    /// 处理手势事件
    ///
    /// - Parameters:
    ///   - transition: 手势识别者
    ///   - progs: 拉动的进度
    private func handleInteractiveEvent(handler: UIPercentDrivenInteractiveTransition, progs: CGFloat, velocityY: CGFloat) {
    
        // 手势交互状态 如果下拉进度大于0.3 (state == finished)
        let state: InteractiveState = progs > progsThreshold ? .finished : .cancelled
        
        // 手势交互手指方向
        let dir: InteractiveDirection = velocityY > 0 ? .down : .up
        let action = InteractiveEventAction.dismiss(state: state, dir: dir)
        
        // 设置参数
        let paramter = action.paramter()
        handler.completionCurve = paramter.completionCurve
        handler.completionSpeed = paramter.completionSpeed
        paramter.finished ? handler.finish() : handler.cancel()
    }
}
