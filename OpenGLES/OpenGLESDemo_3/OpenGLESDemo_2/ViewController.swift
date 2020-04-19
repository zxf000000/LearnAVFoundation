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
        
        glCheckError()
        baseEffect.useConstantColor = GLboolean(GL_TRUE)
        baseEffect.constantColor = GLKVector4Make(1, 1, 1, 1)
        
        context.clearColor = GLKVector4Make(0, 0, 0, 1)
        
        self.buffer = AGLKVertexAttribArrayBuffer(stride: MemoryLayout<SenceVertex>.stride,
                                                  numberOfVertices: GLsizei(vertices.count),
                                                  dataPtr: vertices,
                                                  usage: GLenum(GL_STATIC_DRAW))
        guard let imageRef = UIImage(contentsOfFile: Bundle.main.path(forResource: "leaves.gif", ofType: nil) ?? "")?.cgImage else { return }

        let textureInfo = AGLKTextLoader.textureInfo(with: imageRef, options: nil)
        baseEffect.texture2d0.name = textureInfo.name ?? 0
        baseEffect.texture2d0.target = GLKTextureTarget(rawValue: textureInfo.target ?? 0)!
    }
    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        baseEffect.prepareToDraw()
        context.clear(mask: GLbitfield(GL_COLOR_BUFFER_BIT))
        guard let offset = MemoryLayout<SenceVertex>.offset(of: \SenceVertex.textureCoords) else { return }
        // 分两次glVertexAttribPointer
        // 顶点数据
        buffer?.prepareToDraw(withArrib: GLuint(GLKVertexAttrib.position.rawValue), numberofCoordinates: 3, attribOffset: 0, shouldEnable: true)
        // 纹理数据
        buffer?.prepareToDraw(withArrib: GLuint(GLKVertexAttrib.texCoord0.rawValue), numberofCoordinates: 2, attribOffset: offset, shouldEnable: true)
        buffer?.drawArray(with: GLenum(GL_TRIANGLES), startVertexIndex: 0, numberOfVertices: 3)

    }

}

