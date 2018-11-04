//
//  ViewController.swift
//  SwitchableTableView
//
//  Created by Mikołaj-iMac on 04.11.2018.
//  Copyright © 2018 Mikołaj Płachta. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    // preapre data sources
    let dataSourcePartOne: [String] = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p"]
    let dataSourcePartTwo: [String] = ["k","c","z","a","o","p","l","m","i","k","j","r","f","s","y","b","u"]
    var dataSourceArray: [String] = []
    
    let cellReuseIdentifier = "ReusableCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.dataSource = self
        
        // preapre first use
        dataSourceArray.append(contentsOf: dataSourcePartOne)
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func switchDataSource() {
        if dataSourceArray.elementsEqual(dataSourcePartOne) {
            dataSourceArray.removeAll()
            dataSourceArray.append(contentsOf: dataSourcePartTwo)
        } else {
            dataSourceArray.removeAll()
            dataSourceArray.append(contentsOf: dataSourcePartOne)
        }
        tableView.reloadData()
    }
}

// MARK - Table View delegaate
extension ViewController {
    // number of rows in table view
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSourceArray.count
    }
    
    // create a cell for each table view row
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        cell.textLabel?.text = dataSourceArray[indexPath.row]
        
        return cell
    }
}
