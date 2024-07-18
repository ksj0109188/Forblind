//
//  CommonCustomButton.swift
//  LuminaView
//
//  Created by 송성욱 on 7/18/24.
//

import UIKit

class CommonCustomButton: UIButton {

	override init(frame: CGRect) {
		super.init(frame: frame)
		configure()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	convenience init(
		backgroundColor: UIColor,
		title: String = "",
		fontSize: CGFloat,
		weight: UIFont.Weight,
		cornerRadius: CGFloat
	) {
		self.init(frame: .zero)
		self.backgroundColor = backgroundColor
		self.setTitle(title, for: .normal)
		self.titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: weight)
		self.layer.cornerRadius = cornerRadius
	}
	
	private func configure() {
		self.configuration?.cornerStyle = .capsule
		self.setTitleColor(.white, for: .normal)
		self.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
		self.translatesAutoresizingMaskIntoConstraints = false
	}
	
	func set(
		backgroundColor: UIColor,
		title: String = "",
		fontSize: CGFloat,
		weight: UIFont.Weight,
		cornerRadius: CGFloat
	) {
		self.backgroundColor = backgroundColor
		self.setTitle(title, for: .normal)
		self.titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: weight)
		self.layer.cornerRadius = cornerRadius
	}
}
