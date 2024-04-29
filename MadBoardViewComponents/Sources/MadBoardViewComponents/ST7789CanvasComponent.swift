//
//  ST7789CanvasComponent.swift
//
//
//  Created by Yang Xu on 2024/4/28.
//

import Foundation
import MadBoardBase
import SwiftUI

public final class ST7789Model: ST7789Base, ObservableObject {
  public var width: Int
  public var height: Int
  // add @Published for ST7789CanvasComponent
  var pixels: [UInt16]

  public init(width: Int = 240, height: Int = 240) {
    self.width = width
    self.height = height
    pixels = Array(repeating: 0x0000, count: width * height)
  }

  public func writePixel(x: Int, y: Int, color: UInt16) {
    guard x >= 0, y >= 0, x < width, y < height else { return }
    pixels[y * width + x] = color
  }

  public func writeBitmap(x: Int, y: Int, width w: Int, height h: Int, data: UnsafeRawBufferPointer) {
    guard x >= 0, y >= 0, x + w <= width, y + h <= height else {
      return
    }

    let srcData = data.bindMemory(to: UInt16.self)

    for row in 0 ..< h {
      let srcRowStart = row * w
      let dstRowStart = (y + row) * width + x
      for col in 0 ..< w {
        pixels[dstRowStart + col] = srcData[srcRowStart + col]
      }
    }
  }
}

public struct ST7789CanvasComponent: View {
  @ObservedObject private var model: ST7789Model
  private var scale: Double

  public init(model: ST7789Model, scale: Double = 1.0) {
    _model = ObservedObject(wrappedValue: model)
    self.scale = max(scale, 1)
  }

  public var body: some View {
    Canvas { context, _ in
      for y in 0 ..< model.height {
        for x in 0 ..< model.width {
          let index = y * model.width + x
          let colorValue = model.pixels[index]
          let color = Color(
            red: Double((colorValue & 0xF800) >> 11) / 31.0,
            green: Double((colorValue & 0x07E0) >> 5) / 63.0,
            blue: Double(colorValue & 0x001F) / 31.0
          )
          context.fill(Path(CGRect(x: Double(x) * scale, y: Double(y) * scale, width: scale, height: scale)), with: .color(color))
        }
      }
    }
    .frame(width: CGFloat(CGFloat(model.width) * scale), height: CGFloat(CGFloat(model.height) * scale))
  }
}

#if DEBUG
  struct ST7789CanvasPreview: View {
    @StateObject var model = ST7789Model()
    private var scale: Double
    init(scale: Double = 1.0) {
      self.scale = scale
    }

    var body: some View {
      ST7789CanvasComponent(model: model, scale: scale)
        .onAppear {
          let width = 100
          let height = 100
          let redColor = UInt16(0xF800)
          let redRect = [UInt16](repeating: redColor, count: width * height)
          redRect.withUnsafeBytes {
            model.writeBitmap(x: 30, y: 30, width: width, height: height, data: $0)
          }
          model.writePixel(x: 100, y: 100, color: 0xFFFF)
          model.writePixel(x: 100, y: 101, color: 0xFFFF)
          model.writePixel(x: 101, y: 100, color: 0xFFFF)
          model.writePixel(x: 101, y: 101, color: 0xFFFF)
        }
    }
  }

  #Preview {
    ST7789CanvasPreview(scale: 1.5)
  }
#endif
