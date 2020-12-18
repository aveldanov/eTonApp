//
//  ViewController.swift
//  eTonApp
//
//  Created by Veldanov, Anton on 12/17/20.
//

import UIKit
import AVFoundation

class RecordViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {

    
    
    @IBOutlet weak var recordButtonLabel: UIButton!
    
    @IBOutlet weak var playButtonLabel: UIButton!
    
//    var recordButtonLabel: UIButton!
//    var playButtonLabel: UIButton!

    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var recordingSession: AVAudioSession!
    var isAudioRecordingGranted: Bool!
    var isRecording = false
    var isPlaying = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkRecordPermission()
    }
    
    func checkRecordPermission(){
        recordingSession = AVAudioSession.sharedInstance()

        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        isAudioRecordingGranted = true
                    } else {
                        isAudioRecordingGranted = false
                    }
                }
            }
        } catch {
            // failed to record!
        }
        
        
    }
    
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        print(paths)
        return paths[0]
    }
    
    func getFileUrl() -> URL
    {
        let filename = "recording.m4a"
        let filePath = getDocumentsDirectory().appendingPathComponent(filename)
        return filePath
    }
    
    
//    func loadRecordingUI() {
//        recordButtonLabel = UIButton(frame: CGRect(x: 64, y: 64, width: 300, height: 64))
//        recordButtonLabel.backgroundColor = .blue
//        recordButtonLabel.setTitle("Tap to Record", for: .normal)
//        recordButtonLabel.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
//        recordButtonLabel.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
//        view.addSubview(recordButtonLabel)
//    }
    
    
    
    
//    func loadPlayUI(){
//        playButtonLabel = UIButton(frame: CGRect(x: 64, y: 264, width: 300, height: 64))
//        playButtonLabel.backgroundColor = .red
//        playButtonLabel.setTitle("Tap to Play", for: .normal)
//        playButtonLabel.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
//        playButtonLabel.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
//        view.addSubview(playButtonLabel)
//
//
//    }
//
    
    
 
    
    
    func startRecording() {
        
        if isAudioRecordingGranted{
            recordingSession = AVAudioSession.sharedInstance()

            
            let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")

            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            do {
                audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.record()

                recordButtonLabel.setTitle("Tap to Stop", for: .normal)
            } catch {
                finishRecording(success: false)
            }
            
        }else{
            print("Recording is not permitted")
        }
        
 
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil

        if success {
            recordButtonLabel.setTitle("Tap to Re-record", for: .normal)
        } else {
            recordButtonLabel.setTitle("Tap to Record", for: .normal)
            // recording failed :(
        }
    }
    
    @objc func recordTapped() {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    
    

    
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    
    
}



extension RecordViewController{
    
    func prepare_play()
    {
        do
        {
            audioPlayer = try AVAudioPlayer(contentsOf: getFileUrl())
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
        }
        catch{
            print("Error")
        }
    }

    
    
    
    @objc func playTapped(){
        
        if FileManager.default.fileExists(atPath: getFileUrl().path)
                {
        prepare_play()
                    audioPlayer.play()
        }else{
            print("NO FILE")
        }
    }
    
    
}
