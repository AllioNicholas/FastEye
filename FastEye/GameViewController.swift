//
//  GameViewController.swift
//  FastEye
//
//  Created by Nicholas Allio on 08/10/15.
//  Copyright © 2015 Nicholas Allio. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import Darwin
import CoreGraphics

class GameViewController: UIViewController {
    
    enum GameMode {
        case UpCount
        case DownCount
        case Random
    }
    
    var display: Int!
    var gameMode: GameMode!
    var takenRand = [0]
    var timer: NSTimer = NSTimer()
    var elapsedTime = 0.0
    var correctCount = 0
    var highscore = DBL_MAX
    
    var correctPlayer: AVAudioPlayer!
    var wrongPlayer: AVAudioPlayer!
   
    @IBOutlet weak var highScoreLabel: UILabel!
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var cronoLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var prog2: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var filePath = NSBundle.mainBundle().pathForResource("correct", ofType: "mp3")
        
        correctPlayer = try! AVAudioPlayer(contentsOfURL: NSURL.fileURLWithPath(filePath!))
        
        filePath = NSBundle.mainBundle().pathForResource("wrong", ofType: "mp3")
        
        wrongPlayer = try! AVAudioPlayer(contentsOfURL: NSURL.fileURLWithPath(filePath!))
        
    }
    
    override func viewDidAppear(animated: Bool) {
        //Start chrono with 0.01 precision
        timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: Selector("updateTime"), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        progressBar.progress = 0.0
        prog2.progress = 0.0
        displayLabel.text = "\(display)"
        cronoLabel.text = "0.0"
        var taken = [0]
        for idx in 1...25 {
            let but = self.view.viewWithTag(idx) as! UIButton
            var lab = Int(rand() % 26)
            while taken.contains(lab) {
                lab = Int(rand() % 26)
            }
            taken.append(lab)
            but.setTitle(String(lab), forState: UIControlState.Normal)
        }
        
        //load high score
        switch gameMode! {
        case .UpCount:
            if let hs = NSUserDefaults.standardUserDefaults().valueForKey("highscore_up") {
                highscore = Double(hs as! NSNumber)
                highScoreLabel.text = NSString(format: "High score: %.2f", highscore) as String
            } else {
                highScoreLabel.text = "High score: 0.0"
            }
        case .DownCount:
            if let hs = NSUserDefaults.standardUserDefaults().valueForKey("highscore_down") {
                highscore = Double(hs as! NSNumber)
                highScoreLabel.text = NSString(format: "High score: %.2f", highscore) as String
            } else {
                highScoreLabel.text = "High score: 0.0"
            }
        case .Random:
            if let hs = NSUserDefaults.standardUserDefaults().valueForKey("highscore_rand") {
                highscore = Double(hs as! NSNumber)
                highScoreLabel.text = NSString(format: "High score: %.2f", highscore) as String
                takenRand.append(display)
            } else {
                highScoreLabel.text = "High score: 0.0"
            }
        }
        
        
    }
    
    func updateTime() {
        elapsedTime += 0.01
        cronoLabel.text = NSString(format: "%.2f", elapsedTime) as String
    }
    
    @IBAction func buttonPressed(sender: UIButton) {
        correctPlayer.stop()
        wrongPlayer.stop()
        if sender.titleLabel?.text == String(display) {
            correctPlayer.play()
            switch gameMode! {
            case .UpCount:
                correctCount++
                display!++
                if display == 26 {
                    //end of the game
                    timer.invalidate()
                    displayLabel.text = ""
                    progressBar.setProgress(1.0, animated: true)
                    prog2.setProgress(1.0, animated: true)
                    gameEnded(.UpCount)
                } else {
                    progressBar.setProgress(Float(correctCount)/25.0, animated: true)
                    prog2.setProgress(Float(correctCount)/25.0, animated: true)
                    displayLabel.text = "\(display)"
                }
            case .DownCount:
                correctCount++
                display!--
                if display == 0 {
                    //end of the game
                    timer.invalidate()
                    displayLabel.text = ""
                    progressBar.setProgress(1.0, animated: true)
                    prog2.setProgress(1.0, animated: true)
                    gameEnded(.DownCount)
                } else {
                    progressBar.setProgress(Float(correctCount)/25.0, animated: true)
                    prog2.setProgress(Float(correctCount)/25.0, animated: true)
                    displayLabel.text = "\(display)"
                }
            case .Random:
                correctCount++
                var num = rand() % 26
                while takenRand.contains(Int(num)) {
                    num = rand() % 26
                }
                takenRand.append(Int(num))
                display = Int(num)
                if takenRand.count == 26 {
                    //end of the game
                    timer.invalidate()
                    displayLabel.text = ""
                    progressBar.setProgress(1.0, animated: true)
                    prog2.setProgress(1.0, animated: true)
                    gameEnded(.Random)
                } else {
                    progressBar.setProgress(Float(correctCount)/25.0, animated: true)
                    prog2.setProgress(Float(correctCount)/25.0, animated: true)
                    displayLabel.text = "\(display)"
                }
            }
        } else {
            wrongPlayer.play()
            correctCount = 0
            progressBar.setProgress(0.0, animated: true)
            prog2.setProgress(0.0, animated: true)
            switch gameMode! {
            case .UpCount:
                display! = 1
            case .DownCount:
                display! = 25
            case .Random:
                takenRand = [0]
                var num = rand() % 26
                while takenRand.contains(Int(num)) {
                    num = rand() % 26
                }
                takenRand.append(Int(num))
                display = Int(num)
            }
            displayLabel.text = "\(display)"
        }
    }
    
    func gameEnded(inMode: GameMode) {
        switch inMode {
        case .UpCount:
            if elapsedTime < highscore {
                NSUserDefaults.standardUserDefaults().setValue(elapsedTime, forKey: "highscore_up")
                //TODO: notify new highscore
                highScoreLabel.text = NSString(format: "High score: %.2f", elapsedTime) as String
            }
        case .DownCount:
            if elapsedTime < highscore {
                NSUserDefaults.standardUserDefaults().setValue(elapsedTime, forKey: "highscore_down")
                //TODO: notify new highscore
                highScoreLabel.text = NSString(format: "High score: %.2f", elapsedTime) as String
            }
        case .Random:
            if elapsedTime < highscore {
                NSUserDefaults.standardUserDefaults().setValue(elapsedTime, forKey: "highscore_rand")
                //TODO: notify new highscore
                highScoreLabel.text = NSString(format: "High score: %.2f", elapsedTime) as String
            }
        }
        
    }
    
    @IBAction func backButton(sender: CustomButton) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
}