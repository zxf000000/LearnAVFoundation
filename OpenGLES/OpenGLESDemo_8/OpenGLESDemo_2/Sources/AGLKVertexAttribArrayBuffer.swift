//
//  AGLKVertexAttribArrayBuffer.swift
//  OpenGLESDemo_2
//
//  Created by 壹九科技1 on 2020/4/18.
//  Copyright © 2020 zxf. All rights reserved.
//

import GLKit




class AGLKVertexAttribArrayBuffer {
    var stride: GLsizeiptr?
    var bufferSizeBytes: GLsizeiptr?
    var glName: GLuint = GLuint()

    
    /// 构造方法
    /// - Parameters:
    ///   - stride: 单个顶点数据的数据对齐大小
    ///   - numberOfVertices: 顶点个数
    ///   - dataPtr: 顶点数据集合
    ///   - usage: 用处(GL_STATIC_DRAW...)
    init(stride: GLsizeiptr,
         numberOfVertices: GLsizei,
         dataPtr: UnsafeRawPointer,
         usage: GLenum) {
        assert(stride > 0)
        self.stride = stride
        self.bufferSizeBytes = stride * Int(numberOfVertices)
        glGenBuffers(1, &glName)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), glName)
        glBufferData(GLenum(GL_ARRAY_BUFFER), self.bufferSizeBytes!, dataPtr, usage)
        assert(glName > 0, "Failed to generate glName")
    }
    
    func reinit(stride: GLsizeiptr,
           numberOfVertices: GLsizei,
           bytes: UnsafeRawPointer) {
        self.stride = stride
        bufferSizeBytes = stride * Int(numberOfVertices)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), glName)
        glBufferData(GLenum(GL_ARRAY_BUFFER), bufferSizeBytes!, bytes, GLenum(GL_STATIC_DRAW))
        
    }
    
    /// 绑定buffet
    /// - Parameters:
    ///   - index: bufferindex
    ///   - count: 个数
    ///   - offset: 偏移
    ///   - shouldEnable: shouldEnable
    func prepareToDraw(withArrib index: GLuint,
                       numberofCoordinates count: GLint,
                       attribOffset offset: GLsizeiptr,
                       shouldEnable: Bool) {
        assert(count > 0 && count < 4)
        assert(offset < self.stride ?? 0)
        assert(glName != 0, "Invalid glName")
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), self.glName)
        glCheckError()
        if shouldEnable == true {
            glEnableVertexAttribArray(index)
        }
        glCheckError()
        let offset1 = UnsafeRawPointer(bitPattern: offset)
        glCheckError()
        glVertexAttribPointer(index, count, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(stride!), offset1)
        glCheckError()
        
    }
    
    /// 绘制
    /// - Parameters:
    ///   - mode: 模式 `GL_TRIANGLES`...
    ///   - first: 第一个的index
    ///   - count: 绘制顶点数量
    func drawArray(with mode: GLenum,
                   startVertexIndex first: GLint,
                   numberOfVertices count: GLsizei) {
        let totalCount = Int((first + count))*stride!
        assert(self.bufferSizeBytes! >= totalCount, "Attempt to draw more vertex  datat than available")
        glDrawArrays(mode, first, count)
    }
    
    static func drawPreparedArrays(with mode: GLenum, start index: GLint, numberOfVertices count: GLsizei) {
        glDrawArrays(mode, index, count)
    }
    
    deinit {
        if glName != 0 {
            glDeleteBuffers(1, &glName)
            glName = 0
        }
    }
    
}
