//
//  AudioRecordingManager.swift
//  Mooday
//
//  Created by Anas Ech-Cherfi on 20/07/2025.
//

import Foundation
import AVFoundation
import Combine

class AudioRecordingManager: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var recordingTime: TimeInterval = 0
    @Published var hasPermission = false
    
    private var audioRecorder: AVAudioRecorder?
    private var recordingTimer: Timer?
    private var recordingURL: URL?
    
    override init() {
        super.init()
        // Don't request permission immediately to avoid crash
        // Will request when user actually tries to record
    }
    
    private func requestPermission() {
        if #available(iOS 17.0, *) {
            AVAudioApplication.requestRecordPermission { granted in
                DispatchQueue.main.async {
                    self.hasPermission = granted
                    if granted {
                        // Try to start recording again if permission was granted
                        if let url = self.actuallyStartRecording() {
                            self.recordingURL = url
                        }
                    }
                }
            }
        } else {
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async {
                    self.hasPermission = granted
                    if granted {
                        // Try to start recording again if permission was granted
                        if let url = self.actuallyStartRecording() {
                            self.recordingURL = url
                        }
                    }
                }
            }
        }
    }
    
    func startRecording() -> URL? {
        // Request permission if we don't have it yet
        if !hasPermission {
            requestPermission()
            // Return nil for now, user needs to try again after granting permission
            return nil
        }
        
        return actuallyStartRecording()
    }
    
    private func actuallyStartRecording() -> URL? {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.record, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
            return nil
        }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentsPath.appendingPathComponent("recording_\(Date().timeIntervalSince1970).m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            
            isRecording = true
            recordingTime = 0
            recordingURL = audioFilename
            
            startTimer()
            
            return audioFilename
        } catch {
            print("Could not start recording: \(error)")
            return nil
        }
    }
    
    func stopRecording() -> URL? {
        audioRecorder?.stop()
        isRecording = false
        stopTimer()
        
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Could not stop audio session: \(error)")
        }
        
        return recordingURL
    }
    
    private func startTimer() {
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.recordingTime += 0.1
        }
    }
    
    private func stopTimer() {
        recordingTimer?.invalidate()
        recordingTimer = nil
    }
}

extension AudioRecordingManager: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            print("Recording failed")
        }
    }
} 