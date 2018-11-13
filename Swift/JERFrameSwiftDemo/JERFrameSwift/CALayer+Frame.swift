//
//  CALayer+Frame.swift
//  JERFrameSwift
//
//  Created by super on 2018/6/19.
//  Copyright © 2018 Jeremy. All rights reserved.
//

import Foundation
import UIKit

extension CALayer {
    var origin: CGPoint {
        get {
            return self.frame.origin
        }
        set(newValue) {
            var frame = self.frame
            frame.origin = newValue
            self.frame = frame
        }
    }
    
    var size: CGSize{
        get {
            return self.frame.size
        }
        set(newValue) {
            var frame = self.frame
            frame.size = newValue
            self.frame = frame
        }
    }
    
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
            return self.frame.minX
            //            return self.origin.x
        }
        set(newValue) {
            self.origin = CGPoint(x: newValue, y: self.top)
        }
    }
    
    var top: CGFloat {
        get {
            return self.frame.minY
            //            return self.origin.y
        }
        set(newValue) {
            self.origin = CGPoint(x: self.left, y: newValue)
        }
    }
    
    var right: CGFloat {
        get {
            return self.frame.maxX
            //            return self.left + self.width
        }
        set(newValue) {
            self.origin = CGPoint(x: newValue - self.width, y: self.top)
        }
    }
    
    var bottom: CGFloat {
        get {
            return self.frame.maxY
            //            return self.top + self.height
        }
        set(newValue) {
            self.origin = CGPoint(x: self.left, y: newValue - self.height)
        }
    }
    
    var center: CGPoint {
        get {
            return CGPoint(x:self.frame.midX, y:self.frame.midY)
        }
        set(newValue){
            var frame = self.frame
            frame.origin.x = newValue.x - self.width / 2;
            frame.origin.y = newValue.y - self.height / 2;
            self.frame = frame
        }
    }
    
    var centerX: CGFloat {
        get {
            return self.frame.midX
            //            return self.left + self.width / 2
        }
        set(newValue) {
            self.origin = CGPoint(x: newValue - self.width / 2, y: self.top)
        }
    }
    
    var centerY: CGFloat {
        get {
            return self.frame.midY
            //            return self.bottom + self.height / 2
        }
        set(newValue) {
            self.origin = CGPoint(x: self.left, y: newValue - self.height / 2)
        }
    }
}
