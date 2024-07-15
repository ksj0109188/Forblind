//
//  TextRecognitionViewController.swift
//  LuminaView
//
//  Created by 송성욱 on 7/15/24.
//

import UIKit
import MLKitTextRecognitionKorean
import MLKitTextRecognition
import MLKitVision
import AVFoundation

class TextRecognitionViewController: UIViewController {
	
	private lazy var topSafeAreaView: UIView = {
		var view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	private let labelTitle: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 0
		label.textAlignment = .center
		label.text = "Google MLKit 번역"
		return label
	}()
	
	private let imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.image = UIImage(named: "test")
		imageView.contentMode = .scaleAspectFit
		return imageView
	}()
	
	private let label: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 0
		label.textAlignment = .center
		label.text = "String"
		return label
	}()
	
	var imgTest = UIImage(named: "test")
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.addSubview(topSafeAreaView)
		topSafeAreaView.addSubview(labelTitle)
		topSafeAreaView.addSubview(imageView)
		topSafeAreaView.addSubview(label)
		
		applyConstraints()
		
		reconizeTextKorean()
		
		print("MLKit")
	}
	
	// MARK: - Contstraints
	fileprivate func applyConstraints() {
		let topSafeAreaViewConstraints = [
			topSafeAreaView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			topSafeAreaView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
			topSafeAreaView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
			topSafeAreaView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
		]
		
		let labelTitleConstraints = [
			labelTitle.topAnchor.constraint(equalTo: topSafeAreaView.topAnchor, constant: 20),
			labelTitle.leadingAnchor.constraint(equalTo: topSafeAreaView.leadingAnchor, constant: 20),
			labelTitle.trailingAnchor.constraint(equalTo: topSafeAreaView.trailingAnchor, constant: -20)
		]
		
		let imageViewConstraints = [
			imageView.topAnchor.constraint(equalTo: labelTitle.bottomAnchor, constant: 20),
			imageView.leadingAnchor.constraint(equalTo: topSafeAreaView.leadingAnchor, constant: 20),
			imageView.trailingAnchor.constraint(equalTo: topSafeAreaView.trailingAnchor, constant: -20),
			imageView.heightAnchor.constraint(equalToConstant: 240)
		]
		
		let labelConstraints = [
			label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
			label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
		]
		
		NSLayoutConstraint.activate(topSafeAreaViewConstraints)
		NSLayoutConstraint.activate(labelTitleConstraints)
		NSLayoutConstraint.activate(imageViewConstraints)
		NSLayoutConstraint.activate(labelConstraints)
	}
	
	fileprivate func reconizeTextKorean(){
		let koreanOptions = KoreanTextRecognizerOptions()
		let koreanTextRecognizer = TextRecognizer.textRecognizer(options: koreanOptions)
		
		let visionImage = VisionImage(image: imgTest!)
		visionImage.orientation = imageOrientation(deviceOrientation: UIDevice.current.orientation, cameraPosition: .back)
		
		koreanTextRecognizer.process(visionImage) { features, error in
			koreanTextRecognizer.process(visionImage) { result, error in
				guard error == nil, let result = result else {
					print("Error")
					return
				}
				
				let resultText = result.text
				DispatchQueue.main.async {
					self.label.text = resultText
				}
			}
		}
	}
	
	func imageOrientation(
		deviceOrientation: UIDeviceOrientation,
		cameraPosition: AVCaptureDevice.Position
	) -> UIImage.Orientation {
		switch deviceOrientation {
			case .portrait:
				return cameraPosition == .front ? .leftMirrored : .right
			case .landscapeLeft:
				return cameraPosition == .front ? .downMirrored : .up
			case .portraitUpsideDown:
				return cameraPosition == .front ? .rightMirrored : .left
			case .landscapeRight:
				return cameraPosition == .front ? .upMirrored : .down
			case .faceDown, .faceUp, .unknown:
				return .up
			@unknown default:
				fatalError()
		}
	}
}
