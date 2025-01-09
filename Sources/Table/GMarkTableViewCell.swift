//
//  GMarkTableViewCell.swift
//  GMarkRender
//
//  Created by GIKI on 2024/7/29.
//

import MPITextKit
import UIKit

public class GMarkTableViewCell: UIView {
    public private(set) var reuseIdentifier: String?
    public var indexPath: TabIndexPath!
    public var rowspan = 1
    public var colspan = 1

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    required init(reuseIdentifier: String?) {
        self.reuseIdentifier = reuseIdentifier
        super.init(frame: CGRect())
        setup()
    }

    private func setup() {
        backgroundColor = .white
        clipsToBounds = true
    }

    public static var placeholder: GMarkTableViewCell {
        return PlaceholderGMarkTableViewCell.instance
    }

    public func prepareForReuse() {
        backgroundColor = .clear
    }
}

class PlaceholderGMarkTableViewCell: GMarkTableViewCell {
    static let instance = PlaceholderGMarkTableViewCell()
}

public class GMarkTableRichLabelCell: GMarkTableViewCell {
    public var contentInset = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)

    public let label = MPILabel()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadSubviews()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadSubviews()
    }

    required init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        loadSubviews()
    }

    func loadSubviews() {
        label.numberOfLines = 0
        addSubview(label)
    }

    override public func layoutSubviews() {
        label.frame = bounds.inset(by: contentInset)
    }

    var textRender: MPITextRenderer?
    public func configure(_ textRender: MPITextRenderer) {
        self.textRender = textRender
        label.textRenderer = textRender
    }

    override public func prepareForReuse() {
        super.prepareForReuse()
    }
}
