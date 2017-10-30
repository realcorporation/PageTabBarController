//
//  CollapseStaticHeaderView.swift
//  PageTabBarController
//
//  Created by Keith Chan on 20/10/2017.
//  Copyright © 2017 com.mingloan. All rights reserved.
//

import Foundation
import UIKit

class CollapseStaticHeaderView: UICollectionReusableView {
    
    private(set) var contentView: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let view = super.hitTest(point, with: event) {
            
            if view == contentView {
                return nil
            }
            
            return view
        }
        return nil
    }
    
    func configureWithContentView(_ view: UIView?) {
        contentView?.removeFromSuperview()
        
        contentView = view
        guard let contentView = contentView else { return }
        
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([contentView.topAnchor.constraint(equalTo: topAnchor),
                                     contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
                                     contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     contentView.trailingAnchor.constraint(equalTo: trailingAnchor)])
        
    }
}