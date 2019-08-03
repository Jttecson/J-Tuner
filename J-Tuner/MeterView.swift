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

class MeterView: UIView {
    var meterLabel: UILabel?

    override init(frame: CGRect) {
        super.init(frame: frame)
        meterLabel = UILabel.init(frame: CGRect(origin: CGPoint.zero, size: frame.size))
        meterLabel?.text = "METER"
        meterLabel?.textAlignment = NSTextAlignment.center
        self.addSubview(meterLabel!)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func updateMeter(string: String) {
        if Thread.isMainThread {
            meterLabel?.text = string
        } else {
            DispatchQueue.main.sync {
                meterLabel?.text = string
            }
        }
    }

    func clearMeter() {
        meterLabel?.text = ""
    }
}
