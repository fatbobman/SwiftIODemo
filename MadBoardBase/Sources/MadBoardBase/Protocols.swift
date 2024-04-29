// The Swift Programming Language
// https://docs.swift.org/swift-book

public protocol ST7789Base {
  func writePixel(x: Int, y: Int, color: UInt16)
  func writeBitmap(x: Int, y: Int, width w: Int, height h: Int, data: UnsafeRawBufferPointer)
  var width: Int { get }
  var height: Int { get }
}

public protocol AnalogInBase {
  func readPercentage() -> Float
}
