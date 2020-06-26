//
//  HospitalViewController.swift
//  Covid19Local
//
//  Created by Tommy Guan on 6/25/20.
//  Copyright © 2020 Tommy Guan. All rights reserved.
//

import UIKit

class HospitalViewController: UIViewController {

    @IBOutlet weak var cumulativeButton: UIButton!
    
    @IBOutlet weak var rateButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    @IBAction func rateButtonDown(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            cumulativeButton?.isSelected = true
        }
        else
        {
            sender.isSelected = true
            cumulativeButton?.isSelected = false
        }
    }
    
    @IBAction func cumulativeButtonDown(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
           // rateButton.isSelected = true
        }
        else
        {
            sender.isSelected = true
          //  rateButton.isSelected = false
        }
    }
}
