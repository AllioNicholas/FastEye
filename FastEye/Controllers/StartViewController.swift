//
//  StartViewController.swift
//  FastEye
//
//  Created by Nicholas Allio on 08/10/15.
//  Copyright © 2015 Nicholas Allio. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        weak var weakSelf = self
        GameCenterManager.sharedInstance().authenticateGameCenterUser(successBlockOrViewController: { (success, viewController) in
            if !success, let vc = viewController {
                weakSelf!.present(vc, animated: true, completion: nil)
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "displayHighScores" {
            return
        }
        let vc:GameViewController = segue.destination as! GameViewController
        if segue.identifier == "up" {
            vc.display = 1
            vc.gameMode = GameMode.upCount
        } else if segue.identifier == "down" {
            vc.display = 25
            vc.gameMode = GameMode.downCount
        } else if segue.identifier == "random" {
            var num = Int(arc4random_uniform(26))
            while num == 0 {
                num = Int(arc4random_uniform(26))
            }
            vc.display = Int(num)
            vc.gameMode = GameMode.random
        }
    }
    
    @IBAction func playNavigationSound(_ sender: UIButton) {
        SoundManager.sharedInstance().playNavigationSound()
    }
}

