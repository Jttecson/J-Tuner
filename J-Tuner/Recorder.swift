//
//  Recorder.swift
//  J-Tuner
//
//  Created by Joel Tecson on 2018-10-31.
//  Copyright © 2018 bignerdranch. All rights reserved.
//

import Foundation
import AVFoundation

public struct Constants {
    static let samplesPerWindow = 2
    static let sampleFrequency = 44100
    static let windowSize = 1024
}

class Recorder {
    private var a: Int = 0
    private var lastPitches: [Float] = []
    private let samplePeriod: TimeInterval
    private var audioSession: AVAudioSession!
    private(set) var isRecording: Bool?

    private var audioRecorders: [AVAudioRecorder]
    private var queuedPitches: [Int: Float] = [:]

    public var meterView: MeterView?
    public var gaugeView: GaugeView?

    public init?(audioSession: AVAudioSession) {
        self.samplePeriod = Double(Constants.windowSize)/Double(Constants.sampleFrequency)
        self.audioSession = audioSession
        self.audioRecorders = []

        for var i in 0..<Constants.samplesPerWindow {
            let filename = getDirectory(for: i)
            let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: Constants.sampleFrequency, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
            var audioRecorder: AVAudioRecorder?
            do {
                audioRecorder = try AVAudioRecorder(url: filename, settings: settings)
                if let audioRecorder = audioRecorder {
                    audioRecorder.deleteRecording()
                    audioRecorder.isMeteringEnabled = true
                    self.audioRecorders.append(audioRecorder)
                }
            }
            catch {
                return nil
            }
            i += 1
        }
    }

    private func getDirectory(for index: Int) -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("\(index).m4a")
    }

    public func startRecording() {
        isRecording = true
        let recordingPeriod = TimeInterval(Float(Constants.windowSize)/Float(Constants.sampleFrequency))
        DispatchQueue.main.async {
            self.keepRecording()
        }
    }

    public func keepRecording() {
        let recordingPeriod = TimeInterval(Float(Constants.windowSize)/Float(Constants.sampleFrequency))
        DispatchQueue.main.asyncAfter(deadline: .now() + recordingPeriod / Double(Constants.samplesPerWindow)) {
            self.keepRecording()
        }
        if(self.isRecording ?? false) {
            if let audioRecorder = nextRecorder() {
                audioRecorder.record()
                DispatchQueue.global().asyncAfter(deadline: .now() + recordingPeriod, qos: .userInteractive) {
                    if let pitch = self.finishSampling(audioRecorder: audioRecorder) {
                        self.lastPitches.append(pitch)
                        if(self.lastPitches.count == 5) {
                            self.lastPitches.sort()
                            let new = (self.lastPitches.reduce(0, +) - self.lastPitches.first! - self.lastPitches.last!) / 3
                            if let note = Note(pitch: Double(new)) {
                                self.meterView?.updateMeter(string: note.note)
                                DispatchQueue.main.sync {
                                    self.gaugeView?.value = note.cents
                                }
                            }
                            self.lastPitches = []
                        }
                    }
                }
            }
        }
    }

    public func stopRecording() {
        isRecording = false
    }

    private func nextRecorder() -> AVAudioRecorder? {
        return audioRecorders.first(where: { audioRecorder in !audioRecorder.isRecording })
    }

    public func finishSampling(audioRecorder: AVAudioRecorder) -> Float? {
        audioRecorder.updateMeters()
        if(audioRecorder.averagePower(forChannel: 0) < -60) {
            meterView?.updateMeter(string: "TOO SOFT")
            audioRecorder.stop()
            return nil
        }
        audioRecorder.stop()
        if let index = audioRecorders.firstIndex(of: audioRecorder), var (data, _, _) = loadAudioSignal(audioURL: getDirectory(for: index)) {
            let pitch = getPitch(&data, Int32(min(data.count, Constants.windowSize)), Int32(Constants.windowSize), Int32(Constants.sampleFrequency))
            return Float(pitch)
        }
        return nil
    }

    private func loadAudioSignal(audioURL: URL) -> (signal: [Float], rate: Double, frameCount: Int)? {
        guard
            let file = try? AVAudioFile(forReading: audioURL),
            let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: file.fileFormat.sampleRate, channels: file.fileFormat.channelCount, interleaved: false),
            let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: UInt32(file.length))
            else { return nil }
        try? file.read(into: buf)
        let floatArray = Array(UnsafeBufferPointer(start: buf.floatChannelData?[0], count:Int(buf.frameLength)))
        return (signal: floatArray, rate: file.fileFormat.sampleRate, frameCount: Int(file.length))
    }
}
