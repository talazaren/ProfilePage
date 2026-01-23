//
//  ProfilePageViewController.swift
//  ProfilePage
//
//  Created by Tatiana Lazarenko on 22.01.2026.
//

import UIKit

final class ProfilePageViewController: UIPageViewController {
    weak var profileDelegate: ProfileViewControllerDelegate?
    private weak var scrollView: UIScrollView?

    init(profileDelegate: ProfileViewControllerDelegate? = nil) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        self.profileDelegate = profileDelegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupPagingControl()
    }

    private func setupPagingControl() {
        guard let scroll = view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView else {
            return
        }

        scrollView = scroll
        scroll.panGestureRecognizer.addTarget(self, action: #selector(handlePan(_:)))
    }
    
    @objc
    private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let scrollView else { return }
        let location = gesture.location(in: view)
        
        switch gesture.state {
        case .began:
            if let profileDelegate, profileDelegate.lastContentOffset <= -Constants.topOffset, location.y < abs(profileDelegate.lastContentOffset) {
                scrollView.isScrollEnabled = false
            }
        case .ended, .cancelled, .failed:
            scrollView.isScrollEnabled = true
        default:
            break
        }
    }
}
