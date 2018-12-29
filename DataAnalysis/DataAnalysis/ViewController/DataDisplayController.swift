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
    
    // MARK: Init Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        placeholderView?.layer.borderColor = BORDER_COLOR.cgColor
    }
}


class DataDisplayController: UIViewController {

    @IBOutlet weak var mobileDataTableView: UITableView!
    @IBOutlet weak var launchLogoImageView: UIImageView!
    private var mobileDataViewModel: MobileDataViewModel = MobileDataViewModel()
    private let refreshControl = UIRefreshControl()
    
    //MARK - Detail View Properties
    @IBOutlet weak var detailBgView: UIView!
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var yearLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Data Analytics"
        
        navigationController?.navigationBar.barTintColor = THEME_COLOR
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.barTintColor = THEME_COLOR
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        if #available(iOS 10.0, *) {
            mobileDataTableView.refreshControl = refreshControl
        } else {
            mobileDataTableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        refreshControl.tintColor = THEME_COLOR
        
        let tap = UITapGestureRecognizer(target: self, action:  #selector(self.handleTap(_:)))
        detailBgView.addGestureRecognizer(tap)
        
        mobileDataViewModel.updateHandler = { [unowned self] in
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
                self.mobileDataTableView.alpha = 0
                self.mobileDataTableView.reloadData()
                UIView.animate(withDuration: 1.0) {
                    self.mobileDataTableView.alpha = 1
                }
            }
        }
        
        detailBgView.isHidden = true
        mobileDataTableView.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.launchLogoImageView.transform = CGAffineTransform(scaleX: 3, y: 3)
            self?.launchLogoImageView.alpha = 0
            self?.view.backgroundColor = UIColor.white
        }) { [weak self] (finished) in
            self?.mobileDataTableView.isHidden = false
            self?.navigationController?.setNavigationBarHidden(false, animated: true)
            self?.mobileDataViewModel.loadMobileConsumptionData()
        }
    }
    
    @objc private func refreshData(_ sender: Any) {
        mobileDataViewModel.fetchMobileDataConsumption()
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.5, animations: {
            self.detailBgView.alpha = 0
            self.detailView.alpha = 0
            self.detailBgView.frame = CGRect.init(x: 0, y: self.view.frame.size.height, width: self.view.frame.size.width, height: self.view.frame.size.height)
        }) { (complete) in
            self.detailBgView.backgroundColor = UIColor.clear
            self.detailBgView.isHidden = true
            self.detailBgView.alpha = 1
        }
    }
    
    func showDetailView(_ data: MobileDataObject) {
        
        yearLabel.text = data.year
        let quaterlyDataList = mobileDataViewModel.getQuaterlyDisplayData(data)
        
        var index = 1
        for item in quaterlyDataList {
            let label = detailView.viewWithTag(index) as! UILabel
            label.text = item
            index = index + 1
        }
        
        detailBgView.backgroundColor = UIColor.clear
        detailView.alpha = 0
        detailBgView.isHidden = false
        detailBgView.frame = CGRect.init(x: 0, y: view.frame.size.height, width: view.frame.size.width, height: view.frame.size.height)
        
        UIView.animate(withDuration: 0.5, animations: {
            self.detailBgView.frame = CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
            self.detailBgView.backgroundColor = UIColor.black.withAlphaComponent(0.25)
            self.detailView.alpha = 1
        }) { (completion) in
            
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
            dataCell!.volumeConsumptionLabel.text = "Volume in petabytes"
            
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == HEADER_ROW {
            return
        }
        
        let index = IndexPath.init(row: indexPath.row - 1, section: 0)
        showDetailView(mobileDataViewModel.dataAtIndexPath(index))
    }
}

