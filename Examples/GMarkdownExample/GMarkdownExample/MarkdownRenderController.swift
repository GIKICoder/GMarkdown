//
//  MarkdownRenderController.swift
//  GMarkdownExample
//
//  Created by GIKI on 2024/8/1.
//

import UIKit

class MarkdownRenderController: UIViewController {
  
  
  let markdownView = GMarkdownMultiView()
  override func viewDidLoad() {
    super.viewDidLoad()
    GMarkPluginManager.shared.imageLoader = NukeImageLoader()
    view.addSubview(markdownView)
    markdownView.frame = view.bounds
    // Do any additional setup after loading the view.
//    GMarkPluginManager.shared.imageLoader = GNukeImageLoader()
      Task {
          await setupMarkdown()
      }
  }
  
  
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
              let processor = GMarkProcessor(parser: GMarkParser(), chunkGenerator: GMarkChunkGenerator())
              let chunks = processor.process(markdown: content)
              continuation.resume(returning: chunks)
          }
      }
  }
}
