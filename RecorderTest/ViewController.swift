//
//  ViewController.swift
//  RecorderTest
//
//  Created by kuama on 30/05/22.
//

import AVFoundation
import UIKit
// https://gist.github.com/vikaskore/e5d9fc91feac455d6b4778b3d768a6e8

class ViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    @IBOutlet var recordBtn: UIButton!
    @IBOutlet var playBtn: UIButton!

    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        // setup Recorder
        setupView()
    }

    func setupView() {
        recordingSession = AVAudioSession.sharedInstance()

        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.loadRecordingUI()
                    } else {
                        print("failed to record")
                    }
                }
            }
        } catch {
            print("failed to record")
        }
    }

    func loadRecordingUI() {
        recordBtn.isEnabled = true
        playBtn.isEnabled = false
        recordBtn.setTitle("Tap to Record", for: .normal)
    }

    @IBAction func recordButtonTapped(_: Any) {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }

    func startRecording() {
        let audioFilename = getFileURL()

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()

            recordBtn.setTitle("Tap to Stop", for: .normal)
            playBtn.isEnabled = false
        } catch {
            finishRecording(success: false)
        }
    }

    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil

        if success {
            recordBtn.setTitle("Tap to Re-record", for: .normal)
        } else {
            recordBtn.setTitle("Tap to Record", for: .normal)
            // recording failed :(
        }

        playBtn.isEnabled = true
        recordBtn.isEnabled = true
    }

    @IBAction func playAudioButtonTapped(_ sender: UIButton) {
        if sender.titleLabel?.text == "Play" {
            recordBtn.isEnabled = false
            sender.setTitle("Stop", for: .normal)
            preparePlayer()
            audioPlayer.play()
        } else {
            audioPlayer.stop()
            sender.setTitle("Play", for: .normal)
        }
    }

    func preparePlayer() {
        var error: NSError?
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: getFileURL() as URL)
        } catch let error1 as NSError {
            error = error1
            audioPlayer = nil
        }

        if let err = error {
            print("AVAudioPlayer error: \(err.localizedDescription)")
        } else {
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            audioPlayer.volume = 1.0
        }
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    func getFileURL() -> URL {
        let path = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        return path as URL
    }

    // MARK: Delegates

    func audioRecorderDidFinishRecording(_: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }

    func audioRecorderEncodeErrorDidOccur(_: AVAudioRecorder, error: Error?) {
        print("Error while recording audio \(error!.localizedDescription)")
    }

    func audioPlayerDidFinishPlaying(_: AVAudioPlayer, successfully _: Bool) {
        recordBtn.isEnabled = true
        playBtn.setTitle("Play", for: .normal)
    }

    func audioPlayerDecodeErrorDidOccur(_: AVAudioPlayer, error: Error?) {
        print("Error while playing audio \(error!.localizedDescription)")
    }

    // MARK: To upload video on server

    func uploadAudioToServer() {
        /* Alamofire.upload(
         multipartFormData: { multipartFormData in
         multipartFormData.append(getFileURL(), withName: "audio.m4a")
         },
         to: "https://yourServerLink",
         encodingCompletion: { encodingResult in
         switch encodingResult {
         case .success(let upload, _, _):
         upload.responseJSON { response in
         Print(response)
         }
         case .failure(let encodingError):
         print(encodingError)
         }
         }) */
    }
}
