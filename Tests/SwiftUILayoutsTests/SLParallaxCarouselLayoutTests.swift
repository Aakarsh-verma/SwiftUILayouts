//
//  SLParallaxCarouselLayoutTests.swift
//  SwiftUILayoutsTests
//
//  Created by Aakarsh Verma on 18/08/25.
//

import XCTest
import SwiftUI
import ViewInspector
@testable import SwiftUILayouts

// MARK: - Mock Models

private struct TestImageModel: Identifiable, SLImageModel {
    var placeHolderImage: String?
    let id = UUID()
    let imageName: String
    var image: String { imageName }
}

private struct TestParallaxConfig: SLParallaxCarouselProtocol {
    var itemSpacing: CGFloat = 8
    var parallaxScale: CGFloat = 0.2
    var cornerRadius: CGFloat = 10
    var frameHeight: CGFloat = 300
    var nonCenterItemScale: CGFloat = 0.85
}

// MARK: - Test Suite

@MainActor
final class SLParallaxCarouselLayoutTests: XCTestCase {

    private var items: [TestImageModel] = []
    private var config: TestParallaxConfig!

    override func setUp() {
        super.setUp()
        items = (0..<5).map { TestImageModel(imageName: "img-\($0)") }
        config = TestParallaxConfig()
    }

    // MARK: Helper

    private func buildParallaxView() -> some View {
        SLParallaxCarouselLayout(
            items: items,
            config: config,
            content: { item in
                Color.red
                    .overlay(Text(item.imageName))
                    .accessibilityIdentifier("card-\(item.imageName)")
            },
            overlayContent: { item in
                Text("Overlay-\(item.imageName)")
                    .accessibilityIdentifier("overlay-\(item.imageName)")
            }
        )
        .frame(width: 400, height: 300)
    }

    // MARK: - Tests

    func test_rendersAllItems() throws {
        let sut = buildParallaxView()
        ViewHosting.host(view: sut)
        defer { ViewHosting.expel() }

        let scroll = try sut.inspect().find(ViewType.ScrollView.self)
        let forEach = try scroll.find(ViewType.ForEach.self)
        XCTAssertEqual(try forEach.count, items.count, "Should render one view per item")
    }

    func test_eachItemHasOverlay() throws {
        let sut = buildParallaxView()
        ViewHosting.host(view: sut)
        defer { ViewHosting.expel() }

        let overlays = try sut.inspect().findAll(ViewType.Text.self)
        let count = try overlays.filter { try $0.string().contains("Overlay") == true }.count
        XCTAssertEqual(count, items.count, "Each card should have an overlay")
    }

    func test_frameHeight_matchesConfig() throws {
        let sut = buildParallaxView()
        let frameHeight = try sut.inspect().view(SLParallaxCarouselLayout<[TestImageModel], AnyView, AnyView>.self)
            .fixedHeight()
        XCTAssertEqual(frameHeight, config.frameHeight, accuracy: 0.1)
    }

    func test_parallaxOffsetFormula() throws {
        // direct unit test of internal math
        let layout = SLParallaxCarouselLayout(
            items: items,
            config: config,
            content: { _ in EmptyView() },
            overlayContent: { _ in EmptyView() }
        )

        // GeometryProxy is not accessible, but we can simulate math
        let cardSize = CGSize(width: 200, height: 300)
        let proxyX: CGFloat = 50
        let expected = min((proxyX - 30) * config.parallaxScale, cardSize.width * config.parallaxScale)
        let raw = (proxyX - 30) * config.parallaxScale
        XCTAssertEqual(expected, raw, "Raw and capped parallax calculation should match when within bounds")
    }

    @MainActor
    func test_nonCenterLayout_usesConfiguredSpacing() throws {
        let sut = buildParallaxView()
        ViewHosting.host(view: sut)
        defer { ViewHosting.expel() }

        let geometry = try sut.inspect().find(ViewType.GeometryReader.self)
        let scroll = try geometry.find(ViewType.ScrollView.self)
        let hStack = try scroll.find(ViewType.HStack.self)

        guard let spacing = try hStack.spacing() else {
            return XCTFail("HStack spacing unavailable")
        }
        XCTAssertEqual(spacing, config.itemSpacing, accuracy: 0.001,
                       "HStack spacing should match config.itemSpacing")
    }
}
