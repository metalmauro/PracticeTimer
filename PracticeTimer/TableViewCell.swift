//
//  TableViewCell.swift
//  PracticeTimer
//
//  Created by Matthew Mauro on 2017-03-02.
//  Copyright © 2017 Matthew Mauro. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    var preset:Preset?
    var title:String?
    var detail:String?
    var pic:UIImage?
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var detLabel: UILabel!
    @IBOutlet weak var picView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    func configureSelf(_ preset:Preset) {
        self.preset = preset
        self.title = preset.title
        let mainSess = timeString(time: preset.timeLength)
        let warmup = timeString(time: preset.warmupTime)
        self.detail = String(format: "%@min with %@min warmup", mainSess, warmup)
        self.topLabel?.text = self.title
        self.detLabel?.text = self.detail
        self.picView?.image = self.pic
        self.topLabel.sizeToFit()
        self.detLabel.sizeToFit()
    }
    func timeString(time:TimeInterval) -> String {
        let minutes = Int(time) / 60
        return String(format:"%02i",minutes)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        self.selectionStyle = UITableViewCellSelectionStyle.blue
        if selected == true {
            self.topLabel.textColor = UIColor.blue
            self.detLabel.textColor = UIColor.blue
        } else {
            self.topLabel.textColor = UIColor.white
            self.detLabel.textColor = UIColor.white
        }
        super.setSelected(selected, animated: animated)
    }
    
}
