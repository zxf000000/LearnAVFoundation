//
//  ViewController.swift
//  GLTriangleDemo_2
//
//  Created by 壹九科技1 on 2020/4/18.
//  Copyright © 2020 zxf. All rights reserved.
//

import UIKit
import GLKit

extension Array {
    func size() -> Int {
        return MemoryLayout<Element>.size * count
    }
}

struct SenceVertex {
    var position: GLKVector3?
}

class ViewController: GLKViewController {

    let context: EAGLContext = EAGLContext(api: .openGLES3)!
    
    let vertices = [
        SenceVertex(position: GLKVector3Make(-0.5, -0.5, 0)),
        SenceVertex(position: GLKVector3Make(0.5, -0.5, 0)),
        SenceVertex(position: GLKVector3Make(0, 0.5, 0))
    ]
    
    var vao: GLuint = GLuint()
    var shaderProgram: GLuint = glCreateProgram()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let glkView = view as! GLKView
        glkView.context = context
        EAGLContext.setCurrent(context)
            
        
        var vbo = GLuint()
        glGenBuffers(1, &vbo)
        defer {
            glDeleteBuffers(1, &vbo)
        }
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo)
        
        glBufferData(GLenum(GL_ARRAY_BUFFER), vertices.size(), vertices, GLenum(GL_STATIC_DRAW))
        
        let vertexShader = glCreateShader(GLenum(GL_VERTEX_SHADER))
        
        let shaderSource = getShaderSource(with: "Shader", type: "vsh")
        shaderSource.withCString({
            var s: UnsafePointer<CChar>? = $0
            glShaderSource(vertexShader, 1, &s, nil)
        })
        glCompileShader(vertexShader)
        
        var success: GLint = 0
        glGetShaderiv(vertexShader, GLenum(GL_COMPILE_STATUS), &success)
        
        
        let fragShader: GLuint = glCreateShader(GLenum(GL_FRAGMENT_SHADER))
        let fragShaderSouce = getShaderSource(with: "Shader", type: "fsh")
        fragShaderSouce.withCString {
            var s: UnsafePointer<CChar>? = $0
            glShaderSource(fragShader, 1, &s, nil)
        }
        glCompileShader(fragShader)
        
        
        glAttachShader(shaderProgram, vertexShader)
        glAttachShader(shaderProgram, fragShader)
        
        glLinkProgram(shaderProgram)
        
        glGetProgramiv(shaderProgram, GLenum(GL_LINK_STATUS), &success)
        
        glUseProgram(shaderProgram)
        
        glDeleteShader(vertexShader)
        glDeleteShader(fragShader)
        
        glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<SenceVertex>.stride), nil)
        glEnableVertexAttribArray(0)
        
        
        glUseProgram(shaderProgram)
        
        glGenVertexArrays(1, &vao)

        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vao)
        glBufferData(vao, vertices.size(), vertices, GLenum(GL_STATIC_DRAW))
        glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<SenceVertex>.stride), nil)
        glEnableVertexAttribArray(0)
        glBindVertexArray(0)
        
    }

    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        
        
        
        glUseProgram(shaderProgram)
        glBindVertexArray(vao)
        glDrawArrays(GLenum(GL_TRIANGLES), 0, 3)
        glBindVertexArray(0)
    }
    
    func getShaderSource(with name: String, type: String) -> String {
        let vertexShaderPath = Bundle.main.path(forResource: name, ofType: type)
        var shaderSource: String? = nil
        do {
            shaderSource = try String(contentsOfFile: vertexShaderPath ?? "", encoding: .utf8)
        } catch {
            
        }
        return shaderSource ?? ""
    }

}

