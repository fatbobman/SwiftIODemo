//
//  AnalogInComponent.swift
//
//
//  Created by Yang Xu on 2024/4/28.
//

import Foundation
import MadBoardBase
import SwiftUI

public final class AnalogInModel: AnalogInBase,ObservableObject {
  @Published public var value:Float = .zero
  public init(){}
  public func readPercentage() -> Float {
    value
  }
}

public struct AnalogInComponent: View {
  @ObservedObject private var model:AnalogInModel
  public init(model: AnalogInModel) {
    self.model = model
  }
  public var body: some View {
    Slider(value: $model.value, in: 0...1)
  }
}

#if DEBUG
struct AnalogInComponentPreview:View {
  @StateObject var model = AnalogInModel()
  var body: some View {
    VStack {
      AnalogInComponent(model: model)
        .frame(width:200)
      Text(model.value,format: .number)
    }
  }
}

#Preview {
  AnalogInComponentPreview()
}
#endif
