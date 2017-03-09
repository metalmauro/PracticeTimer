//
//  ViewController.swift
//  PracticeTimer
//
//  Created by Matthew Mauro on 2017-03-02.
//  Copyright © 2017 Matthew Mauro. All rights reserved.
//

import UIKit
import AVFoundation
import MMDrawerController
import RealmSwift

enum TimerStage {
    case WarmUp
    case MainSession
}
protocol statsControl {
    func recentlyCompleted(_ completed:completedSession)
}

class ViewController: UIViewController, UIGestureRecognizerDelegate, TimerControl {

    @IBOutlet var bellTap: UITapGestureRecognizer!
    @IBOutlet weak var warmUpLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var finishEarlyButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    var timer:Timer?
    var warmUpCount:Double?
    var count:Double?
    var selectedPreset:Preset?
    var bellTower: AVAudioPlayer?
    var isPaused = true
    let realm = try! Realm()
    var stats:statsControl?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard self.startButton != nil else {
            // small hack to make sure the view controllers have all been loaded
            // from this point we can assume that the presetsMenu has loaded enough to set its delegate
            
            return
        }
        self.isPaused = true
        self.bellTap = UITapGestureRecognizer(target: self, action: #selector(ViewController.tapGesture(sender:)))
        self.bellTap.delegate = self
        self.view.addGestureRecognizer(bellTap)
        
        // if Preset is nil, made it either a default, or a message saying to make one
        // we need a label for the countdown, a button to finish early (which will remain hidden), and our tap gesture recognizer
        guard self.selectedPreset != nil else {
            // preset is nil, make label blank, do not let the user hit the start button, nor the finish early button
            self.startButton.isHidden = true
            self.startButton.isUserInteractionEnabled = false
            self.finishEarlyButton.isHidden = true
            self.finishEarlyButton.isUserInteractionEnabled = false
            return
        }
        // Preset is not nil
        self.startButton.isHidden = false
        self.startButton.isUserInteractionEnabled = true
       
    }
    //MARK: - Set Preset
    func setPreset(_ preset:Preset) {
        self.selectedPreset = preset
        let minutes = self.timeString(time: preset.timeLength)
        if preset.title == ""{
            self.timerLabel.text = String(format: "%@min Default Session", minutes)
        } else {
            self.timerLabel.text = String(format: "%@ with %@mins",preset.title, minutes)
        }
        self.resetCounts()
        self.isPaused = true
        self.timerLabel.sizeToFit()
        self.startButton.isHidden = false
        self.startButton.isUserInteractionEnabled = true
        self.reloadInputViews()
    }
    
    //MARK: - Update (Timer functions)
    func update(){
        guard self.isPaused == false else {
            // is paused, don't do anything
            return
        }
        guard self.warmUpCount! <= 0.0 else {
            // there is time on our warm up counter
            self.warmUpLabel.isHidden = false
            self.warmUpCount! -= 0.1
            self.timerLabel.text = String(format: "%@", self.timeString(time: self.warmUpCount!))
            return
        }
        // warmup counter is at 0. 
        //If the main session is starting, ring our starting bell tone 3 times
        guard self.count != 0 else {
            //main counter is at 0, sound the ending bell
            self.playSound(3, (self.selectedPreset?.endingSound)!)
            self.timer?.invalidate()
            return
        }
        self.warmUpLabel.isHidden = true
        if self.count == self.selectedPreset?.timeLength {
            self.playSound(3, (self.selectedPreset?.startingSound)!)
        }
        self.count! -= 0.1
        self.timerLabel.text = self.timeString(time: TimeInterval(self.count!))
    }
    
    @IBAction func startAction(_ sender: Any) {
        if self.timer != nil {
            self.startButton.setTitle("Start", for: UIControlState.normal)
            timer?.invalidate()
            timer = nil
            self.isPaused = true
            self.finishEarlyButton.isHidden = true
            self.finishEarlyButton.isUserInteractionEnabled = false
        } else {
            self.startButton.setTitle("Pause", for: UIControlState.normal)
            self.timer = Timer.scheduledTimer(timeInterval: 0.1,
                               target: self,
                               selector: #selector(ViewController.update),
                               userInfo: nil,
                               repeats: true)
            self.isPaused = false
            self.finishEarlyButton.isHidden = false
            self.finishEarlyButton.isUserInteractionEnabled = true
        }
    }
    @IBAction func finishButton(_ sender: Any) {
        guard self.warmUpCount == 0 else {
            self.setPreset(selectedPreset!)
            return
        }
        let elapsedTime = (self.selectedPreset?.timeLength)! - self.count!
        let finished = completedSession()
        finished.date = Date() as NSDate
        finished.elapsedTime = elapsedTime
        try! realm.write {
            realm.add(finished)
        }
    }
    
    func tapGesture(sender: UITapGestureRecognizer? = nil) {
        guard self.selectedPreset?.tapEnabled == true else {
            return
        }
        guard self.isPaused == false else {
            return
        }
        self.playSound(1, (self.selectedPreset?.tapSound)!)
    }
    func resetCounts() {
        guard self.selectedPreset != nil else {
            return
        }
        self.count = self.selectedPreset?.timeLength
        self.warmUpCount = self.selectedPreset?.warmupTime
        self.isPaused = true
        self.warmUpLabel.isHidden = true
        self.timerLabel.text = self.timeString(time: self.count!)
        self.finishEarlyButton.isUserInteractionEnabled = false
        self.finishEarlyButton.isHidden = true
        self.reloadInputViews()
    }
    //MARK: - Play SoundFile
    // takes in String for soundFile, and plays file the number of times inputted
    func playSound(_ times:Int,_ file:String){
        guard let tone = NSDataAsset(name: file) else {
            print("asset not found")
            return
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            bellTower = try AVAudioPlayer(data: tone.data, fileTypeHint: AVFileTypeWAVE)
            bellTower?.numberOfLoops = times
            bellTower!.play()
            print("bell tolled")
        } catch {
            print("couldn't play sound")
        }
    }
    func timeString(time:TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = time - Double(minutes) * 60
        return String(format:"%02i:%02i",minutes,Int(seconds))
    }
}

