//
//  ProfileViewController.swift
//  ProfilePage
//
//  Created by Tatiana Lazarenko on 22.01.2026.
//

import UIKit
import SwiftUI

#Preview {
    ContentView()
}

protocol ProfileViewControllerDelegate: AnyObject {
    var lastContentOffset: CGFloat { get }
    
    func childDidScroll(_ scrollView: UIScrollView, offset: CGFloat)
    func scrollToMenuIndex(_ index: Int)
    func setIsPaging(_ isPaging: Bool)
}

final class ProfileViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, ProfileViewControllerDelegate {
    var viewControllers: [UIViewController] = [] {
        didSet {
            setupViewControllers()
        }
    }
    
    lazy var tabBar: MenuBar = {
        let mb = MenuBar()
        mb.delegate = self
        return mb
    }()
    
    private var headerHeightConstraint: NSLayoutConstraint?
    private var headerTopConstraint: NSLayoutConstraint?
    private var currentOffset: CGFloat = 0
    private var isPaging: Bool = false
    
    var lastContentOffset: CGFloat = 0
    
    
    // MARK: - UI Elements
    private lazy var headerContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.backgroundColor = .systemGreen
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private lazy var pageViewController: ProfilePageViewController = {
        let vc = ProfilePageViewController(profileDelegate: self)
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        vc.delegate = self
        vc.dataSource = self
        return vc
    }()
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        let titleLabel = UILabel()
        titleLabel.text = "Профиль"
        titleLabel.textColor = .black
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textAlignment = .center
        navigationItem.titleView = titleLabel
        
        setupUI()
    }
    
    
    // MARK: - Setup
    private func setupUI() {
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
    
        view.addSubview(headerContainerView)
        view.addSubview(tabBar)
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        headerTopConstraint = headerContainerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0)
        headerHeightConstraint = headerContainerView.heightAnchor.constraint(equalToConstant: Constants.headerHeight)
        
        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            headerTopConstraint!,
            headerHeightConstraint!,
            headerContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tabBar.topAnchor.constraint(equalTo: headerContainerView.bottomAnchor),
            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBar.heightAnchor.constraint(equalToConstant: Constants.tabBarHeight)
        ])
    }
    
    private func setupViewControllers() {
        guard !viewControllers.isEmpty else { return }
        lastContentOffset = -(Constants.headerHeight - Constants.navBarHeight + Constants.tabBarHeight)
        
        for vc in viewControllers {
            if let scrollVC = vc as? ScrollableViewController {
                scrollVC.delegate = self
                scrollVC.updateContentInset(top: lastContentOffset)
            }
        }
        
        pageViewController.setViewControllers(
            [viewControllers[0]],
            direction: .forward,
            animated: false
        )
    }
    
    // MARK: - Actions
    @objc private func tabChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        guard index < viewControllers.count else { return }
        
        let direction: UIPageViewController.NavigationDirection = index > (viewControllers.firstIndex(where: { $0 == pageViewController.viewControllers?.first }) ?? 0) ? .forward : .reverse
        
        pageViewController.setViewControllers(
            [viewControllers[index]],
            direction: direction,
            animated: true
        )
    }
    
    func didChangePage(to index: Int) {
        if let scrollVC = viewControllers[index] as? ScrollableViewController {
            scrollVC.setContentOffset(lastContentOffset)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        isPaging = true
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = viewControllers.firstIndex(of: viewController), index > 0 else {
            return nil
        }
        return viewControllers[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = viewControllers.firstIndex(of: viewController), index < viewControllers.count - 1 else {
            return nil
        }
        return viewControllers[index + 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed,
              let currentVC = pageViewController.viewControllers?.first,
              let index = viewControllers.firstIndex(of: currentVC) else {
            return
        }
        
        tabBar.select(index: index, animated: true)
        didChangePage(to: index)
    }
    
    func childDidScroll(_ scrollView: UIScrollView, offset: CGFloat) {
        guard !isPaging else { return }
        
        let contentInsetTop = Constants.headerHeight + Constants.tabBarHeight + 14
        let maxOffset = -Constants.headerHeight + Constants.navBarHeight + 14
        let adjustedOffset = offset + contentInsetTop
        let newHeaderOffset = min(max(-adjustedOffset, maxOffset), 0)
        
        headerTopConstraint?.constant = newHeaderOffset
        lastContentOffset = offset
        
        for vc in viewControllers {
            if let scrollVC = vc as? ScrollableViewController,
               scrollVC.collectionView != scrollView {
                scrollVC.setContentOffsetWithoutDelegate(offset)
            }
        }
    }
    
    func scrollToMenuIndex(_ index: Int) {
        isPaging = true
        
        guard
            index >= 0,
            index < viewControllers.count,
            let currentVC = pageViewController.viewControllers?.first,
            let currentIndex = viewControllers.firstIndex(of: currentVC),
            currentIndex != index
        else { return }

        let direction: UIPageViewController.NavigationDirection =
            index > currentIndex ? .forward : .reverse

        pageViewController.setViewControllers(
            [viewControllers[index]],
            direction: direction,
            animated: true
        )

        tabBar.select(index: index, animated: true)
    }

    func setIsPaging(_ isPaging: Bool) {
        self.isPaging = isPaging
    }
}
