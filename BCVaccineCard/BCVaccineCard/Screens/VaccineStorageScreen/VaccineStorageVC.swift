//
//  VaccineStorageVC.swift
//  ClientVaxPass-POC
//
//  Created by Connor Ogilvie on 2021-09-09.
//

import UIKit

class VaccineStorageVC: UIViewController {
    
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var roundedContainerView: UIView!
    @IBOutlet weak var passportCollectionView: UICollectionView!
    @IBOutlet weak var clearPassportsButton: UIButton!
    
    var dataSource: [VaccinePassportModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
//        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setup()
    }
    
    private func setup() {
        uiSetup()
        collectionViewSetup()
        loadData()
        passportCollectionView.reloadData()
    }
    
    private func uiSetup() {
        roundedContainerView.layer.cornerRadius = 5
        roundedContainerView.layer.masksToBounds = true
    }
    
    private func loadData() {
        dataSource = Defaults.vaccinePassports ?? []
    }
    
    private func collectionViewSetup() {
        passportCollectionView.register(UINib.init(nibName: "PassportCollectionCell", bundle: .main), forCellWithReuseIdentifier: "PassportCollectionCell")
        passportCollectionView.delegate = self
        passportCollectionView.dataSource = self
        passportCollectionView.backgroundColor = AppColours.backgroundGrey
    }
    
    @IBAction func clearPassportsButtonTapped(_ sender: UIButton) {
        Defaults.vaccinePassports = []
        self.dataSource = []
        passportCollectionView.reloadData()
    }

}

// MARK: Collection View Delegate and Data Source
extension VaccineStorageVC: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PassportCollectionCell", for: indexPath) as? PassportCollectionCell {
            cell.configure(model: dataSource[indexPath.row])
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 0.4106
        // 0.2455
        let width = collectionView.frame.width * 0.475
        let height = width * (233/170)
        print("CONNOR: ", width, height, self.view.frame, collectionView.frame)
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = dataSource[indexPath.row]
        let vc = VaccinePassportVC.constructVaccinePassportVC(withModel: model, delegateOwner: nil)
        self.present(vc, animated: true, completion: nil)
    }
    
}
