//
//  ViewController.swift
//  MonoTest
//
//  Created by Dmitriy Demchenko on 12/21/18.
//  Copyright © 2018 Dmitriy Demchenko. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var cardView: UIView!
    @IBOutlet private weak var leadingConstraint: NSLayoutConstraint!
    
    private var viewControllers: [UIViewController] = []
    private var currentPage = 0
    private var readyForPresentation = false
    
    private var minLeading: CGFloat = 20
    private var currentLeading: CGFloat = 0
    private var maxValue: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        leadingConstraint.constant = view.frame.width / 100 * 80
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard !readyForPresentation else { return }
        readyForPresentation = true
        currentLeading = view.frame.width / 100 * 85
        maxValue = currentLeading - minLeading
        leadingConstraint.constant = currentLeading
    }
    
    
}

private extension ViewController {
    
    func configure() {
        scrollView.delegate = self
        
        cardView.layer.cornerRadius = 20
        
        viewControllers = [
            StoryboardScene.Main.firstViewController.instantiate(),
            StoryboardScene.Main.secondViewController.instantiate()
        ]
        
        setScrollViewContentSize()
        setupScrollView()
    }
    
    func setScrollViewContentSize(isUpdate: Bool = false) {
        let containerViewHeight = containerView.frame.height
        let containerViewWidth = containerView.frame.width
        
        if isUpdate {
            scrollView.frame = containerView.frame
        }
        
        scrollView.contentSize = CGSize(
            width: containerViewWidth * CGFloat(viewControllers.count),
            height: containerViewHeight
        )
        
        for (index, viewController) in viewControllers.enumerated() {
            viewController.view.frame = CGRect(
                x: containerViewWidth * CGFloat(index),
                y: 0,
                width: scrollView.frame.width,
                height: scrollView.frame.height
            )
        }
    }
    
    func setupScrollView() {
        viewControllers.forEach {
            addChild($0)
            scrollView.addSubview($0.view, options: .useAutoresize)
            $0.didMove(toParent: self)
        }
    }
    
}

extension ViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0 || scrollView.contentOffset.y < 0 {
            scrollView.contentOffset.y = 0
        }
        
        let maxContentOffset = scrollView.contentSize.width / CGFloat(viewControllers.count)
        let interpolationValue = currentLeading / maxContentOffset
        let moveDimmention = scrollView.contentOffset.x * interpolationValue
        currentLeading -= moveDimmention

        leadingConstraint.constant = currentLeading
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView === self.scrollView else { return }
        let currentPage = Int(scrollView.contentOffset.x / scrollView.frame.width)
        self.currentPage = currentPage
    }
    
}
