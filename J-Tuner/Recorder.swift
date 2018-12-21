//
//  Recorder.swift
//  J-Tuner
//
//  Created by Joel Tecson on 2018-10-31.
//  Copyright © 2018 bignerdranch. All rights reserved.
//

import Foundation
import AVFoundation

class Recorder: AVAudioRecorder {
    override public init() {
        super.init()
        prepareToRecord()
    }

    public func record(for time: TimeInterval) {
        record(forDuration: time)
    }
}
