[GMarkdown](https://github.com/GIKICoder/GMarkdown.git) 是一个专为 Swift 开发者设计的强大且多功能的 Markdown 渲染库。基于 swift-markdown 解析器构建，GMarkdown 提供纯原生的渲染能力，确保无缝集成和高性能的 iOS 应用。

## 特性

- **纯原生渲染**：享受所有 Markdown 内容的纯原生渲染优势，确保快速高效的性能。
- **富文本支持**：支持多种富文本样式，使您的 Markdown 内容看起来专业而精致。
- **图片渲染**：轻松渲染 Markdown 内容中的图片。
- **代码块**：显示带有语法高亮的代码块，便于代码片段的展示和阅读。
- **表格**：创建和渲染表格，有效组织数据。
- **LaTeX 数学公式**：使用 LaTeX 渲染复杂的数学方程，适用于学术和科学内容。

## 要求

[GMarkdown](https://github.com/GIKICoder/GMarkdown.git) 适用于 iOS 13 及以上版本，并依赖以下框架：

- [swift-markdown](https://github.com/apple/swift-markdown.git)
- [SwiftMath](https://github.com/mgriebling/SwiftMath.git)
- [MPITextKit](https://github.com/meitu/MPITextKit.git)
- [Highlightr](https://github.com/raspu/Highlightr.git)

## 安装

### Swift Package Manager

GMarkdown 可以通过 Swift Package Manager 获取。在您的项目中添加以下内容到 `Package.swift`：

```swift
dependencies: [
    .package(url: "https://github.com/GIKICoder/GMarkdown.git", from: "0.0.1")
]
```

### CocoaPods

如果您需要使用 CocoaPods，可以通过 [cocoapods-spm](https://github.com/kronenthaler/cocoapods-spm)插件 集成 GMarkdown：

```ruby
spm_pkg "GMarkdown", :url => "https://github.com/GIKICoder/GMarkdown.git", :branch => "main"
```

## 使用

### 初始化

要初始化并将 GMarkdown 视图添加到您的视图层次结构中：

```swift
let markdownView = GMarkdownMultiView()
view.addSubview(markdownView)
markdownView.frame = view.bounds
```

### 示例

以下是从文件加载和渲染 Markdown 内容的完整示例：

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

## 截图

<a href="https://github.com/GIKICoder/GMarkdown/blob/main/screenshot/1.png"><img src="https://github.com/GIKICoder/GMarkdown/blob/main/screenshot/1.png" alt="Screenshot 1" width="300"/></a>
<a href="https://github.com/GIKICoder/GMarkdown/blob/main/screenshot/2.png"><img src="https://github.com/GIKICoder/GMarkdown/blob/main/screenshot/2.png" alt="Screenshot 2" width="300"/></a>
<a href="https://github.com/GIKICoder/GMarkdown/blob/main/screenshot/3.png"><img src="https://github.com/GIKICoder/GMarkdown/blob/main/screenshot/3.png" alt="Screenshot 3" width="300"/></a>
<a href="https://github.com/GIKICoder/GMarkdown/blob/main/screenshot/4.png"><img src="https://github.com/GIKICoder/GMarkdown/blob/main/screenshot/4.png" alt="Screenshot 4" width="300"/></a>
<a href="https://github.com/GIKICoder/GMarkdown/blob/main/screenshot/5.png"><img src="https://github.com/GIKICoder/GMarkdown/blob/main/screenshot/5.png" alt="Screenshot 5" width="300"/></a>


## 许可证

GMarkdown 在 MIT 许可证下发布。详细信息请参见 [LICENSE](./LICENSE)。

## 贡献

欢迎贡献！请提交 pull requests 或打开 issues 以帮助改进 GMarkdown。
