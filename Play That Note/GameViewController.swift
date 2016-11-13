//
//  GameViewController.swift
//  Play That Note
//
//  Created by Paul Crompton on 11/7/16.
//  Copyright © 2016 Paul Crompton. All rights reserved.
//

import UIKit
import Pitchy
import Beethoven
import WebKit
import AVFoundation

class GameViewController: UIViewController, PitchEngineDelegate, WKNavigationDelegate {

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    
    var webView: WKWebView?
    let jsDrawStaffWithPitch = "drawStaffWithPitch"
    
    var dimensions: String {
        get {
            let dimParams = "\(Int(containerView.frame.width)), \(Int(containerView.frame.height))"
            print(dimParams)
            return dimParams
        }
    }
    
    var pitchEngine: PitchEngine?
    var noteToPlay: Note? {
        didSet {
            webView?.reload()
        }
    }
    var lowest = try! Note(letter: .C, octave: 4)
    var highest = try! Note(letter: .A, octave: 5)
    var consecutivePitches = [Pitch]()
    let consecutiveMax = 3
    let bufferSize: AVAudioFrameCount = 4096
    let estimationStragegy = EstimationStrategy.yin
    let audioURL: URL? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let config = Config(bufferSize: bufferSize, estimationStrategy: estimationStragegy)
        pitchEngine = PitchEngine(config: config, delegate: self)
        pitchEngine?.levelThreshold = -30.0
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        webView = WKWebView(frame: CGRect(x: 0, y: 0, width: containerView.frame.width, height: containerView.frame.height))
        webView?.configuration.ignoresViewportScaleLimits = true
        if let webView = webView {
            webView.navigationDelegate = self
            webView.allowsBackForwardNavigationGestures = false
            webView.isUserInteractionEnabled = true
            containerView.addSubview(webView)
            
            if let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "vexFlow") {
                let request = URLRequest(url: url)
                noteToPlay = try! Note(letter: .C, octave: 4)
                webView.load(request)
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let pitch = noteToPlay?.string {
            let clef = "treble"
            webView.evaluateJavaScript("\(jsDrawStaffWithPitch)(\"\(pitch)\", \"\(clef)\", \(dimensions))")
        }
    }
    
    @IBAction func StartButton(_ sender: UIButton) {
        if !pitchEngine!.active {
            pitchEngine?.start()
            sender.setTitle("Stop", for: .normal)
            print("Pitch Engine Started")
            noteToPlay = getNoteToPlayInRange(low: lowest, high: highest)
        } else {
            pitchEngine?.stop()
            sender.setTitle("Start", for: .normal)
            print("Pitch Engine Stopped")
        }
    }
    
    func getNoteToPlayInRange(low: Note, high: Note) -> Note {
        let range = high.index-low.index
        let index = Int(arc4random_uniform(UInt32(range+1))) + low.index
        return try! Note(index: index)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pitchEngine?.stop()
    }
    
    func checkIfIsPitch(pitches: [Pitch]) -> Bool {
        for i in 1..<pitches.count {
            if pitches[i].note.index != pitches[i-1].note.index {
                return false
            }
        }
        return true
    }
    
    
    // Mark PitchEngineDelegate functions
    public func pitchEngineDidReceivePitch(_ pitchEngine: PitchEngine, pitch: Pitch) {
        let note = pitch.note
        print(note.string)
        if consecutivePitches.count < consecutiveMax {
            consecutivePitches.append(pitch)
        } else {
            consecutivePitches.remove(at: 0)
            consecutivePitches.append(pitch)
            let isPitch = checkIfIsPitch(pitches: consecutivePitches)
            if isPitch {
                pitchEngine.stop()
                consecutivePitches.removeAll()
                let alertController = UIAlertController(title: note.string, message: nil, preferredStyle: .alert)
                let action = UIAlertAction(title: "Next", style: .default) {
                    (action) in
                    self.pitchEngine?.start()
                    self.noteToPlay = self.getNoteToPlayInRange(low: self.lowest, high: self.highest)
                }
                alertController.addAction(action)
                print(pitch.note.string, pitch.note.index)
                if note.index == noteToPlay!.index {
                    alertController.message = "Congrates, you played \(note.string)"
                } else {
                    alertController.message = "Sorry, that was not \(noteToPlay!.string)"
                    let action = UIAlertAction(title: "Try Again", style: .default) {
                        (action) in
                        self.pitchEngine?.start()
                    }
                    alertController.addAction(action)
                }
                
                present(alertController, animated: true)
            }
        }
    }
    
    public func pitchEngineDidReceiveError(_ pitchEngine: PitchEngine, error: Error) {
        print(Error.self)
    }
    
    public func pitchEngineWentBelowLevelThreshold(_ pitchEngine: PitchEngine) {
        //print("PitchEngine went below threshhold")
        return
    }

}

