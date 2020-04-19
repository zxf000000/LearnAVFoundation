//
//  ViewController.swift
//  OpenGLESDemo_2
//
//  Created by 壹九科技1 on 2020/4/18.
//  Copyright © 2020 zxf. All rights reserved.
//

import UIKit
import GLKit


extension GLKEffectPropertyTexture {
    func aglkSetParameters(parameterID: GLenum, value: GLint) {
        glBindTexture(target.rawValue, name)
        glTexParameteri(target.rawValue, parameterID, value)
    }
}

struct SenceVertex {
    var positionCoords: GLKVector3!
    var textureCoords: GLKVector2!
}

extension Array {
    func size() -> Int {
        return MemoryLayout<Element>.stride
    }
}


// category of context
class ViewController: GLKViewController {

    var context: AGLKContext!
    
    var buffer: AGLKVertexAttribArrayBuffer?
    let baseEffect: GLKBaseEffect = GLKBaseEffect()
    
    
    var textureInfo0: GLKTextureInfo?
    var textureInfo1: GLKTextureInfo?
    
    var vertices = [
        SenceVertex(positionCoords: GLKVector3Make(-1, -0.67, 0),
                    textureCoords: GLKVector2Make(0.0, 0.0)),
        SenceVertex(positionCoords: GLKVector3Make(1, -0.67, 0),
                    textureCoords: GLKVector2Make(1, 0.0)),
        SenceVertex(positionCoords: GLKVector3Make(-1, 0.67, 0),
                    textureCoords: GLKVector2Make(0.0, 1.0)),
        SenceVertex(positionCoords: GLKVector3Make(1, -0.67, 0),
                    textureCoords: GLKVector2Make(1.0, 0.0)),
        SenceVertex(positionCoords: GLKVector3Make(-1, 0.67, 0),
                    textureCoords: GLKVector2Make(0.0, 1.0)),
        SenceVertex(positionCoords: GLKVector3Make(1, 0.67, 0),
                    textureCoords: GLKVector2Make(1.0, 1.0))
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        context = AGLKContext(api: .openGLES3)
        let glkView = view as! GLKView
        glkView.context = context
        AGLKContext.setCurrent(context)
        
        self.delegate = self
        
        baseEffect.useConstantColor = GLboolean(GL_TRUE)
        baseEffect.constantColor = GLKVector4Make(1, 1, 1, 1)
        
        context.clearColor = GLKVector4Make(0, 0, 0, 1)
        
        self.buffer = AGLKVertexAttribArrayBuffer(stride: MemoryLayout<SenceVertex>.stride,
                                                  numberOfVertices: GLsizei(vertices.count),
                                                  dataPtr: vertices,
                                                  usage: GLenum(GL_STATIC_DRAW))
        guard let imageRef =
            UIImage(contentsOfFile: Bundle.main.path(forResource: "leaves", ofType: "gif") ?? "")?.cgImage else { return }
        // options 设置是为了抵消图像反转
        textureInfo0 = try! GLKTextureLoader.texture(with: imageRef, options: [GLKTextureLoaderOriginBottomLeft: true])
        
        guard let imageRef1 =
            UIImage(contentsOfFile: Bundle.main.path(forResource: "beetle", ofType: "png") ?? "")?.cgImage else { return }
        textureInfo1 = try! GLKTextureLoader.texture(with: imageRef1, options: [GLKTextureLoaderOriginBottomLeft: true])

        baseEffect.texture2d0.name = textureInfo0!.name
        baseEffect.texture2d0.target =
            GLKTextureTarget(rawValue: textureInfo0!.target) ?? GLKTextureTarget.target2D
        
        baseEffect.texture2d1.name = textureInfo1!.name
        baseEffect.texture2d1.target =
            GLKTextureTarget(rawValue: textureInfo1!.target) ?? GLKTextureTarget.target2D
        baseEffect.texture2d1.envMode = GLKTextureEnvMode.decal
    }
    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        context.clear(mask: GLbitfield(GL_COLOR_BUFFER_BIT))
        
        /// 重点: 这个 offset 一定要用 MemoryLayout 的 offset 函数来取, 直接用 stride 来取的话,是错误的值
        guard let offset = MemoryLayout<SenceVertex>.offset(of: \SenceVertex.textureCoords) else { return }
        // 分两次glVertexAttribPointer
        // 顶点数据
        buffer?.prepareToDraw(withArrib: GLuint(GLKVertexAttrib.position.rawValue),
                              numberofCoordinates: 3,
                              attribOffset: 0,
                              shouldEnable: true)
        // 纹理数据
        buffer?.prepareToDraw(withArrib: GLuint(GLKVertexAttrib.texCoord0.rawValue),
                              numberofCoordinates: 2,
                              attribOffset: offset,
                              shouldEnable: true)
        buffer?.prepareToDraw(withArrib: GLuint(GLKVertexAttrib.texCoord1.rawValue),
                              numberofCoordinates: 2,
                              attribOffset: offset,
                              shouldEnable: true)


        baseEffect.prepareToDraw()

        buffer?.drawArray(with: GLenum(GL_TRIANGLES),
                          startVertexIndex: 0,
                          numberOfVertices: GLsizei(vertices.count))
    }
    
    deinit {
        let glkView = view as! GLKView
        AGLKContext.setCurrent(glkView.context)
        buffer = nil
        context = nil
        AGLKContext.setCurrent(nil)
    }

}

extension ViewController: GLKViewControllerDelegate {
    func glkViewControllerUpdate(_ controller: GLKViewController) {
        
//        updateTextureParameters()
//        updateAnimatedVerticePositions()
//
//        buffer?.reinit(stride: MemoryLayout<SenceVertex>.stride, numberOfVertices: GLsizei(vertices.count), bytes: vertices)
        
    }
    
    
}

