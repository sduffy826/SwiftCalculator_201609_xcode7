//
//  ViewController.swift
//  SwiftCalculator_201609_xcode7
//
//  Created by Sean Regular on 9/16/16.
//  Copyright © 2016 CS193p. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    private var userInMiddleOfTypeANumber = false
    
    @IBOutlet weak private var display: UILabel!
    
    @IBOutlet weak var descript: UILabel!
    
    // This computed value makes it easy to use the
    // 'display'
    private var displayValue: Double {
        set {
            display.text = String(newValue)
        }
        get {
            return Double(display.text!)!
        }
    }
    
    // Object for the model of our calculator
    private let brain = CalculatorBrain()
    
    private func descriptValue() {
        descript.text = brain.descript +
             ( brain.isPartialResult ? "..." : "" )
    }
    
    // Set variable in brains memory to be whats
    // in the display
    @IBAction func setMemory(sender: UIButton) {
        brain.setVariable("M", value: displayValue)
        userInMiddleOfTypeANumber = false
        displayValue = brain.result
    }
    
    // Need to add logic for when M is pressed
    @IBAction func getMemory(sender: UIButton) {
        brain.setOperand("M")
        displayValue = brain.result
    }
    
    @IBAction private func operatorPressed(sender: UIButton) {
        if let operatorValue = sender.currentTitle {
            // If user typing a number then set accumulator
            // in the model
            if userInMiddleOfTypeANumber {
                brain.setOperand(displayValue)
                userInMiddleOfTypeANumber = false
            }
            
            brain.performOperation(operatorValue)
            displayValue = brain.result
            descriptValue()
        }
    }

    @IBAction func clrPressed() {
        displayValue = 0
        userInMiddleOfTypeANumber = false
        brain.clear()
    }
    
    @IBAction func decimalPointPressed(sender: UIButton) {
        if userInMiddleOfTypeANumber {
            if display.text!.containsString(".") == false {
                self.digitPressed(sender)
            }
        }
        else {
            display.text = "0."
            userInMiddleOfTypeANumber = true
        }
    }
    @IBAction private func digitPressed(sender: UIButton) {
        if let value = sender.currentTitle {
            if userInMiddleOfTypeANumber {
                display.text = display.text! + value
            }
            else {
                display.text = value
            }
            userInMiddleOfTypeANumber = true
        }
    }

}

