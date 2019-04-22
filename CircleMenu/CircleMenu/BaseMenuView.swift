//
//  BaseMenuView.swift
//  CircleMenu
//
//  Created by SonNV-D1 on 4/22/19.
//  Copyright © 2019 SonNV-D1. All rights reserved.
//

import Foundation
import UIKit

public enum CPMenuType {
    case all
    case half
    case upperhalf
    case lowerhalf
    case quarter
}

public enum CPMenuViewState {
    case none
    case expand
}

public protocol CPMenuViewDelegate: class {
    func menuView(_ menuView: CPMenuView, didSelectButtonAtIndex index: Int)
    func menuView(_ menuView: CPMenuView, didSelectHomeButtonState state: CPMenuViewState)
}

public protocol CPMenuViewDataSource: class {
    func menuViewNumberOfItems() -> Int
    func menuView(_ : CPMenuView, buttonAtIndex index: Int) -> SubMenuButton
}

public class CPMenuView {
    fileprivate var parentView: UIView?
    fileprivate var homeButton: HomeMenuButton?
    fileprivate var animator: CPMenuAnimation?
    fileprivate var menuButtons:[SubMenuButton] = []
    
    public var type: CPMenuType = .all
    public var isClockWise = true // Default is clockwise
    public var radius: Double = 100 // Default radius
    
    fileprivate(set) var state: CPMenuViewState = .none {
        didSet {
            state == .none ? animator?.animationHideSubMenuButton(subButtons: menuButtons, completion: nil) : animator?.animationShowSubMenuButton(subButtons: menuButtons, completion: nil)
            animator?.animationHomeButton(homeButton: homeButton!, state: state, completion: nil)
            setHomeButtonImage(pressed: state == .expand)
        }
    }
    
    public var datasource: CPMenuViewDataSource?
    public var delegate: CPMenuViewDelegate?
    
    
    
    init(parentView: UIView, homeButton: HomeMenuButton, animator: CPMenuAnimation, type: CPMenuType, radius: Double = 100, isClockWise: Bool) {
        self.parentView = parentView
        self.homeButton = homeButton
        self.animator = animator
        self.type = type
        self.radius = radius
        self.isClockWise = isClockWise
        setup()
    }
    
    convenience public init(parentView: UIView, homeButton: HomeMenuButton, type: CPMenuType = .all ,radius: Double = 100, isClockWise: Bool = true) {
        self.init(parentView: parentView, homeButton: homeButton, animator: CPMenuAnimation(), type: type, radius: radius, isClockWise: isClockWise)
    }
    
    private func setup() {
        setUpHomeButton()
    }
    
    fileprivate func setUpHomeButton() {
        guard let parentView = parentView else {
            return
        }
        setUpDefaultHomeButtonPosition()
        homeButton?.delegate = self
        parentView.addSubview(homeButton!)
        parentView.bringSubviewToFront(homeButton!)
    }
    
    fileprivate func setUpDefaultHomeButtonPosition() {
        guard let parentView = parentView else {
            return
        }
        homeButton?.center = parentView.center
    }
    
    
    public func reloadButton() {
        state = .none
        removeButton()
        addButton()
        layoutButton()
    }
    
    private func addButton() {
        guard let numberOfItem = datasource?.menuViewNumberOfItems() else { return }
        for i in 0..<numberOfItem {
            let button = datasource!.menuView(self, buttonAtIndex: i)
            button.delegate = self
            parentView?.addSubview(button)
            parentView?.bringSubviewToFront(button)
            menuButtons.append(button)
        }
    }
    
    private func removeButton() {
        let _ =  menuButtons.map { $0.removeFromSuperview() }
        menuButtons.removeAll()
    }
    
    private func layoutButton() {
        let theta = getTheta()
        let flip: Double = isClockWise ? 1 : -1
        var index = 0
        let center = CGPoint(x: homeButton!.frame.midX, y: homeButton!.frame.midY)
        menuButtons.forEach { (item) in
            var x = 0.0
            var y = 0.0
            if type == .upperhalf  {
                x = Double(center.x) - cos(Double(index) * theta) * radius * flip
                y = Double(center.y) - sin(Double(index) * theta) * radius
                
            } else if type == .lowerhalf {
                x = Double(center.x) + cos(Double(index) * theta) * radius * flip
                y = Double(center.y) + sin(Double(index) * theta) * radius
                
            } else {
                x = Double(center.x) + sin(Double(index) * theta) * radius * flip
                y = Double(center.y) - cos(Double(index) * theta) * radius
            }
            
            item.center = center
            item.startPosition = center
            item.endPosition = CGPoint(x: x, y: y)
            item.index = index
            item.alpha = 0
            index += 1
        }
        
    }
    
    private func getTheta() -> Double {
        let numberItem: Double = Double(datasource!.menuViewNumberOfItems() == 0 ? 1 : datasource!.menuViewNumberOfItems() - 1)
        switch type {
        case .all:
            return 2 * M_PI / (numberItem + 1)
        case .half:
            return M_PI / numberItem
        case .upperhalf:
            return M_PI / numberItem
        case .lowerhalf:
            return M_PI / numberItem
        case .quarter:
            return M_PI_2 / numberItem
        }
    }
    
    private func setHomeButtonImage(pressed: Bool) {
        homeButton?.markAsPressed(pressed)
    }
    
    
    public func setHomeButtonPosition(position: CGPoint) {
        homeButton?.center = position
        reloadButton()
    }
}

extension CPMenuView: CPMenuButtonDelegate {
    func didSelecButton(sender: CPMenuButton) {
        if let subMenuButton = sender as? SubMenuButton, let indexOfItem = menuButtons.index(of: subMenuButton) {
            state = .none
            delegate?.menuView(self, didSelectButtonAtIndex: indexOfItem)
        } else {
            state = state == .none ? .expand : .none
            delegate?.menuView(self, didSelectHomeButtonState: state)
        }
    }
}
