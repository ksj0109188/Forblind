//
//  CommonCustomButton.swift
//  LuminaView
//
//  Created by 송성욱 on 7/18/24.
//

import UIKit

class CommonCustomButton: UIButton {
    private var actionHandler: (() -> Void)?
    
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
        self.addTarget(self, action: #selector(handleAction), for: .touchUpInside)
	}
	
	func set(
		backgroundColor: UIColor,
		title: String = "",
		fontSize: CGFloat,
		weight: UIFont.Weight,
		cornerRadius: CGFloat,
        action: (() -> Void)?
	) {
		self.backgroundColor = backgroundColor
		self.setTitle(title, for: .normal)
		self.titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: weight)
		self.layer.cornerRadius = cornerRadius
        self.actionHandler = action
	}
    
    @objc private func handleAction() {
        print("button Tapped")
        actionHandler?()
    }
}
