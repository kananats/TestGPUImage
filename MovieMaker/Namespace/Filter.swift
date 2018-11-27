//
//  Filter.swift
//  MovieMaker
//
//  Created by s.kananat on 2018/11/07.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import UIKit
import GPUImage

// MARK: Main
/// `Filter` to be applied with live `Camera`
public final class Filter {
    
    /// Name of the `Filter`
    let name: String
    
    /// `ImageProcessingOperation` of the `Filter`
    let operation: ImageProcessingOperation
    
    /// Preview `Image`
    let preview: UIImage
    
    /// Creates a `Filter` with corresponding `ImageProcessingOperation` and `UIImage`
    private init<T: ImageProcessingOperation>(name: String, operation: T, preview: UIImage) {
        self.name = name
        self.operation = operation
        self.preview = preview
    }
}

// MARK: Public
public extension Filter {
    
    /// `CGSize` of the `Filter` preview view
    static let previewSize = CGSize(width: 85, height: 60)
    
    /// Array containing all `Filter`
    static let all: [Filter] = [.off, .natural, .coolcam, .retro, .fairy, .pretty, .style, .baby, .marron, .purple]
    
    /// Off `Filter`
    static let off = Filter(name: "Filter Off")
    
    /// Natural `Filter`
    static let natural = Filter(name: "Natural", image: UIImage(named: "natural.png")!)
    
    /// Coolcam `Filter`
    static let coolcam = Filter(name: "CoolCam", image: UIImage(named: "coolcam.png")!)
    
    /// Retro `Filter`
    static let retro = Filter(name: "Retro", image: UIImage(named: "retro.png")!)
    
    /// Fairy `Filter`
    static let fairy = Filter(name: "Fairy", image: UIImage(named: "fairy.png")!)
    
    /// Pretty `Filter`
    static let pretty = Filter(name: "Pretty", image: UIImage(named: "pretty.png")!)
    
    /// Style `Filter`
    static let style = Filter(name: "Style", image: UIImage(named: "style.png")!)
    
    /// Baby `Filter`
    static let baby = Filter(name: "Baby", image: UIImage(named: "baby.png")!)
    
    /// Marron `Filter`
    static let marron = Filter(name: "Marron", image: UIImage(named: "marron.png")!)
    
    /// Purple `Filter`
    static let purple = Filter(name: "Purple", image: UIImage(named: "purple.png")!)
}

// MARK: Private
private extension Filter {
    
    /// Default `Filter` preview `UIImage`
    static let preview = UIImage(named: "preview.png")!
    
    /// Creates no-operation `Filter`
    static func createNoOperationFilter() -> GammaAdjustment { return GammaAdjustment() }
    
    /// Creates lookup `Filter` from `UIImage`
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
    
    /// Creates a `Filter` that performs no-operation
    convenience init(name: String) {
        let operation = Filter.createNoOperationFilter()
        let preview = Filter.preview.filterWithOperation(Filter.createNoOperationFilter())
        
        self.init(name: name, operation: operation, preview: preview)
    }
    
    /// Creates a `Filter` with associated `UIImage` used for image processing.
    convenience init(name: String, image: UIImage) {
        let operation = Filter.createLookupFilter(image: image)
        let preview = Filter.preview.filterWithOperation(Filter.createLookupFilter(image: image))
        
        self.init(name: name, operation: operation, preview: preview)
    }
}
