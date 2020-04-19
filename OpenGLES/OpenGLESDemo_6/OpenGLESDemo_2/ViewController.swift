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
    var GLKVector3: GLKVector3!
}

struct SenceTriangle {
    var vertices: [SenceVertex]
}

extension Array {
    func size() -> Int {
        return MemoryLayout<Element>.stride
    }
}

let vertexA: SenceVertex =
    SenceVertex(positionCoords: GLKVector3Make(-0.5, 0.5, -0.5), GLKVector3: GLKVector3Make(0, 0, 1))
let vertexB: SenceVertex =
    SenceVertex(positionCoords: GLKVector3Make(-0.5,  0.0, -0.5), GLKVector3: GLKVector3Make(0.0, 0.0, 1.0))
let vertexC: SenceVertex =
    SenceVertex(positionCoords: GLKVector3Make(-0.5, -0.5, -0.5), GLKVector3: GLKVector3Make(0, 0, 1))
let vertexD: SenceVertex =
    SenceVertex(positionCoords: GLKVector3Make(0.0,  0.5, -0.5), GLKVector3: GLKVector3Make(0, 0, 1))
let vertexE: SenceVertex =
    SenceVertex(positionCoords: GLKVector3Make(0.0,  0.0, -0.5), GLKVector3: GLKVector3Make(0, 0, 1))
let vertexF: SenceVertex =
    SenceVertex(positionCoords: GLKVector3Make(0.0, -0.5, -0.5), GLKVector3: GLKVector3Make(0, 0, 1))
let vertexG: SenceVertex =
    SenceVertex(positionCoords: GLKVector3Make( 0.5,  0.5, -0.5), GLKVector3: GLKVector3Make(0, 0, 1))
let vertexH: SenceVertex =
    SenceVertex(positionCoords: GLKVector3Make(0.5,  0.0, -0.5), GLKVector3: GLKVector3Make(0, 0, 1))
let vertexI: SenceVertex =
    SenceVertex(positionCoords: GLKVector3Make( 0.5, -0.5, -0.5), GLKVector3: GLKVector3Make(0, 0, 1))

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
    var centerVertexHeight: GLfloat! = 0
    var shouldUseFaceNormals: Bool! = true
    var shouldDrawNormals: Bool! = true
    
    var senceTriangles: [SenceTriangle] = [SenceTriangle]()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        context = AGLKContext(api: .openGLES3)
        let glkView = view as! GLKView
        glkView.context = context
        AGLKContext.setCurrent(context)
        
        self.delegate = self
      
    }
    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        context.clear(mask: GLbitfield(GL_COLOR_BUFFER_BIT))
        
        /// 重点: 这个 offset 一定要用 MemoryLayout 的 offset 函数来取, 直接用 stride 来取的话,是错误的值
        guard let offset = MemoryLayout<SenceVertex>.offset(of: \SenceVertex.textureCoords) else { return }

    }
    
    deinit {
        let glkView = view as! GLKView
        AGLKContext.setCurrent(glkView.context)
        buffer = nil
        context = nil
        AGLKContext.setCurrent(nil)
    }

}

extension ViewController: GLKViewControllerDelegate {
    func glkViewControllerUpdate(_ controller: GLKViewController) {

        
    }
    
    
}

func SenceTriangleMake(vertexA: SenceVertex, vertexB: SenceVertex, vertexC: SenceVertex) -> SenceTriangle {
    return SenceTriangle(vertices: [vertexA, vertexB, vertexC])
}

func SenceTriangleFaceNormal(triangle: SenceTriangle) -> GLKVector3 {
    let vectorA = GLKVector3Subtract(triangle.vertices[1].positionCoords, triangle.vertices[0].positionCoords)
    let vectorB = GLKVector3Subtract(triangle.vertices[2].positionCoords, triangle.vertices[0].positionCoords)
    
    
}

func SenceVetor3UnitNormal(vectorA: GLKVector3, vectorB: GLKVector3) {
    return GLKVector3Normalize(GLKVector3CrossProduct(vectorA, vertexB))
}
