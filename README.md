# GMarkdown

[GMarkdown](https://github.com/GIKICoder/GMarkdown.git) is a powerful and versatile Markdown rendering library designed for Swift developers. Built on top of the swift-markdown parser, GMarkdown offers pure native rendering capabilities, ensuring seamless integration and high performance for your iOS applications.

GMarkdown is currently in the testing phase. Although efforts have been made to support different styles of markdown, some code-level optimizations and modifications are still needed to make the GMarkdown architecture more reasonable. If time permits, part of the code logic will be redesigned in the future.

## Features

- **Pure Native Rendering**: Enjoy the benefits of pure native rendering for all your markdown content, ensuring fast and efficient performance.
- **Rich Text Support**: GMarkdown supports a wide range of rich text styles, making your markdown content look professional and polished.
- **Image Rendering**: Effortlessly render images within your markdown content.
- **Code Blocks**: Display code with syntax highlighting, making it easy to present and read code snippets.
- **Tables**: Create and render tables to organize your data effectively.
- **LaTeX Math Formulas**: Render complex mathematical equations using LaTeX, perfect for academic and scientific content.

## Requirements

[GMarkdown](https://github.com/GIKICoder/GMarkdown.git) works on iOS 13+ and depends on the following frameworks:

- [swift-markdown](https://github.com/apple/swift-markdown.git)
- [SwiftMath](https://github.com/mgriebling/SwiftMath.git)
- [MPITextKit](https://github.com/meitu/MPITextKit.git)
- [Highlightr](https://github.com/raspu/Highlightr.git)

## Installation

### Swift Package Manager

GMarkdown is available through Swift Package Manager. To include it in your project, add the following to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/GIKICoder/GMarkdown.git", from: "0.0.1")
]
```

### CocoaPods

If you prefer using CocoaPods, you can integrate GMarkdown via [cocoapods-spm](https://github.com/kronenthaler/cocoapods-spm):

```ruby
spm_pkg "GMarkdown", :url => "https://github.com/GIKICoder/GMarkdown.git", :branch => "main"
```

## Usage

### Initialization

To initialize and add a GMarkdown view to your view hierarchy:

```swift
let markdownView = GMarkdownMultiView()
view.addSubview(markdownView)
markdownView.frame = view.bounds
```

### Example

Here's a complete example of how to load and render Markdown content from a file:

```swift
func setupMarkdown() async {
    guard let filepath = Bundle.main.path(forResource: "markdown", ofType: nil),
          let filecontents = try? String(contentsOfFile: filepath, encoding: .utf8) else {
        return
    }

    let chunks = await parseMarkdown(filecontents)

    DispatchQueue.main.async { [weak self] in
        self?.markdownView.updateMarkdown(chunks)
    }
}

func parseMarkdown(_ content: String) async -> [GMarkChunk] {
    return await withCheckedContinuation { continuation in
        DispatchQueue.global(qos: .userInitiated).async {
            let processor = GMarkProcessor()
            let chunks = processor.process(markdown: content)
            continuation.resume(returning: chunks)
        }
    }
}
```

## Screenshots

<a href="https://github.com/GIKICoder/GMarkdown/blob/main/screenshot/1.png"><img src="https://github.com/GIKICoder/GMarkdown/blob/main/screenshot/1.png" alt="Screenshot 1" width="300"/></a>
<a href="https://github.com/GIKICoder/GMarkdown/blob/main/screenshot/2.png"><img src="https://github.com/GIKICoder/GMarkdown/blob/main/screenshot/2.png" alt="Screenshot 2" width="300"/></a>
<a href="https://github.com/GIKICoder/GMarkdown/blob/main/screenshot/3.png"><img src="https://github.com/GIKICoder/GMarkdown/blob/main/screenshot/3.png" alt="Screenshot 3" width="300"/></a>
<a href="https://github.com/GIKICoder/GMarkdown/blob/main/screenshot/4.png"><img src="https://github.com/GIKICoder/GMarkdown/blob/main/screenshot/4.png" alt="Screenshot 4" width="300"/></a>
<a href="https://github.com/GIKICoder/GMarkdown/blob/main/screenshot/5.png"><img src="https://github.com/GIKICoder/GMarkdown/blob/main/screenshot/5.png" alt="Screenshot 5" width="300"/></a>


## License

GMarkdown is released under the MIT license. See [LICENSE](./LICENSE) for details.

## Contributions

Contributions are welcome! Please submit pull requests or open issues to help improve GMarkdown.

---



Happy coding!
