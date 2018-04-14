//
//  SettingsTableViewCell.swift
//  Play That Note
//
//  Created by Paul Crompton on 4/13/18.
//  Copyright © 2018 Paul Crompton. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {

    @IBOutlet weak var titleTextLabel: UILabel!
    
    @IBOutlet weak var subtitleTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
