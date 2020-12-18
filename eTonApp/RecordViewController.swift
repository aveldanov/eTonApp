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
    
    
    func startRecording() {
        
        if isAudioRecordingGranted{
            recordingSession = AVAudioSession.sharedInstance()
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            do {
                audioRecorder = try AVAudioRecorder(url: getFileUrl(), settings: settings)
                audioRecorder.delegate = self
                audioRecorder.prepareToRecord()
                
            } catch {
                // failed
            }
            
        }else{
            print("Recording is not permitted")
        }
        
        
    }
    
    
    @IBAction func recordButtonTapped(_ sender: UIButton) {
        if(isRecording)
        {
            finishAudioRecording(success: true)
            recordButtonLabel.setTitle("Record", for: .normal)
            playButtonLabel.isEnabled = true
            isRecording = false
        }
        else
        {
            startRecording()
            
            audioRecorder.record()
            
            recordButtonLabel.setTitle("Stop", for: .normal)
            playButtonLabel.isEnabled = false
            isRecording = true
        }
        
        
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        
        if(isPlaying)
        {
            audioPlayer.stop()
            recordButtonLabel.isEnabled = true
            playButtonLabel.setTitle("Play", for: .normal)
            isPlaying = false
        }
        else
        {
            if FileManager.default.fileExists(atPath: getFileUrl().path)
            {
                recordButtonLabel.isEnabled = false
                playButtonLabel.setTitle("pause", for: .normal)
                prepare_play()
                audioPlayer.play()
                isPlaying = true
            }
            else
            {
                display_alert(msg_title: "Error", msg_desc: "Audio file is missing.", action_title: "OK")
            }
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
    
    
    
    
    
    
    func finishAudioRecording(success: Bool)
    {
        if success
        {
            audioRecorder.stop()
            audioRecorder = nil
            print("recorded successfully.")
        }
        else
        {
            display_alert(msg_title: "Error", msg_desc: "Recording failed.", action_title: "OK")
        }
    }
    
    
}


extension RecordViewController{
    //Check Permission and get file url
    
    
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
}


extension RecordViewController{
    
    func display_alert(msg_title : String , msg_desc : String ,action_title : String)
    {
        let ac = UIAlertController(title: msg_title, message: msg_desc, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: action_title, style: .default)
        {
            (result : UIAlertAction) -> Void in
            _ = self.navigationController?.popViewController(animated: true)
        })
        present(ac, animated: true)
    }
}
