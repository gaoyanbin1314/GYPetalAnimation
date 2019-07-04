//
//  ViewController.swift
//  GYPetalAnimation
//
//  Created by GY on 2019/7/4.
//  Copyright © 2019 GY. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let pertalView = GYPetalAnimateView(frame: CGRect.zero)
    var showAnimation = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(pertalView)
        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pertalView.frame = self.view.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        pertalView.animate()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if showAnimation {
            pertalView.stopAnimate()
        } else {
            pertalView.animate()
        }
        showAnimation = !showAnimation
    }

}

