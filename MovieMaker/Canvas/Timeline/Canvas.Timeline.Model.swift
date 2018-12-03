
//
//  Canvas.Timeline.Model.swift
//  MovieMaker
//
//  Created by s.kananat on 2018/11/26.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import Result
import ReactiveSwift
import ReactiveCocoa
import KPlugin

// MARK: Main
extension Canvas.Timeline {
    
    /// `Model` to be binded with `Canvas.Timeline`
    final class Model {
        
        /// Header `Content`
        let header: Content = Empty()
        
        /// Footer `Content`
        lazy var footer: Content = {
            let content = Empty()
            content.previous = self.header
            return content
        }()
        
        /// An `Array` collecting all contents, excluding header and footer
        private(set) var contents: [Content] = []
        
        /// Index of the selected `Content` (observable)
        /// Returns nil when where is no content
        let index = BidirectionalProperty<Int?>(nil)
        
        /// The timing offset from the beginning of the selected `Content` (observable)
        /// Returns nil when where is no content
        let offset = BidirectionalProperty<TimeInterval?>(nil)
        
        /// A pipe of `Signal<(Content, Int), NoError>` which is triggered when new content was added (observable)
        private let contentAddedPipe = Signal<(content: Content, index: Int), NoError>.pipe()
        
        /// An `Action` which is triggered when a content is selected
        lazy var contentSelectAction: Action<Content, Content, NoError> = {
            return Action { [weak self] input in
                guard let `self` = self else { return .empty }

                return SignalProducer { subscriber, _ in
                    subscriber.send(value: input)
                    subscriber.sendCompleted()
                }
            }
        }()
        
        /// A `TimeInterval` indicating the timing position from the beginning (observable)
        private let seek = MutableProperty<TimeInterval>(0)

        init() { self.bind() }
    }
}

// MARK: Internal
internal extension Canvas.Timeline.Model {
    
    /// Total durations
    var duration: TimeInterval { return self.contents.map { $0.duration }.reduce(0, +) }

    /// Current `URL` (observable)
    var url: Property<URL?> {
        return self.index.map { [weak self] value in
            guard let `self` = self, let value = value else { return nil }
        
            switch `self`.contents[value] {
                case let video as Canvas.Timeline.Video:
                    return video.url
                
                case _ as Canvas.Timeline.Empty:
                    fatalError("Empty content could not be selected.")
                
                default:
                    return nil
            }
        }.skipRepeats()
    }
    
    /// A `BindingTarget<TimeInterval>` for managing adaptive seek position
    var seekBindingTarget: BindingTarget<TimeInterval> { return self.seek.bindingTarget }
    
    /// A `Signal<(Content, Int), NoError>` sending events when new content was added (observable)
    var contentAdded: Signal<(content: Canvas.Timeline.Content, index: Int), NoError> { return self.contentAddedPipe.output }
    
    /// Add a `Content` without specifying index. The content to be added will be at right after currently selected content
    func add(content: Canvas.Timeline.Content) {
        let index = 1 + (self.index.value ?? -1)
        
        self.add(content: content, index: index)
    }
    
    /// Add a `Content` by specifying index
    func add(content: Canvas.Timeline.Content, index: Int) {
        self.contentAddedPipe.input.send(value: (content, index))
    }
}

// Mark: Private
private extension Canvas.Timeline.Model {
    
    /// Current selected index and offset (observable)
    /// Returns nil when there is no content
    var indexAndOffset: Property<(index: Int?, offset: TimeInterval?)> {
        return self.seek.map { [weak self] value in
            guard let `self` = self else { return (nil, nil) }

            return `self`.makeIndexAndOffset(value)
        }.skipRepeats { $0.index == $1.index && $0.offset == $1.offset }
    }
    
    /// Bind
    @discardableResult
    func bind() -> Disposable {
        let disposable = CompositeDisposable()
        
        // Observes contents being added
        disposable += self.contentAdded.observeValues { [weak self] content, index in
            guard let `self` = self else { return }
            
            var previous: Canvas.Timeline.Content = `self`.header
            if index - 1 >= 0 { previous = `self`.contents[index - 1] }
            
            var next: Canvas.Timeline.Content = `self`.footer
            if index < `self`.contents.count { next = `self`.contents[index] }

            content.previous = previous
            next.previous = content
            
            `self`.contents.insert(content, at: index)

            disposable += self.contentSelectAction <~ content.tapped
            
            // Recalculates index and offset
            self.seek.swap(self.seek.value)
        }

        disposable += self.index <~ self.indexAndOffset.map { $0.index }
        disposable += self.offset <~ self.indexAndOffset.map { $0.offset }
        
        return disposable
    }
    
    /// Converts seek position of `Timeline` into content index and remaining offset
    func makeIndexAndOffset(_ seek: TimeInterval) -> (index: Int?, offset: TimeInterval?) {
        
        // Returns nil when there is no content
        guard self.duration > 0 else { return (nil, nil) }
        
        var temp = seek
        for (index, element) in self.contents.enumerated() {
            if temp <= element.duration { return (index, temp) }
            temp -= element.duration
        }

        // Seek should not exceed valid duration
        fatalError("Seek \(seek) should not exceed valid duration \(self.duration)")
    }
}
