//
//  ViewController.swift
//  GLDemo
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

class ViewController: GLKViewController {

    let context = EAGLContext(api: .openGLES3)!
    
    let baseEffect: GLKBaseEffect = GLKBaseEffect()
  
    
    let vertices = [
        SenceVertex(ver: GLKVector3Make(-0.5, -0.5, 0.5)),
        SenceVertex(ver: GLKVector3Make(0.5, -0.5, 0)),
        SenceVertex(ver: GLKVector3Make(0, 0.5, 0)),

    ]

    var vertexBufferID: GLuint = GLuint()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let glkView = view as! GLKView
        glkView.context = context
        EAGLContext.setCurrent(context)
        
        baseEffect.useConstantColor = GLboolean(GL_TRUE)
        baseEffect.constantColor = GLKVector4(v: (1,1,1,1))
        glClearColor(0, 0, 0, 1)

        glGenBuffers(1, &vertexBufferID)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBufferID)
        glBufferData(GLenum(GL_ARRAY_BUFFER), vertices.size(), vertices, GLenum(GL_STATIC_DRAW))
    }
    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        baseEffect.prepareToDraw()

        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.position.rawValue))

        glVertexAttribPointer(GLuint(GLKVertexAttrib.position.rawValue),
                              3,
                              GLenum(GL_FLOAT),
                              GLboolean(GL_FALSE),
                              GLsizei(MemoryLayout<SenceVertex>.stride),
                              nil)

        glDrawArrays(GLenum(GL_TRIANGLES), 0, GLsizei(vertices.count))
    }


}

