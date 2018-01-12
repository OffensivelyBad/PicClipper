//
//  UIImageViewExtensions.swift
//  PicClipper
//
//  Created by Shawn Roller on 1/12/18.
//  Copyright © 2018 Shawn Roller. All rights reserved.
//
/*
 Copyright © 2017 Apple Inc.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 Abstract:
 Extension on UIImageView to compute a clipping rect for an image displayed using the scale aspect fit content mode.
 */

import UIKit

extension UIImageView {
    
    var contentClippingRect: CGRect {
        guard let image = self.image, self.contentMode == .scaleAspectFit else { return self.bounds }
        
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        
        guard imageWidth > 0 && imageHeight > 0 else { return self.bounds }
        
        let scale: CGFloat
        if imageWidth > imageHeight {
            scale = self.bounds.size.width / imageWidth
        }
        else {
            scale = self.bounds.size.height / imageHeight
        }
        
        let clippingSize = CGSize(width: imageWidth * scale, height: imageHeight * scale)
        let xPosition = (self.bounds.size.width - clippingSize.width) / 2
        let yPosition = (self.bounds.size.height - clippingSize.height) / 2
        
        return CGRect(origin: CGPoint(x: xPosition, y: yPosition), size: clippingSize)
        
    }
    
}
