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
    
    var switcher: UISwitch! = UISwitch()
    
    var toolsView: UIView!
    var slider: UISlider!
    var button: UIButton = UIButton()
    
    var cameraControl: CameraController!
    
    var captureButton: UIButton = UIButton()
    var recordButton: UIButton = UIButton()
    var detectFaceButton: UIButton = UIButton()

    override func viewDidLoad() {
    super.viewDidLoad()
        
        
        guard let glkView = view as? GLKView else {return}
        glkView.context = self.context
        glkView.drawableDepthFormat = GLKViewDrawableDepthFormat.format24
        setupGL()
        
        self.delegate = self
        cameraControl = CameraController(context: context)
        
        tapStartButton()

    }
    
    func setupGL()  {
        let cubeVertices1: [GLfloat] = [
            //  Position                 Normal                  Texture
             // x,    y,     z           x,    y,    z           s,    t
                0.50, -0.50, -0.50,      1.00, 0.00, 0.00,       1.00, 1.00,
                0.50,  0.50, -0.50,      1.00, 0.00, 0.00,       1.00, 0.00,
                0.50, -0.50,  0.50,      1.00, 0.00, 0.00,       0.00, 1.00,
                0.50, -0.50,  0.50,      1.00, 0.00, 0.00,       0.00, 1.00,
                0.50,  0.50, -0.50,      1.00, 0.00, 0.00,       1.00, 0.00,
                0.50,  0.50,  0.50,      1.00, 0.00, 0.00,       0.00, 0.00,

                0.50, 0.50, -0.50,       0.00, 1.00, 0.00,       1.00, 0.00,
               -0.50, 0.50, -0.50,       0.00, 1.00, 0.00,       0.00, 0.00,
                0.50, 0.50,  0.50,       0.00, 1.00, 0.00,       1.00, 1.00,
                0.50, 0.50,  0.50,       0.00, 1.00, 0.00,       1.00, 1.00,
               -0.50, 0.50, -0.50,       0.00, 1.00, 0.00,       0.00, 0.00,
               -0.50, 0.50,  0.50,       0.00, 1.00, 0.00,       0.00, 1.00,

               -0.50,  0.50, -0.50,     -1.00, 0.00, 0.00,       0.00, 1.00,
               -0.50, -0.50, -0.50,     -1.00, 0.00, 0.00,       1.00, 1.00,
               -0.50,  0.50,  0.50,     -1.00, 0.00, 0.00,       0.00, 0.00,
               -0.50,  0.50,  0.50,     -1.00, 0.00, 0.00,       0.00, 0.00,
               -0.50, -0.50, -0.50,     -1.00, 0.00, 0.00,       1.00, 1.00,
               -0.50, -0.50,  0.50,     -1.00, 0.00, 0.00,       1.00, 0.00,

               -0.50, -0.50, -0.50,      0.00, -1.00, 0.00,      1.00, 0.00,
                0.50, -0.50, -0.50,      0.00, -1.00, 0.00,      0.00, 0.00,
               -0.50, -0.50,  0.50,      0.00, -1.00, 0.00,      1.00, 1.00,
               -0.50, -0.50,  0.50,      0.00, -1.00, 0.00,      1.00, 1.00,
                0.50, -0.50, -0.50,      0.00, -1.00, 0.00,      0.00, 0.00,
                0.50, -0.50,  0.50,      0.00, -1.00, 0.00,      0.00, 1.00,

                0.50,  0.50, 0.50,       0.00, 0.00, 1.00,       0.00, 0.00,
               -0.50,  0.50, 0.50,       0.00, 0.00, 1.00,       0.00, 1.00,
                0.50, -0.50, 0.50,       0.00, 0.00, 1.00,       1.00, 0.00,
                0.50, -0.50, 0.50,       0.00, 0.00, 1.00,       1.00, 0.00,
               -0.50,  0.50, 0.50,       0.00, 0.00, 1.00,       0.00, 1.00,
               -0.50, -0.50, 0.50,       0.00, 0.00, 1.00,       1.00, 1.00,

                0.50, -0.50, -0.50,      0.00, 0.00, -1.00,      0.00, 1.00,
               -0.50, -0.50, -0.50,      0.00, 0.00, -1.00,      1.00, 1.00,
                0.50,  0.50, -0.50,      0.00, 0.00, -1.00,      0.00, 0.00,
                0.50,  0.50, -0.50,      0.00, 0.00, -1.00,      0.00, 0.00,
               -0.50, -0.50, -0.50,      0.00, 0.00, -1.00,      1.00, 1.00,
               -0.50,  0.50, -0.50,      0.00, 0.00, -1.00,      1.00, 0.00
        ]
        
        var vertices = [SceneVertex]()
        var tempArr = [GLfloat]()
        for i in 0..<cubeVertices1.count {
            tempArr.append(cubeVertices1[i])
            if tempArr.count == 8 {
                vertices.append(SceneVertex(position: GLKVector3Make(tempArr[0], tempArr[1], tempArr[2]), normal: GLKVector3Make(tempArr[3], tempArr[4], tempArr[5]), texture: GLKVector2Make(tempArr[6], tempArr[7])))
                tempArr = [GLfloat]()
            }
        }
        
        EAGLContext.setCurrent(self.context)
        shaderProgram = ShaderProgram(shaderName: "Shader")
        shaderProgram.addVertexAttribute(attribute: GLKVertexAttrib.position, name: "position")
        shaderProgram.addVertexAttribute(attribute: GLKVertexAttrib.texCoord0, name: "videoTextureCoordinate")
        let result = shaderProgram.linkProgram()
        if !result {
            return
        }
        uniforms[UNIFORM.UNIFORM_MVP_MATRIX.rawValue] = shaderProgram.uniformIndex("mvpMatrix")
        glEnable(GLenum(GL_DEPTH_TEST))
        
        glGenVertexArraysOES(1, &vertexArray)
        glBindVertexArrayOES(vertexArray)
        
        
        glGenBuffers(1, &vertexBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER),
                     vertices.size(),
                     vertices,
                     GLenum(GL_STATIC_DRAW))
        
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.position.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.position.rawValue),
                              3,
                              GLenum(GL_FLOAT),
                              GLboolean(GL_FALSE),
                              GLsizei(MemoryLayout<SceneVertex>.stride),
                              UnsafeRawPointer.init(bitPattern: 0))
        
        var offset = MemoryLayout.offset(of: \SceneVertex.normal)
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.normal.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.normal.rawValue),
                              3,
                              GLenum(GL_FLOAT),
                              GLboolean(GL_FALSE),
                              GLsizei(MemoryLayout<SceneVertex>.stride),
                              UnsafeRawPointer.init(bitPattern: offset!))
        
        offset = MemoryLayout.offset(of: \SceneVertex.texture)
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.texCoord0.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.texCoord0.rawValue),
                              2,
                              GLenum(GL_FLOAT),
                              GLboolean(GL_FALSE),
                              GLsizei(MemoryLayout<SceneVertex>.stride),
                              UnsafeRawPointer.init(bitPattern:  offset!))

    }


    func setupUI() {

        
        toolsView = UIView()
        toolsView.frame = view.bounds
        toolsView.backgroundColor = UIColor(white: 0, alpha: 0.1)
        view.addSubview(toolsView)
        
        button.center = view.center
        button.bounds = CGRect(x: 0, y: 0, width: 100, height: 40)
        button.setTitle("start", for: .normal)
        button.backgroundColor = .red
        button.addTarget(self, action: #selector(tapStartButton), for: .touchUpInside)
        toolsView.addSubview(button)
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
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
        glBindVertexArrayOES(vertexArray)

        shaderProgram.useProgram()

            
        let components = MemoryLayout.size(ofValue: mvpMatrix.m)/MemoryLayout.size(ofValue: mvpMatrix.m.0)
        withUnsafePointer(to: &(mvpMatrix.m)) { point in
            point.withMemoryRebound(to: GLfloat.self, capacity: components) {
                glUniformMatrix4fv(uniforms[UNIFORM.UNIFORM_MVP_MATRIX.rawValue], 1, GLboolean(0), $0)
                
                glCheckError()
                glUniform1i(uniforms[UNIFORM.UNIFORM_TEXTURE.rawValue], 0)
                glDrawArrays(GLenum(GL_TRIANGLES), 0, 36)
            }
        }
        
        
    }

}

extension ViewController: GLKViewControllerDelegate {
    func glkViewControllerUpdate(_ controller: GLKViewController) {

        let bounds = view.bounds
        let aspect = abs(bounds.width / bounds.height)
        let projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(50), Float(aspect), 0.1, 100)
        var modelViewMatrix = GLKMatrix4MakeTranslation(0, 0, -3.5)
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, rotation, 1, 1, 1)
        mvpMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix)
        rotation += Float(timeSinceLastUpdate * 0.75)

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


    }
    

}
