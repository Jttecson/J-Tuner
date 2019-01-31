//
//  Note.swift
//  J-Tuner
//
//  Created by Joel Tecson on 2018-12-22.
//  Copyright © 2018 bignerdranch. All rights reserved.
//

import Foundation

class Note {
    public let tone: String
    public let cents: Int

    public var note: String {
        let plusminus = cents > 0 ? "+" : "-"
        return cents == 0 ? self.tone : self.tone + " \(plusminus) " + String(abs(cents))
    }

    public init?(pitch: Double) {
        guard !pitch.isNaN else { return nil }
        var tone: String
        if(pitch < 0) { return nil }
        else {
            let pitchInt = Int(pitch.rounded())
            switch pitchInt % 12 {
            case 0: tone = "C"
            case 1: tone = "C#/Db"
            case 2: tone = "D"
            case 3: tone = "D#/Eb"
            case 4: tone = "E"
            case 5: tone = "F"
            case 6: tone = "F#/Gb"
            case 7: tone = "G"
            case 8: tone = "G#/Ab"
            case 9: tone = "A"
            case 10: tone = "A#/Bb"
            case 11: tone = "B"
            default:
                return nil
            }
        }
        self.tone = tone + String(Int(pitch.rounded()) / 12)
        var cents = Int(pitch*100.rounded()) - Int(pitch.rounded())*100
        if(abs(cents) < 11) { cents = 0 }
        self.cents = cents
    }
}
