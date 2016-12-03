//
//  GraphViewController.swift
//  SwiftCalculator_201609_xcode7
//
//  Created by Sean Regular on 11/12/16.
//  Copyright © 2016 CS193p. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {

    var graph = GraphView()
    
    func test(_ ptsPerUnit: Double) {
        graph.lineWidth += 1.0
        graph.origin.x += 5
        graph.origin.y += 10
        graph.pointsPerUnit = CGFloat(ptsPerUnit)
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
