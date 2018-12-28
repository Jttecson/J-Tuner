//
//  Note.swift
//  J-Tuner
//
//  Created by Joel Tecson on 2018-12-22.
//  Copyright © 2018 bignerdranch. All rights reserved.
//

import Foundation

class Note
{
    public let tone: String
    public let offset: Double

    public var note: String
    {
        let plusminus = offset > 0 ? "+" : "-"
        return self.tone
       // return self.tone + " \(plusminus) " + String(abs(offset.rounded()))
    }

    public init?(pitch: Double)
    {
        guard !pitch.isNaN else { return nil }
        var tone: String
        if(pitch < 0)
        {
            return nil
        }
        else
        {
            let pitchInt = Int(pitch.rounded())
            switch pitchInt % 12
            {
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
        offset = pitch * 100 - pitch.rounded()*100
        self.tone = tone + String(Int(pitch.rounded()) / 12)
    }
}
