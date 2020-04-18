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
    var ver: GLKVector3?
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
        SenceVertex(ver: GLKVector3Make(-0.5, -0.5, 0.5)),
        SenceVertex(ver: GLKVector3Make(0.5, -0.5, 0)),
        SenceVertex(ver: GLKVector3Make(0, 0.5, 0)),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        context = AGLKContext(api: .openGLES3)
        let glkView = view as! GLKView
        glkView.context = context
        AGLKContext.setCurrent(context)
        
        baseEffect.useConstantColor = GLboolean(GL_TRUE)
        baseEffect.constantColor = GLKVector4(v: (0.2,0.7,1,1))
        
        buffer = AGLKVertexAttribArrayBuffer(stride: MemoryLayout<SenceVertex>.stride, numberOfVertices: GLsizei(vertices.count), dataPtr: vertices, usage: GLenum(GL_STATIC_DRAW))
    }
    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        
        baseEffect.prepareToDraw()
        context.clearColor = GLKVector4Make(0.5, 1, 0.1, 1)

        buffer?.prepareToDraw(withArrib: GLuint(GLKVertexAttrib.position.rawValue), numberofCoordinates: 3, attribOffset: 0, shouldEnable: true)
        
        buffer?.drawArray(with: GLenum(GL_TRIANGLES), startVertexIndex: 0, numberOfVertices: GLsizei(vertices.count))
    }

//    func update() {
//        print("udpate")
//    }

}

