//
//  NoteViewController.swift
//  J-Tuner
//
//  Created by Joel Tecson on 2018-10-31.
//  Copyright © 2018 bignerdranch. All rights reserved.
//


import UIKit
import AVFoundation

class NoteViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var recordButton: UIButton!

    var audioSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    var numberOfRecords = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        audioSession = AVAudioSession.sharedInstance()
        audioSession.requestRecordPermission { (permissionGranted) in
            if !permissionGranted {
                print("ERROR")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    @IBAction func recordButton(_ sender: Any?) {
        numberOfRecords += 1
        let filename = getDirectory().appendingPathComponent("\(numberOfRecords).m4a")
        let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 12000, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
        do {
            audioRecorder = try AVAudioRecorder(url: filename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.deleteRecording()
            recordButton.setTitle("recording", for: .normal)
            audioRecorder?.record()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.audioRecorder?.stop()
                self.recordButton.setTitle("done", for: .normal)
                do {
                    self.audioPlayer = try AVAudioPlayer(contentsOf: filename)
                    self.audioPlayer?.play()
                    if let tuple = self.loadAudioSignal(audioURL: filename) {
                        // must be var due to mutability arrays in C
                    }
                } catch {

                }
            }
        } catch {
        }
    }

    func loadAudioSignal(audioURL: URL) -> (signal: [Float], rate: Double, frameCount: Int)?
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
