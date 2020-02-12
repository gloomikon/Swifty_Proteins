import UIKit

class LigandImageViewController: UIViewController {

    // MARK: IBOutlets

    @IBOutlet private weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
            scrollView.showsVerticalScrollIndicator = false
            scrollView.showsHorizontalScrollIndicator = false
        }
    }

    @IBOutlet private weak var imageView: UIImageView! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
            tap.numberOfTapsRequired = 2
            imageView.addGestureRecognizer(tap)
        }
    }

    // MARK: Public properties

    var image: UIImage?

    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = image

        scrollView.contentSize = (imageView?.frame.size)!
        scrollView.maximumZoomScale = 100
    }

    // MARK: Private functions

    @objc private func doubleTapped() {
        scrollView.setZoomScale(scrollView.zoomScale > 2.0 ? 1.0 : 4.0, animated: true)
    }
}

// MARK: UIScrollViewDelegate

extension LigandImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
