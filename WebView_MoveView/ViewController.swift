//
//  ViewController.swift
//  Test_dev
//
//  Created by 임시 사용자 (DJ) on 2021/05/25.
//

import UIKit
import WebKit

class ViewController: UIViewController {

    @IBOutlet weak var WebViewMain: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        //1. url string
        let urlString = "https://www.google.com"
        //2. string > url
        if let url = URL(string: urlString) { //unwrap 과정, if(체크) 또는 !(강제)를 붙여서 unwrap을 진행
            //3. url > request
            let urlReq = URLRequest(url: url)
            WebViewMain.load(urlReq)
            //4. req > load
            WebViewMain.load(urlReq)
        }
    }

    //Click Event
    @IBAction func Click_moveBtn(_ sender: Any) {
        //Storyboard Find
        //nil(null) 방지, 옵셔널 바인딩
        if let controller = self.storyboard?.instantiateViewController(identifier: "DetailController") {
            //Move Controller, add controller > navi
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}


