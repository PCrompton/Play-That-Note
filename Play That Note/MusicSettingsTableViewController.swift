//
//  MusicSettingsTableViewController.swift
//  Play That Note
//
//  Created by Paul Crompton on 6/30/17.
//  Copyright © 2017 Paul Crompton. All rights reserved.
//

import UIKit
import Pitchy

class MusicSettingsTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var trebleButton: UIButton!
    @IBOutlet weak var bassButton: UIButton!
    @IBOutlet weak var altoButton: UIButton!
    @IBOutlet weak var tenorButton: UIButton!
    
    @IBOutlet weak var tranposePickerView: UIPickerView!
    @IBOutlet weak var rangePickerView: UIPickerView!
    
    @IBOutlet weak var omitAccidentalsSwitch: UISwitch!
    @IBOutlet weak var transposeDescription: UILabel!
    
    @IBOutlet weak var rangeDescription: UILabel!
    var selectedClef: Clef?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        transposeDescription.text = MusicSettings.Transpose.description
        let transposeData = MusicSettings.Transpose.pickerView
        tranposePickerView.selectRow(transposeData[0].index(of: MusicSettings.Transpose.direction.rawValue)!, inComponent: 0, animated: false)
        tranposePickerView.selectRow(MusicSettings.Transpose.octave, inComponent: 1, animated: false)
        let rows = getRowsForQualities()
        if let rowToSelect = rows.index(of: MusicSettings.Transpose.quality.rawValue) {
            tranposePickerView.selectRow(rowToSelect, inComponent: 2, animated: false)
        }
        tranposePickerView.selectRow(transposeData[3].index(of: MusicSettings.Transpose.interval.rawValue)!, inComponent: 3, animated: false)
        
        selectButton(trebleButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func omitAccidentalsSwitch(_ sender: UISwitch) {
        if let selectedClef = selectedClef {
            MusicSettings.Range.omitAccidentals(for: selectedClef, bool: sender.isOn)
            rangeDescription.text = MusicSettings.Range.description(for: selectedClef)
        }
        rangePickerView.reloadAllComponents()
        setRange()
    }
    
    @IBAction func selectButton(_ sender: UIButton) {
        
        let buttons = [trebleButton, bassButton, altoButton, tenorButton]
        
        for button in buttons {
            if button === sender {
                button!.isSelected = true
                switch button! {
                case trebleButton:
                    selectedClef = .treble
                case bassButton:
                    selectedClef = .bass
                case altoButton:
                    selectedClef = .alto
                case tenorButton:
                    selectedClef = .tenor
                default:
                    selectedClef = nil
                }
            } else {
                button!.isSelected = false
            }
        }
        if let selectedClef = selectedClef {
            rangeDescription.text = MusicSettings.Range.description(for: selectedClef)
            if let omitAccidentals = MusicSettings.Range.omitAccidentals(for: selectedClef) {
                omitAccidentalsSwitch.isOn = omitAccidentals
            }
            selectRows(for: selectedClef)
        }
        rangePickerView.reloadAllComponents()
        setRange()
        
        
    }
    func setRange() {
        guard let selectedClef = selectedClef else {
            return
        }
        let lowest = MusicSettings.Range.pickerView(for: selectedClef)[0][rangePickerView.selectedRow(inComponent: 0)]
        let highest = MusicSettings.Range.pickerView(for: selectedClef)[1][rangePickerView.selectedRow(inComponent: 1)]
        MusicSettings.Range.set(for: selectedClef, lowest: lowest, highest: highest)
        rangeDescription.text = MusicSettings.Range.description(for: selectedClef)
    }
    
    func selectRows(for selectedClef: Clef) {
        if let rangeForSelectedClef = MusicSettings.Range.range(for: selectedClef) {
            rangePickerView.selectRow(MusicSettings.Range.pickerView(for: selectedClef)[0].index(of: rangeForSelectedClef.lowestIndex)!, inComponent: 0, animated: false)
            rangePickerView.selectRow(MusicSettings.Range.pickerView(for: selectedClef)[1].index(of: rangeForSelectedClef.highestIndex)!, inComponent: 1, animated: false)
        }
    }
    
    func getRowsForQualities() -> [String] {
        var rows = MusicSettings.Transpose.pickerView[2]
        if MusicSettings.Transpose.interval == .fourth || MusicSettings.Transpose.interval == .fifth {
            rows.remove(at: rows.index(of: MusicSettings.Transpose.Quality
                .minor.rawValue)!)
            rows.remove(at: rows.index(of: MusicSettings.Transpose.Quality
                .major.rawValue)!)
        } else if MusicSettings.Transpose.interval == .unison {
            rows.remove(at: rows.index(of: MusicSettings.Transpose.Quality
                .diminished.rawValue)!)
            rows.remove(at: rows.index(of: MusicSettings.Transpose.Quality
                .minor.rawValue)!)
            rows.remove(at: rows.index(of: MusicSettings.Transpose.Quality
                .major.rawValue)!)
            rows.remove(at: rows.index(of: MusicSettings.Transpose.Quality
                .augmented.rawValue)!)
        } else {
            rows.remove(at: rows.index(of: MusicSettings.Transpose.Quality
                .perfect.rawValue)!)
            rows.remove(at: rows.index(of: MusicSettings.Transpose.Quality
                .diminished.rawValue)!)
            rows.remove(at: rows.index(of: MusicSettings.Transpose.Quality
                .augmented.rawValue)!)
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
            return MusicSettings.Transpose.pickerView.count
        case rangePickerView:
            if let selectedClef = selectedClef {
                return MusicSettings.Range.pickerView(for: selectedClef).count
            } else {
                return 0
            }
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case tranposePickerView:
            let rows = MusicSettings.Transpose.pickerView[component].count
            if component == 2 {
                if MusicSettings.Transpose.interval == .fourth || MusicSettings.Transpose.interval == .fifth {
                    return rows - 2
                } else if MusicSettings.Transpose.interval == .unison{
                    return rows - 4
                } else {
                    return rows - 3
                }
            }
            return rows
        case rangePickerView:
            if let selectedClef = selectedClef {
                return MusicSettings.Range.pickerView(for: selectedClef)[component].count
            } else {
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
                let rows = getRowsForQualities()[row]
                return rows
            } else {
                return MusicSettings.Transpose.pickerView[component][row]
            }
        case rangePickerView:
            if let selectedClef = selectedClef {
                return try! Note(index: MusicSettings.Range.pickerView(for: selectedClef)[component][row]).string
            } else {
                return nil
            }
        default:
            return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case tranposePickerView:
            let rowTitle = MusicSettings.Transpose.pickerView[component][row]
            switch component {
            case 0:
                MusicSettings.Transpose.direction = MusicSettings.Transpose.Direction(rawValue: rowTitle)!
            case 1:
                MusicSettings.Transpose.octave = Int(rowTitle.components(separatedBy: " ")[0])!
            case 2:
                let rows = getRowsForQualities()
                MusicSettings.Transpose.quality = MusicSettings.Transpose.Quality(rawValue: rows[row])!
            case 3:
                MusicSettings.Transpose.interval = MusicSettings.Transpose.Interval(rawValue: rowTitle)!
                if rowTitle == MusicSettings.Transpose.Interval.fourth.rawValue || rowTitle == MusicSettings.Transpose.Interval.fifth.rawValue {
                    MusicSettings.Transpose.quality = .perfect
                } else {
                    MusicSettings.Transpose.quality = .major
                }
                pickerView.reloadComponent(2)
                
                let rows = getRowsForQualities()
                print("number of rows in componant 2:", pickerView.numberOfRows(inComponent: 2))
                if let rowToSelect = rows.index(of: MusicSettings.Transpose.quality.rawValue) {
                    pickerView.selectRow(rowToSelect, inComponent: 2, animated: true)
                }
            default:
                break
            }
            transposeDescription.text = MusicSettings.Transpose.description
        case rangePickerView:
            guard let selectedClef = selectedClef else {
                return
            }
            let lowest = MusicSettings.Range.range(for: selectedClef)!.lowestIndex
            let highest = MusicSettings.Range.range(for: selectedClef)!.highestIndex
            let newLowest: Int
            let newHighest: Int
            switch component {
            case 0:
                newLowest = MusicSettings.Range.pickerView(for: selectedClef)[0][row]
                newHighest = highest
            case 1:
                newLowest = lowest
                newHighest = MusicSettings.Range.pickerView(for: selectedClef)[1][row]
            default:
                newLowest = lowest
                newHighest = highest
                break
            }
            MusicSettings.Range.set(for: selectedClef, lowest: newLowest, highest: newHighest)
            pickerView.reloadAllComponents()
            rangeDescription.text = MusicSettings.Range.description(for: selectedClef)
        default:
            break
        }
    }
}
