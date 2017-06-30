//
//  MusicSettingsTableViewController.swift
//  Play That Note
//
//  Created by Paul Crompton on 6/30/17.
//  Copyright © 2017 Paul Crompton. All rights reserved.
//

import UIKit

class MusicSettingsTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var trebleButton: UIButton!
    @IBOutlet weak var bassButton: UIButton!
    @IBOutlet weak var altoButton: UIButton!
    @IBOutlet weak var tenorButton: UIButton!
    
    @IBOutlet weak var tranposePickerView: UIPickerView!
    @IBOutlet weak var rangePickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let transposePickerViewService = TransposePickerViewService()
//        tranposePickerView.dataSource = transposePickerViewService
//        tranposePickerView.delegate = transposePickerViewService
//        
//        let rangePickerViewService = RangePickerViewService()
//        rangePickerView.dataSource = rangePickerViewService
//        rangePickerView.delegate = rangePickerViewService
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func selectButton(_ sender: UIButton) {
        
        let buttons = [trebleButton, bassButton, altoButton, tenorButton]
        
        for button in buttons {
            if button === sender {
                button!.isSelected = true
            } else {
                button!.isSelected = false
            }
        }
    }
    

    // MARK: - Table view data source


    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: DataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 4
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 5
    }
    
    // MARK: Delegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "Row \(row)"
    }

}
