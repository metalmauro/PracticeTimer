
//
//  PresetsTableViewController.swift
//  PracticeTimer
//
//  Created by Matthew Mauro on 2017-03-02.
//  Copyright © 2017 Matthew Mauro. All rights reserved.
//

import UIKit
import RealmSwift

protocol TimerControl {
    func setPreset(_ preset:Preset)
}

class PresetsTableViewController: ViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var editButton: UIBarButtonItem!
    var presets = Array<Preset>()
    var sounds:Array<String>?
    @IBOutlet weak var barButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    var timerController:TimerControl?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.contentInset.top = 20
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let fetched = realm.objects(Preset.self)
        for object in fetched {
            self.presets.append(object)
        }
    }
    
// MARK: - TableView data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard self.presets.count > 0 else {
            let defaultPreset = Preset()
            defaultPreset.startingSound = "Bell 14"
            defaultPreset.endingSound = "Bell 14"
            defaultPreset.tapEnabled = true
            defaultPreset.tapSound = "singingbowl 57"
            defaultPreset.warmupTime = 60.0
            defaultPreset.timeLength = 60*20
            try! realm.write {
                realm.add(defaultPreset)
            }
            self.presets.append(defaultPreset)
            return self.presets.count
        }
        return (self.presets.count)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        cell.configureSelf((self.presets[indexPath.row]))
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath) as! TableViewCell
        self.timerController?.setPreset(cell.preset!)
    }
    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let cell = tableView.cellForRow(at: indexPath) as! TableViewCell
            let prst = cell.preset!
            try! realm.write {
                presets.remove(at: indexPath.row)
                realm.delete(prst)
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
        self.tableView.reloadData()
    }
    
    // Override to support rearranging the table view.
    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    @IBAction func editFunc(_ sender: Any) {
        guard self.tableView.isEditing == false else {
            self.tableView.setEditing(false, animated: true)
            return
        }
        self.tableView.setEditing(true, animated: true)
    }
    // Override to support conditional rearranging of the table view.
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    @IBAction func unwindToPresets(segue: UIStoryboardSegue) {
        self.tableView.reloadData()
    }
}
