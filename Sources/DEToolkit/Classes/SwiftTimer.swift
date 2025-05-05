//
//  Timer.swift
//  DEToolkit
//
//  Created by Le Cuong on 25/4/25.
//
import Foundation

/// Creates an `AsyncStream` that emits the current `Date` at the specified time interval.
/// This is a concurrency-friendly alternative to traditional `Timer` usage.
///
/// - Parameter interval: The time interval in seconds between each tick.
/// - Returns: An `AsyncStream<Date>` that yields the current date on each tick.
///
/// ⚠️ Note:
/// The `Timer.scheduledTimer(...)` is scheduled on the **main run loop** by default,
/// so the timer's callback (and thus the `continuation.yield`) is executed on the **main thread**.
/// If you need this to run on a background thread, consider using `DispatchSourceTimer` or
/// building a custom solution with `Task.sleep` and `AsyncStream`.
//@available(iOS 13.0, *)
//func makeTimerStream(interval: TimeInterval) -> AsyncStream<Date> {
//    AsyncStream { continuation in
//        let queue = DispatchQueue.global(qos: .utility)
//
//        let timer = DispatchSource.makeTimerSource(queue: queue)
//        timer.schedule(deadline: .now(), repeating: interval, leeway: .seconds(Int(interval) / 5))
//
//        timer.setEventHandler {
//            // SAFETY: We're on a background queue → yield directly
//            continuation.yield(Date())
//        }
//
//        timer.resume()
//
//        continuation.onTermination = { [weak timer] _ in
//            guard timer != nil else { return }
//            timer?.cancel()
//        }
//    }
//}
