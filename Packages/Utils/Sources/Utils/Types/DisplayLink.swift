#if os(iOS) || os(tvOS)

import QuartzCore

/// Simple wrapper around `CADisplayLink`.
///
/// Useful for triggering events in sync with a refresh rate of the display.
/// Example of a possible implementation:
///
///     let timer = DisplayLink(duration: 10)
///     timer.onFrame = {
///         print($0.progress)
///     }
///     timer.start()
///
open class DisplayLink {

    public enum State {
        case running
        case paused
        case expired
        case stopped
    }

    open private(set) var state: State = .stopped {
        didSet {
            if state != oldValue {
                onState?(self, state)

                switch state {
                case .running:
                    onStart?(self)
                case .paused:
                    onPause?(self)
                case .expired:
                    onExpire?(self)
                case .stopped:
                    onStop?(self)
                }
            }
        }
    }

    open var duration: TimeInterval? {
        didSet {
            stop()
        }
    }

    public init(duration: TimeInterval? = nil) {
        self.duration = duration
        stop()
    }

    // MARK: Handlers

    open var onFrame: ((DisplayLink) -> Void)?

    open var onElapsed: ((DisplayLink, TimeInterval) -> Void)?
    open var onRemaining: ((DisplayLink, TimeInterval) -> Void)?
    open var onProgress: ((DisplayLink, Double) -> Void)?
    open var onSecond: ((DisplayLink, Int) -> Void)?

    open var onState: ((DisplayLink, State) -> Void)?

    open var onStart: ((DisplayLink) -> Void)?
    open var onPause: ((DisplayLink) -> Void)?
    open var onExpire: ((DisplayLink) -> Void)?
    open var onStop: ((DisplayLink) -> Void)?

    // MARK: API

    open func start() {
        guard state != .running else {
            return
        }

        stopTimers()
        startTime = CACurrentMediaTime() - elapsed
        startTimers()

        state = .running
    }

    open func stop() {
        stopTimers()

        elapsed = 0.0
        progress = 0.0

        state = .stopped
    }

    open func pause() {
        stopTimers()

        state = .paused
    }

    open func restart() {
        stop()
        start()
    }

    open func toggle() {
        switch state {
        case .running:
            pause()
        case .stopped, .paused:
            start()
        case .expired:
            restart()
        }
    }

    open private(set) var elapsed: TimeInterval = 0.0 {
        didSet {
            if let duration = duration {
                remaining = duration - elapsed
            }
            onElapsed?(self, elapsed)

            let currentSecond = Int(elapsed)
            if currentSecond != Int(oldValue) {
                onSecond?(self, currentSecond)
            }
        }
    }

    open private(set) var remaining: TimeInterval = 0.0 {
        didSet {
            if let duration = duration {
                if remaining >= 0.0 {
                    progress = elapsed / duration
                } else {
                    expire()
                }
            }
            onRemaining?(self, remaining)
        }
    }

    open private(set) var progress: Double = 0.0 {
        didSet {
            onProgress?(self, progress)
        }
    }

    // MARK: Helpers

    private var startTime = 0.0
    private var displayLink: CADisplayLink?
    private var backupTimer: Timer?

    private var elapsedSinceStartTime: TimeInterval {
        CACurrentMediaTime() - startTime
    }

    private func startTimers() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateFrame))
        displayLink?.add(to: .main, forMode: .common)

        if duration != nil {
            /// - Note: for sluggish devices this timer will make sure to force expiration
            backupTimer = Timer(
                timeInterval: remaining,
                target: self,
                selector: #selector(expire),
                userInfo: nil,
                repeats: false
            )
        }
    }

    private func stopTimers() {
        displayLink?.invalidate()
        displayLink = nil

        backupTimer?.invalidate()
        backupTimer = nil
    }

    @objc
    private func updateFrame() {
        elapsed = elapsedSinceStartTime
        onFrame?(self)
    }

    @objc
    private func expire() {
        guard state != .expired, let duration = duration else {
            return
        }
        stopTimers()

        elapsed = duration
        progress = 1.0

        state = .expired
    }

}

#endif
