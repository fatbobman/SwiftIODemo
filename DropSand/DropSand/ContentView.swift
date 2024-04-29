//
//  ContentView.swift
//  DropSand
//
//  Created by Yang Xu on 2024/4/28.
//

import Dispatch
import MadBoardViewComponents
import Sand
import SwiftUI

struct ContentView: View {
  @StateObject var sModel: ST7789Model
  @StateObject var aModel: AnalogInModel
  @State var sand: Sand<ST7789Model, AnalogInModel>
  let getSystemUptimeInMilliseconds: () -> Int64
  @State var timer: DispatchSourceTimer?
  init() {
    let sModel = ST7789Model()
    let aModel = AnalogInModel()
    let now = Date.now.timeIntervalSince1970
    getSystemUptimeInMilliseconds = {
      Int64((Date().timeIntervalSince1970 - now) * 1000)
    }
    _sModel = StateObject(wrappedValue: sModel)
    _aModel = StateObject(wrappedValue: aModel)
    _sand = State(wrappedValue: Sand(screen: sModel, cursor: aModel, getSystemUptimeInMilliseconds: getSystemUptimeInMilliseconds))
  }

  var body: some View {
    VStack(spacing: 30) {
      ST7789UIComponent(model: sModel)
//        .frame(width: 240, height: 240)
          .border(.red, width: 2)

      HStack {
        AnalogInComponent(model: aModel)
          .frame(width: 300)

        Button {
          sand.drawNewSand()
        } label: {
          Circle()
            .foregroundStyle(.orange.gradient)
            .frame(width: 50, height: 50)
        }
        .frame(width: 200, alignment: .trailing)
      }
    }
    .onAppear {
      startTimer()
    }
  }

  func startTimer() {
    let queue = DispatchQueue(label: "com.example.timer", attributes: .concurrent)
    timer = DispatchSource.makeTimerSource(queue: queue)
    timer?.schedule(deadline: .now(), repeating: 0.005)
    timer?.setEventHandler {
      // 执行更新
      DispatchQueue.main.async {
        self.sand.update(cursor: aModel)
      }
    }
    timer?.resume()
  }
}

#Preview(traits: .landscapeRight) {
  ContentView()
}
