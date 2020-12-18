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
    
    
    func prepareToRecord() {
        
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
    
    //MARK: - Record
    
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
            prepareToRecord()
            
            audioRecorder.record()
            
            recordButtonLabel.setTitle("Stop", for: .normal)
            playButtonLabel.isEnabled = false
            isRecording = true
        }
        
        
    }
    
    //MARK: - Play
    
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
                reverse()
                recordButtonLabel.isEnabled = false
                playButtonLabel.setTitle("pause", for: .normal)
                prepareToPlay()
                audioPlayer.play()
                isPlaying = true
            }
            else
            {
                display_alert(msg_title: "Error", msg_desc: "Audio file is missing.", action_title: "OK")
            }
        }
    }
    
    
    
    func reverse(){
        
        func getDocumentsDirectory() -> URL {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            print(paths)
            return paths[0]
        }
        
        
        
        var outAudioFile:AudioFileID?
        var pcm = AudioStreamBasicDescription(mSampleRate: 44100.0,
                                              mFormatID: kAudioFormatLinearPCM,
                                              mFormatFlags: kAudioFormatFlagIsBigEndian | kAudioFormatFlagIsSignedInteger,
                                              mBytesPerPacket: 2,
                                              mFramesPerPacket: 1,
                                              mBytesPerFrame: 2,
                                              mChannelsPerFrame: 1,
                                              mBitsPerChannel: 16,
                                              mReserved: 0)

        var theErr = AudioFileCreateWithURL((getDocumentsDirectory() as CFURL?)!,
                                            kAudioFileAIFFType,
                                            &pcm,
                                            .eraseFile,
                                            &outAudioFile)
        if noErr == theErr, let outAudioFile = outAudioFile {
            var inAudioFile:AudioFileID?
            theErr = AudioFileOpenURL(getFileUrl() as CFURL, .readPermission, 0, &inAudioFile)

            if noErr == theErr, let inAudioFile = inAudioFile {

                var fileDataSize:UInt64 = 0
                var thePropertySize:UInt32 = UInt32(MemoryLayout<UInt64>.stride)
                theErr = AudioFileGetProperty(inAudioFile,
                                              kAudioFilePropertyAudioDataByteCount,
                                              &thePropertySize,
                                              &fileDataSize)

                if( noErr == theErr) {
                    let dataSize:Int64 = Int64(fileDataSize)
                    let theData = UnsafeMutableRawPointer.allocate(byteCount: Int(dataSize),
                                                                   alignment: MemoryLayout<UInt8>.alignment)

                    var readPoint:Int64 = Int64(dataSize)
                    var writePoint:Int64 = 0

                    while( readPoint > 0 )
                    {
                        var bytesToRead = UInt32(2)

                        AudioFileReadBytes( inAudioFile, false, readPoint, &bytesToRead, theData)
                        AudioFileWriteBytes( outAudioFile, false, writePoint, &bytesToRead, theData)

                        writePoint += 2
                        readPoint -= 2
                    }

                    theData.deallocate()

                    AudioFileClose(inAudioFile);
                    AudioFileClose(outAudioFile);
                }
            }
        }
        
        
        
        
        
        
    }
    
    
    
}



extension RecordViewController{
    
    func prepareToPlay()
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
    
    
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            audioRecorder.stop()
            audioRecorder = nil
        }
    }
    
    
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if !flag{
            audioPlayer.stop()
            audioPlayer = nil
        }
    }
}



