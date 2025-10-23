//
//  SLGridLayoutTests.swift
//  SwiftUILayouts
//
//  Created by Aakarsh Verma on 23/10/25.
//


//
//  SLGridLayoutTests.swift
//  SwiftUILayoutsTests
//
//  Created by Aakarsh Verma on 23/10/25.
//

import XCTest
import SwiftUI
import ViewInspector
@testable import SwiftUILayouts

@MainActor
final class SLGridLayoutTests: XCTestCase {

    // MARK: - Test Doubles

    private struct Item: Identifiable, Equatable {
        let id = UUID()
        let title: String
    }

    private var items: [Item] = (0..<7).map { Item(title: "cell-\($0)") }

    // Helper that builds the grid with identifiers on content
    private func buildGrid(
        numberOfLayout: Int = 3,
        itemSizeRatio: CGFloat = 0.5,
        isVertical: Bool = true,
        containerSize: CGFloat = 400,
        tapSpy: Spy? = nil
    ) -> some View {
        SLGridLayout(
            items: items,
            numberOfLayout: numberOfLayout,
            itemSizeRatio: itemSizeRatio,
            isVertical: isVertical,
            containerSize: containerSize,
            content: { item in
                // Tag each cell for inspection
                Text(item.title)
                    .accessibilityIdentifier("grid-\(item.title)")
                    .padding(1)
            },
            action: { item in
                tapSpy?.fire(item: item)
            }
        )
        // Constrain for deterministic layout in tests
        .frame(width: containerSize, height: 600)
    }

    // A tiny spy to capture tap callbacks
    private final class Spy {
        private(set) var tapped: [Item] = []
        func fire(item: Item) { tapped.append(item) }
    }

    // MARK: - Tests

    /// Renders one view per item and uses LazyVGrid for vertical orientation
    func test_vertical_rendersAllItems_usesLazyVGrid() throws {
        let sut = buildGrid(isVertical: true)
        ViewHosting.host(view: sut); defer { ViewHosting.expel() }

        // Ensure vertical grid type is used
        let vgrid = try sut.inspect().find(ViewType.LazyVGrid.self)

        // Count rendered cells via ForEach children
        // Descend into the grid's content and count Texts with our identifiers
        let texts = vgrid.findAll(ViewType.Text.self)
        // Only count our tagged cells (skip any incidental Texts)
        let count = try texts.filter { try $0.accessibilityIdentifier().hasPrefix("grid-cell-") == true }.count
        // If you don’t use "grid-cell-" in your titles, count all matching "grid-" instead:
        let safeCount = count > 0 ? count :
        (try texts.filter { try $0.accessibilityIdentifier().hasPrefix("grid-") == true }.count)

        XCTAssertEqual(safeCount, items.count, "Vertical grid should render one cell per item")
    }

    /// Renders one view per item and uses LazyHGrid for horizontal orientation
    func test_horizontal_rendersAllItems_usesLazyHGrid() throws {
        let sut = buildGrid(isVertical: false)
        ViewHosting.host(view: sut); defer { ViewHosting.expel() }

        // Ensure horizontal grid type is used
        let hgrid = try sut.inspect().find(ViewType.LazyHGrid.self)

        let texts = hgrid.findAll(ViewType.Text.self)
        let count = try texts.filter { try $0.accessibilityIdentifier().hasPrefix("grid-") == true }.count
        XCTAssertEqual(count, items.count, "Horizontal grid should render one cell per item")
    }

    /// Tapping a cell calls the action with that item
    func test_tapCell_callsActionWithItem() throws {
        let spy = Spy()
        let sut = buildGrid(tapSpy: spy)
        ViewHosting.host(view: sut); defer { ViewHosting.expel() }

        // Tap the middle cell
        let targetTitle = items[3].title
        let cell = try sut.inspect().find(viewWithAccessibilityIdentifier: "grid-\(targetTitle)")
        try cell.callOnTapGesture()

        XCTAssertEqual(spy.tapped.count, 1)
        XCTAssertEqual(spy.tapped.first?.title, targetTitle)
    }

    /// Switching numberOfLayout builds the right number of tracks (smoke check)
    func test_switchingNumberOfLayout_stillRendersAllItems() throws {
        let sut = buildGrid(numberOfLayout: 4) // more columns/rows
        ViewHosting.host(view: sut); defer { ViewHosting.expel() }

        // Just assert cell count remains correct under different layout counts
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        let count = try texts.filter { try $0.accessibilityIdentifier().hasPrefix("grid-") == true }.count
        XCTAssertEqual(count, items.count)
    }
}

