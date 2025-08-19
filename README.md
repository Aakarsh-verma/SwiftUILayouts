# SwiftUILayouts

SwiftUILayouts is a Swift Package providing a collection of reusable SwiftUI layouts and UI components. It is designed for iOS developers who want to quickly build modern and customizable interfaces with minimal boilerplate. The package leverages **SwiftUI** and integrates with **[Kingfisher](https://github.com/onevcat/Kingfisher)** for efficient image loading and caching.

---

## Features

- 📐 **Reusable Layouts** – Predefined SwiftUI layouts for carousels, grids, and cards.  
- 🎨 **Customizable Components** – Highly flexible with configuration models.  
- 🖼️ **Image Handling** – Supports remote and local images via Kingfisher.  
- 🚀 **Swift Package Manager (SPM)** – Easy integration into your project.  
- ✅ **Unit Tests Included** – Ensures reliability and easy extension.  

---

## Requirements

- **iOS**: 17.0+  
- **Swift**: 6.0+  
- **Xcode**: 15.0+  

---

## Installation

### Swift Package Manager

In Xcode:

1. Go to **File → Add Packages...**  
2. Enter the repository URL:  

   ```bash
   https://github.com/your-username/SwiftUILayouts.git
   ```
3. Select the latest version and add the package to your project.

---

## Usage

### Import the Package

```swift
import SwiftUILayouts
```

### Example: Carousel View

```swift
struct DemoView: View {
    let images: [CustomImageModel] = [
        CustomImageModel(for: "https://picsum.photos/200"),
        CustomImageModel(for: "https://picsum.photos/300"),
        CustomImageModel(for: "mylocalImage")
    ]

    var body: some View {
        StackCarouselView(items: images, currentIndex: .constant(0)) { item in
            CustomImageView(imageModel: item)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(radius: 5)
        }
        .frame(height: 300)
    }
}
```

### Example: Custom Configurations

```swift
struct ConfiguredCarousel: View {
    @State private var index = 0

    var body: some View {
        StackCarouselView(
            items: Array(1...5),
            config: SLStackCarouselModel(
                cardWidthRatio: 0.8,
                cardSizeDifferenceRatio: 0.05,
                cardOffsetDifference: 20,
                visibleCardIndexDifference: 3,
                showSelected: true
            ),
            currentIndex: $index
        ) { number in
            Text("Item \(number)")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.blue.opacity(0.7))
                .cornerRadius(12)
        }
        .frame(height: 250)
    }
}
```

---

## Project Structure

```
SwiftUILayouts/
├── Package.swift
├── Sources/
│   └── SwiftUILayouts/
│       ├── Models/
│       ├── Views/
│       └── Utilities/
└── Tests/
    └── SwiftUILayoutsTests/
```

- **Sources/SwiftUILayouts** – Core components and layouts.  
- **Tests/SwiftUILayoutsTests** – Unit tests for reliability.  

---

## Dependencies

- [Kingfisher](https://github.com/onevcat/Kingfisher) – A powerful Swift library for downloading and caching images from the web.

---

## Contributing

Contributions are welcome! 🎉  
If you’d like to fix bugs or add new features:

1. Fork the repo  
2. Create a feature branch: `git checkout -b feature/my-feature`  
3. Commit your changes: `git commit -m "Add my feature"`  
4. Push and open a PR  

---

## License

This project is licensed under the **MIT License**.  
See [LICENSE](LICENSE) for details.  
