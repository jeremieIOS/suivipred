//
//  RapportLineTableViewCell.swift
//  SuiviPred
//
//  Created by Jeremie Chaine on 14/04/2017.
//  Copyright © 2017 Jeremie Chaine. All rights reserved.
//

import UIKit

class RapportLineTableViewCell: UITableViewCell {

    @IBOutlet var dateLabel: UILabel!
    

    @IBOutlet var durationValueTableLabel: UILabel!
    @IBOutlet var publicationValueTableLabel: UILabel!
    @IBOutlet var videoValueTableLabel: UILabel!
    @IBOutlet var visiteValueTableLabel: UILabel!
    @IBOutlet var coursbValueTableLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
