//
//  CDImage.swift
//  Homework30MusicPlayerApp
//
//  Created by 黃柏嘉 on 2021/12/3.
//

import UIKit

class CDImage: UIImageView {

    func rotate(){
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.toValue = CGFloat.pi*2
        animation.duration = 5
        animation.repeatCount = .greatestFiniteMagnitude
        layer.add(animation, forKey: nil)
    }
}
