//
//  PageTabBarController.swift
//  PageTabBarController
//
//  Created by Keith Chan on 4/9/2017.
//  Copyright © 2017 com.mingloan. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation
import UIKit

@objc
public protocol PageTabBarCollectionViewTouchDelegate: NSObjectProtocol {
    
    @objc optional func pageTabBarCollectionView(_ collectionView: PageTabBarCollectionView, gestureRecognizerShouldBegin gestureRecognizer: UIGestureRecognizer) -> Bool
    
    @objc optional func pageTabBarCollectionView(_ collectionView: PageTabBarCollectionView, gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool
    
    @objc optional func pageTabBarCollectionView(_ collectionView: PageTabBarCollectionView, gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool
    
    @objc optional func pageTabBarCollectionView(_ collectionView: PageTabBarCollectionView, gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
    
    @objc optional func pageTabBarCollectionView(_ collectionView: PageTabBarCollectionView, gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool
    
    @objc optional func pageTabBarCollectionView(_ collectionView: PageTabBarCollectionView, gestureRecognizer: UIGestureRecognizer, shouldReceivePress press: UIPress) -> Bool
}

@objcMembers
open class PageTabBarCollectionView: UICollectionView, UIGestureRecognizerDelegate {
    
    var touchDelegate: PageTabBarCollectionViewTouchDelegate?
    
    override public init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        panGestureRecognizer.delegate = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let boolean = touchDelegate?.pageTabBarCollectionView?(self, gestureRecognizerShouldBegin: gestureRecognizer) {
            return boolean
        }
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
    
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let boolean = touchDelegate?.pageTabBarCollectionView?(self, gestureRecognizer: gestureRecognizer, shouldRequireFailureOf: otherGestureRecognizer) {
            return boolean
        }
        return false
    }
    
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let boolean = touchDelegate?.pageTabBarCollectionView?(self, gestureRecognizer: gestureRecognizer, shouldBeRequiredToFailBy: otherGestureRecognizer) {
            return boolean
        }
        return false
    }
    
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let boolean = touchDelegate?.pageTabBarCollectionView?(self, gestureRecognizer: gestureRecognizer, shouldRecognizeSimultaneouslyWith: otherGestureRecognizer) {
            return boolean
        }
        return false
    }
    
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let boolean = touchDelegate?.pageTabBarCollectionView?(self, gestureRecognizer: gestureRecognizer, shouldReceive: touch) {
            return boolean
        }
        return true
    }
    
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive press: UIPress) -> Bool {
        if let boolean = touchDelegate?.pageTabBarCollectionView?(self, gestureRecognizer: gestureRecognizer, shouldReceivePress: press) {
            return boolean
        }
        return true
    }
}

public enum PageTabBarTransitionAnimation {
    case none
    case scroll
}

@objc
public protocol PageTabBarControllerDelegate: class {
    @objc optional func pageTabBarController(_ controller: PageTabBarController, tabBarHeaderView: PageTabBarSupplementaryView)
    @objc optional func pageTabBarController(_ controller: PageTabBarController, bannerView: PageTabBarSupplementaryView)
    @objc optional func pageTabBarController(_ controller: PageTabBarController, didSelectItem item: PageTabBarItem, atIndex index: Int, previousIndex: Int)
    @objc optional func pageTabBarController(_ controller: PageTabBarController, didChangeContentViewController vc: UIViewController, atIndex index: Int)
    @objc optional func pageTabBarController(_ controller: PageTabBarController, transit fromIndex: Int, to toIndex: Int, progress: CGFloat)
}

internal final class PageTabBarCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let cv = collectionView else { return false }
        let oldBounds = cv.bounds
        if newBounds.height != oldBounds.height {
            cv.collectionViewLayout.invalidateLayout()
            return false
        }
        return false
    }

}

@objcMembers
open class PageTabBarController: UIViewController, UIScrollViewDelegate {
        
    override open var childViewControllerForStatusBarHidden: UIViewController? {
        return selectedViewController
    }
    
    override open var childViewControllerForStatusBarStyle: UIViewController? {
        return selectedViewController
    }
    
    override open var shouldAutomaticallyForwardAppearanceMethods: Bool {
        if case .scroll = transitionAnimation {
            return false
        }
        else {
           return true
        }
    }
    
    open weak var delegate: PageTabBarControllerDelegate?
    open weak var touchDelegate: PageTabBarCollectionViewTouchDelegate? {
        didSet {
            pageTabBarCollectionView.touchDelegate = touchDelegate
        }
    }
    
    open var transitionAnimation = PageTabBarTransitionAnimation.scroll {
        didSet {
            if case .scroll = transitionAnimation {
                isScrollEnabled = true
            }
            else {
                isScrollEnabled = false
            }
        }
    }
    
    open var updateIndex: (Bool, Int) -> () = { _,_  in }
    
    open private(set) var pageIndex: Int = 0 {
        willSet {
            guard !viewDidLayoutSubviewsForTheFirstTime else { return }
            if !shouldAutomaticallyForwardAppearanceMethods{
                viewControllers[pageIndex].beginAppearanceTransition(false, animated: false)
                viewControllers[pageIndex].endAppearanceTransition()
            }
        }
        didSet {
            guard !viewDidLayoutSubviewsForTheFirstTime else { return }
            if !shouldAutomaticallyForwardAppearanceMethods {
                viewControllers[pageIndex].beginAppearanceTransition(true, animated: false)
                viewControllers[pageIndex].endAppearanceTransition()
            }
            
            UIView.animate(withDuration: 0.2) {
                self.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    
    open var selectedViewController: UIViewController? {
        if viewControllers.count > pageIndex {
            return viewControllers[pageIndex]
        }
        return nil
    }
    
    open internal(set) var pageTabBar: PageTabBar
    
    open var isScrollEnabled = true {
        didSet {
            pageTabBarCollectionView.isScrollEnabled = isScrollEnabled
        }
    }
    
    open var bounces = true {
        didSet {
            pageTabBarCollectionView.bounces = bounces
        }
    }
    
    open private(set) var pageTabBarHeaderView = PageTabBarSupplementaryView(frame: CGRect.zero)
    
    open private(set) var pageTabBarBannerView = PageTabBarSupplementaryView(frame: CGRect.zero)
    
    open let pageTabBarCollectionView: PageTabBarCollectionView = {
        let layout = PageTabBarCollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = .zero
        
        let collectionView = PageTabBarCollectionView(frame: UIScreen.main.bounds, collectionViewLayout: layout)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.isPagingEnabled = true
        collectionView.bounces = true
        collectionView.alwaysBounceHorizontal = true
        collectionView.alwaysBounceVertical = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.scrollsToTop = false
        collectionView.backgroundColor = .clear
        collectionView.isDirectionalLockEnabled = true
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        return collectionView
    }()
    
    internal(set) var viewControllers = [UIViewController]()
    private var tabBarPosition: PageTabBarPosition = .top
    
    var pageTabBarItems: [PageTabBarItem] = []
    
    // States
    private var transientIndex = 0
    private var contentOffsetX: CGFloat = 0
    private var viewDidLayoutSubviewsForTheFirstTime = true
    
    // Layout Guide
    open private(set) var tabBarLayoutGuide = UILayoutGuide()
    
    // Constraints
    fileprivate var topConstraint: NSLayoutConstraint?
    fileprivate var bottomConstraint: NSLayoutConstraint?
    fileprivate var headerHeightConstraint: NSLayoutConstraint?
    fileprivate var bannerHeightConstraint: NSLayoutConstraint?
    
    public required init(viewControllers: [UIViewController],
                items: [PageTabBarItem],
                tabBarPosition: PageTabBarPosition = .top) {
        
        self.pageTabBar = PageTabBar(tabBarItems: items)
        
        super.init(nibName: nil, bundle: nil)
        
        self.viewControllers = viewControllers
        self.tabBarPosition = tabBarPosition
        pageTabBarItems = items
        pageTabBar.addLayoutGuide(tabBarLayoutGuide)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        pageTabBar.currentIndex = pageIndex
        pageTabBar.delegate = self
        view.addSubview(pageTabBar)
        pageTabBar.translatesAutoresizingMaskIntoConstraints = false
        pageTabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        pageTabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        view.addSubview(pageTabBarHeaderView)
        pageTabBarHeaderView.translatesAutoresizingMaskIntoConstraints = false
        pageTabBarHeaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        pageTabBarHeaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        view.addSubview(pageTabBarBannerView)
        pageTabBarBannerView.translatesAutoresizingMaskIntoConstraints = false
        pageTabBarBannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        pageTabBarBannerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        pageTabBarCollectionView.dataSource = self
        pageTabBarCollectionView.delegate = self
        
        view.addSubview(pageTabBarCollectionView)
        pageTabBarCollectionView.translatesAutoresizingMaskIntoConstraints = false
        pageTabBarCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        pageTabBarCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        if case .top = tabBarPosition {
            
            if #available(iOS 11.0, *) {
                topConstraint = pageTabBarHeaderView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
                topConstraint?.isActive = true
            } else {
                topConstraint = pageTabBarHeaderView.topAnchor.constraint(equalTo: view.topAnchor)
                topConstraint?.isActive = true
            }
            
            pageTabBar.topAnchor.constraint(equalTo: pageTabBarHeaderView.bottomAnchor).isActive = true
            pageTabBarBannerView.topAnchor.constraint(equalTo: pageTabBar.bottomAnchor).isActive = true
            pageTabBarCollectionView.topAnchor.constraint(equalTo: pageTabBarBannerView.bottomAnchor).isActive = true
            
            bottomConstraint = pageTabBarCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            bottomConstraint?.isActive = true
        }
        else {
            
            if #available(iOS 11.0, *) {
                topConstraint = pageTabBarHeaderView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
                topConstraint?.isActive = true
                
            } else {
                topConstraint = pageTabBarHeaderView.topAnchor.constraint(equalTo: view.topAnchor)
                topConstraint?.isActive = true
            }
            bottomConstraint = pageTabBar.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            bottomConstraint?.isActive = true
            
            pageTabBarCollectionView.topAnchor.constraint(equalTo: pageTabBarHeaderView.bottomAnchor).isActive = true
            pageTabBarBannerView.topAnchor.constraint(equalTo: pageTabBarCollectionView.bottomAnchor).isActive = true
            pageTabBar.topAnchor.constraint(equalTo: pageTabBarBannerView.bottomAnchor).isActive = true
        }
        
        headerHeightConstraint = pageTabBarHeaderView.heightAnchor.constraint(equalToConstant: 0)
        bannerHeightConstraint = pageTabBarBannerView.heightAnchor.constraint(equalToConstant: 0)
        headerHeightConstraint?.isActive = true
        bannerHeightConstraint?.isActive = true
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !shouldAutomaticallyForwardAppearanceMethods {
            selectedViewController?.beginAppearanceTransition(true, animated: animated)
        }
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !shouldAutomaticallyForwardAppearanceMethods {
            selectedViewController?.endAppearanceTransition()
        }
        
        if isMovingToParentViewController || isBeingPresented {
            if #available(iOS 11.0, *) { /* do nothing */ } else {
                if let top = topConstraint, let bottom = bottomConstraint {
                    if case .bottom = tabBarPosition {
                        NSLayoutConstraint.deactivate([top, bottom])
                        topConstraint = pageTabBarHeaderView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor)
                        topConstraint?.isActive = true
                        bottomConstraint = pageTabBar.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor)
                        bottomConstraint?.isActive = true
                    } else {
                        NSLayoutConstraint.deactivate([top])
                        topConstraint = pageTabBarHeaderView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor)
                        topConstraint?.isActive = true
                    }
                }
            }
        }
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !shouldAutomaticallyForwardAppearanceMethods {
            selectedViewController?.beginAppearanceTransition(false, animated: animated)
        }
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if !shouldAutomaticallyForwardAppearanceMethods {
            selectedViewController?.endAppearanceTransition()
        }
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if viewDidLayoutSubviewsForTheFirstTime {
            viewDidLayoutSubviewsForTheFirstTime = false
            
            if case .scroll = transitionAnimation {
                isScrollEnabled = true
            }
            else {
                isScrollEnabled = false
            }
            
            contentOffsetX = view.frame.width * CGFloat(pageIndex)
            transientIndex = pageIndex
            
            pageTabBarCollectionView.scrollToItem(at: IndexPath(item: pageIndex, section: 0), at: .centeredHorizontally, animated: false)
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    // MARK: - Badge
    open func setBadge(_ value: Int, forItemAt index: Int) {
        guard pageTabBarItems.count > index else { return }
        pageTabBarItems[index].badgeCount = value
    }
    
    open func clearAllBadges() {
        for item in pageTabBarItems {
            item.badgeCount = 0
        }
    }
    
    // MARK: - PageIndex
    open func setPageIndex(_ index: Int, animated: Bool) {
        guard pageTabBarItems.count > index else { return }
        
        var shouldAnimate = animated
        if case .scroll = transitionAnimation {
            shouldAnimate = animated
        }
        else {
            shouldAnimate = false
        }
        
        if !isViewLoaded {
            shouldAnimate = false
        }
        
        guard index != pageIndex else { return }
        
        delegate?.pageTabBarController?(self, didSelectItem: pageTabBarItems[index], atIndex: index, previousIndex: pageIndex)
        
        pageIndex = index
        
        let indexPath = IndexPath(item: index, section: 0)
        if !viewDidLayoutSubviewsForTheFirstTime {
            pageTabBarCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: shouldAnimate)
        }
        
        if !shouldAnimate {
            delegate?.pageTabBarController?(self, didChangeContentViewController: viewControllers[pageIndex], atIndex: pageIndex)
        }
    }
    
    internal func interceptTouchesScrollViews() -> [UIScrollView] {
        var scrollViews = [UIScrollView]()
        for vc in viewControllers {
            if let tableViewCtl = vc as? UITableViewController, let scrollView = tableViewCtl.view as? UIScrollView {
                scrollViews.append(scrollView)
            }
            else if let collectionViewCtl = vc as? UICollectionViewController, let scrollView = collectionViewCtl.view as? UIScrollView {
                scrollViews.append(scrollView)
            }
            else if let rootView = vc.view as? UIScrollView {
                scrollViews.append(rootView)
            }
            else if let baseScrollView = theMostBelowScrollViewInView(vc.view) {
                scrollViews.append(baseScrollView)
            }
        }
        return scrollViews
    }
    
    func theMostBelowScrollViewInView(_ view: UIView) -> UIScrollView? {
        
        if let scrollView = view as? UIScrollView {
            return scrollView
        }
        
        for subview in view.subviews {
            // if the real keyboard-view is found, remember it.
            if let scrollView = subview as? UIScrollView {
                return scrollView
            }
            
            let itsSubview = theMostBelowScrollViewInView(subview)
            if itsSubview != nil {
                return itsSubview
            }
        }
        return nil
    }
    
    // MARK: - Supplementary Views
    open func setHeaderViewWithCustomView(_ customView: UIView?, animated: Bool) {
        pageTabBarHeaderView.subviews.forEach { $0.removeFromSuperview() }
        
        guard let customView = customView else {
            
            UIView.animate(withDuration: 0.3) {
                self.headerHeightConstraint?.constant = 0
                self.view.layoutIfNeeded()
            }
            
            return
        }
        
        pageTabBarHeaderView.addSubview(customView)
        let height = ceil(customView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height)
        
        if view.window == nil {
            self.headerHeightConstraint?.constant = height
            return
        }
        
        UIView.animate(withDuration: 0.3) {
            self.headerHeightConstraint?.constant = height
            self.view.layoutIfNeeded()
        }
    }
    
    open func setBannerViewWithCustomView(_ customView: UIView?, animated: Bool) {
        pageTabBarBannerView.subviews.forEach { $0.removeFromSuperview() }
        
        guard let customView = customView else {
            
            UIView.animate(withDuration: 0.3) {
                self.bannerHeightConstraint?.constant = 0
                self.view.layoutIfNeeded()
            }
            
            return
        }
        
        let height = ceil(customView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height)
        
        pageTabBarBannerView.addSubview(customView)
        customView.translatesAutoresizingMaskIntoConstraints = false
        customView.topAnchor.constraint(equalTo: pageTabBarBannerView.topAnchor).isActive = true
        customView.leadingAnchor.constraint(equalTo: pageTabBarBannerView.leadingAnchor).isActive = true
        customView.trailingAnchor.constraint(equalTo: pageTabBarBannerView.trailingAnchor).isActive = true
        customView.heightAnchor.constraint(equalToConstant: height).isActive = true
        
        if view.window == nil {
            self.bannerHeightConstraint?.constant = height
            return
        }
        
        UIView.animate(withDuration: 0.3) {
            self.bannerHeightConstraint?.constant = height
            self.view.layoutIfNeeded()
        }
    }
    
    open func resetPageTabBarController(_ viewControllers: [UIViewController], items: [PageTabBarItem], newPageIndex: Int, animated: Bool) {
        
        pageTabBarItems = items
        pageTabBar.replaceTabBarItems(items, animated: animated)
        
        self.viewControllers.forEach { vc in
            if vc.parent != nil {
                vc.willMove(toParentViewController: nil)
                vc.view.removeFromSuperview()
                vc.removeFromParentViewController()
            }
        }
        self.viewControllers = viewControllers
        pageTabBarCollectionView.reloadData()
    }
}

extension PageTabBarController: PageTabBarDelegate {
    func pageTabBar(_ tabBar: PageTabBar, indexDidChanged index: Int) {
        setPageIndex(index, animated: true)
    }
}

extension PageTabBarController: UICollectionViewDataSource {
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewControllers.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        return cell
    }
}

extension PageTabBarController: UICollectionViewDelegate {
    
    open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let vc = viewControllers[indexPath.row]
        if vc.parent == nil {
            addChildViewController(vc)
            cell.contentView.addSubview(vc.view)
            vc.view.translatesAutoresizingMaskIntoConstraints = false
            vc.view.topAnchor.constraint(equalTo: cell.contentView.topAnchor).isActive = true
            vc.view.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor).isActive = true
            vc.view.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor).isActive = true
            vc.view.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor).isActive = true
            vc.didMove(toParentViewController: self)
        }
        else {
            cell.contentView.addSubview(vc.view)
            vc.view.translatesAutoresizingMaskIntoConstraints = false
            vc.view.topAnchor.constraint(equalTo: cell.contentView.topAnchor).isActive = true
            vc.view.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor).isActive = true
            vc.view.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor).isActive = true
            vc.view.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor).isActive = true
        }
        updateIndex(false, indexPath.row)
    }
    
    open func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let vc = viewControllers[indexPath.row]
        vc.willMove(toParentViewController: nil)
        vc.view.removeFromSuperview()
        vc.removeFromParentViewController()
    }
    
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        pageTabBar.isInteracting = true
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.contentSize.width > 0 else { return }
        
        let previousContentOffsetX = contentOffsetX
        contentOffsetX = scrollView.contentOffset.x
        
        let diff = contentOffsetX * pageTabBar.frame.width/scrollView.contentSize.width
        
        let oldTransientIndex = transientIndex
        transientIndex = pageTabBar.setIndicatorPosition(diff)
        
        if oldTransientIndex != transientIndex {
            //print("changed transientIndex: \(transientIndex)")
            delegate?.pageTabBarController?(self, transit: oldTransientIndex, to: transientIndex, progress: 1.0)
        } else {
            
            let startOffsetX = CGFloat(oldTransientIndex) * pageTabBar.frame.width
            let displacement = abs(startOffsetX - contentOffsetX)
            
            if displacement <= pageTabBar.frame.width/2 {
                let progress = displacement/(pageTabBar.frame.width/2)
                
                if previousContentOffsetX > contentOffsetX {
                    // moving left
                    if startOffsetX < contentOffsetX {
                        //print("moving back to \(oldTransientIndex) with progress \(1.0 - progress)")
                        if oldTransientIndex < viewControllers.count - 1 {
                            delegate?.pageTabBarController?(self, transit: oldTransientIndex, to: oldTransientIndex, progress: progress)
                        }
                    } else if startOffsetX > contentOffsetX {
                        //print("moving from \(oldTransientIndex) to \(oldTransientIndex - 1) with progress \(progress)")
                        if oldTransientIndex > 0 {
                            delegate?.pageTabBarController?(self, transit: oldTransientIndex, to: oldTransientIndex - 1, progress: progress)
                        }
                    }
                    
                } else if previousContentOffsetX < contentOffsetX {
                    // moving right
                    if startOffsetX < contentOffsetX {
                        //print("moving from \(oldTransientIndex) to \(oldTransientIndex + 1) with progress \(progress)")
                        if oldTransientIndex < viewControllers.count - 1 {
                            delegate?.pageTabBarController?(self, transit: oldTransientIndex, to: oldTransientIndex + 1, progress: progress)
                        }
                    } else if startOffsetX > contentOffsetX {
                        //print("moving back to \(oldTransientIndex) with progress \(1.0 - progress)")
                        if oldTransientIndex > 0 {
                            delegate?.pageTabBarController?(self, transit: oldTransientIndex, to: oldTransientIndex, progress: progress)
                        }
                    }
                    
                }
            }
            
            
        }
    }
    
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate && !scrollView.isDragging {
            didDragAndEnd()
        }
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if !scrollView.isDragging {
            didDragAndEnd()
        }
    }
    
    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        delegate?.pageTabBarController?(self, didChangeContentViewController: viewControllers[pageIndex], atIndex: pageIndex)
    }
    
    fileprivate func didDragAndEnd() {
        pageTabBar.isInteracting = false
        pageTabBar.updateCurrentIndex()
        delegate?.pageTabBarController?(self, didChangeContentViewController: viewControllers[pageIndex], atIndex: pageIndex)
    }
    
}

extension PageTabBarController: UICollectionViewDelegateFlowLayout {
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
}
