//
//  ViewController.swift
//  Ex1_Table
//
//  Created by 임시 사용자 (DJ) on 2021/05/29.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var TableViewMain: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //데이터 개수
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //데이터 종류 (반복될 셀)
        //셀 생성 방법 2가지 (임의 셀 생성, 스토리보드 + id로 생성	)
        let cell = UITableViewCell.init(style: .default, reuseIdentifier: "TableCellType1")
        
        cell.textLabel?.text = "\(indexPath.row)"
        
        return cell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        TableViewMain.delegate = self
        TableViewMain.dataSource = self
    }

    //Tableview - 여러개의 행이 모여있는 목록 뷰
    //1. 데이터 종류
    //2. 데이터 개수
    //3. 옵션 처리
}

