//
//  Constants.swift
//  ProfilePage
//
//  Created by Tatiana Lazarenko on 23.01.2026.
//

import Foundation

final class Constants {
    static let shared = Constants()
    
    private(set) var headerHeight: CGFloat = 0
    private(set) var minTopOffset: CGFloat = 0
    private(set) var maxTopOffset: CGFloat = 0
    private(set) var navBarHeight: CGFloat = 0
    
    let tabBarHeight: CGFloat = 40
    let padding: CGFloat = 10
    let columns = 3
    let spacing: CGFloat = 8
    let cellHeight: CGFloat = 160
    
    func setHeaderHeight(_ height: CGFloat) {
        headerHeight = height
    }
    func setMinTopOffset(_ offset: CGFloat) {
        minTopOffset = offset
    }
    func setMaxTopOffset(_ offset: CGFloat) {
        maxTopOffset = offset
    }
    func setNavBarHeight(_ height: CGFloat) {
        navBarHeight = height
    }
    
    private init() {}
}
