//
//  UIView+Appearance.swift
//  SimulcastRTC
//
//  Created by second on 10/18/18.
//  Copyright © 2018 Webxloo. All rights reserved.
//

import UIKit

public struct AppearanceOptions: OptionSet {
    public let rawValue: UInt
    public init(rawValue: UInt) { self.rawValue = rawValue }
    static let overlay = AppearanceOptions(rawValue: 1 << 0)
    static let useAutoresize = AppearanceOptions(rawValue: 1 << 1)
}

extension UIView {
    
    func addSubview(_ subview: UIView, options: AppearanceOptions) {
        if subview.superview == self {
            return
        }
        addSubviewUsingOptions(options) { [weak self] in
            self?.addSubview(subview)
            return subview
        }
    }
    
    func insertSubview(_ subview: UIView, index: Int, options: AppearanceOptions) {
        if subview.superview == self {
            return
        }
        addSubviewUsingOptions(options) { [weak self] in
            self?.insertSubview(subview, at: index)
            return subview
        }
    }
    
}

fileprivate extension UIView {
    
    typealias SubviewTreeModifier = (() -> UIView)
    
    func addSubviewUsingOptions(_ options: AppearanceOptions, modifier: SubviewTreeModifier) {
        let subview = modifier()
        if options.union(.overlay) == .overlay {
            if options.union(.useAutoresize) != .useAutoresize {
                subview.translatesAutoresizingMaskIntoConstraints = false
                let views = dictionaryOfNames([subview])
                
                let horisontalConstraints = NSLayoutConstraint.constraints(
                    withVisualFormat: "|[subview]|",
                    options: [],
                    metrics: nil,
                    views: views
                )
                addConstraints(horisontalConstraints)
                
                let verticalConstraints = NSLayoutConstraint.constraints(
                    withVisualFormat: "V:|[subview]|",
                    options: [],
                    metrics: nil,
                    views: views
                )
                addConstraints(verticalConstraints)
                
            } else {
                frame = bounds
                subview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            }
        }
    }
    
    func dictionaryOfNames(_ views: [UIView]) -> [String: UIView] {
        var container = [String: UIView]()
        views.forEach {
            container["subview"] = $0
        }
        return container
    }
    
}
