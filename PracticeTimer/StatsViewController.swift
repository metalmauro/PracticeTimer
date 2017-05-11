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
import MMDrawerController

class StatsViewController: UIViewController, statsControl, ChartViewDelegate {
    
    var completedSessions:Array<completedSession>?
    let realm = try! Realm()
    @IBOutlet weak var bubbleChart: BubbleChartView!
    weak var axisFormatDelegate: IAxisValueFormatter?
    @IBOutlet weak var testLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bubbleChart.delegate = self
        axisFormatDelegate = self
        
        
        // MMDrawerController sometimes starts a View'sDidLoad too early in the process and may
        // cause a crash because some aspects aren't loaded yet.
        // small guard hack
        guard self.bubbleChart != nil else {
            return
        }
        
        //Chart setup taken from Demo project file
        bubbleChart.chartDescription?.text = ""
        bubbleChart.pinchZoomEnabled = true
        bubbleChart.dragEnabled = true
        let cL = bubbleChart.legend
        cL.horizontalAlignment = Legend.HorizontalAlignment.left
        cL.verticalAlignment = Legend.VerticalAlignment.bottom
        cL.orientation = Legend.Orientation.horizontal
        cL.drawInside = false
        cL.font = UIFont.init(name: "HelveticaNeue-Light", size: 10.0)!
        let yL = bubbleChart.leftAxis
        yL.labelFont = UIFont.init(name: "HelveticaNeue-Light", size: 8.0)!
        yL.spaceTop = 0.3
        yL.spaceBottom = 0.3
        yL.axisMinimum = 0.0
        yL.axisMaximum = 24.0
        bubbleChart.rightAxis.enabled = false
        
        let xL = bubbleChart.xAxis
        xL.labelPosition = XAxis.LabelPosition.bottomInside
        xL.labelFont = UIFont.init(name: "HelveticaNeue-Light", size: 8.0)!
        let xVals = ["Sun",
                     "Mon",
                     "Tue",
                     "Wed",
                     "Thur",
                     "Fri",
                     "Sat"]
        xL.valueFormatter = IndexAxisValueFormatter(values: xVals)
        bubbleChart.leftAxis.valueFormatter = IndexAxisValueFormatter(values: ["00:00",
                                                                               "01:00",
                                                                               "02:00",
                                                                               "03:00",
                                                                               "04:00",
                                                                               "05:00",
                                                                               "06:00",
                                                                               "07:00",
                                                                               "08:00",
                                                                               "09:00",
                                                                               "10:00",
                                                                               "11:00",
                                                                               "12:00",
                                                                               "13:00",
                                                                               "14:00",
                                                                               "15:00",
                                                                               "16:00",
                                                                               "17:00",
                                                                               "18:00",
                                                                               "19:00",
                                                                               "20:00",
                                                                               "21:00",
                                                                               "22:00",
                                                                               "23:00"])
        bubbleChart.xAxis.axisMinimum = 0.0
        bubbleChart.xAxis.axisMaximum = 6.5
        bubbleChart.xAxis.granularity = 1
        bubbleChart.zoomToCenter(scaleX: 1.0, scaleY: 1.0)
        
        let sessions = realm.objects(completedSession.self)
        guard sessions.count > 0 else {
            self.completedSessions = Array<completedSession>()
            updateChartWithData()
            return
        }
        
        self.updateChartWithData()
    }
    func getDayOfWeek(_ date:NSDate)->Double? {
        // returns double to represent the weekday
        // 0 = Sunday, 1 = Monday... etc.
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date as Date)
        if let todayDate = formatter.date(from: dateString) {
            let myCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
            let myComponents = myCalendar.components(.weekday, from: todayDate)
            let weekDay = myComponents.weekday
            return Double(weekDay!)
        } else {
            return nil
        }
    }
    //MARK: - Charts and Delegate methods
    func recentlyCompleted(_ completed: completedSession) {
        self.completedSessions?.append(completed)
        // relaod Chart Data
        updateChartWithData()
    }
    func updateChartWithData() {
        guard (self.completedSessions?.count)! > 0 else {
            
            // add test data, and show our testLabel
            testLabel.isHidden = false
            
            //make fake sessions
            let testSess = completedSession()
            testSess.date = NSDate(timeIntervalSinceNow: 24*60*60)
            testSess.elapsedTime = 60*10
            
            let test2S = completedSession()
            test2S.date = NSDate(timeIntervalSinceNow: 72*60*60)
            test2S.elapsedTime = 60*30
            
            organizeChartData([testSess, test2S])
            return
        }
        organizeChartData(self.completedSessions!)
    }
    func organizeChartData(_ sessions: [completedSession]) {
        // we want to organize our data to make it easier for the user to track
        // organize completed sessions by amount of elapsed time
        // coloured from grey (lowest) to green (middle) and purple (highest)
        // then Return Chart Data object to feed into chart
        
        var val1 = Array<BubbleChartDataEntry>()
        var val2 = Array<BubbleChartDataEntry>()
        var val3 = Array<BubbleChartDataEntry>()
        
        for i in 0..<(sessions.count) {
            let session = sessions[i] as completedSession
            let weekday = getDayOfWeek(session.date)
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: session.date as Date)
            let minute = calendar.component(.minute, from: session.date as Date)
            let timeS = String(format: "%i.%i", hour, minute)
            let time = CGFloat(session.elapsedTime)
            let entry = BubbleChartDataEntry(x: weekday!, y: Double(timeS)!, size: time/(60*60))
            switch time {
            case _ where time < 60*10:
                val1.append(entry)
                break
            case _ where time > 60*30:
                val3.append(entry)
                break
            default:
                val2.append(entry)
                break
            }
        }
        var sets = Array<BubbleChartDataSet>()
        let lowDataSet = BubbleChartDataSet(values: val1)
        lowDataSet.label = "Less than 10min"
        lowDataSet.setColor(NSUIColor.blue, alpha: 0.25)
        lowDataSet.normalizeSizeEnabled = false
        lowDataSet.drawValuesEnabled = false
        if lowDataSet.entryCount > 0 {
            sets.append(lowDataSet)
        }
        let medDataSet = BubbleChartDataSet(values: val2)
        medDataSet.label = "11-29"
        medDataSet.setColor(NSUIColor.green, alpha: 0.25)
        medDataSet.normalizeSizeEnabled = false
        medDataSet.drawValuesEnabled = false
        if medDataSet.entryCount > 0 {
            sets.append(medDataSet)
        }
        let highDataSet = BubbleChartDataSet(values: val3)
        highDataSet.label = "Over 30min"
        highDataSet.setColor(NSUIColor.purple, alpha: 0.25)
        highDataSet.normalizeSizeEnabled = false
        highDataSet.drawValuesEnabled = false
        if highDataSet.entryCount > 0 {
            sets.append(highDataSet)
        }
        
        self.bubbleChart.data = BubbleChartData(dataSets: sets)
        self.bubbleChart.data?.setValueTextColor(NSUIColor.white)
    }
}
//MARK: - IAxisValueFormatter Extension
extension UIViewController: IAxisValueFormatter {
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm.ss"
        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
    }
}
