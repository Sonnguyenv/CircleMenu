//
//  BaseMenuAnimation.swift
//  CircleMenu
//
//  Created by SonNV-D1 on 4/22/19.
//  Copyright © 2019 SonNV-D1. All rights reserved.
//

import Foundation
import UIKit

public protocol CPMenuAnimationProtocol {
    // Animation khi touch home button
    func animationHomeButton(homeButton: HomeMenuButton, state: CPMenuViewState, completion: (() -> Void)?)
    // Animation hiển thị các child button
    func animationShowSubMenuButton(subButtons: [SubMenuButton], completion: (() -> Void)?)
    // Animation ẩn các child button
    func animationHideSubMenuButton(subButtons: [SubMenuButton], completion: (() -> Void)?)
}

struct CPMenuAnimation {
    // Thời gian thực hiện animation.
    var commonDuration: TimeInterval = 0.5
    //hệ số suy giảm
    var commonDampingCoefficient: CGFloat = 0.5
    // Tốc độ bắt đầu giao động.
    var commonStartVelocity: CGFloat = 0
    

    func animation(delay: TimeInterval, animation: @escaping () -> Void, completion: @escaping (Bool) -> Void) {
        UIView.animate(withDuration: commonDuration, delay: delay, usingSpringWithDamping: commonDampingCoefficient, initialSpringVelocity: commonStartVelocity, options: UIView.AnimationOptions.curveEaseInOut, animations: animation, completion: completion)
    }
}

extension CPMenuAnimation: CPMenuAnimationProtocol {
    
    func animationHomeButton(homeButton: HomeMenuButton, state: CPMenuViewState, completion: (() -> Void)?) {
        let scale: CGFloat = state == .expand ? 1.0 : 0.9
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        animation(delay: 0, animation: {
            homeButton.transform = transform
        }, completion: { finish in
            completion?()
        })
    }
    
    func animationShowSubMenuButton(subButtons: [SubMenuButton], completion: (() -> Void)?) {
        var delay: TimeInterval = 0
        for button in subButtons {
            let completionBlock = button.isEqual(subButtons.last) ? completion : nil
            animation(delay:delay, animation: {
                button.center = button.endPosition!
                button.alpha = 1
            }, completion: { (finish) in
                completionBlock?()
            })
            delay += 0.2
        }
    }
    
    func animationHideSubMenuButton(subButtons: [SubMenuButton], completion: (() -> Void)?) {
        var delay: TimeInterval = 0
        for button in subButtons.reversed() {
            let completionBlock = button.isEqual(subButtons.last) ? completion : nil
            animation(delay:delay, animation: {
                button.center = button.startPosition!
                button.alpha = 0
            }, completion: { (finish) in
                completionBlock?()
            })
            delay += 0.2
        }
    }
}
