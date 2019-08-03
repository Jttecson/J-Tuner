//
//  ViewController.swift
//  test gauge
//
//  Created by Joel Tecson on 2019-06-20.
//  Copyright © 2019 bignerdranch. All rights reserved.
//
import UIKit
import AVFoundation

class TunerViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var tuneButton: UIButton!

    var audioSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder?
    var recorder: Recorder?
    var audioPlayer: AVAudioPlayer?
    var numberOfRecords = 0
    var gaugeView: GaugeView?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
        audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord)
        } catch {
            print("ascascdasc")
        }
        audioSession.requestRecordPermission { (permissionGranted) in
            if !permissionGranted {
                print("ERROR")
            }
        }

        let screenRect = UIScreen.main.bounds
        let screenWidth = screenRect.size.width
        let screenHeight = screenRect.size.height

        let test = GaugeView(frame: CGRect(x: screenWidth * 0.1 , y: screenHeight * 0.1, width: screenWidth * 0.8, height: screenHeight * 0.8))
        gaugeView = test
        test.backgroundColor = .clear
        view.addSubview(test)
        view.bringSubviewToFront(test)
        view.backgroundColor = Utilities.backgroundColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            test.value = 33
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            UIView.animate(withDuration: 1) {
                test.value = 66
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            UIView.animate(withDuration: 1) {
                test.value = 100
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        recorder = Recorder(audioSession: audioSession)
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        recorder?.meterView = MeterView(frame: CGRect(origin: CGPoint(x: screenWidth*0.3, y: screenHeight*0.4), size: CGSize(width: screenWidth*0.4, height: screenHeight*0.2)))
        recorder?.gaugeView = gaugeView
        view.addSubview(recorder!.meterView!)
        recorder?.startRecording()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    func tuneButton(_ sender: Any?) {
        numberOfRecords += 1
        if let recorder = recorder { recorder.startRecording() }
    }

    func loadAudioSignal(audioURL: URL) -> (signal: [Float], rate: Double, frameCount: Int)? {
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
