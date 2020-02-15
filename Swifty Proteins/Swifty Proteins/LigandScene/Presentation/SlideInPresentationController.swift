import UIKit

class SlideInPresentationController: UIPresentationController {
    private enum Constant {
        static let settingViewWidth: CGFloat = 200
        static let atomInfoViewHeight: CGFloat = 350
    }
    private var dimmingView: UIView!
    private let direction: PresentationDirection

    init(presentedViewController: UIViewController,
                  presenting presentingViewController: UIViewController?,
                  direction: PresentationDirection) {
        self.direction = direction
        super.init(presentedViewController: presentedViewController,
                   presenting: presentingViewController)
        self.presentedView?.roundCorners([.topLeft, .bottomLeft], radius: 25)
        setupDimmingView()
    }

    /*
     UIPresentationController has a property named containerView. It holds the view hierarchy of the presentation and presented controllers. This section is where you insert the dimmingView into the back of the view hierarchy.
     Next, you constrain the dimming view to the edges of the container view so that it fills the entire screen.
     transitionCoordinator of UIPresentationController has a very cool method to animate things during the transition. In this section, you set the dimming view’s alpha to 1.0 along with the presentation transition.
     */

    override func presentationTransitionWillBegin() {
        guard let dimmingView = dimmingView else {
            return
        }

        containerView?.insertSubview(dimmingView, at: 0)

        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "V:|[dimmingView]|",
                                           options: [], metrics: nil, views: ["dimmingView": dimmingView]))
        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[dimmingView]|",
                                           options: [], metrics: nil, views: ["dimmingView": dimmingView]))

        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 1.0
            return
        }

        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1.0
        })
    }

    /*
     Similar to presentationTransitionWillBegin(), you set the dimming view’s alpha to 0.0 alongside the dismissal transition. This gives the effect of fading the dimming view.
     */

    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 0.0
            return
        }

        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0.0
        })
    }

    /*
     Here you reset the presented view’s frame to fit any changes to the containerView frame.
     */

    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }

    /*
     This method receives the content container and parent view’s size, and then it calculates the size for the presented content. In this code, you restrict the presented view to 2/3 of the screen by returning 2/3 the width for presentations.
     */

    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        switch direction {
        case .right:
            return CGSize(width: Constant.settingViewWidth, height: parentSize.height)
        case .bottom:
            return CGSize(width: parentSize.width, height: Constant.atomInfoViewHeight)
        }
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        var frame: CGRect = .zero
        frame.size = size(forChildContentContainer: presentedViewController,
                          withParentContainerSize: containerView!.bounds.size)

        switch direction {
        case .right:
            frame.origin.x = containerView!.frame.width - Constant.settingViewWidth
        case .bottom:
            frame.origin.y = containerView!.frame.height - Constant.atomInfoViewHeight
        }
        return frame
    }
}

// MARK: Private

private extension SlideInPresentationController {
    func setupDimmingView() {
        dimmingView = UIView()
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        dimmingView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        dimmingView.alpha = 0.0

        let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        dimmingView.addGestureRecognizer(recognizer)
    }

    @objc private func handleTap(recognizer: UITapGestureRecognizer) {
        presentingViewController.dismiss(animated: true)
    }
}
