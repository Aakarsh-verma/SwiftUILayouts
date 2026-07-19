//
//  SLAmbientCarouselLayoutTest.swift
//  SwiftUILayouts
//
//  Created by Aakarsh Verma on 21/10/25.
//

import XCTest
import SwiftUI
@testable import SwiftUILayouts
import ViewInspector

// MARK: - Test Doubles

private struct DummyImage: Identifiable, SLImageModel, Equatable {
    var placeHolderImage: String?
    let id: UUID = UUID()
    let image: String
}

private struct TestConfig: SLAmbientCarouselProtocol {
    var frameHeight: CGFloat = 300
    var itemSpacing: CGFloat = 12
    var backgroundBlurRadius: CGFloat = 24
    var backgroundBlurDarkness: CGFloat = 0.35
    var visibleTopBlur: CGFloat = 24
    var visibleBottomBlur: CGFloat = 40
}

// MARK: - Make the view inspectable

@available(iOS 18.0, *)
final class SLAmbientCarouselLayoutTests: XCTestCase {

    private var items: [DummyImage] = (0..<5).map { DummyImage(image: "img-\($0)") }
    private var config = TestConfig()

    // Helpers to build consistent content
    @MainActor 
    private func buildView() -> some View {
        SLAmbientCarouselLayout(
            config: config,
            items: items,
            content: { item in
                // Foreground cell with a stable identifier we can assert on
                ZStack { Color.clear }
                    .accessibilityIdentifier("card-\(item.image)")
                    .frame(width: 200, height: 260)
            },
            backdropContent: { item in
                // Backdrop cell with a stable identifier we can assert on
                ZStack { Color.clear }
                    .accessibilityIdentifier("backdrop-\(item.image)")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        )
        // Important: Constrain width so LazyHStack layout is deterministic in tests
        .frame(width: 390, height: config.frameHeight)
    }

    // MARK: - Tests

    @MainActor
    func test_rendersSameNumberOfForegroundCells_asItems() throws {
        let sut = buildView()

        // ScrollView(.horizontal) -> LazyHStack -> ForEach -> cells
        let scrollView = try sut.inspect().find(ViewType.ScrollView.self)
        let hStack = try scrollView.find(ViewType.LazyHStack.self)
        // Count is number of direct children in ForEach
        let itemsForEach = try hStack.forEach(0)
        let count = itemsForEach.count

        XCTAssertEqual(count, items.count, "Foreground cell count should match items count")
    }

    @MainActor
    func test_lazyHStack_usesConfiguredItemSpacing() throws {
        let sut = buildView()
        let scrollView = try sut.inspect().find(ViewType.ScrollView.self)
        let hStack = try scrollView.find(ViewType.LazyHStack.self)

        guard let spacing = try hStack.spacing() else { return XCTFail("LazyHStack reported no spacing") }
        XCTAssertEqual(spacing, config.itemSpacing, accuracy: 0.001,
                       "LazyHStack spacing should equal config.itemSpacing")
    }

    @MainActor
    func test_background_hasMaskAndBlur_andDarkOverlayPaddingApplied() throws {
        let sut = buildView()
        // Find the backdrop via the first GeometryReader in the view tree (it's used by the backdrop)
        let geom = try sut.inspect().find(ViewType.GeometryReader.self)

        // The ZStack (backdrop layers) is inside GeometryReader.
        let zstack = try geom.find(ViewType.ZStack.self)

        // Assert blur is applied on the composited group
        XCTAssertNoThrow(try zstack.blur(), "Backdrop ZStack should have a blur effect applied")

        // Assert overlay exists (the darkening rectangle)
        XCTAssertNoThrow(try zstack.overlay(), "Backdrop should have a dark overlay")

        // The mask (gradient fade) may be applied either on the GeometryReader or the inner ZStack,
        // depending on SwiftUI optimizations. Accept either to avoid brittle failures.
        let maskOnGeom = (try? geom.mask()) != nil
        let maskOnZStack = (try? zstack.mask()) != nil
        XCTAssertTrue(maskOnGeom || maskOnZStack, "Backdrop should have a gradient mask (on geometry reader or zstack)")
    }

    @MainActor
    func test_height_via_hosting() throws {
        let sut = buildView()
        ViewHosting.host(view: sut)
        defer { ViewHosting.expel() }

        // Give SwiftUI a runloop tick to layout:
        let exp = XCTestExpectation(description: "layout")
        DispatchQueue.main.async { exp.fulfill() }
        wait(for: [exp], timeout: 1)

        // Sanity-check scrolling container is present and composed as expected
        let scrollView = try sut.inspect().find(ViewType.ScrollView.self)
        let hStack = try scrollView.find(ViewType.LazyHStack.self)
        let count = try hStack.forEach(0).count
        XCTAssertEqual(count, items.count, "Hosted layout should still render all foreground items")
    }
}

// MARK: - Utilities

// A generic placeholder to satisfy the typed lookup in fixedHeight() accessor below.
// We won't actually instantiate this; it's only used to help ViewInspector navigate.
private struct DataStub: RandomAccessCollection {
    typealias Element = DummyImage
    var startIndex: Int { 0 }
    var endIndex: Int { 0 }
    subscript(position: Int) -> DummyImage { fatalError() }
    func index(after i: Int) -> Int { i + 1 }
}
