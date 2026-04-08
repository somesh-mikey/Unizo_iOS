//
//  UIView+Animations.swift
//  Unizo_iOS
//
//  Reusable UIKit animations. All durations reference AnimationDuration
//  constants so the whole app's motion can be tuned from one place.
//

import UIKit

// MARK: - Duration Constants

enum AnimationDuration {
    static let quick:    TimeInterval = 0.15
    static let standard: TimeInterval = 0.25
    static let smooth:   TimeInterval = 0.3
    static let slow:     TimeInterval = 0.4
}

// MARK: - UIView Animations

extension UIView {

    // MARK: Scale

    /// Spring-bounce scale: 1 → 1.2 → 1. Good for icon/heart tap feedback.
    func animateBounce(completion: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: AnimationDuration.quick,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.5,
            options: .curveEaseInOut
        ) {
            self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        } completion: { _ in
            UIView.animate(
                withDuration: AnimationDuration.quick,
                delay: 0,
                usingSpringWithDamping: 0.5,
                initialSpringVelocity: 0.5,
                options: .curveEaseInOut
            ) {
                self.transform = .identity
            } completion: { _ in completion?() }
        }
    }

    /// Quick scale-up then spring back. Used for cart/wishlist add actions.
    func animatePop(scale: CGFloat = 1.15, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: AnimationDuration.quick, delay: 0, options: .curveEaseOut) {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        } completion: { _ in
            UIView.animate(
                withDuration: AnimationDuration.standard,
                delay: 0,
                usingSpringWithDamping: 0.6,
                initialSpringVelocity: 0.3,
                options: .curveEaseOut
            ) {
                self.transform = .identity
            } completion: { _ in completion?() }
        }
    }

    /// Repeating scale pulse. Useful for drawing attention to an element.
    func animatePulse(repeatCount: Float = 2) {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = AnimationDuration.smooth
        pulse.fromValue = 1.0
        pulse.toValue = 1.08
        pulse.autoreverses = true
        pulse.repeatCount = repeatCount
        pulse.initialVelocity = 0.5
        pulse.damping = 1.0
        layer.add(pulse, forKey: "pulse")
    }

    // MARK: Fade

    func fadeIn(duration: TimeInterval = AnimationDuration.standard, completion: (() -> Void)? = nil) {
        alpha = 0
        isHidden = false
        UIView.animate(withDuration: duration, animations: { self.alpha = 1 }) { _ in completion?() }
    }

    func fadeOut(duration: TimeInterval = AnimationDuration.standard, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration, animations: { self.alpha = 0 }) { _ in
            self.isHidden = true
            completion?()
        }
    }

    func crossFade(duration: TimeInterval = AnimationDuration.standard, changes: @escaping () -> Void) {
        UIView.transition(with: self, duration: duration, options: .transitionCrossDissolve, animations: changes)
    }

    // MARK: Slide

    /// Slides in from below the parent view (or screen edge if no superview).
    func slideInFromBottom(duration: TimeInterval = AnimationDuration.smooth, completion: (() -> Void)? = nil) {
        let originalY = frame.origin.y
        frame.origin.y = superview?.bounds.height
            ?? window?.windowScene?.screen.bounds.height
            ?? bounds.height
        isHidden = false
        alpha = 1

        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.3,
            options: .curveEaseOut
        ) {
            self.frame.origin.y = originalY
        } completion: { _ in completion?() }
    }

    func slideOutToBottom(duration: TimeInterval = AnimationDuration.smooth, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseIn) {
            self.frame.origin.y = self.superview?.bounds.height
                ?? self.window?.windowScene?.screen.bounds.height
                ?? self.bounds.height
        } completion: { _ in
            self.isHidden = true
            completion?()
        }
    }

    // MARK: Shake

    /// Horizontal shake — use to signal invalid input or errors.
    func shake(intensity: CGFloat = 10, duration: TimeInterval = 0.5) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.duration = duration
        animation.values = [
            -intensity,       intensity,
            -intensity * 0.8, intensity * 0.8,
            -intensity * 0.5, intensity * 0.5,
            0
        ]
        layer.add(animation, forKey: "shake")
    }

    // MARK: Shimmer (Skeleton Loading)

    /// Adds a left-to-right shimmer gradient. Call `stopShimmer()` once content loads.
    func startShimmer() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint   = CGPoint(x: 1, y: 0.5)
        gradientLayer.colors = [
            UIColor.systemGray5.cgColor,
            UIColor.systemGray4.cgColor,
            UIColor.systemGray5.cgColor
        ]
        gradientLayer.locations = [0, 0.5, 1]
        gradientLayer.name = "shimmerLayer"

        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue  = [-1.0, -0.5, 0]
        animation.toValue    = [1.0, 1.5, 2.0]
        animation.duration   = 1.5
        animation.repeatCount = .infinity
        gradientLayer.add(animation, forKey: "shimmerAnimation")

        layer.addSublayer(gradientLayer)
    }

    func stopShimmer() {
        layer.sublayers?.removeAll { $0.name == "shimmerLayer" }
    }
}

// MARK: - UIButton Tap Feedback

extension UIButton {

    /// Adds a subtle press-down/spring-back animation to the button via target-action.
    func addTapAnimation() {
        addTarget(self, action: #selector(animateTouchDown), for: .touchDown)
        addTarget(self, action: #selector(animateTouchUp),
                  for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    @objc private func animateTouchDown() {
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            self.alpha = 0.9
        }
    }

    @objc private func animateTouchUp() {
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut
        ) {
            self.transform = .identity
            self.alpha = 1.0
        }
    }
}

// MARK: - Staggered Cell Appearance

extension UICollectionViewCell {

    /// Fades in and slides up. Pass an increasing `delay` per index for staggered effect.
    func animateAppearance(delay: TimeInterval = 0) {
        alpha = 0
        transform = CGAffineTransform(translationX: 0, y: 20)
        UIView.animate(
            withDuration: AnimationDuration.smooth,
            delay: delay,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.3,
            options: .curveEaseOut
        ) {
            self.alpha = 1
            self.transform = .identity
        }
    }
}

extension UITableViewCell {

    /// Fades in and slides up. Pass an increasing `delay` per index for staggered effect.
    func animateAppearance(delay: TimeInterval = 0) {
        alpha = 0
        transform = CGAffineTransform(translationX: 0, y: 20)
        UIView.animate(
            withDuration: AnimationDuration.smooth,
            delay: delay,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.3,
            options: .curveEaseOut
        ) {
            self.alpha = 1
            self.transform = .identity
        }
    }
}
