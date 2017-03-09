//
//  StatsViewController.swift
//  PracticeTimer
//
//  Created by Matthew Mauro on 2017-03-08.
//  Copyright © 2017 Matthew Mauro. All rights reserved.
//

import UIKit
import Charts
import RealmSwift

class StatsViewController: UITableViewController, statsControl {

    var completedSessions:Array<completedSession>?
    let realm = try! Realm()
    @IBOutlet weak var statsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.statsTable.delegate = self
        self.statsTable.dataSource = self
        // get completed Sessions, if any
        let sessions = realm.objects(completedSession.self)
        guard sessions.count > 0 else {
            self.completedSessions = Array<completedSession>()
            return
        }
        for objects in sessions {
            self.completedSessions?.append(objects)
        }
    }
    func recentlyCompleted(_ completed: completedSession) {
        self.completedSessions?.append(completed)
        // relaod Chart Data
        
    }
//    //MARK: - cell for row
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        
//    }
}
