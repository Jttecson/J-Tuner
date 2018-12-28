//
//  Recorder.swift
//  J-Tuner
//
//  Created by Joel Tecson on 2018-10-31.
//  Copyright © 2018 bignerdranch. All rights reserved.
//

import Foundation
import AVFoundation

private struct Constants
{
    static let samplesPerWindow = 4
    static let sampleFrequency = 12000
    static let windowSize = 4096
}

class Recorder
{
    private let samplePeriod: TimeInterval
    private let recordingsPerSample: Int
    private var audioSession: AVAudioSession!
    private var keepRecording: Bool?

    private var AudioRecorders: [AVAudioRecorder?]
    private var queuedPitches: [Int: Float] = [:]

    public var meterViewController: MeterViewController?

    public init?(samplePeriod: TimeInterval, recordingsPerSample: Int, audioSession: AVAudioSession)
    {
        self.samplePeriod = samplePeriod
        self.recordingsPerSample = recordingsPerSample
        self.audioSession = audioSession
        self.AudioRecorders = []

        for var i in 0..<Constants.samplesPerWindow*2
        {
            let filename = getDirectory(for: i)
            let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 12000, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
            var audioRecorder: AVAudioRecorder?
            do
            {
                audioRecorder = try AVAudioRecorder(url: filename, settings: settings)
                audioRecorder?.deleteRecording()
                self.AudioRecorders.append(audioRecorder)
            }
            catch
            {
                return nil
            }
            i += 1
        }
    }

    private func getDirectory(for index: Int) -> URL
    {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("\(index).m4a")
    }

    public func startRecording()
    {
        keepRecording = true
        let recordingPeriod = TimeInterval(1.0 / Float((Constants.sampleFrequency / Constants.windowSize)))
        DispatchQueue.global().async {
            repeat
            {
                for (index, audioRecorder) in self.AudioRecorders.enumerated()
                {
                    guard let audioRecorder = audioRecorder else { continue }
                    audioRecorder.deleteRecording()
                    audioRecorder.record()
                    DispatchQueue.main.async
                    {
                        DispatchQueue.main.asyncAfter(deadline: .now() + recordingPeriod)
                        {
                            if let pitch = self.finishSampling(audioRecorder: audioRecorder, index: self.AudioRecorders.index(of: audioRecorder))
                            {
                                print(pitch)
                                if let note = Note(pitch: Double(pitch))
                                {
                                    self.meterViewController?.updateMeter(string: note.note)
                                }
//                                if(index % 2 == 0)
//                                {
//                                    self.queuedPitches[index] = pitch
//                                } else
//                                {
//                                    var queuedPitch = self.queuedPitches[index-1] ?? pitch
//                                    if queuedPitch.isNaN { queuedPitch = pitch }
//                                    if let note = Note(pitch: Double((pitch + queuedPitch) / 2))
//                                    {
//                                        self.meterViewController?.updateMeter(string: note.note)
//                                    } else
//                                    {
////                                        self.meterViewController?.clearMeter()
//                                    }
//                                }
                            }
                        }
                    }
                    // Use usleep here to pause thread which runs overall repeat loop
                    // Sets functional time interval for one loop iteration
                    usleep(useconds_t((Float(Constants.windowSize)/Float(Constants.samplesPerWindow))/Float(Constants.sampleFrequency)*1000000))
                }
            }
            while self.keepRecording ?? false
        }
    }

    public func stopRecording()
    {
        keepRecording = false
    }

    public func isRecording() -> Bool
    {
        return true
    }

    private func finishSampling(audioRecorder: AVAudioRecorder?, index: Int?) -> Float?
    {
        audioRecorder?.stop()
        if let index = index, var (data, _, _) = loadAudioSignal(audioURL: getDirectory(for: index))
        {
            let pitch = getPitch(&data, Int32(data.count), Int32(Constants.sampleFrequency))
            return Float(pitch)
        }
        return nil
    }

    private func loadAudioSignal(audioURL: URL) -> (signal: [Float], rate: Double, frameCount: Int)?
    {
        guard
            let file = try? AVAudioFile(forReading: audioURL),
            let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: file.fileFormat.sampleRate, channels: file.fileFormat.channelCount, interleaved: false),
            let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: UInt32(file.length))
            else
        {
            return nil
        }
        try? file.read(into: buf)
        let floatArray = Array(UnsafeBufferPointer(start: buf.floatChannelData?[0], count:Int(buf.frameLength)))
        return (signal: floatArray, rate: file.fileFormat.sampleRate, frameCount: Int(file.length))
    }
}
