//
//  CategoryViewController.swift
//  taskapp
//
//  Created by Toshi Fujita on 2018/04/16.
//  Copyright © 2018年 toshibo. All rights reserved.
//

import UIKit
import RealmSwift
import SVProgressHUD

class CategoryViewController: UIViewController {

    var category:Category!
    let realm = try! Realm()
    @IBOutlet weak var categoryTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func categoryAddButton(_ sender: Any) {
    //空文字もしくはすでに登録されているカテゴリ名の場合、アラートを出し登録しない
    //登録されていない場合は登録し、登録した旨を通知
        if categoryTextField.text == "" {
            SVProgressHUD.showError(withStatus: "カテゴリ名が入力されていません。")
            print("DEBUG: カテゴリ名が空入力")
        } else if realm.objects(Category.self).filter("name == %@", categoryTextField.text).count > 0 {
            SVProgressHUD.showError(withStatus: "そのカテゴリ名はすでに入力されています。")
        } else {
            try! realm.write {
                print("DEBUG: \(categoryTextField.text!)")
                self.category.name = categoryTextField.text!
                self.realm.add(self.category, update: true)
                
                SVProgressHUD.showSuccess(withStatus: "カテゴリ名を入力しました。")
            }
        }
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
