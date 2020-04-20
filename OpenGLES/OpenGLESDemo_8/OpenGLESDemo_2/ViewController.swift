//
//  ViewController.swift
//  OpenGLESDemo_2
//
//  Created by 壹九科技1 on 2020/4/18.
//  Copyright © 2020 zxf. All rights reserved.
//

import UIKit
import GLKit



extension Array {
    func size() -> Int {
        return MemoryLayout<Element>.stride * count
    }
}

enum SceneTransformationSelector: Int {
    case SceneTranlate = 0
    case SceneRotate = 1
    case SceneScale = 2
}

enum SceneTransformationAxisSelector: Int {
    case SceneXAxis = 0
    case SceneYAxis = 1
    case SceneZAxis = 2
}

func SceneMatrixForTransform(type: SceneTransformationSelector, axis: SceneTransformationAxisSelector, value: Float) -> GLKMatrix4 {
    var result = GLKMatrix4Identity
    switch type {
    case .SceneRotate:
        switch axis {
        case .SceneXAxis:
            result = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(180 * value), 1, 0, 0)
        case .SceneYAxis:
            result = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(180 * value), 0, 1, 0)
        case .SceneZAxis:
            result = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(180 * value), 0, 0, 1)
        }
    case .SceneScale:
        switch axis {
        case .SceneXAxis:
            result = GLKMatrix4MakeScale(1 + value, 1, 1)
        case .SceneYAxis:
            result = GLKMatrix4MakeScale(1, 1 + value, 1)
        case .SceneZAxis:
            result = GLKMatrix4MakeScale(1 , 1, 1 + value)
        }
        break
    case .SceneTranlate:
        switch axis {
        case .SceneXAxis:
            result = GLKMatrix4MakeTranslation(0.3 * value, 0, 0)
        case .SceneYAxis:
            result = GLKMatrix4MakeTranslation( 0, 0.3 * value, 0)
        case .SceneZAxis:
            result = GLKMatrix4MakeTranslation(0, 0, 0.3 * value)
        }
        break
    }
    return result
}

// category of context
class ViewController: GLKViewController {


    
    var context: AGLKContext!
    
    let baseEffect: GLKBaseEffect = GLKBaseEffect()
    var vertexPositionBuffer: AGLKVertexAttribArrayBuffer?
    var vertexNormalBuffer: AGLKVertexAttribArrayBuffer?
    var vertexTextureCoordinateBuffer: AGLKVertexAttribArrayBuffer?

    override func viewDidLoad() {
        super.viewDidLoad()

        context = AGLKContext(api: .openGLES3)
        let glkView = view as! GLKView
        glkView.context = context
        AGLKContext.setCurrent(context)

        glkView.drawableDepthFormat = GLKViewDrawableDepthFormat.format16
        
        baseEffect.light0.enabled = GLboolean(GL_TRUE)
//        baseEffect.light0.diffuseColor = GLKVector4Make(0.7, 0.7, 0.7, 1)
        baseEffect.light0.ambientColor = GLKVector4Make(0.4, 0.4, 0.4, 1)
        baseEffect.light0.position = GLKVector4Make(1, 0.8, 0.4, 0)
        context.clearColor = GLKVector4Make(0, 0, 0, 1)

        
        
        let floatStride = MemoryLayout<Float>.stride
        
        vertexPositionBuffer = AGLKVertexAttribArrayBuffer(stride: floatStride * 3, numberOfVertices: GLsizei(lowPolyAxesAndModels2Verts.size() / (floatStride * 3)), dataPtr: lowPolyAxesAndModels2Verts, usage: GLenum(GL_STATIC_DRAW))

        vertexNormalBuffer = AGLKVertexAttribArrayBuffer(stride: floatStride * 3, numberOfVertices: Int32(lowPolyAxesAndModels2Normals.count) / 3, dataPtr: lowPolyAxesAndModels2Normals, usage: GLenum(GL_STATIC_DRAW))

        
        context.enable(capability: GLenum(GL_DEPTH_TEST))
        
        var modelviewMatrix = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(30), 1, 0, 0)
        modelviewMatrix = GLKMatrix4Rotate(modelviewMatrix, GLKMathDegreesToRadians(-30), 0, 1, 0)
        modelviewMatrix = GLKMatrix4Translate(modelviewMatrix, -0.25, 0, -0.25)
        
        baseEffect.transform.modelviewMatrix = modelviewMatrix
        
        context.enable(capability: GLenum(GL_BLEND))
        context.setBlendSourceFunction(sfactor: GLenum(GL_SRC_ALPHA), destinationFunction: GLenum(GL_ONE_MINUS_SRC_ALPHA))
    }
    

    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        context.clear(mask: GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
        
                
 
        


    }
    
    deinit {
        let glkView = view as! GLKView
        AGLKContext.setCurrent(glkView.context)
        context = nil
        AGLKContext.setCurrent(nil)
    }

}

