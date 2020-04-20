//
//  AGLKTextureTransformBaseEffect.swift
//  OpenGLESDemo_2
//
//  Created by 壹九科技1 on 2020/4/20.
//  Copyright © 2020 zxf. All rights reserved.
//

import GLKit

let AGLKModelviewMatrix =       0
let AGLKMVPMatrix       =       1
let AGLKNormalMatrix    =       2
let AGLKTex0Matrix      =       3
let AGLKTex1Matrix      =       4
let AGLKSamplers        =       5
let AGLKTex0Enabled     =       6
let AGLKTex1Enabled     =       7
let AGLKGlobalAmbient   =       8
let AGLKLight0Pos       =       9
let AGLKLight0Direction =       10
let AGLKLight0Diffuse   =       11
let AGLKLight0Cutoff    =       12
let AGLKLight0Exponent  =       13
let AGLKLight1Pos       =       14
let AGLKLight1Direction =       15
let AGLKLight1Diffuse   =       16
let AGLKLight1Cutoff    =       17
let AGLKLight1Exponent  =       18
let AGLKLight2Pos       =       19
let AGLKLight2Diffuse   =       20
let AGLKNumUniforms     =       21


class AGLKTextureTransformBaseEffect: GLKBaseEffect {
    var program: GLuint = GLuint()
    var uniforms: [GLint] = [GLint]()
    
    var light0EyePosition: GLKVector3?
    var light0EyeDirection: GLKVector3?
    var light1EyePosition: GLKVector3?
    var light1EyeDirection: GLKVector3?
    var light2EyePosition: GLKVector3?
    
    private var _light0Position: GLKVector4?
    var light0Position: GLKVector4? {
        set {
            light0.position = newValue!
            let position = GLKMatrix4MultiplyVector4(light0.transform.modelviewMatrix, newValue!)
            light0EyePosition = GLKVector3Make(position.x, position.y, position.z)
        }
        get {
            return light0.position
        }
    }
    private var _light0SpotDirection: GLKVector3?
    var light0SpotDirection: GLKVector3? {
        set {
            light0.spotDirection = newValue!
            let direction = GLKMatrix4MultiplyVector3(light0.transform.modelviewMatrix, newValue!)
            light0EyeDirection = GLKVector3Normalize(GLKVector3Make(direction.x, direction.y, direction.z))
        }
        get {
            return light0.spotDirection
        }
    }
    var light1Position: GLKVector4? {
           set {
               light1.position = newValue!
               let position = GLKMatrix4MultiplyVector4(light1.transform.modelviewMatrix, newValue!)
               light1EyePosition = GLKVector3Make(position.x, position.y, position.z)
           }
           get {
               return light1.position
           }
       }
    var light1SpotDirection: GLKVector3? {
        set {
            light1.spotDirection = newValue!
            let direction = GLKMatrix4MultiplyVector3(light1.transform.modelviewMatrix, newValue!)
            light1EyeDirection = GLKVector3Normalize(GLKVector3Make(direction.x, direction.y, direction.z))
        }
        get {
            return light1.spotDirection
        }
    }
    var light2Position: GLKVector4? {
        set {
            light2.position = newValue!
            let position = GLKMatrix4MultiplyVector4(light2.transform.modelviewMatrix, newValue!)
            light2EyePosition = GLKVector3Make(position.x, position.y, position.z)
        }
        get {
            return light2.position
        }
    }
    
    var textureMatrix2d0: GLKMatrix4?
    var textureMatrix2d1: GLKMatrix4?
    
    override init() {
        super.init()
        textureMatrix2d0 = GLKMatrix4Identity
        textureMatrix2d1 = GLKMatrix4Identity
        texture2d0.enabled = GLboolean(GL_FALSE)
        texture2d1.enabled = GLboolean(GL_FALSE)
        
        material.ambientColor = GLKVector4Make(1, 1, 1, 1)
        lightModelAmbientColor = GLKVector4Make(1, 1, 1, 1)
        
        light0.enabled = GLboolean(GL_FALSE)
        light1.enabled = GLboolean(GL_FALSE)
        light2.enabled = GLboolean(GL_FALSE)
        
    }
    
    func prepareToDrawMutitextures() {
        if 1 == program {
            
        }
    }
 
    
    
}


extension GLKEffectPropertyTexture {
    func aglkSetParameter(parameterID: GLenum, value: GLint) {
        
    }
}
