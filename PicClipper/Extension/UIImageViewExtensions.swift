//
//  UIImageViewExtensions.swift
//  PicClipper
//
//  Created by Shawn Roller on 1/12/18.
//  Copyright © 2018 Shawn Roller. All rights reserved.
//
/*
 Copyright © 2017 Apple Inc.
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
