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
    private var readyForPresentation = false
    
    private var currentPage = 0
    
    private var minLeading: CGFloat = 20
    private var currentLeading: CGFloat = 0
    private var interpalationValue: CGFloat = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard !readyForPresentation else { return }
        readyForPresentation = true
        
        let initialLeading = view.frame.width / 100 * 85
        leadingConstraint.constant = initialLeading
        
        setupValues(with: initialLeading)
    }
    
    private func setupValues(with initialLeading: CGFloat) {
        let maxContentOffset = scrollView.contentSize.width / CGFloat(viewControllers.count)
        currentLeading = initialLeading - minLeading
        interpalationValue = currentLeading / maxContentOffset
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
        
        let leadingConstraintConstant = currentLeading - (scrollView.contentOffset.x * interpalationValue)
        leadingConstraint.constant = leadingConstraintConstant
        
        guard leadingConstraintConstant >= minLeading else { return }
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView === self.scrollView else { return }
        let currentPage = Int(scrollView.contentOffset.x / scrollView.frame.width)
        self.currentPage = currentPage
    }
    
}
