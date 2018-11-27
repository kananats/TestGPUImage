
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
        
        /// Current timing position of `Timeline` (observable)
        private let time = MutableProperty<Double>(0)

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
    var index: Property<Int> { return self.indexAndOffset.map { $0.index }.skipRepeats() }
    
    /// Timing offset of current selected content (observable)
    var offset: Property<TimeInterval> { return self.indexAndOffset.map { $0.offset }.skipRepeats() }
    
    /// A `Signal<(Content, Int), NoError>` which is triggered when new content was added (observable)
    var contentAddedSignal: Signal<(content: Canvas.Timeline.Content, index: Int), NoError> {
        return self.contentAddedPipe.output
    }
    
    /// A `BindingTarget<TimeInterval>` for managing adaptive time
    var timeBindingTarget: BindingTarget<TimeInterval> {
        return self.time.bindingTarget.transform { [weak self] value in
            guard let `self` = self else { return 0 }
            return value.clamped(to: 0 ... `self`.duration)
        }
    }
    
    /// Add `Content` without specifying index. The content to be added will be at right after currently selected content
    func add(content: Canvas.Timeline.Content) {
        var index = 0
        
        if self.durations.count > 0 { index = self.index.value + 1 }
        
        self.add(content: content, index: index)
    }
    
    /// Add `Content` by specifying index
    func add(content: Canvas.Timeline.Content, index: Int) {
        self.contentAddedPipe.input.send(value: (content, index))
    }
}

// Mark: Private
private extension Canvas.Timeline.Model {
    
    /// Current selected index and timing offset (observable)
    var indexAndOffset: Property<(index: Int, offset: TimeInterval)> {
        return self.time.skipRepeats().map { [weak self] value -> (index: Int, offset: TimeInterval) in
            guard let `self` = self else { return (index: 0, offset: 0) }
            
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
            
            //disposable += content
        }
        
        disposable += self.debug()
        
        return disposable
    }
    
    /// Converts time position of `Timeline` into content index and remaining offset
    func makeIndexAndOffset(_ time: TimeInterval) -> (index: Int, offset: TimeInterval) {
        var time = time
        for (index, duration) in self.durations.enumerated() {
            if time <= duration { return (index, time) }
            time -= duration
        }

        return (self.durations.count, time)
    }
    
    /// For debug
    @discardableResult
    func debug() -> Disposable {
        let disposable = CompositeDisposable()
        
        // disposable += self.indexAndOffset.debug()
        
        return disposable
    }
}
