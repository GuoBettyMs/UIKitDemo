//
//  CustomLoginTableViewController.swift
//  SwiftTest
//
//  Created by user on 2025/1/15.
//

import UIKit

class CustomLoginTableViewController: UITableViewController {
    
    private var userName:String = ""
    
    // MARK: - IBOutlet
    @IBOutlet weak var countryCodeTextField: UITextField!
    
    @IBOutlet weak var accountTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    
    @IBOutlet weak var registerButton: UIButton!
    

    /// 按钮事件相当于一次 segue 的跳转
    @IBAction func loginTapped(_ sender: UIButton) {
        print("loginButton")
    }
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 { //未被 loginButton 覆盖的 tableViewcell 区域
//            loginButton.sendActions(for: .touchUpInside) //执行按钮点击事件
            userName = "UserPage"
            self.performSegue(withIdentifier: "UserPage", sender: userName) //将 userName 作为 sender 参数传递给 prepare(for:sender:) 方法,最后启动指定标识符的 segue
        }
    }
    
    // MARK: - Navigation
    // 根据指定标识符 identifier 的 segue 跳转到指定视图控制器 destinationVC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier{
        case "UserPage":
            guard let name = sender as? String else { return }
            print("namenamename: \(name)")
            break
        case "Reset":
            let destinationVC = segue.destination as! ResetPasswordTableViewController
            destinationVC.accountText = accountTextField.text ?? ""
        case "Register":
            _ = segue.destination as! RegisterTableViewController
        case .none:
            break
        case .some(_):
            break
        }
    }
    

}
