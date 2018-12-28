//
//  DataDisplayController.swift
//  DataAnalysis
//
//  Created by Peer Mohamed Thabib on 12/26/18.
//  Copyright © 2018 Peer Mohamed Thabib. All rights reserved.
//

import UIKit

private let CELL_HEIGHT: CGFloat = 75
private let HEADER_HEIGHT: CGFloat = 50
private let HEADER_ROW = 0

private let THEME_COLOR = UIColor.init(red: 215.0/255.0, green: 63/255.0, blue: 68/255.0, alpha: 1.0)
private let BORDER_COLOR = UIColor.init(white: 223.0/255.0, alpha: 1.0)

class DataCell: UITableViewCell {
  
    @IBOutlet var placeholderView: UIView?
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var volumeConsumptionLabel: UILabel!
    @IBOutlet weak var infoIconButton: UIButton!
    @IBOutlet weak var infoIconTapHandler: UIButton!
    
    // MARK: Init Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        placeholderView?.layer.borderColor = BORDER_COLOR.cgColor
    }
}

class DataDisplayController: UIViewController {

    @IBOutlet weak var mobileDataTableView: UITableView!
    var mobileDataViewModel: MobileDataViewModel = MobileDataViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        navigationController?.navigationBar.barTintColor = THEME_COLOR
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        mobileDataViewModel.loadMobileConsumptionData()
        mobileDataViewModel.updateHandler = { [unowned self] in
            self.mobileDataTableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.title = "Data Analytics"
        
        self.navigationController?.navigationBar.alpha = 0
        UIView.animate(withDuration: 1.5) {
            self.navigationController?.navigationBar.alpha = 1
        }
    }
}

extension DataDisplayController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var count = mobileDataViewModel.numberOfRowsToBeDisplayed()
        
        if count != 0 {
            count = count + 1
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var dataCell: DataCell? = nil
        
        if indexPath.row == HEADER_ROW {
            dataCell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell", for: indexPath) as? DataCell
            dataCell!.yearLabel.text = "YEAR"
            dataCell!.volumeConsumptionLabel.text = "Total volume consumed in petabytes"
            
            dataCell!.yearLabel.textColor = THEME_COLOR
            dataCell?.volumeConsumptionLabel.textColor = THEME_COLOR
            
            return dataCell!
        }
        
        dataCell = tableView.dequeueReusableCell(withIdentifier: "DataCell", for: indexPath) as? DataCell
        
        let index = IndexPath.init(row: indexPath.row - 1, section: 0)
        let mobileData: MobileDataObject = mobileDataViewModel.dataAtIndexPath(index)
        dataCell!.yearLabel.text = mobileData.year
        dataCell!.volumeConsumptionLabel.text = mobileDataViewModel.getVolumeDisplayString(mobileData.totalVolumeConsumed)
        
        let flag = !mobileData.isVolumeDecreasedYear
        dataCell!.infoIconButton.isHidden = flag
        dataCell!.infoIconTapHandler.isHidden = flag
        dataCell!.selectionStyle = .none
        
        return dataCell!
    }
}


extension DataDisplayController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == HEADER_ROW {
            return HEADER_HEIGHT
        }
        
        return CELL_HEIGHT
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row != HEADER_ROW {
            let rotationTransform = CATransform3DTranslate(CATransform3DIdentity, -500, 10, 0)
            cell.layer.transform = rotationTransform
            
            UIView.animate(withDuration: 0.5) {
                cell.layer.transform = CATransform3DIdentity
            }
        }
    }
}

