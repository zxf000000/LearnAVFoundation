//
//  ViewController.swift
//  OpenGLESDemo_2
//
//  Created by 壹九科技1 on 2020/4/18.
//  Copyright © 2020 zxf. All rights reserved.
//

import UIKit
import GLKit

struct SenceVertex {
    var positionCoords: GLKVector3?
    var textureCoords: GLKVector2?
    
}

extension Array {
    func size() -> Int {
        return MemoryLayout.stride(ofValue: self[0]) * count
    }
}


// category of context
class ViewController: GLKViewController {

    var context: AGLKContext!
    
    var buffer: AGLKVertexAttribArrayBuffer?
    let baseEffect: GLKBaseEffect = GLKBaseEffect()
    
    let vertices = [
        SenceVertex(positionCoords: GLKVector3Make(-0.5, -0.5, 0),
                    textureCoords: GLKVector2Make(0.0, 0.0)),
        SenceVertex(positionCoords: GLKVector3Make(0.5, -0.5, 0),
                    textureCoords: GLKVector2Make(1.0, 0.0)),
        SenceVertex(positionCoords: GLKVector3Make(-0.5, 0.5, 0),
                    textureCoords: GLKVector2Make(0.0, 1.0)),
    ]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        context = AGLKContext(api: .openGLES3)
        let glkView = view as! GLKView
        glkView.context = context
        AGLKContext.setCurrent(context)
        
        
        baseEffect.useConstantColor = GLboolean(GL_TRUE)
        baseEffect.constantColor = GLKVector4Make(1, 1, 1, 1)
        
        context.clearColor = GLKVector4Make(0, 0, 0, 1)
        
        self.buffer = AGLKVertexAttribArrayBuffer(stride: MemoryLayout<SenceVertex>.stride, numberOfVertices: GLsizei(vertices.count), dataPtr: vertices, usage: GLenum(GL_STATIC_DRAW))
        guard let imageRef = UIImage(contentsOfFile: Bundle.main.path(forResource: "test", ofType: "jpeg") ?? "")?.cgImage else { return }
        var textureInfo: GLKTextureInfo? = nil
        do {
            // 通过图片生成一个纹理缓存,
            // GLKTextureLoader 会自动调用 glTexParameteri() 方法来为创建的纹理贴图设置 OpenGL ES 取样和循环模式
            /// 如果使用了 MIP贴图, 并且告诉 GL_TEXTURE_MIN_FILTER 设置成 GL_LINEAR_MIPMAP_LINEAR, 会告诉OpenGL ES
            // 使用与 被取样的 S,T坐标最接近的文素的线性插值取样两个最合适的MIP贴图图像尺寸
           textureInfo = try GLKTextureLoader.texture(with: imageRef, options: nil)
        } catch {
            
        }
        
        let aTextureInfo = AGLKTextLoader.textureInfo(with: imageRef, options: [String: Any]())
        
        baseEffect.texture2d0.name = aTextureInfo.name ?? 0
        baseEffect.texture2d0.target = GLKTextureTarget.init(rawValue: aTextureInfo.target ?? 0) ?? GLKTextureTarget(rawValue: 0) as! GLKTextureTarget

    }
    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        
        baseEffect.prepareToDraw()
        context.clear(mask: GLbitfield(GL_COLOR_BUFFER_BIT))
        
        let offset = MemoryLayout.stride(ofValue: vertices[0].positionCoords)
        // 分两次glVertexAttribPointer
        // 顶点数据
        buffer?.prepareToDraw(withArrib: GLuint(GLKVertexAttrib.position.rawValue), numberofCoordinates: 3, attribOffset: 0, shouldEnable: true)
        // 纹理数据
        buffer?.prepareToDraw(withArrib: GLuint(GLKVertexAttrib.texCoord0.rawValue), numberofCoordinates: 2, attribOffset: offset, shouldEnable: true)
        buffer?.drawArray(with: GLenum(GL_TRIANGLES), startVertexIndex: 0, numberOfVertices: 3)
    }

}

