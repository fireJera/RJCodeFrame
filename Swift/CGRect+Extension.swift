
//
//  CGRect+Extension.swift
//  JERFrameSwift
//
//  Created by super on 17/12/2017.
//  Copyright © 2017 Jeremy. All rights reserved.
//

import Foundation
import UIKit

extension CGRect {
    var width: CGFloat {
        get {
            return self.size.width;
        }
        set(newValue) {
            self.size = CGSize(width: newValue, height: self.height)
        }
    }
    
    var height: CGFloat {
        get {
            return self.size.height;
        }
        set(newValue) {
            self.size = CGSize(width: self.width, height: newValue)
        }
    }
    
    var left: CGFloat {
        get {
            return self.minX
//            return self.origin.x
        }
        set(newValue) {
            self.origin = CGPoint(x: newValue, y: self.top)
        }
    }
    
    var top: CGFloat {
        get {
            return self.minY
//            return self.origin.y
        }
        set(newValue) {
            self.origin = CGPoint(x: self.left, y: newValue)
        }
    }
    
    var right: CGFloat {
        get {
            return self.maxX
//            return self.left + self.width
        }
        set(newValue) {
            self.origin = CGPoint(x: newValue - self.width, y: self.top)
        }
    }
    
    var bottom: CGFloat {
        get {
            return self.maxY
//            return self.top + self.height
        }
        set(newValue) {
            self.origin = CGPoint(x: self.left, y: newValue - self.height)
        }
    }
    
    var centerX: CGFloat {
        get {
            return self.midX
//            return self.left + self.width / 2
        }
        set(newValue) {
            self.origin = CGPoint(x: newValue - self.width / 2, y: self.top)
        }
    }
    
    var centerY: CGFloat {
        get {
            return self.midY
//            return self.bottom + self.height / 2
        }
        set(newValue) {
            self.origin = CGPoint(x: self.left, y: newValue - self.height / 2)
        }
    }
}
