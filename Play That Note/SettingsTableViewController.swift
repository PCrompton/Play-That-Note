//
//  SettingsTableViewController.swift
//  Play That Note
//
//  Created by Paul Crompton on 6/30/17.
//  Copyright © 2017 Paul Crompton. All rights reserved.
//

import UIKit
import StoreKit

class SettingsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        IAPManager.shared.settingsVC = self
        menuConfig()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        menuConfig()
    }
    
    func menuConfig() {
        tableView.reloadData()
    }
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDataSource Function
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return Settings.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell") as? SettingsTableViewCell else {
            fatalError("Unable to instantiate SettingsTableView cell")
        }
        switch indexPath.row {
        case Settings.music.hashValue:
            cell.titleTextLabel.text = "Music"
            cell.subtitleTextLabel.text = "Set custom range and transposition"
            if !MusicSettings.isUnlocked {
                if let product = IAPManager.shared.getProduct(by: MusicSettings.productID) {
                    cell.titleTextLabel.text?.append(" - Unlock for \(priceStringForProduct(product: product))")
                    let localizedDescription = product.localizedDescription
                    if localizedDescription != "" {
                        cell.subtitleTextLabel.text = product.localizedDescription
                    }
                } else {
                    cell.titleTextLabel?.text?.append(" - Needs IAP Permission")
                }
            }
        case Settings.pitchDetection.hashValue:
            cell.titleTextLabel?.text = "Pitch Detection"
            cell.subtitleTextLabel?.text = "Set Buffers and Level Threshhold"
        case Settings.license.hashValue:
            cell.titleTextLabel?.text = "License"
            cell.subtitleTextLabel?.isHidden = true
        case Settings.restorePurchases.hashValue:
            cell.titleTextLabel?.text = "Restore In-App Purchases"
            cell.titleTextLabel?.font = UIFont.boldSystemFont(ofSize: (cell.titleTextLabel?.font.pointSize)!)
            cell.accessoryType = .none
            cell.subtitleTextLabel?.isHidden = true
        default:
            break
        }
        return cell
    }
    
    func showMusicSettings(sender: Any?) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "MusicSettingsTableViewController") as! MusicSettingsTableViewController
        show(vc, sender: sender)
    }
    
    // MARK: - UITableViewDelegate Functions
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            fatalError("Cell Not Found")
        }
        switch indexPath.row {
        case Settings.music.hashValue:
            if MusicSettings.isUnlocked {
                showMusicSettings(sender: cell)
            } else {
                if let product = IAPManager.shared.getProduct(by: MusicSettings.productID) {
                    IAPManager.shared.createPaymentRequestForProduct(product: product)
                }
            }
        case Settings.pitchDetection.hashValue:
            let vc = storyboard?.instantiateViewController(withIdentifier: "PitchDetectionSettingsTableViewController") as! PitchDetectionSettingsTableViewController
            show(vc, sender: cell)
        case Settings.license.hashValue:
            let vc = storyboard?.instantiateViewController(withIdentifier: "LicenseViewController") as! LicenseViewController
            show(vc, sender: cell)
        case Settings.restorePurchases.hashValue:
            IAPManager.shared.restorePurchasedItems()
            cell.setSelected(false, animated: false)
        default: return
        }
    }
    
    func priceStringForProduct(product: SKProduct) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        
        return formatter.string(from: product.price)!
    }

    // MARK: - Navigation

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//    }
}
