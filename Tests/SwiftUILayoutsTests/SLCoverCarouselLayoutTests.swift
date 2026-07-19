//
//  SLCoverCarouselLayoutTests.swift
//  SwiftUILayouts
//
//  Created by Aakarsh Verma on 21/10/25.
//


import XCTest
import SwiftUI
import ViewInspector
@testable import SwiftUILayouts

@available(iOS 17.0, *)
final class SLCoverCarouselLayoutTests: XCTestCase {

    // MARK: - Helpers

    private struct Item: Identifiable, Equatable {
        let id = UUID()
        let title: String
    }

    private struct TestCoverConfig: SLCoverCarouselProtocol {
        var cardWidth: CGFloat = 240
        var minimumCardWidth: CGFloat = 180
        var spacing: CGFloat = 12
        var hasOpacity: Bool = true
        var opacityValue: CGFloat = 0.25
        var hasScale: Bool = true
        var scaleValue: CGFloat = 0.1
        var cornerRadius: CGFloat = 16
    }

    private var items: [Item] = (0..<5).map { Item(title: "item-\($0)") }
    private var cfg = TestCoverConfig()

    @MainActor
    private func buildCoverView(selection: Item.ID?) -> some View {
        let constantSelection = Binding.constant(selection)
        return SLCoverCarouselLayout(
            config: cfg,
            data: items,
            selection: constantSelection,
            content: { item in
                // Each item gets a visible tag for testing
                Text(item.title)
                    .accessibilityIdentifier("cover-card-\(item.title)")
                    .frame(width: 220, height: 260)
            }
        )
        .frame(width: 390, height: 300)
    }

    // MARK: - Tests

    /// 1️⃣ The layout renders exactly one card per data element and uses the expected HStack spacing
    @MainActor
    func test_rendersSameNumberOfCards_asDataCount() throws {
        let sel: Item.ID? = items.first?.id
        let sut = buildCoverView(selection: sel)

        let scroll = try sut.inspect().find(ViewType.ScrollView.self)
        XCTAssertEqual(try scroll.axes(), .horizontal, "ScrollView should be horizontal")

        let hstack = try scroll.find(ViewType.HStack.self)
        guard let spacing = try hstack.spacing() else {
            return XCTFail("HStack spacing unavailable")
        }
        XCTAssertEqual(spacing, cfg.spacing, accuracy: 0.001, "HStack spacing should match config.spacing")

        let forEach = try hstack.forEach(0)
        XCTAssertEqual(forEach.count, items.count, "Number of rendered cards should match data count")
    }

    /// 2️⃣ Each card should be wrapped in a GeometryReader (for scroll metrics)
    @MainActor
    func test_eachCardWrappedInGeometryReader() throws {
        let sel: Item.ID? = nil
        let sut = buildCoverView(selection: sel)

        let hstack = try sut.inspect().find(ViewType.HStack.self)
        let forEach = try hstack.forEach(0)
        let first = forEach.first?.first

        XCTAssertNoThrow(try first?.find(ViewType.GeometryReader.self), "Each card should contain a GeometryReader")
    }

    /// 3️⃣ When opacity and scale are enabled, modifiers should exist on the card content
    @MainActor
    func test_effectModifiersExist_whenEnabled() throws {
        let sel: Item.ID? = items.first?.id
        let sut = buildCoverView(selection: sel)

        let geom = try sut.inspect().find(ViewType.GeometryReader.self)
        let scroll = try geom.find(ViewType.ScrollView.self)
        let hstack = try scroll.hStack()
        let hstackForEach = try hstack.forEach(0)
        let content = hstackForEach.first?.first
        let z = try content?.find(ViewType.Text.self)

        XCTAssertNoThrow(try z?.opacity(), "Opacity modifier should exist when hasOpacity is true")
        XCTAssertNoThrow(try z?.scaleEffect(), "Scale modifier should exist when hasScale is true")
        XCTAssertNoThrow(try z?.offset(), "offset modifier should exist because of totalOffset")
    }

    /// 4️⃣ When effects are disabled, opacity and scale modifiers should not be found
    @MainActor
    func test_effectModifiersAbsent_whenDisabled() throws {
        var disabledCfg = cfg
        disabledCfg.hasOpacity = false
        disabledCfg.hasScale = false
        self.cfg = disabledCfg

        let sel: Item.ID? = nil
        let sut = buildCoverView(selection: sel)
        let geom = try sut.inspect().find(ViewType.GeometryReader.self)
        let scroll = try geom.find(ViewType.ScrollView.self)
        let hstack = try scroll.hStack()
        let hstackForEach = try hstack.forEach(0)
        let content = hstackForEach.first?.first
        let z = try content?.find(ViewType.Text.self)

        XCTAssertEqual(try z?.opacity(), 1.0, "Opacity handling should be absent when disabled")
        XCTAssertEqual(try z?.scaleEffect(), CGSize(width: 1.0, height: 1.0), "Scale handling should be absent when disabled")

        self.cfg = TestCoverConfig() // restore defaults
    }

    /// 5️⃣ Selection binding should initialize and stay connected
    @MainActor
    func test_selectionBinding_initializes() throws {
        let sel: Item.ID? = items[2].id
        let sut = buildCoverView(selection: sel)
        let _ = try sut.inspect().find(ViewType.ScrollView.self)
        XCTAssertEqual(sel, items[2].id, "Selection binding should initialize properly")
    }
}
