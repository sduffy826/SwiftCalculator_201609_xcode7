//
//  CalculatorViewController.swift
//  SwiftCalculator_201609_xcode7
//
//  Created by Sean Regular on 9/16/16.
//  Copyright © 2016 CS193p. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    private var userInMiddleOfTypeANumber = false
    
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
    
    // Labels in storyboard
    @IBOutlet weak private var display: UILabel!
    
    @IBOutlet weak private var descript: UILabel!
    
    // Set variable in brains memory to be whats
    // in the display
    @IBAction func setMemory(sender: UIButton) {
      brain.setVariable("M", value: displayValue)
      userInMiddleOfTypeANumber = false
      displayValue = brain.result
    }
    
    // When they press M we just call the set operand method
    // it retrieves value of M and sets it as operand
    @IBAction func getMemory(sender: UIButton) {
        brain.setOperand("M")
        displayValue = brain.result
    }
    
    // User pressed an operator
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

    // User pressed the clear button, tell brain to clear then
    // reset display
    @IBAction func clrPressed() {
        userInMiddleOfTypeANumber = false
        brain.clear()
        displayValue = brain.result
        descriptValue()
    }
    
    // User pressed decimal point, if in the middle of typing a 
    // number then we'll append it (if doesn't already have .) otherwise
    // we'll set display text to 0.
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
    
    // User pressed a digit
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        var destinationVC = segue.destinationViewController
        if let navigationVC = destinationVC as? UINavigationController {
            // If the dest vc is a navigation controller then get the
            // controller within it... this is typical :)
            destinationVC = navigationVC.visibleViewController ?? destinationVC
        }
        if let graphVC = destinationVC as? GraphViewController {
            if let sequeIdentifier = segue.identifier {
                if sequeIdentifier == "graphit" {
                    graphVC.navigationItem.title = brain.descript
                    graphVC.test(displayValue)
                }
            }
        }
    }


}

