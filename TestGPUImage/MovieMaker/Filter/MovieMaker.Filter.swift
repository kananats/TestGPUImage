//
//  MovieMaker.Filter.swift
//  TestGPUImage
//
//  Created by s.kananat on 2018/11/07.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import UIKit
import GPUImage

extension MovieMaker {
    
    /// `Filter` to be applied with live `Camera`
    public final class Filter {
        let name: String
        let operation: ImageProcessingOperation
        let preview: UIImage
        
        /// Create a `Filter` with corresponding `ImageProcessingOperation` and `UIImage`
        private init<T: ImageProcessingOperation>(name: String, operation: T, preview: UIImage) {
            self.name = name
            self.operation = operation
            self.preview = preview
        }
    }
}

// Public
public extension MovieMaker.Filter {
    
    /// Array containing all `Filter`
    static let all: [MovieMaker.Filter] = [.off, .natural, .coolcam, .retro, .fairy, .pretty, .style, .baby, .marron, .purple]
    
    /// Off `Filter`
    static let off = MovieMaker.Filter(name: "Filter Off")
    
    /// Natural `Filter`
    static let natural = MovieMaker.Filter(name: "Natural", image: UIImage(named: "natural.png")!)
    
    /// Coolcam `Filter`
    static let coolcam = MovieMaker.Filter(name: "CoolCam", image: UIImage(named: "coolcam.png")!)
    
    /// Retro `Filter`
    static let retro = MovieMaker.Filter(name: "Retro", image: UIImage(named: "retro.png")!)
    
    /// Fairy `Filter`
    static let fairy = MovieMaker.Filter(name: "Fairy", image: UIImage(named: "fairy.png")!)
    
    /// Pretty `Filter`
    static let pretty = MovieMaker.Filter(name: "Pretty", image: UIImage(named: "pretty.png")!)
    
    /// Style `Filter`
    static let style = MovieMaker.Filter(name: "Style", image: UIImage(named: "style.png")!)
    
    /// Baby `Filter`
    static let baby = MovieMaker.Filter(name: "Baby", image: UIImage(named: "baby.png")!)
    
    /// Marron `Filter`
    static let marron = MovieMaker.Filter(name: "Marron", image: UIImage(named: "marron.png")!)
    
    /// Purple `Filter`
    static let purple = MovieMaker.Filter(name: "Purple", image: UIImage(named: "purple.png")!)
}

// Private
private extension MovieMaker.Filter {
    
    /// Default `Filter` preview image
    static let preview = UIImage(named: "preview.png")!
    
    /// Create a `Filter` that performs no-operation
    convenience init(name: String) {
        let operation = MovieMaker.Filter.createNoOperationFilter()
        let preview = MovieMaker.Filter.preview.filterWithOperation(MovieMaker.Filter.createNoOperationFilter())
        
        self.init(name: name, operation: operation, preview: preview)
    }
    
    /// Create a `Filter` with associated `UIImage` used for image processing.
    convenience init(name: String, image: UIImage) {
        let operation = MovieMaker.Filter.createLookupFilter(image: image)
        let preview = MovieMaker.Filter.preview.filterWithOperation(MovieMaker.Filter.createLookupFilter(image: image))
        
        self.init(name: name, operation: operation, preview: preview)
    }
    
    /// Create no-operation `Filter`
    static func createNoOperationFilter() -> GammaAdjustment { return GammaAdjustment() }
    
    /// Create Lookup `Filter` from `UIImage`
    static func createLookupFilter(image: UIImage) -> OperationGroup {
        let operation = OperationGroup()
        
        let lookup = LookupFilter()
        lookup.lookupImage = PictureInput(image: image)
        lookup.intensity = 0.88
        
        let blur = GaussianBlur()
        blur.blurRadiusInPixels = 0.2
        
        operation.configureGroup { input, output in
            input --> lookup --> blur --> output
        }
        
        return operation
    }
}
