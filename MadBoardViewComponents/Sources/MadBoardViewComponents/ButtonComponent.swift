//
//  File.swift
//
//
//  Created by Yang Xu on 2024/4/29.
//

import Combine
import Foundation
import SwiftUI

import Combine
import SwiftUI

public struct PulsingButton<Content>: View where Content: View {
  let content: Content
  let trigger: () -> Void
  let timeInterval: Double

  @State private var timer: AnyCancellable?
  @GestureState private var pressing = false

  public init(timeInterval: Double = 0.3, @ViewBuilder content: () -> Content, trigger: @escaping () -> Void) {
    self.content = content()
    self.trigger = trigger
    self.timeInterval = timeInterval
  }

  public var body: some View {
    content
      .gesture(
        TapGesture()
          .onEnded {
            trigger()
          }
          .simultaneously(with:
            LongPressGesture(minimumDuration: 100_000)
              .updating($pressing) { currentState, gestureState, _ in
                gestureState = currentState
              }
              .onChanged { _ in
                if timer == nil {
                  startTimer()
                }
              }
              .onEnded { _ in
                stopTimer()
              }
          )
      )
      .onChange(of: pressing) {
        if !pressing {
          stopTimer()
        }
      }
  }

  private func startTimer() {
    // Create and start a timer
    timer = Timer.publish(every: timeInterval, on: .main, in: .common)
      .autoconnect()
      .sink { _ in
        self.trigger()
      }
  }

  private func stopTimer() {
    // Invalidate and release the timer
    timer?.cancel()
    timer = nil
  }
}

#if DEBUG
  struct PulsingButtonDemo: View {
    var body: some View {
      PulsingButton {
        Circle()
          .frame(width: 50, height: 50)
      } trigger: {
        print("hello")
      }
    }
  }

  #Preview {
    PulsingButtonDemo()
  }
#endif
