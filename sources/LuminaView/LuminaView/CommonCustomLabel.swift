//
//  CommonCustomLabel.swift
//  LuminaView
//
//  Created by 송성욱 on 7/18/24.
//

import UIKit

class CommonCustomLabel: UILabel {

	override init(frame: CGRect) {
		super.init(frame: frame)
		configure()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	convenience init(
		label: String,
		textAlignment: NSTextAlignment,
		fontSize: CGFloat,
		weight: UIFont.Weight,
		textColor: UIColor
	) {
		self.init(frame: .zero)
		self.text = label
		self.textAlignment = textAlignment
		self.font = UIFont.systemFont(ofSize: fontSize, weight: weight)
		self.textColor = textColor
	}
	
	private func configure() {
		textColor = .label
		adjustsFontSizeToFitWidth = true
		minimumScaleFactor = 0.9
		translatesAutoresizingMaskIntoConstraints = false
	}
	
	func set(
		label: String,
		textAlignment: NSTextAlignment,
		fontSize: CGFloat,
		weight: UIFont.Weight,
		textColor: UIColor
	) {
		self.text = label
		self.textAlignment = textAlignment
		self.font = UIFont.systemFont(ofSize: fontSize, weight: weight)
		self.textColor = textColor
	}
}
