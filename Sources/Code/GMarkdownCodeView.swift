//
//  GMarkdownCodeView.swift
//  GMarkRender
//
//  Created by GIKI on 2024/7/25.
//

import UIKit
import MPITextKit

class GMarkdownCodeView: UIView {
  private var container: UIView!
  private var topView: UIView!
  private var languageLabel: UILabel!
  private var scrollView: UIScrollView!
  private var codeCopyButton: UIButton!
  private var codeLabel: MPILabel!
  
  public var onCopy: ((String) -> Void)?
  
  var markChunk: GMarkChunk? {
    didSet {
      guard let markChunk = markChunk else { return }
      languageLabel.text = markChunk.language
      if let textRender = markChunk.textRender {
        codeLabel.textRenderer = textRender
      }
      codeLabel.frame = CGRect(x: 0, y: 0, width: markChunk.codeSize.width, height: markChunk.codeSize.height)
      scrollView.contentSize = markChunk.codeSize
      
      container.layer.cornerRadius = markChunk.style.codeBlockStyle.cornerRadius
      container.backgroundColor = markChunk.style.codeBlockStyle.backgroundColor
      
      let frame = adjustedFrame(frame: self.bounds, withInsets: markChunk.style.codeBlockStyle.padding)
      container.frame = frame
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    let frame = adjustedFrame(frame: self.bounds, withInsets: markChunk?.style.codeBlockStyle.padding ?? UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0))
    container.frame = frame
  }
  
  private func setupViews() {
    backgroundColor = .white
    
    container = UIView()
    container.backgroundColor = .white
    container.layer.cornerRadius = 4
    container.layer.masksToBounds = true
    addSubview(container)
    
    topView = UIView()
    topView.backgroundColor = UIColor(hex: "#E9EBF0")
    container.addSubview(topView)
    
    languageLabel = UILabel()
    languageLabel.font = UIFont.boldSystemFont(ofSize: 12)
    languageLabel.textColor = UIColor(hex: "#525866")
    topView.addSubview(languageLabel)
    
    
    codeCopyButton = UIButton(type: .custom)
    codeCopyButton.addTarget(self, action: #selector(codeCopyAction), for: .touchUpInside)
    codeCopyButton.setTitle("Copy Code", for: .normal)
    codeCopyButton.setTitleColor(UIColor(hex: "#525866"), for: .normal)
    codeCopyButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
    topView.addSubview(codeCopyButton)
    
    scrollView = UIScrollView()
    container.addSubview(scrollView)
    
    codeLabel = MPILabel()
    codeLabel.numberOfLines = 0
    scrollView.addSubview(codeLabel)
    
    setupConstraints()
    setDefaultCopyImage()
  }
  
  private func setupConstraints() {
    
    let frame = adjustedFrame(frame: self.bounds, withInsets: UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0))
    container.frame = frame
    
    topView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      topView.leftAnchor.constraint(equalTo: container.leftAnchor),
      topView.topAnchor.constraint(equalTo: container.topAnchor),
      topView.rightAnchor.constraint(equalTo: container.rightAnchor),
      topView.heightAnchor.constraint(equalToConstant: 32)
    ])
    languageLabel.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      languageLabel.centerYAnchor.constraint(equalTo: topView.centerYAnchor),
      languageLabel.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: 8)
    ])
    codeCopyButton.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      codeCopyButton.widthAnchor.constraint(equalToConstant: 86),
      codeCopyButton.heightAnchor.constraint(equalToConstant: 32),
      codeCopyButton.centerYAnchor.constraint(equalTo: topView.centerYAnchor),
      codeCopyButton.rightAnchor.constraint(equalTo: topView.rightAnchor, constant: -8)
    ])
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: container.topAnchor, constant: 40),
      scrollView.leftAnchor.constraint(equalTo: container.leftAnchor, constant: 8),
      scrollView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8),
      scrollView.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -8)
    ])
  }
  
  /// 计算新的frame，原始frame减去UIEdgeInsets的值
  /// - Parameters:
  ///   - frame: 原始的CGRect
  ///   - insets: UIEdgeInsets，各方向的内边距
  /// - Returns: 调整后的CGRect
  func adjustedFrame(frame: CGRect, withInsets insets: UIEdgeInsets) -> CGRect {
    let newX = frame.origin.x + insets.left
    let newY = frame.origin.y + insets.top
    let newWidth = frame.width - insets.left - insets.right
    let newHeight = frame.height - insets.top - insets.bottom
    
    return CGRect(x: newX, y: newY, width: newWidth, height: newHeight)
  }
  
  private func imageFromBase64(base64String: String) -> UIImage? {
    if let imageData = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters) {
      let image = UIImage(data: imageData)
      return image
    }
    return nil
  }
  
  private func setDefaultCopyImage() {
    let base64String = "iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAIdJREFUOE9jZKAQMGLTHxKR4fCX4W89PrOZGZgb16yYcQCrAYERqfsZGRgd/jP8P4DNEJjc+hWzHXEaANIIUoDNAJAFMHmsBhAKFgwDSPEzyHAMA0jxM04DiPXzwBuA7F14NCIHCqFog6lFSUikGIBuATgdUMUAYpMuVheQmpCQDSErKSMbAADIwosRSoQbzQAAAABJRU5ErkJggg=="
    if let image = imageFromBase64(base64String: base64String) {
      codeCopyButton.setImage(image, for: .normal)
    }
  }
  
  @objc private func codeCopyAction() {
    if let text = markChunk?.attributeText?.string {
       onCopy?(text)
    }
  }
  
}
