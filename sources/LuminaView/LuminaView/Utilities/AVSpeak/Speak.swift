//
//  Speak.swift
//  LuminaView
//
//  Created by 김성준 on 1/16/25.
//

import Foundation
import AVFAudio

protocol Speakable {
    func speak(content: String)
}

final class SpeakManager: Speakable {
    let synthesizer = AVSpeechSynthesizer()
    
    func speak(content: String) {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: content)
        synthesizer.speak(utterance)
    }
}
