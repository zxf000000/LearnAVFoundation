//
//  ShaderProgram.swift
//  CaptureDemo
//
//  Created by 壹九科技1 on 2020/4/16.
//  Copyright © 2020 zxf. All rights reserved.
//

import GLKit

enum AttributeIndex {
    case ATTRIB_VERTEX
    case ATTRIB_TEXTCOORDS
    case NUM_ATTRIBUTES
}

class ShaderProgram {
    var shaderProgram: GLuint = GLuint()
    var verShader: GLuint = GLuint()
    var fragShader: GLuint = GLuint()
    var attributes: Array<Any>?
    var uniforms: Array<Any>?
    
    init(shaderName: String) {
        shaderProgram = glCreateProgram()
        let vertShaderPath = path(for: shaderName, type: "vsh")
        if !compile(shader: &verShader, type: GLenum(GL_VERTEX_SHADER), file: vertShaderPath) {
            print("failed")
        }
        let fragShaderPath = path(for: shaderName, type: "fsh")
        if !compile(shader: &fragShader, type: GLenum(GL_FRAGMENT_SHADER), file: fragShaderPath) {
            print("failed")
        }
        glAttachShader(shaderProgram, verShader)
        glAttachShader(shaderProgram, fragShader)

    }
    
    
    func path(for name: String, type: String?) -> String {
        return Bundle.main.path(forResource: name, ofType: type) ?? ""
    }
    
    func addVertexAttribute(attribute: GLKVertexAttrib, name: String) {

        glBindAttribLocation(shaderProgram, GLuint(attribute.rawValue), getUnsafePoitner(from: name.utf8CString))
    }
    
    func uniformIndex(_ uniform: String) -> GLint {
        return glGetUniformLocation(shaderProgram, getUnsafePoitner(from: uniform.utf8CString))
    }
    
    func compile(shader: inout GLuint, type: GLenum, file: String) -> Bool {
        var status: GLint = GLint()
        
        do {
            let source = try String(contentsOfFile: file, encoding: .utf8)
            
            var cStringSource = (source as NSString).utf8String
                        
            shader = glCreateShader(type)
            glCheckError()
            glShaderSource(shader, 1, &cStringSource, nil)
            glCheckError()
            glCompileShader(shader)
            glCheckError()

            
            var logLength = GLint()
            glGetShaderiv(shader, GLenum(GL_INFO_LOG_LENGTH), &logLength)
            if (logLength > 0) {
                let log = UnsafeMutablePointer<GLchar>.allocate(capacity: Int(logLength))
                glGetShaderInfoLog(shader, logLength, &logLength, log)
                
                print("Shader compile log: \(String(describing: String(cString: log, encoding: .unicode))))")
                
                free(log)
            }
            
            glGetShaderiv(shader, GLenum(GL_COMPILE_STATUS), &status)

            if status == 0 {
                glDeleteShader(shader)
                return false
            }
            return true

        } catch {
            return false
        }
    }

    func linkProgram() -> Bool {
        var status: GLint = GLint()
        glLinkProgram(shaderProgram)
        glGetProgramiv(shaderProgram, GLenum(GL_LINK_STATUS), &status)
        if status == 0 {
            return false
        }
        
        glDetachShader(shaderProgram, verShader)
        glDeleteShader(verShader)
        glDetachShader(shaderProgram, fragShader)
        glDeleteShader(fragShader)
        
        return true
    }
    
    func useProgress() {
        glUseProgram(shaderProgram)
    }
    
    func getUnsafePoitner(from utf8String: ContiguousArray<CChar>) -> UnsafePointer<CChar> {
        let string = utf8String
        let address = string.withUnsafeBufferPointer({$0})
        return address.baseAddress!
    }
    
}
