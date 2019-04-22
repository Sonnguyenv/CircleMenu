//
//  Base.swift
//  CircleMenu
//
//  Created by SonNV-D1 on 4/22/19.
//  Copyright © 2019 SonNV-D1. All rights reserved.
//

import Foundation
import UIKit

// Định nghĩa delegate cho menu button
protocol CPMenuButtonDelegate: class {
    func didSelecButton(sender: CPMenuButton)
}

// Thuộc tính của Button
protocol CPSubMenuButtonProtocol {
    var index: Int { get set }
    var startPoistion: CGPoint? { get set }
    var endPosition: CGPoint? { get set }
}

public class CPMenuButton: UIView {
    private lazy var menuImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(origin: CGPoint.zero, size: self.frame.size))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    weak var delegate: CPMenuButtonDelegate?
    
    
    var image: UIImage? {
        didSet {
            setUpImageView()
        }
    }
    
    var size: CGSize? {
        didSet {
            if let size = size {
                frame.size = size
            }
        }
    }
    
    var offset: CGFloat = 0 {
        didSet {
            let sizeImage = CGSize(width: frame.size.width - offset , height: frame.size.height - offset)
            menuImageView.frame.size = sizeImage
            menuImageView.center = center
        }
    }
    
    
    init(image: UIImage, size: CGSize? = nil) {
        super.init(frame: CGRect.zero)
        self.image = image
        self.size = size
        if let size = size {
            frame.size = size
        } else {
            frame.size = CGSize(width: 50, height: 50)
        }
        menuImageView.image = image
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(CPMenuButton.tap(gesture:)))
        addGestureRecognizer(tapGesture)
        addSubview(menuImageView)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpImageView() {
        menuImageView.image = image
    }
    
    @objc func tap(gesture: UITapGestureRecognizer) {
        delegate?.didSelecButton(sender: gesture.view as! CPMenuButton)
    }
}

public class SubMenuButton: CPMenuButton, CPMenuButtonDelegate {
    func didSelecButton(sender: CPMenuButton) {
        print("did selecbutton")
    }
    
    var index = 0
    var startPosition: CGPoint?
    var endPosition: CGPoint?
}

public class HomeMenuButton: CPMenuButton {
    var pressedImage: UIImage?
    var notPressedImage: UIImage?
    
    func markAsPressed(_ pressed: Bool) {
        notPressedImage = notPressedImage ?? image
        image = pressed ? pressedImage : notPressedImage
    }
}
