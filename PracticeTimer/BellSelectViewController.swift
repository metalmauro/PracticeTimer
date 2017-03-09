//
//  BellSelectViewController.swift
//  PracticeTimer
//
//  Created by Matthew Mauro on 2017-03-03.
//  Copyright © 2017 Matthew Mauro. All rights reserved.
//

import UIKit
import AVFoundation

public enum BellType:Int {
    case StartEnd = 0
    case Tap = 1
}

class BellSelectViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    let soundOptions: [String:UIImage] =
        ["Bell 05": UIImage.init(named: "bell1")!,
         "Bell 13": UIImage.init(named: "bell2")!,
         "Bell 14": UIImage.init(named: "bell3")!,
         "BrassGong 21": UIImage.init(named: "gong1")!,
         "gong 103" : UIImage.init(named: "gong2")!,
         "singingbowl 57" : UIImage.init(named: "singingbowl1")!,
         "treblebowl 21" : UIImage.init(named: "singingbowl2")!]
    var bellTower: AVAudioPlayer?
    
    var typeSelect:BellType?
    var selectedBellString:String?
    @IBOutlet weak var selectingBell: UILabel!
    @IBOutlet weak var bellInfolabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard self.typeSelect == BellType.StartEnd else {
            //is tapGesture Bell
            self.selectingBell.text = "Select a Tap Gesture Bell"
            self.selectingBell.sizeToFit()
            return
        }
        self.selectingBell.text = "Select the Timer Bell"
        self.selectingBell.sizeToFit()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
            for _ in 1...times {
                bellTower!.play()
            }
        } catch {
            print("couldn't play sound")
        }
    }
    
    //MARK: - CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bell", for: indexPath) as! BellCollectionViewCell
        let sounds:Array<String> = Array(soundOptions.keys)
        let images:Array<UIImage> = Array(soundOptions.values)
        cell.configure(sounds[indexPath.row], images[indexPath.row])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedBell = collectionView.cellForItem(at: indexPath) as! BellCollectionViewCell
        selectedBell.selectionImage.image = UIImage(named: "IMG_62D70FC69FFC-1")
        let information = selectedBell.soundString?.components(separatedBy: " ")
        let bellTitle = information?[0]
        let timeLength = information?[1]
        print(String(format: "%@ - %@seconds", bellTitle!, timeLength!))
        self.bellInfolabel.text = String(format: "%@ - %@seconds", bellTitle!, timeLength!)
        self.bellInfolabel.sizeToFit()
        self.selectedBellString = selectedBell.soundString
        // make function in this class to play soundFile associated with 'selectedBell' sound.
        self.playSound(1, selectedBell.soundString!)
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let selectedBell = collectionView.cellForItem(at: indexPath) as! BellCollectionViewCell
        selectedBell.selectionImage.image = nil
        
    }
    @IBAction func doneHit(_ sender: Any) {
        // send back Bell Sound information to Preset to be created
        self.bellTower?.stop()
        self.performSegue(withIdentifier: "bellChosen", sender: self)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let destination = segue.destination as! AddViewController
        switch (self.typeSelect?.rawValue)! {
        case 0:
            destination.startEndBell = self.selectedBellString
            destination.configureBellTitles()
            break
        case 1:
            destination.tapBell = self.selectedBellString
            destination.configureBellTitles()
            break
        default:
            break
        }
        //destination.
    }
    

}
