//
//  AddViewController.swift
//  PracticeTimer
//
//  Created by Matthew Mauro on 2017-03-03.
//  Copyright © 2017 Matthew Mauro. All rights reserved.
//

import UIKit
import RealmSwift

class AddViewController: UITableViewController {

    var startEndBell:String?
    var tapBell:String?
    var presetTitle:String?
    var presetTimeLength:Int?
    var warmUpTime:Int?
    @IBOutlet weak var tapEnabled: UISwitch!
    
    @IBOutlet weak var startEndLabel: UILabel!
    @IBOutlet weak var tapLabel: UILabel!
    @IBOutlet weak var presetName: UITextField!
    
    @IBOutlet weak var timeLengthPicker: UIDatePicker!
    @IBOutlet weak var warmUpPicker: UIDatePicker!
    
    var sendingPreset:Preset?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.contentInset.top = 20
        
        guard self.timeLengthPicker != nil else {
            return
        }
        var dateC = DateComponents(calendar: Calendar.current)
        dateC.second = 0
        dateC.hour = 0
        dateC.minute = 5
        let date = Calendar.current.date(from: dateC)
        self.timeLengthPicker.setDate(date!, animated: false)
        self.warmUpPicker.setDate(date!, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {
        
    }
    
    func configureBellTitles(){
        if self.startEndBell != nil {
            self.startEndLabel.text = self.startEndBell
        } else {
            self.startEndLabel.text = "No Bell Selected"
        }
        if self.tapBell != nil {
            self.tapLabel.text = self.tapBell
        } else {
            self.tapLabel.text = "No Bell Selected"
        }
        self.startEndLabel.sizeToFit()
        self.tapLabel.sizeToFit()
    }
    
    @IBAction func finishPreset(_ sender: Any) {
        guard self.startEndBell != "", self.presetTitle != "" else {
            // make alert to say you have to have bellSound Strings
            // as well as a Preset Name
            let alert = UIAlertController(title: "Incomplete",
                                          message: "Presets must have a title, as well as start/end bells \n or would you like to cancel?",
                                          preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction = UIAlertAction(title: "Cancel Preset",
                                             style: UIAlertActionStyle.destructive,
                                             handler: { (result:UIAlertAction) in
                                                print("Cancelled")
                                                self.cancelHit(self)
            })
            let okAction = UIAlertAction(title: "OK",
                                         style: UIAlertActionStyle.default,
                                         handler: { (results:UIAlertAction) in
                                            print("OK")
            })
            alert.addAction(cancelAction)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        let new = Preset()
        new.title = self.presetName.text!
        new.startingSound = self.startEndBell!
        new.endingSound = self.startEndBell!
        new.tapEnabled = self.tapEnabled.isOn
        new.tapSound = self.tapBell
        new.timeLength = round(self.timeLengthPicker.countDownDuration)
        new.warmupTime = round(self.warmUpPicker.countDownDuration)
        let realm = try! Realm()
        try! realm.write {
            realm.add(new)
        }
        self.sendingPreset = new
        self.performSegue(withIdentifier: "presetMade", sender: self)
    }
    
    @IBOutlet weak var cancel: UIButton!
    @IBAction func cancelHit(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier?.isEqual("startEnd"))! {
            let destination = segue.destination as! BellSelectViewController
            destination.typeSelect = BellType.StartEnd
        } else if (segue.identifier?.isEqual("tapGest"))! {
            let destination = segue.destination as! BellSelectViewController
            destination.typeSelect = BellType.Tap
        } else if (segue.identifier?.isEqual("presetMade"))! {
            let destination = segue.destination as! PresetsTableViewController
            destination.presets.append(sendingPreset!)
            destination.tableView.reloadData()
        }
        print(segue.identifier!)
    }
}
