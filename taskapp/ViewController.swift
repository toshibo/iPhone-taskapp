//
//  ViewController.swift
//  taskapp
//
//  Created by Toshi Fujita on 2018/03/15.
//  Copyright © 2018年 toshibo. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBAction func catchEditingChangedEvent(_ sender: Any) {
        categoryTextField.text = "かわったお"
    }
    
    
    private var filteredTasks: Results<Task>!
    private var pickerView = UIPickerView()
    
    //Realmインスタンスを取得する
    var realm = try! Realm()
    var categoryList = try! Realm().objects(Category.self)

    //DB内のタスクが格納されるリスト
    //日付近い順でソート：降順
    //以降内容をアップデートするとリスト内は自動的に更新される
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false) //追加
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
        
        setup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //入力画面から戻ってきたときにTableViewを更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: UITableViewDataSourceプロトコルのメソッド
    // データの数(=セルの数)を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        if !categoryTextField.text!.isEmpty {
            return filteredTasks.count
        } else {
            return taskArray.count
        }
    }
    
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能なCellを得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        //Cellに値を設定する
        let task = !categoryTextField.text!.isEmpty ? filteredTasks[indexPath.row] : taskArray[indexPath.row]
        if task.category?.name != "" {
            cell.textLabel?.text = "[\(task.category!.name)\(task.category!.id)]\(task.title)"
        } else {
            cell.textLabel?.text = "[カテゴリ未分類]\(task.title)"
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        
        return cell
    }
    
    //MARK: UITableViewDelegateプロトコルのメソッド
    //各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        performSegue(withIdentifier: "cellSegue", sender: nil) //追加する
    }
    
    // セル削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }

    // Deleteボタンが押されたときに呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //削除されたタスクを取得する
            let task = !categoryTextField.text!.isEmpty ? filteredTasks[indexPath.row] : taskArray[indexPath.row]
            
            //ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            //データベースから削除する
            try! realm.write {
                self.realm.delete(task)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            //未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
        }
        
    }
    
    // segueで画面遷移する際に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let inputViewController:InputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = !categoryTextField.text!.isEmpty ? filteredTasks[indexPath!.row] : taskArray[indexPath!.row]
            print("DEBG: \(inputViewController.task.category)")
        } else {
            let task = Task()
            task.date = Date()
            
            let taskArray = realm.objects(Task.self)
            if taskArray.count != 0 {
                task.id = taskArray.max(ofProperty: "id")! + 1
            }
            
            inputViewController.task = task
        }
    }
    
    @objc func done() {
        categoryTextField.endEditing(true)
    }
    
    @objc func cancel() {
        categoryTextField.text = ""
        categoryTextField.endEditing(true)
        tableView.reloadData()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        print("DEBUG:\(categoryList[row])")
        return categoryList[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categoryTextField.text = categoryList[row].name
        
        if categoryTextField.text!.isEmpty { //サーチバーが空文字の場合、
            filteredTasks = taskArray
        } else {
            filteredTasks = taskArray.filter("category.name contains %@", categoryTextField.text)
        }
        tableView.reloadData()
    }
    
    func setup() {
        pickerView.delegate = self
        pickerView.dataSource = self
        
        let toolbar = UIToolbar(frame: CGRect(x:0, y:0, width:0, height:35))
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.done))
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancel))
        toolbar.setItems([cancelItem, doneItem], animated: true)
        
        categoryTextField.frame.size.width = 10000
        categoryTextField.inputView = pickerView
        categoryTextField.inputAccessoryView = toolbar
        
        tableView.delegate = self
        tableView.dataSource = self
    }
}
