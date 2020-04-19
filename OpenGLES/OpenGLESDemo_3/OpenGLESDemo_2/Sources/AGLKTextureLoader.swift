//
//  AGLKTextureLoader.swift
//  OpenGLESDemo_2
//
//  Created by 壹九科技1 on 2020/4/18.
//  Copyright © 2020 zxf. All rights reserved.
//

import GLKit

enum AGLKPowerOf2: Int {
    case AGLK1 = 1
    case AGLK2 = 2
    case AGLK4 = 4
    case AGLK8 = 8
    case AGLK16 = 16
    case AGLK32 = 32
    case AGLK64 = 64
    case AGLK128 = 128
    case AGLK256 = 256
    case AGLK512 = 512
    case AGLK1024 = 1024
}

class AGLKTextureInfo {
    var name: GLuint?
    var target: GLenum?
    var width: size_t?
    var height: size_t?
    
    init(name: GLuint, target: GLenum, width: size_t, height: size_t) {
        self.name = name
        self.target = target
        self.width = width
        self.height = height
    }
}


class AGLKTextLoader {
    private var name: GLuint = GLuint()
    private var target: GLenum?
    private var width: GLuint?
    private var height: GLuint?

    static func textureInfo(with cgImage: CGImage, options: Dictionary<String, Any>?) -> AGLKTextureInfo {
        var width: size_t = 0
        var height: size_t = 0
        let widthPtr = withUnsafeMutablePointer(to: &width, {$0})
        let heightPtr = withUnsafeMutablePointer(to: &height, {$0})
        let imageData = AGLKDataWithResizedCGImageBytes(cgImage: cgImage, widthPtr: widthPtr, heightPtr: heightPtr)
        var textureBufferID: GLuint = GLuint()
        glCheckError()
        glGenTextures(1, &textureBufferID)
        glBindTexture(GLenum(GL_TEXTURE_2D), textureBufferID)
        glCheckError()
        let bytes = imageData.withUnsafeBytes({$0})
        glCheckError()
        glTexImage2D(GLenum(GL_TEXTURE_2D),
                     0,
                     GL_RGBA,
                     GLsizei(width),
                     GLsizei(height),
                     0,
                     GLenum(GL_RGBA),
                     GLenum(GL_UNSIGNED_BYTE),
                     bytes.baseAddress)
        glCheckError()
        // pname 参数
//        public var GL_TEXTURE_MAG_FILTER: Int32 { get }
//        public var GL_TEXTURE_MIN_FILTER: Int32 { get }
//        public var GL_TEXTURE_WRAP_S: Int32 { get }
//        public var GL_TEXTURE_WRAP_T: Int32 { get }
//        public var GL_GENERATE_MIPMAP: Int32 { get }
        glTexParameteri(GLenum(GL_TEXTURE_2D),
                        GLenum(GL_TEXTURE_MIN_FILTER),
                        GL_NEAREST)
        glCheckError()
        let result = AGLKTextureInfo(name: textureBufferID,
                                     target: GLenum(GL_TEXTURE_2D),
                                     width: width,
                                     height: height)
        glCheckError()
        return result
    }
}


func AGLKCaculatePowerOf2ForDiemnsion(dimension: GLuint) -> AGLKPowerOf2.RawValue {
    var result: AGLKPowerOf2.RawValue = AGLKPowerOf2.AGLK1.rawValue
    if dimension > 512 {
        result = AGLKPowerOf2.AGLK1024.rawValue
    } else if dimension > 256 {
        result = AGLKPowerOf2.AGLK512.rawValue
    } else if dimension > 128 {
        result = AGLKPowerOf2.AGLK256.rawValue
    } else if dimension > 64 {
        result = AGLKPowerOf2.AGLK128.rawValue
    } else if dimension > 32 {
        result = AGLKPowerOf2.AGLK64.rawValue
    } else if dimension > 16 {
        result = AGLKPowerOf2.AGLK32.rawValue
    } else if dimension > 8 {
        result = AGLKPowerOf2.AGLK16.rawValue
    } else if dimension > 4 {
        result = AGLKPowerOf2.AGLK8.rawValue
    } else if dimension > 2 {
        result = AGLKPowerOf2.AGLK4.rawValue
    } else if dimension > 1 {
        result = AGLKPowerOf2.AGLK2.rawValue
    }
    return result
}
func AGLKDataWithResizedCGImageBytes(cgImage: CGImage, widthPtr: UnsafeMutablePointer<size_t>, heightPtr:  UnsafeMutablePointer<size_t>) -> Data {
    let originWidth = cgImage.width
    let originHeight = cgImage.height
    assert(originWidth > 0 && originHeight > 0, "Invalid image")
    
    let width = AGLKCaculatePowerOf2ForDiemnsion(dimension: GLuint(originWidth))
    let height = AGLKCaculatePowerOf2ForDiemnsion(dimension: GLuint(originHeight))

//    var data = Data(count: width.rawValue * height.rawValue * 4)
    
    var data = Data(count: width * height * 4)
    let unsafeMutablePoint = data.withUnsafeMutableBytes({$0})
//    var data = NSMutableData(length: width * height * 4)
    let colorSpace = CGColorSpaceCreateDeviceRGB()
//    let bytes = data.withUnsafeMutableBytes({($0[0])})
    guard let context = CGContext(data: unsafeMutablePoint.baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 4 * width, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {return Data()}
    
    
    context.ctm.translatedBy(x: 0, y: CGFloat(height))
    context.ctm.scaledBy(x: 1, y: -1)
    let rect = CGRect(x: 0, y: 0, width: width, height: height)
    context.draw(cgImage, in: rect)
    
    widthPtr.pointee = width
    heightPtr.pointee = height
    
    return data as! Data
//    return (data?.copy() ?? Data()) as Data
}
