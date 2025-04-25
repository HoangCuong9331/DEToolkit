//
//  AsynchronousOperation.swift
//  DEToolkit
//
//  Created by Le Cuong on 25/4/25.
//
import Foundation

/// A base class for performing asynchronous `Operation`s in a thread-safe manner.
///
/// `AsynchronousOperation` is a subclass of `Operation` that overrides key properties
/// and lifecycle methods to support custom asynchronous tasks. Subclass this and override
/// `main()` to perform your async work. When your async task completes, call `finish()`
/// to properly update the operation's state and notify the operation queue.
///
/// - Note: This class uses a custom `State` enum to track readiness, execution, and completion,
///         and manages state changes in a thread-safe manner using a concurrent `DispatchQueue`.
///
/// - Important: Subclasses must call `finish()` manually when the asynchronous task completes,
///             otherwise the operation will remain in the `.executing` state indefinitely.
///
/// - Example:
/// ```swift
/// class MyAsyncOp: AsynchronousOperation {
///     override func main() {
///         super.main()
///         fetchDataFromNetwork { [weak self] result in
///             // handle result
///             self?.finish()
///         }
///     }
/// }
/// ```
class AsynchronousOperation: Operation, @unchecked Sendable {
    public override var isAsynchronous: Bool {
        return true
    }
    
    public override var isExecuting: Bool {
        return state == .executing
    }
    
    public override var isFinished: Bool {
        return state == .finished
    }
    
    public override func start() {
        if self.isCancelled {
            state = .finished
        } else {
            state = .ready
            main()
        }
    }
    
    open override func main() {
        if self.isCancelled {
            state = .finished
        } else {
            state = .executing
        }
    }
    
    public func finish() {
        state = .finished
    }
    
    // MARK: - State management
    
    public enum State: String {
        case ready = "Ready"
        case executing = "Executing"
        case finished = "Finished"
        fileprivate var keyPath: String { return "is\(self.rawValue)" }
    }
    
    /// Thread-safe computed state value
    public var state: State {
        get {
            stateQueue.sync {
                return stateStore
            }
        }
        set {
            let oldValue = state
            willChangeValue(forKey: state.keyPath)
            willChangeValue(forKey: newValue.keyPath)
            stateQueue.sync(flags: .barrier) {
                stateStore = newValue
            }
            didChangeValue(forKey: state.keyPath)
            didChangeValue(forKey: oldValue.keyPath)
        }
    }
    
    private let stateQueue = DispatchQueue(label: "AsynchronousOperation State Queue", attributes: .concurrent)
    
    private var stateStore: State = .ready
}
