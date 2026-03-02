//
//  PrimaryViewController.swift
//  SwiftTest
//
//  Created by user on 2026/2/5.
//
// 主视图控制器,支持显示未读标识,可左滑删除表格行

import UIKit

protocol PrimaryViewControllerDelegate: AnyObject {
    func didSelect(mailItem: MailItem)
}

class PrimaryViewController: UITableViewController {
    
    weak var delegate: PrimaryViewControllerDelegate?
    
    private var mailItems: [MailItem] = [
        MailItem(id: 1, title: "欢迎使用邮件", subtitle: "这是一封欢迎邮件", date: "今天", isUnread: true),
        MailItem(id: 2, title: "系统通知", subtitle: "您的账户有新的登录", date: "昨天", isUnread: true),
        MailItem(id: 3, title: "Apple 开发者", subtitle: "WWDC 2024 即将开始", date: "5月15日", isUnread: false),
        MailItem(id: 4, title: "GitHub", subtitle: "仓库收到了新的 star", date: "5月14日", isUnread: false),
        MailItem(id: 5, title: "设计团队", subtitle: "UI设计稿已更新", date: "5月13日", isUnread: false)
    ]
    
    private let cellIdentifier = "MailCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "收件箱"
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            // Fallback on earlier versions
        }
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        
        // 下拉刷新
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc private func refreshData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.tableView.refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Public API
    func selectFirstRowIfNeeded() {
        guard !mailItems.isEmpty,
              UIDevice.current.userInterfaceIdiom != .phone else { return }
        
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: 0, section: 0)
            self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            self.tableView(self.tableView, didSelectRowAt: indexPath)
        }
    }
    
    // MARK: - UITableViewDataSource / Delegate
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mailItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let item = mailItems[indexPath.row]
        
        if #available(iOS 14.0, *) {
            var config = cell.defaultContentConfiguration()
            config.text = item.title
            config.textProperties.font = item.isUnread ? .boldSystemFont(ofSize: 16) : .systemFont(ofSize: 16)
            config.textProperties.color = item.isUnread ? .label : .secondaryLabel
            
            config.secondaryText = item.subtitle
            config.secondaryTextProperties.color = .secondaryLabel
            
            cell.contentConfiguration = config
        }
        
        // 显示未读标记
        if item.isUnread {
            let unreadView = UIView()
            unreadView.backgroundColor = .systemBlue
            unreadView.layer.cornerRadius = 4
            unreadView.translatesAutoresizingMaskIntoConstraints = false
            cell.accessoryView = unreadView
            
            NSLayoutConstraint.activate([
                unreadView.widthAnchor.constraint(equalToConstant: 8),
                unreadView.heightAnchor.constraint(equalToConstant: 8)
            ])
        } else {
            cell.accessoryView = nil
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }
    //允许左滑删除
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            mailItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = mailItems[indexPath.row]
        // 标记为已读
        if item.isUnread {
            mailItems[indexPath.row] = MailItem(
                id: item.id,
                title: item.title,
                subtitle: item.subtitle,
                date: item.date,
                isUnread: false
            )
            tableView.reloadRows(at: [indexPath], with: .none)
        }
        delegate?.didSelect(mailItem: item)
        
//        // iPhone 上显示详情按钮
//        if UIDevice.current.userInterfaceIdiom == .phone {
//            showDetailButtonIfNeeded()
//        }
    }
    
    // MARK: - Navigation Items (延迟设置以避免约束警告)
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if navigationItem.rightBarButtonItems == nil {
            setupNavigationBar()
        }
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = editButtonItem
        
        let composeButton = UIBarButtonItem(
            barButtonSystemItem: .compose,
            target: self,
            action: #selector(composeMail)
        )
        
        let searchButton = UIBarButtonItem(
            barButtonSystemItem: .search,
            target: self,
            action: #selector(searchMails)
        )
        
        navigationItem.rightBarButtonItems = [composeButton, searchButton]
    }
    
    @objc private func composeMail() { /* 实现撰写逻辑 */
        let alert = UIAlertController(
            title: "新邮件",
            message: "创建新邮件",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "创建", style: .default))
        
        present(alert, animated: true)
    }
    @objc private func searchMails() { /* 实现搜索逻辑 */
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "搜索邮件"
        present(searchController, animated: true)
    }
    private func showDetailButtonIfNeeded() {
        // 在 iPhone 上，显示返回按钮
        if splitViewController?.displayMode == .primaryHidden {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                title: "返回",
                style: .plain,
                target: self,
                action: #selector(showPrimaryViewController)
            )
        }
    }
    
    @objc private func showPrimaryViewController() {
        if #available(iOS 14.0, *) {
            splitViewController?.show(.primary)
        } else {
            // Fallback on earlier versions
        }
    }
}
