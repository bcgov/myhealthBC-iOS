//
//  EmptyTableViewCell.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2023-01-12.
//

import UIKit

class EmptyTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}


extension UITableView {
    func registerEmptyCell() {
        self.register(UINib.init(nibName: EmptyTableViewCell.getName, bundle: .main), forCellReuseIdentifier: EmptyTableViewCell.getName)
    }
    
    func getEmptyCell(indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.dequeueReusableCell(withIdentifier: EmptyTableViewCell.getName, for: indexPath) as? EmptyTableViewCell else {
            return UITableViewCell()
        }
        return cell
    }
}
