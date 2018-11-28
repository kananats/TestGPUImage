
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

// MARK: Main
extension Canvas.Timeline {
    
    /// `Model` to be binded with `Canvas.Timeline`
    final class Model {
        
        /// An `Array` collecting duration of each contents
        private var durations: [TimeInterval] = []
        
        /// A pipe of `Signal<(Content, Int), NoError>` which is triggered when new content was added (observable)
        private let contentAddedPipe = Signal<(content: Content, index: Int), NoError>.pipe()
        
        lazy var contentSelectAction: Action<Content, Content, NoError> = {
            return Action { [weak self] input in
                guard let `self` = self else { return .empty }

                return SignalProducer { subscriber, _ in
                    subscriber.send(value: input)
                    subscriber.sendCompleted()
                }
            }
        }()
        
        /// Current timing position from the beginning (observable)
        private let seek = MutableProperty<Double>(0)

        init() {
            self.bind()
        }
    }
}

// MARK: Internal
internal extension Canvas.Timeline.Model {
    
    /// Total durations
    var duration: TimeInterval { return self.durations.reduce(0, +) }
    
    /// Current selected index (observable)
    /// Returns nil if there is no content
    var index: Property<Int?> { return self.indexAndOffset.map { $0.index }.skipRepeats() }
    
    /// Current timing position from the beginning of current content (observable)
    /// Returns nil if there is no content
    var offset: Property<TimeInterval?> { return self.indexAndOffset.map { $0.offset }.skipRepeats() }
    
    /// A `Signal<(Content, Int), NoError>` which is triggered when new content was added (observable)
    var contentAddedSignal: Signal<(content: Canvas.Timeline.Content, index: Int), NoError> {
        return self.contentAddedPipe.output
    }
    
    /// A `BindingTarget<TimeInterval>` for clamping seek
    var seekBindingTarget: BindingTarget<TimeInterval> {
        return self.seek.bindingTarget.transform { [weak self] value in
            guard let `self` = self else { return 0 }
            return value.clamped(to: 0 ... `self`.duration)
        }
    }
    
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
    
    /// Current selected index and timing offset (observable)
    /// Returns nil if there is no content
    var indexAndOffset: Property<(index: Int?, offset: TimeInterval?)> {
        return self.seek.skipRepeats().map { [weak self] value in
            guard let `self` = self else { return (nil, nil) }
            
            return `self`.makeIndexAndOffset(value)
        }
    }

    /// Bind
    @discardableResult
    func bind() -> Disposable {
        let disposable = CompositeDisposable()
        
        disposable += self.contentAddedSignal.observeValues { [weak self] content, index in
            guard let `self` = self else { return }

            guard index >= 0 && index <= self.durations.count else {
                fatalError("Index out of range")
            }
            
            `self`.durations.insert(content.duration, at: index)
            
            disposable += self.contentSelectAction <~ content.tapped
        }
        
        disposable += self.debug()
        
        return disposable
    }
    
    /// Converts seek position of `Timeline` into content index and remaining offset
    func makeIndexAndOffset(_ seek: TimeInterval) -> (index: Int?, offset: TimeInterval?) {
        
        // Returns nil when there is no content
        guard self.duration > 0 else { return (nil, nil) }
        
        var seek = seek
        for (index, duration) in self.durations.enumerated() {
            if seek <= duration { return (index, seek) }
            seek -= duration
        }

        // Seek should not exceed valid duration
        fatalError()
    }
    
    /// For debug
    @discardableResult
    func debug() -> Disposable {
        let disposable = CompositeDisposable()
        
        
        
        return disposable
    }
}
