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
        IAPManager.sharedInstance.settingsVC = self
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell") else {
            fatalError("Unable to instantiate SettingsTableView cell")
        }
        
        switch indexPath.row {
        case Settings.music.hashValue:
            cell.textLabel?.text = "Music"
            cell.detailTextLabel?.text = "Set custom range and transposition"
            if !MusicSettings.isUnlocked {
                if let product = IAPManager.sharedInstance.getProduct(by: MusicSettings.productID) {
                    cell.textLabel?.text?.append(" - Unlock for \(priceStringForProduct(product: product))")
                    cell.detailTextLabel?.text = product.localizedDescription
                } else {
                    cell.textLabel?.text?.append(" - Needs IAP Permission")
                }
            }

        case Settings.pitchDetection.hashValue:
            cell.textLabel?.text = "Pitch Detection"
            cell.detailTextLabel?.text = "Set Buffers and Level Threshhold"
        case Settings.license.hashValue:
            cell.textLabel?.text = "License"
            cell.detailTextLabel?.isHidden = true
        case Settings.restorePurchases.hashValue:
            cell.textLabel?.text = "Restore In-App Purchases"
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: (cell.textLabel?.font.pointSize)!)
            cell.detailTextLabel?.isHidden = true
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
                if let product = IAPManager.sharedInstance.getProduct(by: MusicSettings.productID) {
                    IAPManager.sharedInstance.createPaymentRequestForProduct(product: product)
                }
            }
        case Settings.pitchDetection.hashValue:
            let vc = storyboard?.instantiateViewController(withIdentifier: "PitchDetectionSettingsTableViewController") as! PitchDetectionSettingsTableViewController
            show(vc, sender: cell)
        case Settings.license.hashValue:
            let vc = storyboard?.instantiateViewController(withIdentifier: "LicenseViewController") as! LicenseViewController
            show(vc, sender: cell)
        case Settings.restorePurchases.hashValue:
            IAPManager.sharedInstance.restorePurchasedItems()
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
