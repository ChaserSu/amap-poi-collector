import AppKit
import Foundation

// 生成 1024x1024 应用图标：紫色渐变底 + 白色地图定位针
let S: CGFloat = 1024
let image = NSImage(size: NSSize(width: S, height: S))
image.lockFocus()
let ctx = NSGraphicsContext.current!.cgContext
let bounds = CGRect(x: 0, y: 0, width: S, height: S)

// 圆角裁剪
let clip = CGPath(roundedRect: bounds.insetBy(dx: 3, dy: 3), cornerWidth: 225, cornerHeight: 225, transform: nil)
ctx.addPath(clip)
ctx.clip()

// 背景渐变（左上亮紫 → 右下深紫）
let c1 = NSColor(calibratedRed: 0.55, green: 0.48, blue: 0.95, alpha: 1).cgColor
let c2 = NSColor(calibratedRed: 0.27, green: 0.20, blue: 0.58, alpha: 1).cgColor
let grad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                      colors: [c1, c2] as CFArray, locations: [0, 1])!
ctx.drawLinearGradient(grad, start: CGPoint(x: 0, y: S), end: CGPoint(x: S, y: 0), options: [])

// 淡淡的网格纹理
ctx.setStrokeColor(NSColor(white: 1, alpha: 0.07).cgColor)
ctx.setLineWidth(2)
for i in 1...7 {
    let p = CGFloat(i) * CGFloat(S) / 8
    ctx.move(to: CGPoint(x: p, y: 0)); ctx.addLine(to: CGPoint(x: p, y: S))
    ctx.move(to: CGPoint(x: 0, y: p)); ctx.addLine(to: CGPoint(x: S, y: p))
}
ctx.strokePath()

// 白色定位针：圆头在上 + 尖尾朝下指向
let cx: CGFloat = 512, headCy: CGFloat = 390, r: CGFloat = 235
NSColor.white.setFill()
let head = CGRect(x: cx - r, y: headCy - r, width: 2 * r, height: 2 * r)
ctx.fillEllipse(in: head)
let tail = NSBezierPath()
tail.move(to: NSPoint(x: cx, y: 880))                 // 针尖
tail.line(to: NSPoint(x: cx - 150, y: 565))
tail.line(to: NSPoint(x: cx + 150, y: 565))
tail.close()
tail.fill()

// 针芯紫色圆
NSColor(calibratedRed: 0.43, green: 0.36, blue: 0.90, alpha: 1).setFill()
let inner: CGFloat = 112
ctx.fillEllipse(in: CGRect(x: cx - inner, y: headCy - inner, width: 2 * inner, height: 2 * inner))

image.unlockFocus()

// 输出 PNG
let rep = NSBitmapImageRep(data: image.tiffRepresentation!)!
let png = rep.representation(using: .png, properties: [:])!
let out = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "icon.png"
try! png.write(to: URL(fileURLWithPath: out))
print("written: \(out) \(png.count) bytes")
