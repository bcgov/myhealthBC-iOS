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
