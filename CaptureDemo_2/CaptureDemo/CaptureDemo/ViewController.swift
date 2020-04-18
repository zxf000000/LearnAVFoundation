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

class ViewController: GLKViewController {

    var context: EAGLContext = EAGLContext(api: .openGLES3)!
  
    var uniforms: GLint!
    var shaderProgram: ShaderProgram!
    var mvpMatrix: GLKMatrix4!
    var rotation: Float! = 0
    var vertexArray: GLuint! = GLuint()
    var vertexBuffer: GLuint! = GLuint()
    
    var switcher: UISwitch! = UISwitch()
    
    var toolsView: UIView!
    var slider: UISlider!
    var button: UIButton = UIButton()
    var previewView: PreviewView!
    
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

        let bounds = view.bounds
        let aspect = fabs(bounds.width / bounds.height)
        let projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(50), Float(aspect), 0.1, 100)
        var modelViewMatrix = GLKMatrix4MakeTranslation(0, 0, -3.5)
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, rotation, 1, 1, 1)
        mvpMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix)
        rotation += Float(timeSinceLastUpdate * 0.75)

//        setupUI()
        
        tapStartButton()
    }
    
    func setupGL()  {
        let cubeVertices: [GLfloat] = [
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
        
        EAGLContext.setCurrent(self.context)
        shaderProgram = ShaderProgram(shaderName: "Shader")
        shaderProgram.addVertexAttribute(attribute: GLKVertexAttrib.position, name: "position")
        shaderProgram.addVertexAttribute(attribute: GLKVertexAttrib.texCoord0, name: "videoTextureCoordinate")
        let result = shaderProgram.linkProgram()
        if !result {
            return
        }
        uniforms = shaderProgram.uniformIndex("mvpMatrix")
        glEnable(GLenum(GL_DEPTH_TEST))
        
        glGenVertexArraysOES(1, &vertexArray)
        glBindVertexArrayOES(vertexArray)
        
        glGenBuffers(1, &vertexBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), cubeVertices.size(), cubeVertices, GLenum(GL_STATIC_DRAW))
        
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.position.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.position.rawValue),
                              3,
                              GLenum(GL_FLOAT),
                              GLboolean(GL_FALSE),
                              Int32(MemoryLayout<GLfloat>.size) * 8,
                              UnsafeRawPointer.init(bitPattern: 0))
        
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.normal.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.normal.rawValue),
                              3,
                              GLenum(GL_FLOAT),
                              GLboolean(GL_FALSE),
                              Int32(MemoryLayout<GLfloat>.size) * 8,
                              UnsafeRawPointer.init(bitPattern: MemoryLayout<GLfloat>.size * 3))
        
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.texCoord0.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.texCoord0.rawValue),
                              2,
                              GLenum(GL_FLOAT),
                              GLboolean(GL_FALSE),
                              Int32(MemoryLayout<GLfloat>.size) * 8,
                              UnsafeRawPointer.init(bitPattern:  MemoryLayout<GLfloat>.size * 6))
        
            
        
        
    }

    func update() {
        let bounds = view.bounds
        let aspect = fabs(bounds.width / bounds.height)
        let projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(50), Float(aspect), 0.1, 100)
        var modelViewMatrix = GLKMatrix4MakeTranslation(0, 0, -3.5)
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, rotation, 1, 1, 1)
        mvpMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix)
        rotation += Float(timeSinceLastUpdate * 0.75)
    }
    
    func setupUI() {
        
        previewView = PreviewView()
        previewView.frame = view.bounds
        view.addSubview(previewView)
        
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
        
        captureButton.center = CGPoint(x: view.center.x, y: view.center.y + 100)
        captureButton.bounds = CGRect(x: 0, y: 0, width: 100, height: 40)
        captureButton.setTitle("captureImage", for: .normal)
        captureButton.backgroundColor = .red
        captureButton.addTarget(self, action: #selector(tapCaptureButton), for: .touchUpInside)
        toolsView.addSubview(captureButton)
        
        recordButton.center = CGPoint(x: view.center.x, y: view.center.y + 150)
        recordButton.bounds = CGRect(x: 0, y: 0, width: 100, height: 40)
        recordButton.setTitle("record", for: .normal)
        recordButton.backgroundColor = .red
        recordButton.addTarget(self, action: #selector(tapRecordButton), for: .touchUpInside)
        toolsView.addSubview(recordButton)

        switcher.frame = CGRect(x: 20, y: 130, width: 100, height: 40)
        toolsView.addSubview(switcher)
        switcher.addTarget(self, action: #selector(switcherChange), for: .valueChanged)
        
        detectFaceButton.center = CGPoint(x: view.center.x, y: view.center.y + 200)
        detectFaceButton.bounds = CGRect(x: 0, y: 0, width: 100, height: 40)
        detectFaceButton.setTitle("detectFace", for: .normal)
        detectFaceButton.backgroundColor = .red
        detectFaceButton.addTarget(self, action: #selector(tapdetectFaceButton), for: .touchUpInside)
        toolsView.addSubview(detectFaceButton)
        
        slider = UISlider(frame: CGRect(x: 20, y: 100, width: view.bounds.width - 40, height: 30))
        view.addSubview(slider)
        slider.addTarget(self, action: #selector(sliderValueChange), for: .valueChanged)
        
    }
        
    @objc
    func switcherChange() {
        do {
            let _ = try cameraControl.switchCameras()
        } catch {
            
        }
        
    }
    
    @objc
    func tapdetectFaceButton() {
        cameraControl.faceDetectionDelegate = previewView
        let _ = cameraControl.setupSessionOutput()
    }
    
    @objc
    func sliderValueChange() {
        cameraControl.rampZoomToValue(CGFloat(slider.value))
    }

    @objc
    func tapStartButton() {
        cameraControl.delegate = self
        cameraControl.textureDelegate = self
        do {
            let _ = try cameraControl.setupSession()
//            previewView.session = cameraControl.captureSession
            cameraControl.startSession()

        } catch {

        }


    }
    
    @objc
    func tapCaptureButton() {
        cameraControl.captureStillImage()
    }
    
    @objc
    func tapRecordButton() {
        recordButton.isSelected = !recordButton.isSelected
        if recordButton.isSelected {
            let _ = cameraControl.enableHighFrameRateCapture()
            cameraControl.startRecording()
            
            
        } else {
            cameraControl.stopRecording()
        }
    }

    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        glClearColor(0.2, 0.2, 0.2, 1)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
        glBindVertexArray(vertexArray)
        shaderProgram.useProgress()
        
        if uniforms != nil {
            
            let v = withUnsafePointer(to: &(mvpMatrix.m00), {$0})
            
            glUniform4fv(uniforms, 1, v)
            glUniform1i(uniforms, 0)
            glDrawArrays(GLenum(GL_TRIANGLES), 0, 36)
            
        }

    }

}

extension ViewController: GLKViewControllerDelegate {
    func glkViewControllerUpdate(_ controller: GLKViewController) {
        let bounds = view.bounds
        let aspect = fabs(bounds.width / bounds.height)
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
        
        glTexParameterf(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GLfloat(GL_CLAMP_TO_EDGE))
        glTexParameterf(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GLfloat(GL_CLAMP_TO_EDGE))

    }
    

}
