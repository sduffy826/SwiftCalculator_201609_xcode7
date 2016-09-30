//
//  CalculatorBrain.swift
//  SwiftCalculator_201609_xcode7
//
//  Created by Sean Regular on 9/16/16.
//  Copyright © 2016 CS193p. All rights reserved.
//

import Foundation

// Global function to add two doubles, just done this way to show possibilities
// for operations... see below for how it's invoked :)
func add(op1: Double, op2: Double) -> Double {
    return op1 + op2
}

// Understand the closure stuff in the dictionary, it's cool!!  Closures
// are like inline functions (but have state)
class CalculatorBrain {
    typealias PropertyList = AnyObject
    static let debugIt = true
    private var accumulator = 0.0
    private var description = ""
    private var internalProgram = [AnyObject]()
    private var pending: PendingBinaryOperationInfo?
    private var variableValues = [String: Double]()
    
    // ============= S T R U C T S ==================
    
    // This is called when user hits a binary operation, it
    // saves the accumulator and the function that was hit
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
    }
    
    // ============ C O M P U T E D   P R O P E R T I E S ================
    
    // Computed property to return accumulator as a string
    private var accumulatorString: String {
        get { return String(accumulator) }
    }
    
    // Return the description (operands and operators)
    var descript: String {
        get { return description }
    }
    
    // Computed property to show that pending operation exists
    var isPartialResult: Bool {
        get { return pending != nil }
    }
    
    // Define the operations availabe to calculator and the operation to be performed
    // also define the associated value for it
    private var operations: Dictionary<String, Operation> = [
        // You need to provide the associated value to the enum case
        "π" : Operation.Constant(M_PI),
        "e" : Operation.Constant(M_E),
        
        // Associate function for unary operations
        "√" : Operation.UnaryOperation(sqrt),
        
        // Show using closure for next two :)
        "x²" : Operation.UnaryOperation({ $0 * $0 }),
        "≪" : Operation.UnaryOperation({ $0 * 2 }), // shift left is mult by 2
        "≫" : Operation.UnaryOperation({ $0 / 2 }),
        "±" : Operation.UnaryOperation({ -$0 }),
        
        "sin" : Operation.UnaryOperation(sin),
        "cos" : Operation.UnaryOperation(cos),
        "tan" : Operation.UnaryOperation(tan),
        "log" : Operation.UnaryOperation(log),
        
        // This is without closure, just call method to do the add
        "+" : Operation.BinaryOperation(add),
        
        // This is showing with closure, first is long form
        "−" : Operation.BinaryOperation({ (op1: Double, op2: Double) -> Double in return op1 - op2 }),
        
        // More... it knows the arguments based on associated value
        // so we can clean up more
        "×" : Operation.BinaryOperation({ (op1, op2) in return op1 * op2 }),
        
        // Even more, closure use $0..$n as default args and since
        // it knows return type we can simplify with just :)
        "÷" : Operation.BinaryOperation({ $0 / $1 }),
        
        "=" : Operation.Equals
    ]
    
    // Enum for the different types of operations on the
    // calculator, some (most) cases have an associated value
    private enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Equals
    }

    // Computed property that is the program in the calculator
    var program: PropertyList {
        get {
            return internalProgram
        }
        set {
            // Means we want to set the program based on what
            // the user passed us (in newValue)
            clearMe(false)  // Clear calculator brain without clearing variables
            
            // Loop thru the array of anyobject and perform
            // the operation or set the operand
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand)
                    }
                    else if let operation = op as? String {
                        // Either an operation or a variable name
                        if let variableName = variableValues[operation] {
                            setOperand(variableName)
                        }
                        else {
                            performOperation(operation)
                        }
                    }
                }
            }
            
        }
    }
    
    // Used in the controller to get the result of operation (or
    // value in accumulator... it's read only externally)
    var result: Double {
        get { return accumulator }
    }
    
    // ============== F U N C T I O N S =================
    // Clear out the brain
    internal func clear() {
        clearMe(true)
    }
    
    // Clear my attributes, the bool passed in of true means even my local
    // variables... that's not done during a local recompute
    private func clearMe(everything: Bool) {
        accumulator = 0.0
        description = ""
        pending = nil
        internalProgram.removeAll()
        if everything {
          variableValues.removeAll()
        }
    }
    
    // Dump out the contents of the variableValues dictionary (mainly debugging)
    private func dumpVariables() {
        for (key, value) in variableValues {
            print("key \(key) value \(value)")
        }
    }
    
    // This executes the pending operation, made function since
    // it's called in several places :)
    private func executePendingBinaryOperation() {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
            
        }
    }
    // This function executes the operation the user requested
    // it uses the operations dictionary to determine the type of
    // operation (an enum), then uses the associated value for the
    // enum case to carry out the operation... only one a little
    // tricky is for binary operations we need to save the accumulator
    // and function they requested (in pending...)
    func performOperation(symbol: String) {
        if let operation = operations[symbol] {
            internalProgram.append(symbol)
            switch operation {
            // Use (let xxx) to get the associated value
            case .Constant(let value) :
                accumulator = value
                description = accumulatorString
                
                // Set the accumulator to the value from the
            // function call with the current accumulator
            case .UnaryOperation(let function) :
                description = symbol + "(" + description + ")"
                accumulator = function(accumulator)
                
                // Set pending struct to be function and the current
            // accumulator value
            case .BinaryOperation(let function) :
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
                description += symbol
                
                // If a pending operation exists then we'll call
                // it passing in the old accumulator value and the
            // new one
            case .Equals :
                description += "="
                executePendingBinaryOperation()
            }
        }
    }
    
    // Used to set the current accumulator value (needed in controller)
    func setOperand(operand: Double) {
        accumulator = operand
        description += accumulatorString
        internalProgram.append(operand)
    }
    
    // Used to set accumulator to the value of a variable,
    // use 0.0 if not defined
    func setOperand(variableName: String) {
      accumulator = variableValues[variableName] ?? 0.0
      description += variableName
      internalProgram.append(variableName)  // Put the variable name into the program
      if CalculatorBrain.debugIt { dumpVariables() }
    }
    
    // Sets variable to value (both args passed in
    func setVariable(variableName: String, value: Double) {
        variableValues[variableName] = value
        print("Variable \(variableName) with value \(value).")
        reCompute()
        if CalculatorBrain.debugIt { dumpVariables() }
    }
    
    // Recompute the program
    private func reCompute() {
        let oldList = program  // Get old program
        program = oldList      // invokes setter which will recompute/rebuild
    }
}