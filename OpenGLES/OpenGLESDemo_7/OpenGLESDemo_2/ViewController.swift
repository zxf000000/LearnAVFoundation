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
    var positionCoords: GLKVector3!
    var textureCoords: GLKVector2!
}

extension Array {
    func size() -> Int {
        return MemoryLayout<Element>.stride * count
    }
}


// category of context
class ViewController: GLKViewController {

    var context: AGLKContext!
    
    var buffer: AGLKVertexAttribArrayBuffer?
    let baseEffect: GLKBaseEffect = GLKBaseEffect()
    var extraEffect: GLKBaseEffect?
    
    var vertexPositionBuffer: AGLKVertexAttribArrayBuffer?
    var vertexNormalBuffer: AGLKVertexAttribArrayBuffer?
    var vertexTextureCoordinateBuffer: AGLKVertexAttribArrayBuffer?

    var shouldUseDetailLighting: Bool! = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        context = AGLKContext(api: .openGLES3)
        let glkView = view as! GLKView
        glkView.context = context
        AGLKContext.setCurrent(context)

        glkView.drawableDepthFormat = GLKViewDrawableDepthFormat.format16
        
        baseEffect.light0.enabled = GLboolean(GL_TRUE)
        baseEffect.light0.diffuseColor = GLKVector4Make(0.7, 0.7, 0.7, 1)
        baseEffect.light0.ambientColor = GLKVector4Make(0.2, 0.2, 0.2, 1)
        baseEffect.light0.position = GLKVector4Make(1, 0, -0.8, 0)
        
        let image = UIImage(named: "Earth512x256.jpg")?.cgImage
        let textureInfo = try! GLKTextureLoader.texture(with: image!, options: [GLKTextureLoaderOriginBottomLeft: true])
        
        baseEffect.texture2d0.name = textureInfo.name
        baseEffect.texture2d0.target = GLKTextureTarget(rawValue: textureInfo.target)!
        

        
        context.clearColor = GLKVector4Make(0, 0, 0, 1)
        
        let floatStride = MemoryLayout<Float>.stride
        
        vertexPositionBuffer = AGLKVertexAttribArrayBuffer(stride: floatStride * 3, numberOfVertices: GLsizei(sphereVerts.size() / (floatStride * 3)), dataPtr: sphereVerts, usage: GLenum(GL_STATIC_DRAW))
        
        vertexNormalBuffer = AGLKVertexAttribArrayBuffer(stride: floatStride * 3, numberOfVertices: Int32(sphereNormals.count) / 3, dataPtr: sphereNormals, usage: GLenum(GL_STATIC_DRAW))
        
        vertexTextureCoordinateBuffer = AGLKVertexAttribArrayBuffer(stride: floatStride * 2, numberOfVertices: GLsizei(sphereTexCoords.size() / (floatStride * 2)), dataPtr: sphereTexCoords, usage: GLenum(GL_STATIC_DRAW))
        
        context.enable(capability: GLenum(GL_DEPTH_TEST))
        
    }
    

    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        context.clear(mask: GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
        
        baseEffect.prepareToDraw()
                
        vertexPositionBuffer?.prepareToDraw(
            withArrib: GLuint(GLKVertexAttrib.position.rawValue),
            numberofCoordinates: 3,
            attribOffset: 0,
            shouldEnable: true)
        
        
        vertexNormalBuffer?.prepareToDraw(
            withArrib: GLuint(GLKVertexAttrib.normal.rawValue),
            numberofCoordinates: 3,
            attribOffset: 0,
            shouldEnable: true)
        
        vertexTextureCoordinateBuffer?.prepareToDraw(
            withArrib: GLuint(GLKVertexAttrib.texCoord0.rawValue),
            numberofCoordinates: 2,
            attribOffset: 0,
            shouldEnable: true)
        
        
        let aspectRatio = CGFloat(view.drawableWidth) / CGFloat(view.drawableHeight)
        let transform = GLKMatrix4MakeScale(1, Float(aspectRatio), 1)
//        transform = GLKMatrix4Multiply(transform, GLKMatrix4MakeFrustum(1, 1, 1, 1, 0, 0))
        baseEffect.transform.projectionMatrix = transform

        
        AGLKVertexAttribArrayBuffer.drawPreparedArrays(with: GLenum(GL_TRIANGLES), start: 0, numberOfVertices: GLsizei(sphereNumVerts))


    }
    
    deinit {
        let glkView = view as! GLKView
        AGLKContext.setCurrent(glkView.context)
        buffer = nil
        context = nil
        AGLKContext.setCurrent(nil)
    }

}

