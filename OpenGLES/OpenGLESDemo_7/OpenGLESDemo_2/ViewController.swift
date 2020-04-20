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

// 三角形结构体如果使用数组的话,偏移量不好计算,且数组的stride 并不是元素的stride 之和,所以需要使用三个属性
struct SenceTriangle {
    
    var vertexA: SenceVertex
    var vertexB: SenceVertex
    var vertexC: SenceVertex
    
}

extension Array {
    func size() -> Int {
        return MemoryLayout<Element>.stride
    }
}

var vertexA: SenceVertex =
    SenceVertex(positionCoords: GLKVector3Make(-0.5, 0.5, -0.5),
                textureCoords: GLKVector2Make(0, 1))
var vertexB: SenceVertex =
    SenceVertex(positionCoords: GLKVector3Make(-0.5,  0.0, -0.5),
                textureCoords: GLKVector2Make(0, 0.5))
var vertexC: SenceVertex =
    SenceVertex(positionCoords: GLKVector3Make(-0.5, -0.5, -0.5),
                textureCoords: GLKVector2Make(0, 0))
var vertexD: SenceVertex =
    SenceVertex(positionCoords: GLKVector3Make(0.0,  0.5, -0.5),
                textureCoords: GLKVector2Make(0.5, 1))
var vertexE: SenceVertex =
    SenceVertex(positionCoords: GLKVector3Make(0.0,  0.0, -0.5),
                textureCoords: GLKVector2Make(0.5, 0.5))
var vertexF: SenceVertex =
    SenceVertex(positionCoords: GLKVector3Make(0.0, -0.5, -0.5),
                textureCoords: GLKVector2Make(0.5, 0))
var vertexG: SenceVertex =
    SenceVertex(positionCoords: GLKVector3Make( 0.5,  0.5, -0.5),
                textureCoords: GLKVector2Make(1, 1))
var vertexH: SenceVertex =
    SenceVertex(positionCoords: GLKVector3Make(0.5,  0.0, -0.5),
                textureCoords: GLKVector2Make(1, 0.5))
var vertexI: SenceVertex =
    SenceVertex(positionCoords: GLKVector3Make( 0.5, -0.5, -0.5),
                textureCoords: GLKVector2Make(1, 0))

let NUM_FACES: Int = 8
let NUM_NORMAL_LINE_VERTS: Int = 48
let NUM_LINE_VERTS = NUM_NORMAL_LINE_VERTS + 2

// category of context
class ViewController: GLKViewController {

    var context: AGLKContext!
    
    var buffer: AGLKVertexAttribArrayBuffer?
    let baseEffect: GLKBaseEffect = GLKBaseEffect()
    var extraEffect: GLKBaseEffect?
    var extraBuffer: AGLKVertexAttribArrayBuffer?

    var blandTextureInfo: GLKTextureInfo?
    var interestTextureInfo: GLKTextureInfo?
    
    var triangles: [SenceTriangle]?
    
    var shouldUseDetailLighting: Bool! = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        context = AGLKContext(api: .openGLES3)
        let glkView = view as! GLKView
        glkView.context = context
        AGLKContext.setCurrent(context)

        baseEffect.useConstantColor = GLboolean(GL_TRUE)
        baseEffect.constantColor = GLKVector4Make(1, 1, 1, 1)
        

        var modelViewMatrix = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(-60), 1, 0, 0)
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(-45), 0, 0, 1)
        modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0, 0, 0.25)

        baseEffect.transform.modelviewMatrix = modelViewMatrix
        
        let blandSimulatedLightingImage = UIImage(named: "Lighting256x256.png")?.cgImage
        blandTextureInfo = try! GLKTextureLoader.texture(with: blandSimulatedLightingImage!, options: [GLKTextureLoaderOriginBottomLeft: true])
        
        let intereseingSimulatedLightingImage = UIImage(named: "LightingDetail256x256.png")?.cgImage
        interestTextureInfo = try! GLKTextureLoader.texture(with: intereseingSimulatedLightingImage!, options: [GLKTextureLoaderOriginBottomLeft: true])


        context.clearColor = GLKVector4Make(0, 0, 0, 1)
        
        triangles = [SenceTriangle]()
        triangles?.append(SenceTriangleMake(vertexA, vertexB, vertexD))
        triangles?.append(SenceTriangleMake(vertexB, vertexC, vertexF))
        triangles?.append(SenceTriangleMake(vertexD, vertexB, vertexE))
        triangles?.append(SenceTriangleMake(vertexE, vertexB, vertexF))
        triangles?.append(SenceTriangleMake(vertexD, vertexE, vertexH))
        triangles?.append(SenceTriangleMake(vertexE, vertexF, vertexH))
        triangles?.append(SenceTriangleMake(vertexG, vertexD, vertexH))
        triangles?.append(SenceTriangleMake(vertexH, vertexF, vertexI))



        buffer = AGLKVertexAttribArrayBuffer(stride: MemoryLayout<SenceVertex>.stride,
                                             numberOfVertices: Int32(triangles!.count) * 3,
                                             dataPtr: triangles!,
                                             usage: GLenum(GL_DYNAMIC_DRAW))
        
    }
    
  
    @IBAction func switchChange(_ sender: Any) {
        shouldUseDetailLighting = !shouldUseDetailLighting
    }
    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        context.clear(mask: GLbitfield(GL_COLOR_BUFFER_BIT))
        
        /// 重点: 这个 offset 一定要用 MemoryLayout 的 offset 函数来取, 直接用 stride 来取的话,是错误的值
        guard let offset = MemoryLayout<SenceVertex>.offset(of: \SenceVertex.textureCoords) else { return }
        guard let positionOffset = MemoryLayout<SenceVertex>.offset(of: \SenceVertex.positionCoords) else {
            return
        }
        
        if shouldUseDetailLighting {
            
            baseEffect.texture2d0.name = interestTextureInfo!.name
            baseEffect.texture2d0.target = GLKTextureTarget(rawValue: interestTextureInfo!.target) ?? GLKTextureTarget.target2D
            
        } else {
            
            baseEffect.texture2d0.name = blandTextureInfo!.name
            baseEffect.texture2d0.target = GLKTextureTarget(rawValue: blandTextureInfo!.target) ?? GLKTextureTarget.target2D
            
        }

        
        baseEffect.prepareToDraw()
        
        buffer?.prepareToDraw(withArrib: GLuint(GLKVertexAttrib.position.rawValue), numberofCoordinates: 3, attribOffset: positionOffset, shouldEnable: true)
        buffer?.prepareToDraw(withArrib: GLuint(GLKVertexAttrib.texCoord0.rawValue), numberofCoordinates: 2, attribOffset: offset, shouldEnable: true)
        
        buffer?.drawArray(with: GLenum(GL_TRIANGLES), startVertexIndex: 0, numberOfVertices: GLsizei(triangles!.count * 3))

    }
    
    deinit {
        let glkView = view as! GLKView
        AGLKContext.setCurrent(glkView.context)
        buffer = nil
        context = nil
        AGLKContext.setCurrent(nil)
    }

}

func SenceTriangleMake(_ vertexA: SenceVertex,_ vertexB: SenceVertex,_ vertexC: SenceVertex) -> SenceTriangle {
    return SenceTriangle(vertexA: vertexA, vertexB: vertexB, vertexC: vertexC)
}

