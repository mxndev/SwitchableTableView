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
    var dataSourcePartOne: [String] = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p"]
    var dataSourcePartTwo: [String] = ["k","c","z","a","o","p","l","m","i","k","j","r","f","s","y","b", "u"]
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
        tableView.beginUpdates()
        
        let switchOneToTwo = dataSourceArray.elementsEqual(dataSourcePartOne)
        // "remove" old strings
        let rowsToDelete = self.calculateRowsToDelete(setToReplace: switchOneToTwo ? self.dataSourcePartOne : self.dataSourcePartTwo, setToAdd: switchOneToTwo ? self.dataSourcePartTwo : self.dataSourcePartOne)
        tableView.reloadRows(at: rowsToDelete.map({ IndexPath(row: $0, section: 0) }), with: .top)

        // "move" existing strings
        let rowsToMove = self.calculateRowsToMove(setOne: switchOneToTwo ? self.dataSourcePartOne : self.dataSourcePartTwo, setTwo: switchOneToTwo ? self.dataSourcePartTwo : self.dataSourcePartOne)
        tableView.reloadRows(at: rowsToMove.map({ IndexPath(row: $0, section: 0) }), with: .right)

        // "add" new strings
        let rowsToInsert = self.calculateRowsToInsert(setToReplace: switchOneToTwo ? self.dataSourcePartOne : self.dataSourcePartTwo, setToAdd: switchOneToTwo ? self.dataSourcePartTwo : self.dataSourcePartOne)
        tableView.reloadRows(at: rowsToInsert.map({ IndexPath(row: $0, section: 0) }), with: .bottom)

        // calculate differences in arrays
        let calculatedDifference = (switchOneToTwo ? self.dataSourcePartTwo : self.dataSourcePartOne).count - (!switchOneToTwo ? self.dataSourcePartTwo : self.dataSourcePartOne).count
        let smallerValue = (self.dataSourcePartOne.count - self.dataSourcePartTwo.count > 0) ? self.dataSourcePartTwo.count : self.dataSourcePartOne.count
        if calculatedDifference > 0 {
            for i in 0..<calculatedDifference {
                tableView.insertRows(at: [IndexPath(row: smallerValue + i, section: 0)], with: .bottom)
            }
        } else {
            for i in 0..<(calculatedDifference*(-1)) {
                tableView.deleteRows(at: [IndexPath(row: smallerValue + i, section: 0)], with: .top)
            }
        }
        
        dataSourceArray.removeAll()
        dataSourceArray.append(contentsOf: switchOneToTwo ? self.dataSourcePartTwo : self.dataSourcePartOne)
        tableView.endUpdates()
    }
    
    @IBAction func generateNewDatasource() {
        dataSourcePartOne.removeAll()
        let initialDataSource: [String] = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","r","s","t","u","w","x","y","z"]
        // prepare first set
        while dataSourcePartOne.count < 17 {
            let value = arc4random_uniform(23)
            if !dataSourcePartOne.contains(initialDataSource[Int(value)]) {
                dataSourcePartOne.append(initialDataSource[Int(value)])
            }
        }
        // prepare initial overlap data for second set (67%)
        var secondDataSource: [String] = []
        while secondDataSource.count < 12 {
            let value = arc4random_uniform(17)
            if !secondDataSource.contains(dataSourcePartOne[Int(value)]) {
                secondDataSource.append(dataSourcePartOne[Int(value)])
            }
        }
        // prepare second set
        dataSourcePartTwo.removeAll()
        while dataSourcePartTwo.count < 18 {
            if arc4random_uniform(2) == 1 {
                let value = arc4random_uniform(12)
                if !dataSourcePartTwo.contains(secondDataSource[Int(value)]) {
                    dataSourcePartTwo.append(secondDataSource[Int(value)])
                }
            } else {
                let value = arc4random_uniform(23)
                if !dataSourcePartTwo.contains(initialDataSource[Int(value)]) {
                    dataSourcePartTwo.append(initialDataSource[Int(value)])
                }
            }
        }
        dataSourceArray.removeAll()
        dataSourceArray.append(contentsOf: dataSourcePartOne)
        tableView.reloadData()
    }
}

// MARK - Table View delegaate
extension ViewController {
    // number of rows in table view
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(dataSourceArray.count)
        return dataSourceArray.count
    }
    
    // create a cell for each table view row
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        cell.textLabel?.text = dataSourceArray[indexPath.row]
        
        return cell
    }
}

extension ViewController {
    fileprivate func calculateRowsToDelete(setToReplace: [String], setToAdd: [String]) -> [Int] {
        // here calculate position from first set, because there are is removed from first one
        var rows: [Int] = []
        for (index, element) in setToReplace.enumerated() {
            if setToAdd.filter({ $0 == element }).count == 0 {
                if ((setToAdd.count - setToReplace.count < 0) && (index < setToAdd.count)) || ((setToAdd.count - setToReplace.count >= 0) && (index < setToReplace.count)) {
                    rows.append(index)
                }
            }
        }
        return rows
    }
    
    fileprivate func calculateRowsToMove(setOne: [String], setTwo: [String]) -> [Int] {
        // there is two options, from which set positions should be animated cells(I choose second, because it will replace everything)
        var rows: [Int] = []
        for (index, element) in setTwo.enumerated() {
            if setOne.filter({ $0 == element }).count == 1 {
                // move only when indexes is differents
                if (((setOne.count > index) && (setOne[index] != setTwo[index])) || (setOne.count < index)) {
                    if ((setTwo.count - setOne.count < 0) && (index < setOne.count)) || ((setTwo.count - setOne.count >= 0) && (index < setTwo.count)) {
                        rows.append(index)
                    }
                }
            }
        }
        return rows
    }
    
    fileprivate func calculateRowsToInsert(setToReplace: [String], setToAdd: [String]) -> [Int] {
        // here calculate position from second set, because there are is added from second one
        var rows: [Int] = []
        for (index, element) in setToAdd.enumerated() {
            if setToReplace.filter({ $0 == element }).count == 0 {
                if ((setToAdd.count - setToReplace.count < 0) && (index < setToAdd.count)) || ((setToAdd.count - setToReplace.count >= 0) && (index < setToReplace.count)) {
                    rows.append(index)
                }
            }
        }
        return rows
    }
}
