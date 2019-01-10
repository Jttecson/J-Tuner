//
//  TunerViewController.swift
//  J-Tuner
//
//  Created by Joel Tecson on 2018-12-22.
//  Copyright © 2018 bignerdranch. All rights reserved.
//

import AVFoundation
import Foundation
import UIKit

class MeterViewController: UIViewController
{

    @IBOutlet weak var meterLabel: UILabel!

    func updateMeter(string: String)
    {
        if Thread.isMainThread {
            meterLabel.text = string
        } else {
            DispatchQueue.main.sync {
                meterLabel.text = string
            }
        }
        print(string)
    }

    func clearMeter()
    {
        meterLabel.text = ""
    }
}
