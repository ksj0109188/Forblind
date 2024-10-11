//
//  UIView+.swift
//  LuminaView
//
//  Created by 김성준 on 7/17/24.
//

import UIKit

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
}
