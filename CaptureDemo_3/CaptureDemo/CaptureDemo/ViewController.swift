//
//  ViewController.swift
//  CaptureDemo
//

import UIKit
import AVFoundation
import GLKit
import OpenGLES.ES2.gl
import OpenGLES.ES2.glext

enum UNIFORM: Int {
    case UNIFORM_MVP_MATRIX
    case UNIFORM_TEXTURE
    case NUM_UNIFORMS
}


extension Array {
    func size() -> Int {
        return MemoryLayout<Element>.stride * self.count
    }
}

struct SceneVertex {
    var position: GLKVector3
    var normal: GLKVector3
    var texture: GLKVector2
}


class ViewController: GLKViewController {

    var context: EAGLContext = EAGLContext(api: .openGLES2)!
  
    var uniforms: [GLint] = [GLint](repeating: GLint(), count: 2)
    var shaderProgram: ShaderProgram!
    var mvpMatrix: GLKMatrix4! = GLKMatrix4Identity
    var rotation: Float! = 0
    var vertexArray: GLuint! = GLuint()
    var vertexBuffer: GLuint! = GLuint()

    let baseEffect = GLKBaseEffect()
    
    var cameraControl: CameraController!

    var squareVertices = [
        SceneVertex(position: GLKVector3Make(-1, -0.67, 0), normal: GLKVector3Make(1, 0, 0), texture: GLKVector2Make(0, 0)),
        SceneVertex(position: GLKVector3Make(1, -0.67, 0), normal: GLKVector3Make(0, 1, 0), texture: GLKVector2Make(1, 0)),
        SceneVertex(position: GLKVector3Make(-1, 0.67, 0), normal: GLKVector3Make(0, 0, 1), texture: GLKVector2Make(0, 1)),
        SceneVertex(position: GLKVector3Make(1, -0.67, 0), normal: GLKVector3Make(0, 1, 0), texture: GLKVector2Make(1, 0)),
        SceneVertex(position: GLKVector3Make(1, 0.67, 0), normal: GLKVector3Make(1, 0, 0), texture: GLKVector2Make(1, 1)),
        SceneVertex(position: GLKVector3Make(-1, 0.67, 0), normal: GLKVector3Make(0, 0, 1), texture: GLKVector2Make(0, 1)),
    ]

    override func viewDidLoad() {
    super.viewDidLoad()
        
        
        guard let glkView = view as? GLKView else {return}
        glkView.context = self.context
        setupGL()
        
        cameraControl = CameraController(context: context)
        
        tapStartButton()

    }
    
    func setupGL()  {
        
        
        EAGLContext.setCurrent(self.context)

        
        glGenVertexArraysOES(1, &vertexArray)
        glBindVertexArrayOES(vertexArray)
        
        
        glGenBuffers(1, &vertexBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER),
                     squareVertices.size(),
                     squareVertices,
                     GLenum(GL_STATIC_DRAW))
        
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.position.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.position.rawValue),
                              3,
                              GLenum(GL_FLOAT),
                              GLboolean(GL_FALSE),
                              GLsizei(MemoryLayout<SceneVertex>.stride),
                              UnsafeRawPointer.init(bitPattern: 0))
        
//        var offset = MemoryLayout.offset(of: \SceneVertex.normal)
//        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.normal.rawValue))
//        glVertexAttribPointer(GLuint(GLKVertexAttrib.normal.rawValue),
//                              3,
//                              GLenum(GL_FLOAT),
//                              GLboolean(GL_FALSE),
//                              GLsizei(MemoryLayout<SceneVertex>.stride),
//                              UnsafeRawPointer.init(bitPattern: offset!))

        let offset = MemoryLayout.offset(of: \SceneVertex.texture)
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.texCoord0.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.texCoord0.rawValue),
                              2,
                              GLenum(GL_FLOAT),
                              GLboolean(GL_FALSE),
                              GLsizei(MemoryLayout<SceneVertex>.stride),
                              UnsafeRawPointer.init(bitPattern:  offset!))

        
        
    }


    func setupUI() {

    }

    @objc
    func tapStartButton() {
        cameraControl.delegate = self
        cameraControl.textureDelegate = self
        do {
            let _ = try cameraControl.setupSession()
            cameraControl.startSession()
        } catch {
        }
    }


    override func glkView(_ view: GLKView, drawIn rect: CGRect) {

        glClearColor(0.2, 0.2, 0.2, 1)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        baseEffect.prepareToDraw()

        glBindVertexArrayOES(vertexArray)


        glDrawArrays(GLenum(GL_TRIANGLES), 0, GLsizei(squareVertices.count))
        
        
    }

}

extension ViewController: GLKViewControllerDelegate {
    func glkViewControllerUpdate(_ controller: GLKViewController) {

//        let bounds = view.bounds
//        let aspect = abs(bounds.width / bounds.height)
//        let projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(50), Float(aspect), 0.1, 100)
//        var modelViewMatrix = GLKMatrix4MakeTranslation(0, 0, -3.5)
//        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, rotation, 1, 1, 1)
//        mvpMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix)
//        rotation += Float(timeSinceLastUpdate * 0.75)

    }
    
    
}

extension ViewController: CameraControllerDelegate {
    func deviceConfigurationFailed(with error: Error?) {
        print("deviceConfigurationFailed")
        
    }
    func mediaCaptureFailed(with error: Error?) {
        print("mediaCaptureFailed")
    }
    func assetLibraryWriteFailed(with error: Error?) {
        print("assetLibraryWriteFailed")        
    }
    
    
    
}

extension ViewController: TextureDelegate {
    func textureCreated(with target: GLenum, name: GLuint) {
        
        glActiveTexture(GLenum(GL_TEXTURE0))

        glBindTexture(target, name)

        glTexParameterf(GLenum(GL_TEXTURE_2D),
                        GLenum(GL_TEXTURE_WRAP_S),
                        GLfloat(GL_CLAMP_TO_EDGE))

        glTexParameterf(GLenum(GL_TEXTURE_2D),
                        GLenum(GL_TEXTURE_WRAP_T),
                        GLfloat(GL_CLAMP_TO_EDGE))
        
        baseEffect.texture2d0.enabled = GLboolean(GL_TRUE)
        baseEffect.texture2d0.name = name
        baseEffect.texture2d0.target = GLKTextureTarget(rawValue: target)!


    }
    

}
