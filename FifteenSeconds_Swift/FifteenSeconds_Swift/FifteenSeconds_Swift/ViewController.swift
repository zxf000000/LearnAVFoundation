//
//  ViewController.swift
//  FifteenSeconds_Swift
//

//  Copyright © 2020 zxf. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        

    }

    @IBAction func tapAddItem(_ sender: Any) {
        
        let pickerVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PickerTabBarController")
        navigationController?.pushViewController(pickerVC, animated: true)
        
    }
    
}

