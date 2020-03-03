/**************************************************
*
* DOImageBrowser
*
* A custom view that contain three images view
* to loop images.
*
* Copyright © 2020 Leiyt. All rights reserved.
**************************************************/

import UIKit
import SDWebImage

public class DOImageLoop: UIView {

    /// The content scroll view.
    @IBOutlet private weak var contentScrollView: UIScrollView!

    /// The content view.
    @IBOutlet private weak var contentView: UIView!

    /// The image views.
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var middleImageView: UIImageView!
    @IBOutlet weak var rightImageView: UIImageView!

    /// The control for page.
    @IBOutlet weak var pageControl: UIPageControl!

    /// The placeholder image before remote downloaded.
    var placeholderImage: UIImage?

    /// Saved images.
    private var images: [String]!
    private var isOffestedOnce = false

    /// Timer.
    private var timer: Timer?

    /// Instance browser view.
    public class func instanced() -> DOImageLoop {
        let bundle = Bundle(for: DOImageLoop.self)
        let xib = UINib(nibName: "DOImageLoop", bundle: bundle)
        let ibView = xib.instantiate(withOwner: nil, options: nil).first as! DOImageLoop
        return ibView
    }

    public override func draw(_ rect: CGRect) {
        if !isOffestedOnce {
            isOffestedOnce = true
            contentScrollView.setContentOffset(CGPoint(x: bounds.width, y: 0), animated: false)
        }
    }

    deinit {
        broken()
    }
}

//MARK: - Settings
public extension DOImageLoop {

    /// Set images with given paths.
    func setImages(_ images: [String], mode: UIView.ContentMode = .scaleAspectFit) {
        guard !images.isEmpty else { return }
        self.images = images
        pageControl.isHidden = images.count <= 1
        pageControl.numberOfPages = images.count
        contentScrollView.isScrollEnabled = images.count > 1

        /// Set modes
        leftImageView.contentMode = mode
        middleImageView.contentMode = mode
        rightImageView.contentMode = mode

        /// set images first.
        resetImage(from: 0, isFirst: true)
    }

    /// Start loop images with time interval.
    func start(duration interval: TimeInterval) {
        assert(images != nil || images.isEmpty, "Must invoke this 'setImages(_:)' method before looping.")
        if timer == nil {
            timer = Timer(timeInterval: interval,
                          target: self,
                          selector: #selector(onTimerBecoming(_:)),
                          userInfo: nil,
                          repeats: true)
            RunLoop.current.add(timer!, forMode: .common)
        }
        timer?.fireDate = Date.distantPast
    }

    /// Stop loop.
    func stop() {
        timer?.fireDate = Date.distantFuture
    }

    /// Break loop.
    ///
    /// Make timer invalid if called it, use 'stopLoop' to stop loop.
    func broken() {
        timer?.invalidate()
        timer = nil
    }

    /// Reset images.
    private func resetImage(from index: Int, isFirst: Bool) {
        let current = isFirst ? index : (pageControl.currentPage + (index == 0 ? -1 : 1))
        let lIndex = (current - 1 + images.count) % images.count
        let mIndex = (current + images.count) % images.count
        let rIndex = (current + 1 + images.count) % images.count
        leftImageView.sd_setImage(with: URL(string: images[lIndex]),
                                  placeholderImage: placeholderImage)
        middleImageView.sd_setImage(with: URL(string: images[mIndex]),
                                    placeholderImage: placeholderImage)
        rightImageView.sd_setImage(with: URL(string: images[rIndex]),
                                   placeholderImage: placeholderImage)
        pageControl.currentPage = mIndex
        contentScrollView.setContentOffset(CGPoint(x: bounds.width, y: 0), animated: false)
    }

    /// Timer triggerred.
    @objc private func onTimerBecoming(_ timer: Timer) {
        contentScrollView.setContentOffset(CGPoint(x: bounds.width * 2, y: 0), animated: true)
    }
}

//MARK: - Delegate
extension DOImageLoop: UIScrollViewDelegate {
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let idx = Int(round(scrollView.contentOffset.x / bounds.width))
        guard idx != 1 else { return }
        resetImage(from: idx, isFirst: false)
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollViewDidEndDecelerating(scrollView)
    }
}
