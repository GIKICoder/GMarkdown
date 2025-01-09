//
//  GMarkTableStyle.swift
//  GMarkRender
//
//  Created by GIKI on 2024/7/29.
//

import Foundation
import UIKit

public class GMarkTableStyle {
    public var rowGap: CGFloat = 0
    public var colGap: CGFloat = 1
    public var gapColor: UIColor? = .clear

    public var borderWidth: CGFloat = 0
    public var borderColor: UIColor? = .clear
    public var cornerRadius: CGFloat = 0

    static var _appearance: GMarkTableStyle?
    public static var appearance: GMarkTableStyle {
        guard let appearance = _appearance else {
            _appearance = GMarkTableStyle()
            return _appearance!
        }
        return appearance
    }

    public init() {
        if let appearance = GMarkTableStyle._appearance {
            rowGap = appearance.rowGap
            colGap = appearance.colGap
            borderWidth = appearance.borderWidth
            borderColor = appearance.borderColor
            gapColor = appearance.gapColor
            cornerRadius = appearance.cornerRadius
        }
    }
}
