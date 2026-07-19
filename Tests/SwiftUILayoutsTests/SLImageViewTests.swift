//
//  SLImageViewTests.swift
//  SwiftUILayoutsTests
//
//  Created by Aakarsh Verma on 23/10/25.
//

import XCTest
import SwiftUI
import ViewInspector
import Kingfisher
@testable import SwiftUILayouts

// MARK: - Mock Image Model

private struct MockImageModel: SLImageModel {
    var image: String
    var placeHolderImage: String? = nil

    var isRemoteImage: Bool {
        image.hasPrefix("http")
    }

    var isAssetImage: Bool {
        UIImage(named: image) != nil
    }
}

// MARK: - Test Suite

@MainActor
final class SLImageViewTests: XCTestCase {

    // MARK: - Remote URL Image Tests

    func test_remoteImage_usesKFImage() throws {
        let model = MockImageModel(image: "https://example.com/sample.jpg")
        let sut = SLImageView(model)
        ViewHosting.host(view: sut)
        defer { ViewHosting.expel() }

        // Verify presence of KFImage (remote loader)
        XCTAssertNoThrow(try sut.inspect().find(ViewType.View<KFImage>.self),
                         "Should use KFImage for remote images")
    }

    func test_remoteImage_showsPlaceholder_whenProvided() throws {
        let model = MockImageModel(image: "https://example.com/sample.jpg", placeHolderImage: "localPlaceholder")
        let sut = SLImageView(model)
        ViewHosting.host(view: sut)
        defer { ViewHosting.expel() }

        // Verify placeholder Image content exists
        let placeholder = try sut.inspect().find(ViewType.Image.self)
        XCTAssertNoThrow(placeholder, "Placeholder should render when provided")
    }

    @MainActor
    func test_remoteImage_showsSystemPlaceholder_whenNoPlaceholder() throws {
        let model = MockImageModel(image: "https://example.com/sample.jpg", placeHolderImage: nil)
        let sut = SLImageView(model)
        ViewHosting.host(view: sut)
        defer { ViewHosting.expel() }

        // Collect all Image views in the hierarchy
        let images = try sut.inspect().findAll(ViewType.Image.self)

        // Try to read a system image name where supported; ignore others (e.g., UIImage-backed)
        let systemNames: [String] = images.compactMap { img in
            // `name()` only succeeds for system images; use optional try to avoid throwing
            try? img.actualImage().name()
        }

        XCTAssertTrue(systemNames.contains("photo.fill"),
                      "Expected fallback system placeholder 'photo.fill' to appear among rendered images")
    }

    // MARK: - Local Asset Tests

    func test_localAssetImage_usesImageView() throws {
        let model = MockImageModel(image: "testAsset")
        let sut = SLImageView(model)
        ViewHosting.host(view: sut)
        defer { ViewHosting.expel() }

        XCTAssertNoThrow(try sut.inspect().find(ViewType.Image.self),
                         "Should render Image view for local assets")
    }

    // MARK: - SF Symbol / Default Image Tests

    func test_systemImage_fallback_whenNotRemoteOrAsset() throws {
        let model = MockImageModel(image: "star.fill")
        let sut = SLImageView(model)
        ViewHosting.host(view: sut)
        defer { ViewHosting.expel() }

        let image = try sut.inspect().find(ViewType.Image.self)
        let name = try image.actualImage().name()
        XCTAssertEqual(name, "star.fill", "Should fallback to system image when not remote or asset")
    }
}
