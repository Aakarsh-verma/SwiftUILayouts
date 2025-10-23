//
//  PinchZoomTests.swift
//  SwiftUILayouts
//
//  Created by Aakarsh Verma on 23/10/25.
//


import XCTest
import SwiftUI
import ViewInspector
@testable import SwiftUILayouts

// Make our custom SwiftUI types inspectable

@MainActor
final class PinchZoomTests: XCTestCase {

    // A simple test content view
    struct TestContent: View {
        var body: some View {
            Rectangle()
                .fill(.blue)
                .frame(width: 100, height: 100)
                .pinchZoom()
        }
    }

    // MARK: - Tests

    func test_initialZoomState_defaultsToOne() throws {
        let sut = TestContent()
        ViewHosting.host(view: sut); defer { ViewHosting.expel() }

        let zoomHelper = try sut.inspect().find(PinchZoomHelper<ModifiedContent<_ShapeView<Rectangle, Color>, _FrameLayout>>.self)
        let mirror = Mirror(reflecting: try zoomHelper.actualView())
        let zoomValue = mirror.children.first { $0.label == "_zoom" }?.value as? State<CGFloat>
        XCTAssertEqual(zoomValue?.wrappedValue ?? 0.0, 1, "Default zoom should start at 1.0")
    }

    func test_pinchGesture_updatesConfigZoomAndAnchor() {
        let view = UIView(frame: .init(x: 0, y: 0, width: 100, height: 100))
        var config = ZoomConfig()
        let coordinator = GestureOverlay.Coordnator(config: .init(get: { config }, set: { config = $0 }))

        let pinch = UIPinchGestureRecognizer()
        pinch.scale = 2.3
        pinch.state = .began
        pinch.location(in: view)

        coordinator.handlePinchGesture(pinch)
        XCTAssertTrue(config.isActive)
        XCTAssertGreaterThan(config.zoom, 1.0)
    }

    func test_panGesture_updatesConfigDragOffset() {
        var config = ZoomConfig()
        let coordinator = GestureOverlay.Coordnator(config: .init(get: { config }, set: { config = $0 }))

        let pan = UIPanGestureRecognizer()
        pan.state = .changed

        coordinator.handlePanGesture(pan)
        XCTAssertTrue(config.isActive)
        XCTAssertEqual(config.dragOffset.width, 0.0, accuracy: 0.1)
        XCTAssertEqual(config.dragOffset.height, 0.0, accuracy: 0.1)
    }

    func test_gestureSimultaneousRecognition_allowedForPinchAndPan() {
        let coord = GestureOverlay.Coordnator(config: .constant(.init()))
        let pinch = UIPinchGestureRecognizer()
        pinch.name = "PINCHZOOMGESTURE"
        let pan = UIPanGestureRecognizer()
        pan.name = "PINCHPANGESTURE"

        XCTAssertTrue(coord.gestureRecognizer(pan, shouldRecognizeSimultaneouslyWith: pinch))
        XCTAssertFalse(coord.gestureRecognizer(pinch, shouldRecognizeSimultaneouslyWith: pan))
    }
}
