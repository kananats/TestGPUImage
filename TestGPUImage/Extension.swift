//
//  Extension.swift
//  TestGPUImage
//
//  Created by s.kananat on 2018/11/01.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import Foundation
import UIKit
import GPUImage

extension ImageOrientation {
    static func from(deviceOrientation: UIDeviceOrientation) -> ImageOrientation? {
        switch deviceOrientation {
        case .portrait:             return .portrait
        case .portraitUpsideDown:   return .portraitUpsideDown
        case .landscapeLeft:        return .landscapeLeft
        case .landscapeRight:       return .landscapeRight
        default: return nil
        }
    }
    
    static func from(interfaceOrientation: UIInterfaceOrientation) -> ImageOrientation? {
        switch interfaceOrientation {
        case .portrait:             return .portrait
        case .portraitUpsideDown:   return .portraitUpsideDown
        case .landscapeLeft:        return .landscapeLeft
        case .landscapeRight:       return .landscapeRight
        default: return nil
        }
    }
}
