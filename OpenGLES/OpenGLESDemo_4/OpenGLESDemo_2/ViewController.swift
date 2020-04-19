//
//  ViewController.swift
//  OpenGLESDemo_2
//
//  Created by 壹九科技1 on 2020/4/18.
//  Copyright © 2020 zxf. All rights reserved.
//

import UIKit
import GLKit


extension GLKEffectPropertyTexture {
    func aglkSetParameters(parameterID: GLenum, value: GLint) {
        glBindTexture(target.rawValue, name)
        glTexParameteri(target.rawValue, parameterID, value)
    }
}

struct SenceVertex {
    var positionCoords: GLKVector3!
    var textureCoords: GLKVector2!
    
}

extension Array {
    func size() -> Int {
        return MemoryLayout<Element>.stride
    }
}


// category of context
class ViewController: GLKViewController {

    var context: AGLKContext!
    
    var buffer: AGLKVertexAttribArrayBuffer?
    let baseEffect: GLKBaseEffect = GLKBaseEffect()
    
    var shouldUnlinearFilter: Bool = true
    var shouldAnimate: Bool = true
    var shouldRepearTexture: Bool = true
    var sCoornidateOffset: CGFloat = 0.0
    
    var vertices = [
        SenceVertex(positionCoords: GLKVector3Make(-0.5, -0.5, 0),
                    textureCoords: GLKVector2Make(0.0, 0.0)),
        SenceVertex(positionCoords: GLKVector3Make(0.5, -0.5, 0),
                    textureCoords: GLKVector2Make(1, 0.0)),
        SenceVertex(positionCoords: GLKVector3Make(-0.5, 0.5, 0),
                    textureCoords: GLKVector2Make(0.0, 1.0)),
    ]
    
    let defaultVertice = [
        SenceVertex(positionCoords: GLKVector3Make(-0.5, -0.5, 0),
                    textureCoords: GLKVector2Make(0.0, 0.0)),
        SenceVertex(positionCoords: GLKVector3Make(0.5, -0.5, 0),
                    textureCoords: GLKVector2Make(1, 0.0)),
        SenceVertex(positionCoords: GLKVector3Make(-0.5, 0.5, 0),
                    textureCoords: GLKVector2Make(0.0, 1.0)),
    ]
    
    let movementVectors = [
        GLKVector3Make(-0.02, -0.01, 0.0),
        GLKVector3Make(0.01, -0.005, 0.0),
        GLKVector3Make(-0.01, 0.01, 0.0)
    ]
    
    func updateTextureParameters() {
        baseEffect
            .texture2d0
            .aglkSetParameters(parameterID: GLenum(GL_TEXTURE_WRAP_S),
                               value: shouldRepearTexture ? GL_REPEAT : GL_CLAMP_TO_EDGE)
        baseEffect
            .texture2d0
            .aglkSetParameters(parameterID: GLenum(GL_TEXTURE_MAG_FILTER), value: shouldUnlinearFilter ? GL_LINEAR : GL_NEAREST)
    }
    
    func updateAnimatedVerticePositions() {
        if shouldAnimate {
            for i in 0..<3 {
                vertices[i].positionCoords.x += movementVectors[i].x
                if vertices[i].positionCoords.x  >= 1 || vertices[i].positionCoords.x  <= -1 {
                    vertices[i].positionCoords?.x = -movementVectors[i].x
                }
                vertices[i].positionCoords?.y += movementVectors[i].y
                if vertices[i].positionCoords.y >= Float(1) || vertices[i].positionCoords.y <= Float(-1) {
                    vertices[i].positionCoords?.y = -movementVectors[i].y
                }
                
                vertices[i].positionCoords.z += movementVectors[i].z
                if vertices[i].positionCoords.z  >= 1 || vertices[i].positionCoords.z <= -1 {
                    vertices[i].positionCoords.z = -movementVectors[i].z
                }
            }
        } else {
            for i in 0..<3 {
                vertices[i].positionCoords?.x = defaultVertice[i].positionCoords?.x ?? 0
                vertices[i].positionCoords?.y = defaultVertice[i].positionCoords?.y ?? 0
                vertices[i].positionCoords?.z = defaultVertice[i].positionCoords?.z ?? 0
            }
            
            for i in 0..<3 {
                vertices[i].textureCoords?.s = Float(defaultVertice[i].positionCoords?.s ?? 0) + Float(sCoornidateOffset)
            }
        }
    }
    
    func update() {
        updateTextureParameters()
        updateAnimatedVerticePositions()
        
        buffer?.reinit(stride: MemoryLayout<SenceVertex>.stride, numberOfVertices: GLsizei(vertices.count), bytes: vertices)
    }
    
    @IBAction func linearFilterChange(_ sender: UISwitch) {
        shouldUnlinearFilter = sender.isOn
    }
    
    @IBAction func offsetChange(_ sender: UISlider) {
        sCoornidateOffset = CGFloat(sender.value)
    }
    @IBAction func repeatChange(_ sender: UISwitch) {
        shouldRepearTexture = sender.isOn
    }
    @IBAction func animationChange(_ sender: UISwitch) {
        shouldAnimate = sender.isOn
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        preferredFramesPerSecond = 60
        shouldAnimate = true
        shouldRepearTexture = true
        
        context = AGLKContext(api: .openGLES3)
        let glkView = view as! GLKView
        glkView.context = context
        AGLKContext.setCurrent(context)
        
        self.delegate = self
        
        baseEffect.useConstantColor = GLboolean(GL_TRUE)
        baseEffect.constantColor = GLKVector4Make(1, 1, 1, 1)
        
        context.clearColor = GLKVector4Make(0, 1, 0, 1)
        
        self.buffer = AGLKVertexAttribArrayBuffer(stride: MemoryLayout<SenceVertex>.stride,
                                                  numberOfVertices: GLsizei(vertices.count),
                                                  dataPtr: vertices,
                                                  usage: GLenum(GL_DYNAMIC_DRAW))
        guard let imageRef =
            UIImage(contentsOfFile: Bundle.main.path(forResource: "grid", ofType: "png") ?? "")?.cgImage else { return }
        let textureInfo = try! GLKTextureLoader.texture(with: imageRef, options: nil)
        baseEffect.texture2d0.name = textureInfo.name
        baseEffect.texture2d0.target =
            GLKTextureTarget(rawValue: textureInfo.target) ?? GLKTextureTarget.target2D
    }
    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {

        baseEffect.prepareToDraw()
        context.clear(mask: GLbitfield(GL_COLOR_BUFFER_BIT))

        guard let offset = MemoryLayout<SenceVertex>.offset(of: \SenceVertex.textureCoords) else { return }
        // 分两次glVertexAttribPointer
        // 顶点数据
        buffer?.prepareToDraw(withArrib: GLuint(GLKVertexAttrib.position.rawValue),
                              numberofCoordinates: 3,
                              attribOffset: 0,
                              shouldEnable: true)
        // 纹理数据
        buffer?.prepareToDraw(withArrib: GLuint(GLKVertexAttrib.texCoord0.rawValue),
                              numberofCoordinates: 2,
                              attribOffset: offset,
                              shouldEnable: true)
        buffer?.drawArray(with: GLenum(GL_TRIANGLES), startVertexIndex: 0, numberOfVertices: 3)

    }

}

extension ViewController: GLKViewControllerDelegate {
    func glkViewControllerUpdate(_ controller: GLKViewController) {
        
        updateTextureParameters()
        updateAnimatedVerticePositions()
        
        buffer?.reinit(stride: MemoryLayout<SenceVertex>.stride, numberOfVertices: GLsizei(vertices.count), bytes: vertices)
        
    }
    
    
}

