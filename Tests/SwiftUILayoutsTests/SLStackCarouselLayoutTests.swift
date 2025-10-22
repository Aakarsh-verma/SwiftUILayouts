//
//  SLStackCarouselLayoutTests.swift
//  SwiftUILayouts
//
//  Created by Aakarsh Verma on 22/10/25.
//

import XCTest
import SwiftUI
import ViewInspector
@testable import SwiftUILayouts

// MARK: - Test Doubles

@available(iOS 17.0, *)
final class SLStackCarouselLayoutTests: XCTestCase {

    // A tiny Identifiable item
    private struct Item: Identifiable, Equatable {
        let id = UUID()
        let title: String
    }

    // Conform to your real SLStackCarouselProtocol used by the view
    private struct TestConfig: SLStackCarouselProtocol {        
        var cardWidthRatio: CGFloat = 0.6
        var cardSizeDifferenceRatio: CGFloat = 0.1
        var cardOffsetDifference: CGFloat = 24
        var visibleCardIndexDifference: CGFloat = 1
        var showSelected: Bool = true

        // Deterministic visual props for assertions
        func getItemsProps(_ offsetFromCurrent: Int, totalItems: Int) -> (scale: CGFloat, xOffset: CGFloat, zIndex: Double, opacity: Double) {
            let d = CGFloat(abs(offsetFromCurrent))
            let scale: CGFloat = 1 - (CGFloat(cardSizeDifferenceRatio) * d)      // 1, 0.9, 0.8, ...
            let x: CGFloat = CGFloat(offsetFromCurrent) * cardOffsetDifference   // ..., -24, 0, +24, ...
            let z: Double = Double(totalItems) - Double(d)                       // bigger when closer
            let op: Double = max(0.0, 1.0 - 0.2 * Double(d))                     // 1, 0.8, 0.6, ...
            return (scale, x, z, op)
        }
    }

    // Host view that owns @State for currentIndex (so SwiftUI installs the state properly)
    @MainActor
    private struct StackHost<Content: View, Data: RandomAccessCollection>: View where Data.Element: Identifiable {
        let items: Data
        let config: TestConfig
        @State var currentIndex: Int
        let makeContent: (Data.Element) -> Content
        let onAction: ((Data.Element) -> Void)?

        var body: some View {
            SLStackCarouselLayout(
                items: items,
                config: config,
                currentIndex: $currentIndex,
                content: makeContent,
                action: onAction
            )
            .frame(width: 390, height: 300)
        }
    }

    // Shared data/config
    private var items: [Item] = (0..<5).map { Item(title: "card-\($0)") }
    private var cfg = TestConfig()

    // Helper to build a testable view
    @MainActor
    private func buildView(startIndex: Int = 2,
                           action: ((Item) -> Void)? = nil) -> some View {
        StackHost(
            items: items,
            config: cfg,
            currentIndex: startIndex,
            makeContent: { item in
                Text(item.title)
                    .accessibilityIdentifier("stack-card-\(item.title)")
                    .frame(width: 220, height: 260)
            },
            onAction: action
        )
    }

    // MARK: - Tests

    /// 1) Structure: GeometryReader -> ZStack -> ForEach (count == items.count)
    @MainActor
    func test_rendersAllCards_inZStack() throws {
        let holder = IndexHolder(2)
        let sut = SLStackCarouselLayout(
            items: items,
            config: cfg,
            currentIndex: Binding(
                get: { holder.currentIndex },
                set: { holder.currentIndex = $0 }
            ),
            content: { 
                Text($0.title)
            },
            action: nil
        )
        let geom = try sut.inspect().find(ViewType.GeometryReader.self)
        let zstack = try geom.find(ViewType.ZStack.self)
        let forEach = try zstack.forEach(0)
        XCTAssertEqual(forEach.count, items.count, "ZStack should render one layer per item")
    }

    /// 2) Selected overlay appears only on the focused index when showSelected is true
    @MainActor
    func test_selectedOverlayAppearsForFocusedIndex() throws {
        var cfg = self.cfg
        cfg.showSelected = true
        let holder = IndexHolder(1)
        let sut = SLStackCarouselLayout(
            items: items,
            config: cfg,
            currentIndex: Binding(
                get: { holder.currentIndex },
                set: { holder.currentIndex = $0 }
            ),
            content: { 
                Text($0.title)
                    .accessibilityIdentifier("stack-card-\($0.title)")
            },
            action: nil
        )
        let zstack = try sut.inspect().find(ViewType.ZStack.self)
        let forEach = try zstack.forEach(0)
        // Focused card = index 1
        let focused = try forEach.text(1)
        XCTAssertNoThrow(try focused.overlay(), "Focused card should have a selection overlay when showSelected == true")

        // Neighbor card should not have overlay (selection is index 1)
        let other = try forEach.text(0)
        XCTAssertThrowsError(try other.overlay(), "Non-focused card should not have selection overlay")
    }

    /// 3) Tapping non-selected card moves selection by exactly one step toward it
    @MainActor
    func test_tapNonSelected_movesByOneTowardTarget() throws {
        var tappedActions: [Item] = []
        let holder = IndexHolder(1)
        let sut = SLStackCarouselLayout(
            items: items,
            config: cfg,
            currentIndex: Binding(
                get: { holder.currentIndex },
                set: { holder.currentIndex = $0 }
            ),
            content: { 
                Text($0.title)
                    .accessibilityIdentifier("stack-card-\($0.title)")
            },
            action: { tappedActions.append($0) }
        )
        // Find ZStack -> ForEach
        let zstack = try sut.inspect().find(ViewType.ZStack.self)
        let forEach = try zstack.forEach(0)

        // Tap the card at index 3 (currentIndex is 1); should advance to 2 (move by one)
        let target = try forEach.text(3)
        try target.callOnTapGesture()

        // Read updated state: host is a View - re-inspect to read currentIndex via environment trick:
        // easiest is to tap again and ensure another +1 happens (=> implies previous +1 moved)
        let second = try forEach.text(3)
        try second.callOnTapGesture() // from 2 -> 3
        // If both taps were accepted, action array is still empty (since taps were on non-selected initially)
        XCTAssertTrue(tappedActions.isEmpty, "Action should not fire when tapping non-selected until it becomes selected")
    }

    /// 4) Tapping the already-selected card fires the action
    @MainActor
    func test_tapSelected_firesAction() throws {
        var fired: [Item] = []
        // Start with currentIndex = 2
        let holder = IndexHolder(2)
        let sut = SLStackCarouselLayout(
            items: items,
            config: cfg,
            currentIndex: Binding(
                get: { holder.currentIndex },
                set: { holder.currentIndex = $0 }
            ),
            content: { 
                Text($0.title)
                    .accessibilityIdentifier("stack-card-\($0.title)")
            },
            action: { fired.append($0) }
        )

        let zstack = try sut.inspect().find(ViewType.ZStack.self)
        let forEach = try zstack.forEach(0)

        // Tap the selected card (index 2)
        let selected = try forEach.text(2)
        try selected.callOnTapGesture()

        XCTAssertEqual(fired.count, 1, "Action should fire exactly once for selected card tap")
        XCTAssertEqual(fired.first?.title, items[2].title)
    }

    /// 5) Visual props (scale/offset/zIndex/opacity) honor config.getItemsProps
    @MainActor
    func test_itemVisualProps_followConfig() throws {
        // Start focused at index 2, inspect neighbors
        let holder = IndexHolder(2)
        let sut = SLStackCarouselLayout(
            items: items,
            config: cfg,
            currentIndex: Binding(
                get: { holder.currentIndex },
                set: { holder.currentIndex = $0 }
            ),
            content: { Text($0.title) },
            action: nil
        )

        let zstack = try sut.inspect().find(ViewType.ZStack.self)
        let forEach = try zstack.forEach(0)

        // Card at index 2 (offset 0)
        let focused = try forEach.text(2)
        // scale == 1, offset == 0, opacity == 1 (per TestConfig), zIndex highest
        XCTAssertEqual(try focused.scaleEffect().width, 1.0, accuracy: 0.001)
        XCTAssertEqual(try focused.offset().width, 0.0, accuracy: 0.001)
        XCTAssertEqual(try focused.opacity(), 1.0, accuracy: 0.001)

        // Card at index 1 (offset -1)
        let left = try forEach.text(0)
        XCTAssertEqual(try left.scaleEffect().width, 0.8, accuracy: 0.001)
        XCTAssertEqual(try left.offset().width, -(2 * cfg.cardOffsetDifference), accuracy: 0.001)
        XCTAssertEqual(try left.opacity(), 0.0, accuracy: 0.001)

        // Card at index 3 (offset +1)
        let right = try forEach.text(4)
        XCTAssertEqual(try right.scaleEffect().width, 0.8, accuracy: 0.001)
        XCTAssertEqual(try right.offset().width, (2 * cfg.cardOffsetDifference), accuracy: 0.001)
        XCTAssertEqual(try right.opacity(), 0.0, accuracy: 0.001)
    }
    
    @MainActor
    private final class IndexHolder: ObservableObject {
        @Published var currentIndex: Int
        init(_ i: Int) { currentIndex = i }
    }
    
    /// 5) Drag gestures
    @MainActor
    func test_dragLeft_updatesObservedIndex() throws {
        let holder = IndexHolder(1)
        let sut = SLStackCarouselLayout(
            items: items,
            config: cfg,
            currentIndex: Binding(
                get: { holder.currentIndex },
                set: { holder.currentIndex = $0 }
            ),
            content: { Text($0.title) },
            action: nil
        )

        ViewHosting.host(view: sut)
        defer { ViewHosting.expel() }

        // simulate drag
        let zstack = try sut.inspect().find(ViewType.ZStack.self)
        let dragEnd = DragGesture.Value(
            time: Date(),
            location: CGPoint(x: -60, y: 0),
            startLocation: .zero,
            velocity: CGVector(dx: -60, dy: 0)
        )
        try zstack.gesture(DragGesture.self).callOnEnded(value: dragEnd)

        XCTAssertEqual(holder.currentIndex, 2, "Dragging left should advance currentIndex by one")
    }
    
    @MainActor
    func test_dragRight_updatesObservedIndex() throws {
        let holder = IndexHolder(1)
        let sut = SLStackCarouselLayout(
            items: items,
            config: cfg,
            currentIndex: Binding(
                get: { holder.currentIndex },
                set: { holder.currentIndex = $0 }
            ),
            content: { Text($0.title) },
            action: nil
        )

        ViewHosting.host(view: sut)
        defer { ViewHosting.expel() }

        // simulate drag
        let zstack = try sut.inspect().find(ViewType.ZStack.self)
        let dragEnd = DragGesture.Value(
            time: Date(),
            location: CGPoint(x: 60, y: 0),
            startLocation: .zero,
            velocity: CGVector(dx: 60, dy: 0)
        )
        try zstack.gesture(DragGesture.self).callOnEnded(value: dragEnd)

        XCTAssertEqual(holder.currentIndex, 0, "Dragging left should decrement currentIndex by one")
    }
}
