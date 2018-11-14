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
import ReactiveSwift
import Result

public extension Camera {
    
    /// Shorthand for executing `stopCapture()` then `removeAllTargets` on `sharedImageProcessingContext`
    func stopThenRemoveAllTargets() {
        sharedImageProcessingContext.runOperationSynchronously{
            self.stopCapture()
            self.removeAllTargets()
        }
    }
}
