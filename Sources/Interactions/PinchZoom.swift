//
//  PinchZoom.swift
//  SwiftUILayouts
//
//  Created by Aakarsh Verma on 19/10/25.
//

import SwiftUI

// MARK: - View Extension

public extension View {

    /**
     Applies a pinch-to-zoom and two-finger pan gesture to the current view.

     Use `pinchZoom()` to enable both pinch and pan gestures simultaneously on any SwiftUI view,
     such as images or custom compositions. The modifier supports natural two-finger interaction,
     with automatic reset when the gesture ends.

     Example:
     ```swift
     Image("photo")
         .resizable()
         .scaledToFit()
         .pinchZoom()
     ```

     - Returns: A view wrapped with simultaneous pinch and pan gesture handling.
     */
    @ViewBuilder
    func pinchZoom() -> some View {
        PinchZoomHelper {
            self
        }
    }
}

// MARK: - Pinch Zoom Helper

/**
 A SwiftUI helper view that manages gesture states for pinch and pan simultaneously.

 `PinchZoomHelper` acts as the core of the pinch-zoom modifier. It uses a `UIViewRepresentable`
 overlay to capture UIKit gestures and translates them into SwiftUI bindings through `ZoomConfig`.

 The scaling and panning behavior is animated using `.snappy` animation when reset.

 - Parameters:
    - Content: The original SwiftUI view being magnified or panned.
 */
internal struct PinchZoomHelper<Content: View>: View {
    @ViewBuilder var content: Content
    @State private var config: ZoomConfig = .init()
    @State private var zoom: CGFloat = 1
    @State private var anchor: UnitPoint = .center
    @State private var dragOffset: CGSize = .zero
    
    var body: some View {
        content
            .scaleEffect(zoom, anchor: anchor)
            .offset(dragOffset)
            .overlay(GestureOverlay(config: $config))
            .overlay {
                Color.clear
                    .onChange(of: config.isActive) { _, newValue in
                        handleGestureStateChange(newValue)
                    }
                    .onChange(of: config) { _, _ in
                        handleZoomingAndPanning()
                    }
            }
    }

    /**
     Handles activation and deactivation of the gesture state.

     - Parameter isActive: A Boolean indicating if the gesture is currently active.
     */
    private func handleGestureStateChange(_ isActive: Bool) {
        if isActive {
            anchor = config.anchor
        } else {
            resetZoomState()
        }
    }

    /// Resets the zoom and pan state to default using a snappy animation.
    private func resetZoomState() {
        withAnimation(.snappy(duration: 0.2, extraBounce: 0), completionCriteria: .logicallyComplete) {
            dragOffset = .zero
            zoom = 1
        } completion: {
            config = .init()
        }
    }

    /**
     Updates zoom and pan properties based on gesture configuration changes.
     */
    private func handleZoomingAndPanning() {
        guard config.isActive else { return }
        let isScaleChanged = abs(zoom - config.zoom) > 0.01
        let isPanChangedX = abs(dragOffset.width - config.dragOffset.width) > 5.0
        let isPanChangedY = abs(dragOffset.height - config.dragOffset.height) > 5.0
        let isPanChanged = isPanChangedX || isPanChangedY

        if isScaleChanged { zoom = config.zoom }
        if isPanChanged { dragOffset = config.dragOffset }
    }
}

// MARK: - Zoom Configuration

/**
 Captures the current interaction state for pinch-zoom gestures.

 `ZoomConfig` acts as a bridge between UIKit gesture handlers and SwiftUI states.
 It is `Equatable` to prevent redundant state updates.

 - Properties:
    - isActive: Whether a zoom or pan gesture is currently happening.
    - zoom: The current zoom level, default is `1.0`.
    - anchor: The anchor point for the scale effect in normalized coordinates.
    - dragOffset: The offset applied when panning with two fingers.
 */
internal struct ZoomConfig: Equatable {
    var isActive: Bool = false
    var zoom: CGFloat = 1
    var anchor: UnitPoint = .center
    var dragOffset: CGSize = .zero
}

// MARK: - Gesture Overlay

/**
 A `UIViewRepresentable` component that injects UIKit gestures into SwiftUI.

 `GestureOverlay` combines `UIPinchGestureRecognizer` and `UIPanGestureRecognizer`
 to allow natural, simultaneous pinch and pan interactions.

 The configuration state is continuously updated via its `@Binding` property.
 */
internal struct GestureOverlay: UIViewRepresentable {
    @Binding var config: ZoomConfig

    func makeCoordinator() -> Coordnator {
        Coordnator(config: $config)
    }

    func makeUIView(context: Context) -> some UIView {
        let view = UIView()
        view.backgroundColor = .clear

        // Pan Gesture
        let panGesture = UIPanGestureRecognizer()
        panGesture.name = "PINCHPANGESTURE"
        panGesture.minimumNumberOfTouches = 2
        panGesture.addTarget(context.coordinator, action: #selector(Coordnator.handlePanGesture(_:)))
        panGesture.delegate = context.coordinator
        view.addGestureRecognizer(panGesture)

        // Pinch Gesture
        let pinchGesture = UIPinchGestureRecognizer()
        pinchGesture.name = "PINCHZOOMGESTURE"
        pinchGesture.addTarget(context.coordinator, action: #selector(Coordnator.handlePinchGesture(_:)))
        pinchGesture.delegate = context.coordinator
        view.addGestureRecognizer(pinchGesture)

        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}

    // MARK: - Coordinator

    /**
     A UIKit coordinator that handles simultaneous pinch and pan gestures.

     The coordinator transmits current gesture data (scale, anchor, and translation)
     back into SwiftUI's state via a binding to `ZoomConfig`.
     */
    class Coordnator: NSObject, UIGestureRecognizerDelegate {
        @Binding var config: ZoomConfig
        
        init(config: Binding<ZoomConfig>) {
            _config = config
        }

        /// Handles two-finger pan gestures.
        @objc
        func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
            if gesture.state == .began || gesture.state == .changed {
                let translation = gesture.translation(in: gesture.view)
                config.dragOffset = .init(width: translation.x, height: translation.y)
                config.isActive = true
            } else {
                config.isActive = false
            }
        }

        /// Handles pinch gestures and determines anchor position dynamically.
        @objc
        func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
            if gesture.state == .began {
                let location = gesture.location(in: gesture.view)
                if let bounds = gesture.view?.bounds {
                    config.anchor = .init(x: location.x / bounds.width, y: location.y / bounds.height)
                }
            }
            if gesture.state == .began || gesture.state == .changed {
                let scale = max(1, gesture.scale)
                config.zoom = scale
                config.isActive = true
            } else {
                config.isActive = false
            }
        }

        /// Enables simultaneous recognition of both pinch and pan gestures.
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            if gestureRecognizer.name == "PINCHPANGESTURE" && otherGestureRecognizer.name == "PINCHZOOMGESTURE" {
                return true
            }
            return false
        }
    }
}
