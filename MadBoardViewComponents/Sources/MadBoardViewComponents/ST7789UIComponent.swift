//
//  ST7789UIComponent.swift
//
//
//  Created by Yang Xu on 2024/4/28.
//

import Foundation
import SwiftUI
import UIKit

public class ST7789UIView: UIView {
  private var displayLink: CADisplayLink?
  var model: ST7789Model!

  public init(frame: CGRect, model: ST7789Model) {
    super.init(frame: frame)
    self.model = model
    backgroundColor = .black
    setupDisplayLink()
  }

  @available(*, unavailable)
  public required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // 设置 CADisplayLink 以与设备刷新率同步更新视图
  private func setupDisplayLink() {
    displayLink = CADisplayLink(target: self, selector: #selector(step))
    displayLink?.add(to: .main, forMode: .common)
  }

  // CADisplayLink 事件处理
  @objc private func step(displayLink _: CADisplayLink) {
    setNeedsDisplay()
  }

  // 清理资源
  deinit {
    displayLink?.invalidate()
  }

  // 绘图逻辑
  override public func draw(_: CGRect) {
    guard let context = UIGraphicsGetCurrentContext() else { return }

    // 绘制1x1像素点
    let pixelSize = CGSize(width: 1, height: 1)
    for y in 0 ..< model.height {
      for x in 0 ..< model.width {
        let index = y * model.width + x
        let colorValue = model.pixels[index]
        let color = colorValue.UIColor
        context.setFillColor(color.cgColor)
        let rect = CGRect(origin: CGPoint(x: x, y: y), size: pixelSize)
        context.fill(rect)
      }
    }
  }
}

extension UInt16 {
  var UIColor: UIKit.UIColor {
    // 首先反转字节顺序，确保字节是正确排列的
    let correctedValue = byteSwapped

    // 现在解析RGB565格式的颜色值
    let red = CGFloat((correctedValue & 0xF800) >> 11) / 31.0
    let green = CGFloat((correctedValue & 0x07E0) >> 5) / 63.0
    let blue = CGFloat(correctedValue & 0x001F) / 31.0

    // 创建并返回UIColor对象
    return UIKit.UIColor(red: red, green: green, blue: blue, alpha: 1.0)
  }
}

// SwiftUI 包装器
public struct ST7789UIComponent: UIViewRepresentable {
  var model: ST7789Model
  var scale: CGFloat

  public init(model: ST7789Model, scale: CGFloat = 1.0) {
    self.model = model
    self.scale = scale
  }

  public func makeUIView(context _: Context) -> ST7789UIView {
    let view = ST7789UIView(frame: CGRect(x: 0, y: 0, width: CGFloat(model.width), height: CGFloat(model.height)), model: model)
    return view
  }

  public func updateUIView(_: ST7789UIView, context _: Context) {}

  public func sizeThatFits(_: ProposedViewSize, uiView _: ST7789UIView, context _: Context) -> CGSize? {
    .init(width: CGFloat(model.width), height: CGFloat(model.height))
  }
}

#if DEBUG
  struct ST7789UIPreview: View {
    @StateObject var model = ST7789Model()

    var body: some View {
      ST7789UIComponent(model: model)
        .frame(width: 240, height: 240)
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
    ST7789UIPreview()
  }

#endif
