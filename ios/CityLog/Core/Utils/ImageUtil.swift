// Copyright © 2026 CityLog. All rights reserved.

import UIKit

enum ImageUtil {
    /// 发给 AI 和存入日志的照片最长边。
    static let maxDimension: CGFloat = 1024
    static let jpegQuality: CGFloat = 0.7

    /// 把照片缩小并压成 JPEG，控制上传体积和本机占用。
    static func compactJPEG(_ image: UIImage) -> Data? {
        let longest = max(image.size.width, image.size.height)
        guard longest > 0 else { return nil }
        let scale = min(1, maxDimension / longest)
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let resized = UIGraphicsImageRenderer(size: size, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        return resized.jpegData(compressionQuality: jpegQuality)
    }
}
