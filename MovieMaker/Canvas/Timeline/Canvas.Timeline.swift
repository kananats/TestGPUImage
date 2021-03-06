//
//  Canvas.Timeline.swift
//  MovieMaker
//
//  Created by s.kananat on 2018/11/20.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import UIKit
import ReactiveSwift
import KPlugin

// MARK: Main
extension Canvas {
    
    /// `UIView` for post processing contents
    public final class Timeline: UIView {
        
        /// A `Model` for this `UIView`
        private let model = Model()
        
        /// `UIScrollView` for collecting contents
        private lazy var scrollView: UIScrollView = {
            let scrollView = UIScrollView(frame: self.bounds)

            // Hide scroll bars
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.showsVerticalScrollIndicator = false

            return scrollView
        }()
        
        /// Current seek indicator
        private lazy var line: CALayer = {
            let frame = self.bounds
            let layer = CAShapeLayer()
            
            layer.frame = frame
            layer.fillColor = nil
            layer.lineWidth = 5
            layer.opacity = 1
            layer.strokeColor = .red

            let path = UIBezierPath()
            path.move(to: CGPoint(x: frame.midX, y: frame.minY))
            path.addLine(to: CGPoint(x: frame.midX, y: frame.maxY))
            
            layer.path = path.cgPath

            return layer
        }()
        
        /// Width of the content in scroll view, excluding header and footer (observable)
        private let contentWidth = MutableProperty<Double>(0)
        
        /// `CGSize` of the header and footer (observable)
        private let headerFooterSize = MutableProperty<CGRect>(.zero)
        
        /// One-time layout initialization
        private lazy var makeLayout: () = {
            self.addSubview(self.scrollView)
            
            self.layer.addSublayer(self.line)
            
            self.scrollView.addSubview(self.model.header)
            self.scrollView.addSubview(self.model.footer)
            
            self.bind()
            self.bind(with: self.model)
        }()
        
        public override init(frame: CGRect = .zero) { super.init(frame: frame) }
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    }
}

// MARK: Inheritance
public extension Canvas.Timeline {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        _ = self.makeLayout
        
        self.updateLayout()
    }
}

// MARK: Public
public extension Canvas.Timeline {
    
    subscript(index: Int) -> Content {
        get { return self.model.contents[index] }
    }
}

// MARK: Internal
internal extension Canvas.Timeline {
    
    /// Width for rendering one second `Content`
    static let widthPerSecond: Double = 50
    
    /// Width for rendering one thumbnail
    /// Note that last thumbnail may be cropped to a smaller size
    static let widthPerThumbnail: Double = 80
    
    /// Bind with `Canvas.ViewController.Model`
    func bind(with model: Canvas.ViewController.Model) -> Disposable {
        let disposable = CompositeDisposable()
        
        disposable += model.url <~ self.model.url
        disposable += model.offset <~> self.model.offset
        
        return disposable
    }
}

// MARK: Private
private extension Canvas.Timeline {
    
    /// Bind
    @discardableResult
    func bind() -> Disposable {
        let disposable = CompositeDisposable()
        
        disposable += self.headerFooterSize <~ self.reactive.bounds
        disposable += self.scrollView.reactive.contentSize <~ self.contentSize
        
        return disposable
    }
    
    /// Bind with `Canvas.Timeline.Model`
    @discardableResult
    func bind(with model: Model) -> Disposable {
        let disposable = CompositeDisposable()
        
        // Scrollview content offset -> seek -> timing offset
        disposable += model.seekBindingTarget <~ self.scrollView.reactive.normalizedContentOffset.filterMap { [weak self] value in
            guard let `self` = self,
                `self`.scrollView.isTracking || `self`.scrollView.isDragging || `self`.scrollView.isDecelerating
                else { return nil }
            
            return Double(value.x) * `self`.contentWidth.value / Canvas.Timeline.widthPerSecond
        }
        
        // Timing offset -> scrollview content offset
        disposable += model.offset.external.filterMap { value -> CGPoint? in
            guard let value = value else { return nil }
            
            return CGPoint(x: value * Canvas.Timeline.widthPerSecond, y: 0)
        }.startWithValues { [weak self] value in
            guard let `self` = self else { return }
            
            // TODO: Stops playing
            if `self`.scrollView.isTracking || `self`.scrollView.isDragging || `self`.scrollView.isDecelerating { return }
            
            // Sets content offset
            `self`.scrollView.setContentOffset(value, animated: false)
        }
        
        // Observes contents being added
        disposable += model.contentAdded.observeValues { [weak self] content, index in
            guard let `self` = self else { return }
            
            `self`.scrollView.insertSubview(content, at: index)
            
            let contentWidth = `self`.contentWidth.value + content.width
            `self`.contentWidth.swap(contentWidth)
        }
        
        // Observes contents being selected
        disposable += model.contentSelectAction.values.observeValues { [weak self] value in
            guard let `self` = self else { return }

            `self`.seek(to: value)
        }
        
        return disposable
    }
    
    /// Seek to center the content
    func seek(to content: Content) {
        var content: Content! = content
        
        // Center position
        var x = content.width / 2
        
        while content.previous != nil {
            content = content.previous
            x = x + content.width
        }
        
        var offset = self.scrollView.contentOffset
        offset.x = CGFloat(x)
        
        self.scrollView.setContentOffset(offset, animated: true)
    }
    
    /// `CGSize` of the `Content` in the `UIScrollView`, including header and footer (observable)
    var contentSize: Property<CGSize> {
        return Property.combineLatest(self.contentWidth, self.headerFooterSize).map { value -> CGSize in
            let (contentWidth, headerFooterSize) = value
            return CGSize(width: contentWidth + Double(headerFooterSize.width), height: Double(headerFooterSize.height))
        }
    }
    
    static var bool = false
    /// Update layout constraints
    func updateLayout() {
        self.scrollView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        if Canvas.Timeline.bool {
            return
        }

        //add con1
        let con1 = Video(asset: .test)
        self.model.add(content: con1)

        //add con2
        let con2 = Content(duration: 2.5)
        self.model.add(content: con2)
        
        //remove con1

        
        Canvas.Timeline.bool = true
    }
}
