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
    
    
    
    
    static func textureInfo(with cgImage: CGImage, options: Dictionary<String, Any>) -> AGLKTextureInfo {
        var width: size_t = 0
        var height: size_t = 0
        let widthPtr = withUnsafeMutablePointer(to: &width, {$0})
        let heightPtr = withUnsafeMutablePointer(to: &height, {$0})
        let imageData = AGLKDataWithResizedCGImageBytes(cgImage: cgImage, widthPtr: widthPtr, heightPtr: heightPtr)
        var textureBufferID: GLuint = 0
        glGenTextures(1, &textureBufferID)
        glBindBuffer(GLenum(GL_TEXTURE_2D), textureBufferID)
        
        let bytes = UnsafeMutableRawBufferPointer(start: UnsafeMutableRawPointer(bitPattern: 0), count: imageData.count)
        
        imageData.copyBytes(to: bytes)
        
        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA, GLsizei(width), GLsizei(height), 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), bytes as? UnsafeRawPointer)
        
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        let result = AGLKTextureInfo(name: textureBufferID, target: GLenum(GL_TEXTURE_2D), width: width, height: height)
        return result
    }
}


func AGLKCaculatePowerOf2ForDiemnsion(dimension: GLuint) -> AGLKPowerOf2 {
    var result: AGLKPowerOf2 = AGLKPowerOf2.AGLK1
    if dimension > 512 {
        result = .AGLK1024
    } else if dimension > 256 {
        result = .AGLK512
    } else if dimension > 128 {
        result = .AGLK256
    } else if dimension > 64 {
        result = .AGLK128
    } else if dimension > 32 {
        result = .AGLK64
    } else if dimension > 16 {
        result = .AGLK32
    } else if dimension > 8 {
        result = .AGLK16
    } else if dimension > 4 {
        result = .AGLK8
    } else if dimension > 2 {
        result = .AGLK4
    } else if dimension > 1 {
        result = .AGLK2
    }
    return result
}
func AGLKDataWithResizedCGImageBytes(cgImage: CGImage, widthPtr: UnsafeMutablePointer<size_t>, heightPtr:  UnsafeMutablePointer<size_t>) -> Data {
    let originWidth = cgImage.width
    let originHeight = cgImage.height
    assert(originWidth > 0 && originHeight > 0, "Invalid image")
    
    let width = AGLKCaculatePowerOf2ForDiemnsion(dimension: GLuint(originWidth))
    let height = AGLKCaculatePowerOf2ForDiemnsion(dimension: GLuint(originHeight))
    var imageData = Data(capacity: width.rawValue * height.rawValue)
    
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let context = CGContext(data: &imageData, width: width.rawValue, height: height.rawValue, bitsPerComponent: 8, bytesPerRow: 4 * width.rawValue, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
    
    context?.ctm.translatedBy(x: 0, y: CGFloat(height.rawValue))
    context?.ctm.scaledBy(x: 1, y: -1)
    context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width.rawValue, height: height.rawValue))
    
    widthPtr.pointee = width.rawValue
    heightPtr.pointee = height.rawValue
    
    return imageData
}
