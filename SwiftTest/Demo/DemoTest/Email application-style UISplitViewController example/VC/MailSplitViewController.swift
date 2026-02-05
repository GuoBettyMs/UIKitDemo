//
//  MailSplitViewController.swift
//  SwiftTest
//
//  Created by user on 2026/2/5.
// 分割视图控制器

import UIKit

class MailSplitViewController: UISplitViewController, PrimaryViewControllerDelegate {
    
    private var detailVC: DetailViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSplitView()
        setupViewControllers()
//        delegate = self
    }
    
    private func setupSplitView() {
        preferredDisplayMode = .oneBesideSecondary
        preferredPrimaryColumnWidthFraction = 0.35
        minimumPrimaryColumnWidth = 300
        maximumPrimaryColumnWidth = 400
        
        #if targetEnvironment(macCatalyst)
        style = .doubleColumn
        primaryBackgroundStyle = .sidebar
        minimumPrimaryColumnWidth = 280
        maximumPrimaryColumnWidth = 360
        #endif
    }
    
    private func setupViewControllers() {
        let primaryVC = PrimaryViewController()
        primaryVC.delegate = self
        
        detailVC = DetailViewController()
        
        let primaryNav = UINavigationController(rootViewController: primaryVC)
        let detailNav = UINavigationController(rootViewController: detailVC)
        
        #if targetEnvironment(macCatalyst)
        setViewController(primaryNav, for: .primary)
        setViewController(detailNav, for: .secondary)
        #else
        viewControllers = [primaryNav, detailNav]
        #endif
        
        // 初始选中第一项（仅非手机）
        if UIDevice.current.userInterfaceIdiom != .phone {
            primaryVC.selectFirstRowIfNeeded()
        }
    }
    
    // MARK: - PrimaryViewControllerDelegate
    func didSelect(mailItem: MailItem) {
        detailVC.mailItem = mailItem
    }
}
