//
//  ViewController.swift
//  OpenGLESDemo
//
//  Created by 壹九科技1 on 2020/4/16.
//  Copyright © 2020 zxf. All rights reserved.
//

import UIKit
import GLKit

extension Array {
    func size() -> Int {
        return MemoryLayout<Element>.stride * self.count
    }
}

class ViewController: GLKViewController {

    var context: EAGLContext?
    
    var Vertices = [
        Vertex(x: 1, y: -1, z: 0, r: 1, g: 0, b: 0, a: 1),
        Vertex(x: 1, y: 1, z: 0, r: 0, g: 1, b: 0, a: 1),
        Vertex(x: -1, y: 1, z: 1, r: 0, g: 0, b: 1, a: 1),
        Vertex(x: -1, y: -1, z: 0, r: 0, g: 0, b: 0, a: 1)
    ]
    
    var indices: [GLubyte] = [
        0, 1, 2,
        2, 3, 0
    ]
    
    
    /// Vertex Buffer Object (VBO):
    ///     Keeps track of the per-vertex data itself, like the data you have in the Vertices array.
    /// Element Buffer Object (EBO):
    ///     Keeps track of the indices that define triangles, like the indices you have stored in the Indices array.
    /// Vertex Array Object (VAO):
    ///     This object can be bound like the vertex buffer object. Any future vertex attribute calls you make — after binding a vertex array object — will be stored inside it. What this means is that you only have to make calls to configure vertex attribute pointers once and then — whenever you want to draw an object — you bind the corresponding VAO. This facilitates and speeds up drawing different vertex data with different configurations.
    
    
    private var ebo: GLuint = GLuint()
    private var vbo: GLuint = GLuint()
    private var vao: GLuint = GLuint()
    
    private var effect: GLKBaseEffect! = GLKBaseEffect()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupGL()
        
        
    }
    
    func setupGL() {
        context = EAGLContext(api: EAGLRenderingAPI.openGLES3)
        EAGLContext.setCurrent(context)
        
        let glkView = view as! GLKView
        glkView.context = context!
        delegate = self
        glkView.drawableColorFormat = GLKViewDrawableColorFormat.RGBA8888
        glkView.drawableDepthFormat = GLKViewDrawableDepthFormat.format24
        glkView.drawableStencilFormat = GLKViewDrawableStencilFormat.format8
        // Multisampling is a form of antialiasing that smooths jagged edges,
        // improving image quality in most 3D apps at the cost of using more memory and fragment processing time—if you enable multisampling,
        // always test your app’s performance to ensure that it remains acceptable.
        glkView.drawableMultisample = GLKViewDrawableMultisample.multisample4X
        
        let vertexAttributeColor = GLuint(GLKVertexAttrib.color.rawValue)
        let vertextAttributePosition = GLuint(GLKVertexAttrib.position.rawValue)
        let vertexSize = MemoryLayout<Vertex>.stride
        /// 取出颜色的值的偏移, 颜色值在Vertex结构体中从第四个开始, 所以要偏移3个 GLfloat (x, y, z)
        let colorOffset = MemoryLayout<GLfloat>.stride * 3
        /// 把颜色的偏移转换成转换成指针
        let colorOffsetPointer = UnsafeRawPointer(bitPattern: colorOffset)
        
        /// 创建一个新的 vao
        glGenVertexArraysOES(1, &vao)
        /// 绑定
        glBindVertexArrayOES(vao)
        
        glGenBuffers(1, &vbo)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo)
        glBufferData(GLenum(GL_ARRAY_BUFFER),
                     Vertices.size(),
                     Vertices,
                     GLenum(GL_STATIC_DRAW))
        
        glEnableVertexAttribArray(vertextAttributePosition)
        glVertexAttribPointer(vertextAttributePosition,
                              3,
                              GLenum(GL_FLOAT),
                              GLboolean(UInt8(GL_FALSE)),
                              GLsizei(vertexSize), nil)
        
        glEnableVertexAttribArray(vertexAttributeColor)
        glVertexAttribPointer(vertexAttributeColor,
                              4,
                              GLenum(GL_FLOAT),
                              GLboolean(UInt8(GL_FALSE)),
                              GLsizei(vertexSize),
                              colorOffsetPointer)
        
        
        glGenBuffers(1, &ebo)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), ebo)
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER),
                     indices.size(),
                     indices,
                     GLenum(GL_STATIC_DRAW))
        
        
        glBindVertexArrayOES(0)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), 0)

        
    }

    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
                
        glClearColor(0.85, 0.85, 0.85, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        effect.prepareToDraw()
        
        glBindVertexArrayOES(vao)

        
        glDrawElements(GLenum(GL_TRIANGLES),
                       GLsizei(indices.count),
                       GLenum(GL_UNSIGNED_BYTE),
                       nil)
        glBindVertexArrayOES(0)

    }
    
    
    private func tearDownGL() {
        EAGLContext.setCurrent(context)
        glDeleteBuffers(1, &vao)
        glDeleteBuffers(1, &vbo)
        glDeleteBuffers(1, &ebo)
        EAGLContext.setCurrent(nil)
        context = nil
    }
    
    deinit {
        tearDownGL()
    }


}

extension ViewController: GLKViewControllerDelegate {
    func glkViewControllerUpdate(_ controller: GLKViewController) {
        
    }
    
    
}

