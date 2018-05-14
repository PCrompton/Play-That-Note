//
//  GameViewController+Appearance.swift
//  Play That Note
//
//  Created by Paul Crompton on 4/16/18.
//  Copyright © 2018 Paul Crompton. All rights reserved.
//

import Foundation
import UIKit

extension GameViewController {

    func configTranspositionLabel() {
        if view.traitCollection.verticalSizeClass == .compact {
            transpositionLabel.isHidden = true
        } else {
            transpositionLabel.isHidden = false
        }
    }
    
    func configRangeLabel() {
        if view.traitCollection.verticalSizeClass == .compact {
            rangeLabel.isHidden = true
        } else {
            rangeLabel.isHidden = false
        }
    }
    
    func setTranspositionLabel() {
        transpositionLabel.text = MusicSettings.Transpose.description
    }
    
    func setRangeLabel() {
        rangeLabel.text = MusicSettings.Range.description(for: clef)
    }
    
    func configButtons() {
        for button in [startButton, cancelButton] {
            addShadows(to: button!)
        }
    }
    
    func addShadows(to button: UIButton) {
        button.layer.shadowOpacity = 0.7
        button.layer.shadowOffset = CGSize(width: 3.0, height: 2.0)
        button.layer.shadowRadius = 5.0
        button.layer.shadowColor = UIColor.darkGray.cgColor
    }
    
    func setButtonStackViewAxis() {
        if view.traitCollection.verticalSizeClass == .compact {
            buttonStackView.axis = .horizontal
        } else {
            buttonStackView.axis = .vertical
        }
    }
}
