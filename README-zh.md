# GMarkdown

[GMarkdown](https://github.com/GIKICoder/GMarkdown.git) 是一个专为 Swift 开发者设计的强大且多功能的 Markdown 渲染库。基于 swift-markdown 解析器构建，GMarkdown 提供纯原生渲染能力，确保与您的 iOS 应用程序无缝集成和高性能表现。

GMarkdown 目前处于测试阶段。尽管我们已经努力支持不同风格的 Markdown，但仍需要一些代码级别的优化和修改，以使 GMarkdown 架构更加合理。如果时间允许，未来将重新设计部分代码逻辑。

## 功能特性

- **纯原生渲染**: 享受纯原生渲染带来的优势，确保所有 Markdown 内容都能快速高效地呈现。
- **富文本支持**: GMarkdown 支持多种富文本样式，让您的 Markdown 内容看起来专业而精美。
- **图片渲染**: 轻松在 Markdown 内容中渲染图片。
- **代码块**: 支持语法高亮显示代码，让代码片段更易于展示和阅读。
- **表格**: 创建和渲染表格，有效组织您的数据。
- **LaTeX 数学公式**: 使用 LaTeX 渲染复杂的数学方程式，非常适合学术和科学内容。
- **Mermaid 图表**: 使用 Mermaid 语法创建精美的流程图、时序图和其他可视化图表。
- **HTML 预览**: 在 Markdown 文档中无缝预览和渲染 HTML 内容，提供更强的格式化灵活性。

## 系统要求

[GMarkdown](https://github.com/GIKICoder/GMarkdown.git) 支持 iOS 13+ 并依赖以下框架：

- [swift-markdown](https://github.com/apple/swift-markdown.git)
- [SwiftMath](https://github.com/mgriebling/SwiftMath.git)
- [MPITextKit](https://github.com/meitu/MPITextKit.git)
- [Highlightr](https://github.com/raspu/Highlightr.git)

## 安装

### Swift Package Manager

GMarkdown 可通过 Swift Package Manager 获取。要将其包含在您的项目中，请将以下内容添加到您的 `Package.swift`：

```swift
dependencies: [
    .package(url: "https://github.com/GIKICoder/GMarkdown.git", from: "0.0.6")
]
```

### CocoaPods

如果您更喜欢使用 CocoaPods，可以通过 [cocoapods-spm](https://github.com/kronenthaler/cocoapods-spm) 集成 GMarkdown：

```ruby
spm_pkg "GMarkdown", :url => "https://github.com/GIKICoder/GMarkdown.git", :branch => "main"
```

## 使用方法

### 初始化

初始化并将 GMarkdown 视图添加到您的视图层次结构中：

```swift
let markdownView = GMarkdownMultiView()
view.addSubview(markdownView)
markdownView.frame = view.bounds
```

### 示例

以下是如何从文件加载和渲染 Markdown 内容的完整示例：

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

## 截图展示

<a href="https://github.com/GIKICoder/GMarkdown/blob/main/screenshot/1.png"><img src="https://github.com/GIKICoder/GMarkdown/blob/main/screenshot/1.png" alt="截图 1" width="300"/></a>
<a href="https://github.com/GIKICoder/GMarkdown/blob/main/screenshot/2.png"><img src="https://github.com/GIKICoder/GMarkdown/blob/main/screenshot/2.png" alt="截图 2" width="300"/></a>
<a href="https://github.com/GIKICoder/GMarkdown/blob/main/screenshot/3.png"><img src="https://github.com/GIKICoder/GMarkdown/blob/main/screenshot/3.png" alt="截图 3" width="300"/></a>
<a href="https://github.com/GIKICoder/GMarkdown/blob/main/screenshot/4.png"><img src="https://github.com/GIKICoder/GMarkdown/blob/main/screenshot/4.png" alt="截图 4" width="300"/></a>
<a href="https://github.com/GIKICoder/GMarkdown/blob/main/screenshot/5.png"><img src="https://github.com/GIKICoder/GMarkdown/blob/main/screenshot/5.png" alt="截图 5" width="300"/></a>

## 许可证

GMarkdown 基于 MIT 许可证发布。详情请参阅 [LICENSE](./LICENSE)。

## 贡献

欢迎贡献！请提交 Pull Request 或创建 Issue 来帮助改进 GMarkdown。

---
