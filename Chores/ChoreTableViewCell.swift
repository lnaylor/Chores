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
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var pushButton: UIButton!
    @IBOutlet weak var historyButton: UIButton!
    
    
    var chore : Chore?
    
    weak var delegate : ChoreTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.doneButton.addTarget(self, action: #selector(doneButtonTapped(_:)), for: .touchUpInside)
        
        self.skipButton.addTarget(self, action: #selector(skipButtonTapped(_:)), for: .touchUpInside)
        
        self.pushButton.addTarget(self, action: #selector(pushButtonTapped(_:)), for: .touchUpInside)
        
        self.historyButton.addTarget(self, action: #selector(historyButtonTapped(_:)), for: .touchUpInside)
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
    
    @IBAction func skipButtonTapped(_ sender: UIButton) {
        if let chore = chore,
            let delegate = delegate {
            self.delegate?.choreSkipButtonCell(self, chore: chore)
        }
    }
    
    @IBAction func pushButtonTapped(_ sender: UIButton) {
        if let chore = chore,
            let delegate = delegate {
            self.delegate?.chorePushButtonCell(self, chore: chore)
        }
    }
    
    @IBAction func historyButtonTapped(_ sender: UIButton) {
        if let chore = chore,
            let delegate = delegate {
            self.delegate?.choreHistoryButtonCell(self, chore: chore)
        }
    }

}

protocol ChoreTableViewCellDelegate: AnyObject {
    func choreDoneButtonCell(_ choreTableViewCell: ChoreTableViewCell, chore: Chore)
    
    func choreSkipButtonCell(_ choreTableViewCell: ChoreTableViewCell, chore: Chore)
    
    func chorePushButtonCell(_ choreTableViewCell: ChoreTableViewCell, chore: Chore)
    
    func choreHistoryButtonCell(_ choreTableViewCell: ChoreTableViewCell, chore: Chore)
}
