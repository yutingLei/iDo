/**************************************************
*
* DOLoading
*
* A custom loading widget.
*
* Copyright © 2020 Leiyt. All rights reserved.
**************************************************/

import UIKit

public class DOLoading: UIView {

    /// Define loading modes.
    public enum Mode {
        case classic
        case system
    }
    var mode: Mode = .classic

    /// Wether loading.
    private(set) var isLoading = false
    private var isAnimating = false

    /// The content view that contains animate components.
    private(set) var contentView: UIView!

    /// Set stroke color for classic mode, if nil, white color instead.
    var strokeColor: UIColor?

    /// Saved contentView's constraints.
    private var contentWidth: NSLayoutConstraint!
    private var contentHeight: NSLayoutConstraint!

    /// Saved self's constraints.
    private var top: NSLayoutConstraint?
    private var leading: NSLayoutConstraint?
    private var trailing: NSLayoutConstraint?
    private var bottom: NSLayoutConstraint?

    /// Animated layer.
    private var circleLayer: CAShapeLayer?
    private var systemIndicator: UIActivityIndicatorView?
    private var shouldRefactorAnimations = false

    /// Init loading with given mode.
    public init(mode: Mode = .classic) {
        super.init(frame: .zero)
        backgroundColor = .orange
        translatesAutoresizingMaskIntoConstraints = false
        self.mode = mode
        createContentView()
    }

    /// Create content view.
    private func createContentView() {
        contentView = UIView()
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        addSubview(contentView)
        contentView.centerToSuperview()
        contentWidth = contentView.width(65)
        contentHeight = contentView.height(65)
    }

    /// Everything already prepared.
    public override func draw(_ rect: CGRect) {
        guard let father = superview else { return }
        let minWidth = min(65, father.frame.width * 0.5)
        let minHeight = min(65, father.frame.height * 0.5)
        contentWidth.constant = min(minWidth, minHeight)
        contentHeight.constant = min(minWidth, minHeight)
        if shouldRefactorAnimations && mode == .classic {
            shouldRefactorAnimations = false
            createCircleLayerIfNeeded(true)
        }
        startAnimating()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK: - Show & Hide
public extension DOLoading {

    /// Show loading in a view.
    ///
    /// view: Show loading in this view, if nil, use window instead.
    func show(in view: UIView? = nil) {

        /// Add it to view.
        let view = view ?? UIApplication.shared.keyWindow
        guard let aView = view else { return }
        if superview != aView {
            aView.addSubview(self)
            fillToSuperview()
            contentView.centerToSuperview()
            shouldRefactorAnimations = true
        }
    }

    /// Hide loading.
    func hide() {
        isLoading = false
        isAnimating = false
        circleLayer?.removeAllAnimations()
        removeFromSuperview()
    }
}

//MARK: - Animated
private extension DOLoading {

    /// Start animation.
    func startAnimating() {
        guard !isLoading else { return }
        isAnimating = true
        isLoading = true
        switch mode {
        case .classic: startClassicAnimating()
        default: startSystemIndicator()
        }
    }

    /// Start system animation.
    func startSystemIndicator() {
        if circleLayer != nil {
            circleLayer?.removeFromSuperlayer()
        }
        if systemIndicator == nil {
            systemIndicator = UIActivityIndicatorView()
            systemIndicator?.style = .white
            contentView.addSubview(systemIndicator!)
            systemIndicator?.fillToSuperview(edges: .zero)
        }
        systemIndicator?.startAnimating()
    }

    /// Start classic animations.
    func startClassicAnimating() {
        if systemIndicator != nil {
            systemIndicator?.removeFromSuperview()
        }

        /// Animator with rotation
        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.byValue = 2 * Double.pi
        #if swift(>=4.2)
        rotation.timingFunction = CAMediaTimingFunction(name: .linear)
        #else
        rotation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        #endif

        /// Animator with stroke
        let start = CABasicAnimation(keyPath: "strokeStart")
        start.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 0.0, 0.2, 1.0)
        start.duration = 1.7
        start.fromValue = 0
        start.toValue = 1
        start.beginTime = 0.5

        let end = CABasicAnimation(keyPath: "strokeEnd")
        start.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 0.0, 0.2, 1.0)
        end.duration = 1.2
        end.fromValue = 0
        end.toValue = 1

        let groups = CAAnimationGroup()
        groups.duration = 2.2
        groups.animations = [rotation, start, end]
        groups.repeatCount = Float.infinity
        groups.isRemovedOnCompletion = false
        #if swift(>=4.2)
        groups.fillMode = .forwards
        #else
        groups.fillMode = kCAFillModeForwards
        #endif
        circleLayer?.add(groups, forKey: nil)
    }
}

//MARK: - Others
private extension DOLoading {

    /// Fill to superview.
    func fillToSuperview() {
        /// Clear old constraints
        if let top = top {
            removeConstraint(top)
        }
        if let leading = leading {
            removeConstraint(leading)
        }
        if let trailing = trailing {
            removeConstraint(trailing)
        }
        if let bottom = bottom {
            removeConstraint(bottom)
        }
        top = makeConstraint(attribute: .top)
        leading = makeConstraint(attribute: .leading)
        trailing = makeConstraint(attribute: .trailing)
        bottom = makeConstraint(attribute: .bottom)
        NSLayoutConstraint.activate([top!, leading!, trailing!, bottom!])
    }

    /// Constraints.
    func makeConstraint(attribute: NSLayoutConstraint.Attribute) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self,
                                  attribute: attribute,
                                  relatedBy: .equal,
                                  toItem: superview,
                                  attribute: attribute,
                                  multiplier: 1,
                                  constant: 0)
    }

    /// Create circle layer if needed.
    func createCircleLayerIfNeeded(_ isNeeded: Bool) {
        if !isNeeded && circleLayer != nil {
            return
        }
        circleLayer?.removeFromSuperlayer()

        let x = contentWidth.constant / 2
        let y = contentHeight.constant / 2
        let r = contentHeight.constant / 2 * 0.55
        let path = UIBezierPath(arcCenter: CGPoint(x: x, y: y),
                                radius: r,
                                startAngle: 0,
                                endAngle: 2 * CGFloat.pi,
                                clockwise: true)
        circleLayer = CAShapeLayer()
        circleLayer?.frame = CGRect(x: 0, y: 0, width: contentWidth.constant, height: contentHeight.constant)
        circleLayer?.fillColor = UIColor.clear.cgColor
        circleLayer?.strokeColor = (strokeColor ?? UIColor.white).cgColor
        circleLayer?.path = path.cgPath
        circleLayer?.lineWidth = 4.0
        contentView?.layer.addSublayer(circleLayer!)
    }
}
