//
//  GeminiWebRepository.swift
//  LuminaView
//
//  Created by 김성준 on 7/16/24.
//

import UIKit
import GoogleGenerativeAI
import RxSwift
import CoreMedia

protocol GuideAPIWebRepository {
    func setupApiConnect(requestStream: PublishSubject<CMSampleBuffer>)
    func setupResultStream(resultStream: PublishSubject<Result<String, Error>>) 
}


enum ServerStateEnumType {
    
}
