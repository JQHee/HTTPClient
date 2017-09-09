//
//  ViewController.swift
//  HTTPClientDemo
//
//  Created by HJQ on 2017/9/9.
//  Copyright © 2017年 HJQ. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
       
        HTTPClient.sharedInstance.send(HomeAPI.homeBannerData, success: { (result) in
            JQLog(result)
        }) { (error) in
            JQLog(error)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
