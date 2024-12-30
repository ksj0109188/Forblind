//
//  Coordinator.swift
//  LuminaView
//
//  Created by 김성준 on 11/20/24.
//

import Foundation

protocol Coordinator: AnyObject {
    var children: [Coordinator]? { get set }
    
    func start(animated: Bool, onDismissed: (() -> Void)?)
    func presentChild(_ child: Coordinator,
                      animated: Bool,
                      onDismissed: (() -> Void)?)
}

extension Coordinator {
  public func presentChild(_ child: Coordinator,
                           animated: Bool,
                           onDismissed: (() -> Void)? = nil) {
    children?.append(child)
    child.start(animated: animated, onDismissed: { [weak self, weak child] in
      guard let self = self, let child = child else { return }
      self.removeChild(child)
      onDismissed?()
    })
  }

  private func removeChild(_ child: Coordinator) {
      guard let index = children?.firstIndex(where:  { $0 === child }) else { return }
      children?.remove(at: index)
  }
}
