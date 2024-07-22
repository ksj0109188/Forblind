//
//  RecognitionProgressView.swift
//  LuminaView
//
//  Created by 송성욱 on 7/18/24.
//

import UIKit
import Lottie

//TODO: - View Model -> 촬영된 사진에서 텍스트를 인식하는 동안 Progress Animation이 작동하게 구현

class RecognitionProgressView: UIViewController {
	///1. 인스턴스 초기화 생성
	private let progressView: LottieAnimationView = .init(name: "ProgressAnimation")
	private var stateLabel = CommonCustomLabel(
		label: "텍스트 인식중입니다...",
		textAlignment: .center,
		fontSize: 24,
		weight: .bold,
		textColor: .white
	)
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setProgressView()
		
	}
	///2. animation 세팅
	private func setProgressView() {
		progressView.loopMode = .loop
		progressView.contentMode = .scaleAspectFit
		progressView.animationSpeed = 0.5
		progressView.frame = view.bounds
		progressView.play { completed in
			if completed {
				print("인식완료")
			} else {
				print("인식중")
			}
		}
		view.addSubview(progressView)
	}
	
	//MARK: - 상태에 따른 애니메이션 진행
	
	enum ProgressKeyFrames: CGFloat {
		case start = 0
		case end = 60
	}
	
	func progress(to progress: CGFloat) {
		setProgressView()

		let progressRange = ProgressKeyFrames.start.rawValue - ProgressKeyFrames.end.rawValue
		let progressFrame = progressRange * progress
		let currentFrame = progressFrame + ProgressKeyFrames.start.rawValue
        print("currentFrame", currentFrame)
		progressView.currentFrame = currentFrame
		print("Downloading \((progress * 100).rounded())%")
		progressView.play()
	}

}
