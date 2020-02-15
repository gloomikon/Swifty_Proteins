import UIKit

/*
    isPresentation to tell the animation controller whether to present or dismiss the view controller.
*/

class SlideInPresentationAnimator: NSObject {
    let direction: PresentationDirection
    let isPresentation: Bool

    init(direction: PresentationDirection, isPresentation: Bool) {
        self.direction = direction
        self.isPresentation = isPresentation
        super.init()
    }
}

// MARK:  UIViewControllerAnimatedTransitioning
extension SlideInPresentationAnimator: UIViewControllerAnimatedTransitioning {
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.2
  }

/*
     If this is a presentation, the method asks the transitionContext for the view controller associated with .to. This is the view controller you’re moving to. If dismissal, it asks the transitionContext for the view controller associated with .from. This is the view controller you’re moving from.
     If the action is a presentation, your code adds the view controller’s view to the view hierarchy. This code uses the transitionContext to get the container view.
     Calculate the frames you’re animating from and to. The first line asks the transitionContext for the view’s frame when it’s presented. The rest of the section tackles the trickier task of calculating the view’s frame when it’s dismissed. This section sets the frame’s origin so it’s just outside the visible area based on the presentation direction.
     Determine the transition’s initial and final frames. When presenting the view controller, it moves from the dismissed frame to the presented frame — vice versa when dismissing.
     Lastly, this method animates the view from initial to final frame. If this is a dismissal, you remove the view controller’s view from the view hierarchy. Note that you call completeTransition(_:) on transitionContext to inform the transition has finished.
*/

  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

    let key: UITransitionContextViewControllerKey = isPresentation ? .to : .from

    guard let controller = transitionContext.viewController(forKey: key)
      else { return }

    if isPresentation {
      transitionContext.containerView.addSubview(controller.view)
    }

    let presentedFrame = transitionContext.finalFrame(for: controller)
    var dismissedFrame = presentedFrame

    switch direction {
    case .right:
        dismissedFrame.origin.x = transitionContext.containerView.frame.size.width
    case .bottom:
        dismissedFrame.origin.y = transitionContext.containerView.frame.size.height
    }
    
    let initialFrame = isPresentation ? dismissedFrame : presentedFrame
    let finalFrame = isPresentation ? presentedFrame : dismissedFrame
    
    let animationDuration = transitionDuration(using: transitionContext)
    controller.view.frame = initialFrame
    UIView.animate(withDuration: animationDuration,
                   animations: {
                    controller.view.frame = finalFrame
    }, completion: { finished in
        if !self.isPresentation {
            controller.view.removeFromSuperview()
        }
        transitionContext.completeTransition(finished)
    })
    }
}
