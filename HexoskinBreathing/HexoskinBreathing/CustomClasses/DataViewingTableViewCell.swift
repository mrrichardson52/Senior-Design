//
//  DataViewingTableViewCell.swift
//  HexoskinBreathing
//
//  Created by Matthew Richardson on 4/13/17.
//  Copyright © 2017 Matthew Richardson. All rights reserved.
//

import UIKit

class DataViewingTableViewCell: UITableViewCell {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
