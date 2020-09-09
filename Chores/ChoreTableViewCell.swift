//
//  ChoreTableViewCell.swift
//  Chores
//
//  Created by Lauren Marie Naylor on 8/29/20.
//  Copyright © 2020 Lauren Marie Naylor. All rights reserved.
//

import UIKit

class ChoreTableViewCell: UITableViewCell {

    //MARK: Properties
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    
    var chore : Chore?
    
    weak var delegate : ChoreTableViewCellDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.doneButton.addTarget(self, action: #selector(doneButtonTapped(_:)), for: .touchUpInside)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        if let chore = chore,
            let delegate = delegate {
            self.delegate?.choreDoneButtonCell(self, chore: chore)
        }
    }

}

protocol ChoreTableViewCellDelegate: AnyObject {
    func choreDoneButtonCell(_ choreTableViewCell: ChoreTableViewCell, chore: Chore)
}
