//
//  MovieMaker.Filter.swift
//  TestGPUImage
//
//  Created by s.kananat on 2018/11/07.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import GPUImage

extension MovieMaker {
    
    /// `Filter` to be applied with live `Camera`
    public final class Filter {
        let name: String
        let operation: ImageProcessingOperation
        
        fileprivate init(name: String, operation: ImageProcessingOperation) {
            self.name = name
            self.operation = operation
        }
    }
}

// Public
extension MovieMaker.Filter {
    /// Array containing all `Filter`
    static let all: [MovieMaker.Filter] = [.off, .toon, .natural]
    
    /// Off `Filter`
    static let off = MovieMaker.Filter(name: "Filter Off", operation: GammaAdjustment())
    
    /// Toon `Filter`
    static let toon = MovieMaker.Filter(name: "Toon Filter", operation: SmoothToonFilter())
    
    /// Natural `Filter`
    static let natural = MovieMaker.Filter(name: "Natural", operation: SaturationAdjustment())
}
