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
    private let constant: Constants = Constants.shared
    private var headerTopConstraint: NSLayoutConstraint?
    private var currentOffset: CGFloat = 0
    private var isPaging: Bool = false
    private var hasTriggeredInitialOffset = false
    private var isSetViewControllers: Bool = false
    
    var lastContentOffset: CGFloat = 0
    var viewControllers: [UIViewController] = []
    
    
// MARK: - UI Elements
    private lazy var tabBar: MenuBar = {
        let mb = MenuBar()
        mb.delegate = self
        return mb
    }()
    
    private lazy var headerContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
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
    
    private let userInfoView: UserInfoView = {
        let userInfoView = UserInfoView()
        userInfoView.configure(
            avatarURL: "https://i.natgeofe.com/n/548467d8-c5f1-4551-9f58-6817a8d2c45e/NationalGeographic_2572187_16x9.jpg?w=1200",
            name: "Tim Cook",
            nickname: "cooktim"
        )
        userInfoView.translatesAutoresizingMaskIntoConstraints = false
        return userInfoView
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
        titleLabel.text = "Profile"
        titleLabel.textColor = .black
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textAlignment = .center
        navigationItem.titleView = titleLabel
        
        setupUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        constant.setHeaderHeight(headerContainerView.frame.height)
        constant.setNavBarHeight(view.layoutMargins.top)
        constant.setMinTopOffset(-(constant.navBarHeight + constant.tabBarHeight + constant.padding))
        constant.setMaxTopOffset(constant.headerHeight + constant.navBarHeight + constant.tabBarHeight + constant.padding)
        
        setupViewControllers()
    }

    
// MARK: - Setup
    private func setupUI() {
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
    
        view.addSubview(headerContainerView)
        view.addSubview(tabBar)
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        headerContainerView.addSubview(userInfoView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        headerTopConstraint = headerContainerView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 0)
        
        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            headerTopConstraint!,
            headerContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tabBar.topAnchor.constraint(equalTo: headerContainerView.bottomAnchor),
            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBar.heightAnchor.constraint(equalToConstant: constant.tabBarHeight),

            userInfoView.topAnchor.constraint(equalTo: headerContainerView.topAnchor),
            userInfoView.bottomAnchor.constraint(equalTo: headerContainerView.bottomAnchor),
            userInfoView.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor),
            userInfoView.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor)
        ])
    }
    
    private func setupViewControllers() {
        guard !viewControllers.isEmpty, !isSetViewControllers else { return }
        defer { isSetViewControllers = true }
        
        lastContentOffset = -(constant.headerHeight + constant.tabBarHeight + constant.padding)
        
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
        resetInitialTrigger()
        tabBar.select(index: index, animated: true)
    }
    
    func childDidScroll(_ scrollView: UIScrollView, offset: CGFloat) {
        guard !isPaging else { return }
        
        let maxOffset = -constant.headerHeight
        let adjustedOffset = offset + constant.maxTopOffset
        let newHeaderOffset = min(max(-adjustedOffset, maxOffset), 0)
        
        headerTopConstraint?.constant = newHeaderOffset
        lastContentOffset = offset
        
        
        if offset >= constant.minTopOffset && !hasTriggeredInitialOffset {
            hasTriggeredInitialOffset = true
            for vc in viewControllers {
                if let scrollVC = vc as? ScrollableViewController,
                   scrollVC.collectionView != scrollView {
                    scrollVC.setContentOffset(constant.minTopOffset)
                }
            }
        }
        
        for vc in viewControllers {
            if let scrollVC = vc as? ScrollableViewController,
               scrollVC.collectionView != scrollView, offset < constant.minTopOffset {
                scrollVC.setContentOffset(offset)
                resetInitialTrigger()
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
    
    private func resetInitialTrigger() {
        hasTriggeredInitialOffset = false
    }
}
