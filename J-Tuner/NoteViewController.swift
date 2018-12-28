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

    @IBOutlet weak var tuneButton: UIButton!

//    var parentViewController = 
    var audioSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder?
    var recorder: Recorder?
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

    override func viewDidAppear(_ animated: Bool) {
        recorder = Recorder(samplePeriod: 1, recordingsPerSample: 1, audioSession: audioSession)
        if let parent = parent
        {
            for child in parent.childViewControllers
            {
                if child is MeterViewController
                {
                    recorder?.meterViewController = child as? MeterViewController
                    break
                }
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

    @IBAction func tuneButton(_ sender: Any?) {
        numberOfRecords += 1
        if let recorder = recorder
        {
            recorder.startRecording()
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
