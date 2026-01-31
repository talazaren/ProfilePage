//
//  ProfileRepresentable.swift
//  ProfilePage
//
//  Created by Tatiana Lazarenko on 22.01.2026.
//

import UIKit
import SwiftUI


struct ProfileViewRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        let vc = ProfileViewController()

        vc.viewControllers = [
            GridViewController(color: .systemRed, numberOfItems: 30),
            GridViewController(color: .systemBlue, numberOfItems: 8),
            GridViewController(color: .systemCyan, numberOfItems: 40)
        ]
        
        let navController = UINavigationController(rootViewController: vc)
        return navController
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        
    }
}
