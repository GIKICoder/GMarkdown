//
//  GMarkdownCodeView.swift
//  GMarkRender
//
//  Created by GIKI on 2024/7/25.
//

import MPITextKit
import UIKit

open class GMarkdownCodeView: UIView {
    public var container: UIView!
    public var topView: UIView!
    public var languageLabel: UILabel!
    public var scrollView: UIScrollView!
    public var codeCopyButton: UIButton!
    public var codeLabel: MPILabel!

    @objc public var onCopy: ((String) -> Void)?

    public var markChunk: GMarkChunk? {
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

            let frame = adjustedFrame(frame: bounds, withInsets: markChunk.style.codeBlockStyle.padding)
            container.frame = frame
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        let frame = adjustedFrame(frame: bounds, withInsets: markChunk?.style.codeBlockStyle.padding ?? UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0))
        container.frame = frame
    }

    private func setupViews() {
        backgroundColor = .white

        container = UIView()
        container.backgroundColor = UIColor(hex: "#E7E7E7")
        container.layer.cornerRadius = 12
        container.layer.masksToBounds = true
        container.layer.borderColor = UIColor(red: 0.973, green: 0.973, blue: 0.973, alpha: 1).cgColor
        container.layer.borderWidth = 1
        addSubview(container)

        topView = UIView()
        topView.backgroundColor = UIColor(hex: "#FFFFFF")
        container.addSubview(topView)

        _ = NSMutableParagraphStyle()
        languageLabel = UILabel()
        languageLabel.font = UIFont(name: "PingFangSC-Medium", size: 14)
        languageLabel.textColor = UIColor(hex: "#000000")
        topView.addSubview(languageLabel)

        codeCopyButton = UIButton(type: .custom)
        codeCopyButton.addTarget(self, action: #selector(codeCopyAction), for: .touchUpInside)
        codeCopyButton.setTitle("Copy Code", for: .normal)
        codeCopyButton.setTitleColor(UIColor(hex: "#666666"), for: .normal)
        codeCopyButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        topView.addSubview(codeCopyButton)
        codeCopyButton.setImage(UIImage(named: "code_copy"), for: .normal)

        scrollView = UIScrollView()
        container.addSubview(scrollView)

        codeLabel = MPILabel()
        codeLabel.numberOfLines = 0
        scrollView.addSubview(codeLabel)

        setupConstraints()
         setDefaultCopyImage()
    }

    private func setupConstraints() {
        let frame = adjustedFrame(frame: bounds, withInsets: UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0))
        container.frame = frame

        topView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topView.leftAnchor.constraint(equalTo: container.leftAnchor),
            topView.topAnchor.constraint(equalTo: container.topAnchor),
            topView.rightAnchor.constraint(equalTo: container.rightAnchor),
            topView.heightAnchor.constraint(equalToConstant: 36),
        ])
        languageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            languageLabel.centerYAnchor.constraint(equalTo: topView.centerYAnchor),
            languageLabel.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: 8),
        ])
        codeCopyButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            codeCopyButton.widthAnchor.constraint(equalToConstant: 86),
            codeCopyButton.heightAnchor.constraint(equalToConstant: 32),
            codeCopyButton.centerYAnchor.constraint(equalTo: topView.centerYAnchor),
            codeCopyButton.rightAnchor.constraint(equalTo: topView.rightAnchor, constant: -8),
        ])
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: container.topAnchor, constant: 40),
            scrollView.leftAnchor.constraint(equalTo: container.leftAnchor, constant: 8),
            scrollView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8),
            scrollView.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -8),
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
        if let text = markChunk?.attributedText.string {
            onCopy?(text)
        }
    }
}
