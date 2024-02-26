import UIKit

public protocol DayViewDelegate: AnyObject {
    func dayViewDidSelectEventView(_ eventView: EventView)
    func dayViewDidLongPressEventView(_ eventView: EventView)
    func dayView(dayView: DayView, didTapTimelineAt date: Date)
    func dayView(dayView: DayView, didLongPressTimelineAt date: Date)
    func dayViewDidBeginDragging(dayView: DayView)
    func dayViewDidTransitionCancel(dayView: DayView)
    func dayView(dayView: DayView, willMoveTo date: Date)
    func dayView(dayView: DayView, didMoveTo  date: Date)
    func dayView(dayView: DayView, didUpdate event: EventDescriptor)
}

public class DayView: UIView, TimelinePagerViewDelegate {
    public weak var dataSource: EventDataSource? {
        get {
            timelinePagerView.dataSource
        }
        set(value) {
            timelinePagerView.dataSource = value
        }
    }
    
    public weak var delegate: DayViewDelegate?
    
    public var timelineScrollOffset: CGPoint {
        timelinePagerView.timelineScrollOffset
    }
    
    public var autoScrollToFirstEvent: Bool {
        get {
            timelinePagerView.autoScrollToFirstEvent
        }
        set (value) {
            timelinePagerView.autoScrollToFirstEvent = value
        }
    }
    
    public let timelinePagerView: TimelinePagerView
    
    public var state: DayViewState? {
        didSet {
            timelinePagerView.state = state
        }
    }
    
    public var calendar: Calendar = Calendar.autoupdatingCurrent
    
    public var eventEditingSnappingBehavior: EventEditingSnappingBehavior {
        get {
            timelinePagerView.eventEditingSnappingBehavior
        }
        set {
            timelinePagerView.eventEditingSnappingBehavior = newValue
        }
    }
    
    private var style = CalendarStyle()
    
    public init(calendar: Calendar = Calendar.autoupdatingCurrent) {
        self.calendar = calendar
        self.timelinePagerView = TimelinePagerView(calendar: calendar)
        super.init(frame: .zero)
        configure()
    }
    
    override public init(frame: CGRect) {
        self.timelinePagerView = TimelinePagerView(calendar: calendar)
        super.init(frame: frame)
        configure()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.timelinePagerView = TimelinePagerView(calendar: calendar)
        super.init(coder: aDecoder)
        configure()
    }
    
    private func configure() {
        addSubview(timelinePagerView)
        configureLayout()
        timelinePagerView.delegate = self
    }
    
    private func configureLayout() {
        timelinePagerView.translatesAutoresizingMaskIntoConstraints = false

        timelinePagerView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor).isActive = true
        timelinePagerView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor).isActive = true
        timelinePagerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        timelinePagerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    public func updateStyle(_ newStyle: CalendarStyle) {
        style = newStyle
        timelinePagerView.updateStyle(style.timeline)
    }
    
    public func timelinePanGestureRequire(toFail gesture: UIGestureRecognizer) {
        timelinePagerView.timelinePanGestureRequire(toFail: gesture)
    }
    
    public func scrollTo(hour24: Float, animated: Bool = true) {
        timelinePagerView.scrollTo(hour24: hour24, animated: animated)
    }
    
    public func scrollToFirstEventIfNeeded(animated: Bool = true) {
        timelinePagerView.scrollToFirstEventIfNeeded(animated: animated)
    }
    
    public func reloadData() {
        timelinePagerView.reloadData()
    }
    
    public func move(to date: Date) {
        state?.move(to: date)
    }
    
    public func transitionToHorizontalSizeClass(_ sizeClass: UIUserInterfaceSizeClass) {
        updateStyle(style)
    }
    
    public func create(event: EventDescriptor, animated: Bool = false) {
        timelinePagerView.create(event: event, animated: animated)
    }
    
    public func beginEditing(event: EventDescriptor, animated: Bool = false) {
        timelinePagerView.beginEditing(event: event, animated: animated)
    }
    
    public func endEventEditing() {
        timelinePagerView.endEventEditing()
    }
    
    // MARK: TimelinePagerViewDelegate
    
    public func timelinePagerDidSelectEventView(_ eventView: EventView) {
        delegate?.dayViewDidSelectEventView(eventView)
    }
    public func timelinePagerDidLongPressEventView(_ eventView: EventView) {
        delegate?.dayViewDidLongPressEventView(eventView)
    }
    public func timelinePagerDidBeginDragging(timelinePager: TimelinePagerView) {
        delegate?.dayViewDidBeginDragging(dayView: self)
    }
    public func timelinePagerDidTransitionCancel(timelinePager: TimelinePagerView) {
        delegate?.dayViewDidTransitionCancel(dayView: self)
    }
    public func timelinePager(timelinePager: TimelinePagerView, willMoveTo date: Date) {
        delegate?.dayView(dayView: self, willMoveTo: date)
    }
    public func timelinePager(timelinePager: TimelinePagerView, didMoveTo  date: Date) {
        delegate?.dayView(dayView: self, didMoveTo: date)
    }
    public func timelinePager(timelinePager: TimelinePagerView, didLongPressTimelineAt date: Date) {
        delegate?.dayView(dayView: self, didLongPressTimelineAt: date)
    }
    public func timelinePager(timelinePager: TimelinePagerView, didTapTimelineAt date: Date) {
        delegate?.dayView(dayView: self, didTapTimelineAt: date)
    }
    public func timelinePager(timelinePager: TimelinePagerView, didUpdate event: EventDescriptor) {
        delegate?.dayView(dayView: self, didUpdate: event)
    }
}
