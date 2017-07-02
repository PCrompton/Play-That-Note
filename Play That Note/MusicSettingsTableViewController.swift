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
    
    @IBOutlet weak var transposeDescription: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        transposeDescription.text = MusicSettings.transposeDescription
        let transposeData = MusicSettings.transposePickerView
        tranposePickerView.selectRow(transposeData[0].index(of: MusicSettings.direction)!, inComponent: 0, animated: false)
        tranposePickerView.selectRow(MusicSettings.octave, inComponent: 1, animated: false)
        let rows = getRowsForQualities()
        tranposePickerView.selectRow(rows.index(of: MusicSettings.quality)!, inComponent: 2, animated: false)
        tranposePickerView.selectRow(transposeData[3].index(of: MusicSettings.interval)!, inComponent: 3, animated: false)
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
    
    func getRowsForQualities() -> [String] {
        var rows = MusicSettings.transposePickerView[2]
        if MusicSettings.interval == "4th" || MusicSettings.interval == "5th" {
            rows.remove(at: rows.index(of: "Min")!)
            rows.remove(at: rows.index(of: "Maj")!)
        } else if MusicSettings.interval == "Unison" {
            rows.remove(at: rows.index(of: "Dim")!)
            rows.remove(at: rows.index(of: "Min")!)
            rows.remove(at: rows.index(of: "Maj")!)
            rows.remove(at: rows.index(of: "Aug")!)
        } else {
            rows.remove(at: rows.index(of: "Per")!)
            rows.remove(at: rows.index(of: "Dim")!)
            rows.remove(at: rows.index(of: "Aug")!)
        }
        return rows
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
    
    // MARK: PickerView helper functions
    

    
    // MARK: DataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        switch pickerView {
        case tranposePickerView:
            return MusicSettings.transposePickerView.count
        case rangePickerView:
            return 3
        default:
            return 0
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case tranposePickerView:
            let rows = MusicSettings.transposePickerView[component].count
            if component == 2 {
                if MusicSettings.interval == "4th" || MusicSettings.interval == "5th" {
                    return rows - 2
                } else if MusicSettings.interval == "Unison" {
                    return rows - 4
                } else {
                    return rows - 3
                }
            }
            return rows
        case rangePickerView:
            switch component {
            case 0:
                return 2
            case 1:
                return 3
            case 2:
                return 4
            case 3:
                return 5
            default:
                return 0
            }
        default:
            return 0
        }
    }
    
    // MARK: Delegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case tranposePickerView:
            if component == 2 {
                return getRowsForQualities()[row]
            } else {
                return MusicSettings.transposePickerView[component][row]
            }
        case rangePickerView:
            return nil
        default:
            return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let rowTitle = MusicSettings.transposePickerView[component][row]
        switch pickerView {
        case tranposePickerView:
            switch component {
            case 0:
                MusicSettings.direction = rowTitle
            case 1:
                MusicSettings.octave = Int(rowTitle.components(separatedBy: " ")[0])!
            case 2:
                MusicSettings.quality = rowTitle
            case 3:
                MusicSettings.interval = rowTitle
                let rows = getRowsForQualities()
                pickerView.selectRow(0, inComponent: 2, animated: true)
                MusicSettings.quality = rows[pickerView.selectedRow(inComponent: 2)]
                pickerView.reloadComponent(2)
            default:
                break
            }
        transposeDescription.text = MusicSettings.transposeDescription
        case rangePickerView:
            break
        default:
            break
        }
    }
}
