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
    var normal: GLKVector3!
}

// 三角形结构体如果使用数组的话,偏移量不好计算,且数组的stride 并不是元素的stride 之和,所以需要使用三个属性
struct SenceTriangle {
    
    var vertexA: SenceVertex
    var vertexB: SenceVertex
    var vertexC: SenceVertex
    
    static func empty() -> SenceTriangle {
        return SenceTriangle(vertexA: SenceVertex(positionCoords: GLKVector3Make(0, 0, 0),
                                                  normal: GLKVector3Make(0, 0, 0)),
                             vertexB: SenceVertex(positionCoords: GLKVector3Make(0, 0, 0),
                             normal: GLKVector3Make(0, 0, 0)),
                             vertexC: SenceVertex(positionCoords: GLKVector3Make(0, 0, 0),
                             normal: GLKVector3Make(0, 0, 0)))
    }
}

extension Array {
    func size() -> Int {
        return MemoryLayout<Element>.stride
    }
}

var vertexA: SenceVertex =
    SenceVertex(positionCoords: GLKVector3Make(-0.5, 0.5, -0.5),
                normal: GLKVector3Make(0, 0, 1))
var vertexB: SenceVertex =
    SenceVertex(positionCoords: GLKVector3Make(-0.5,  0.0, -0.5),
                normal: GLKVector3Make(0.0, 0.0, 1.0))
var vertexC: SenceVertex =
    SenceVertex(positionCoords: GLKVector3Make(-0.5, -0.5, -0.5),
                normal: GLKVector3Make(0, 0, 1))
var vertexD: SenceVertex =
    SenceVertex(positionCoords: GLKVector3Make(0.0,  0.5, -0.5),
                normal: GLKVector3Make(0, 0, 1))
var vertexE: SenceVertex =
    SenceVertex(positionCoords: GLKVector3Make(0.0,  0.0, -0.5),
                normal: GLKVector3Make(0, 0, 1))
var vertexF: SenceVertex =
    SenceVertex(positionCoords: GLKVector3Make(0.0, -0.5, -0.5),
                normal: GLKVector3Make(0, 0, 1))
var vertexG: SenceVertex =
    SenceVertex(positionCoords: GLKVector3Make( 0.5,  0.5, -0.5),
                normal: GLKVector3Make(0, 0, 1))
var vertexH: SenceVertex =
    SenceVertex(positionCoords: GLKVector3Make(0.5,  0.0, -0.5),
                normal: GLKVector3Make(0, 0, 1))
var vertexI: SenceVertex =
    SenceVertex(positionCoords: GLKVector3Make( 0.5, -0.5, -0.5),
                normal: GLKVector3Make(0, 0, 1))

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
    var centerVertexHeight: GLfloat! = 0 {
        didSet {
            var newVertexE = vertexE
            newVertexE.positionCoords.z = centerVertexHeight
            senceTriangles[2] = SenceTriangleMake(vertexD, vertexB, newVertexE);
            senceTriangles[3] = SenceTriangleMake(newVertexE, vertexB, vertexF);
            senceTriangles[4] = SenceTriangleMake(vertexD, newVertexE, vertexH);
            senceTriangles[5] = SenceTriangleMake(newVertexE, vertexF, vertexH);
            
            self.udpateFaceNormals()
        }
    }
    
    var shouldUseFaceNormals: Bool = true {
        didSet {
            udpateFaceNormals()
        }
    }
    var shouldDrawNormals: Bool = true
    
    var senceTriangles: [SenceTriangle] = [SenceTriangle](repeating: SenceTriangle.empty(), count: NUM_FACES)
    
    func udpateFaceNormals() {
        if shouldUseFaceNormals {
            SenceTriangleUpdateFaceNormals(someTriangles: &senceTriangles)
        } else {
            SenceTriangleUpdateVertexNormals(someTriangles: &senceTriangles)
        }
        
        buffer?.reinit(stride: MemoryLayout<SenceVertex>.stride, numberOfVertices: GLsizei(senceTriangles.count * 3), bytes: senceTriangles)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        context = AGLKContext(api: .openGLES3)
        let glkView = view as! GLKView
        glkView.context = context
        AGLKContext.setCurrent(context)


        baseEffect.light0.enabled = GLboolean(GL_TRUE)
//        baseEffect.light0.ambientColor = GLKVector4Make(1, 1, 1, 1)
        baseEffect.light0.diffuseColor = GLKVector4Make(0.7, 0.7, 0.7, 1)
        
        baseEffect.light0.position = GLKVector4Make(1, 1, 0.5, 0)
        glCheckError()

        extraEffect = GLKBaseEffect()
        extraEffect?.useConstantColor = GLboolean(GL_TRUE)
        extraEffect?.constantColor = GLKVector4Make(0, 1, 0, 1)
        
        var modelViewMatrix = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(-60), 1, 0, 0)
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(-30), 0, 0, 1)
        modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0, 0, 0.25)

        baseEffect.transform.modelviewMatrix = modelViewMatrix
        extraEffect?.transform.modelviewMatrix = modelViewMatrix
        
        context.clearColor = GLKVector4Make(0, 0, 0, 1)
        
        senceTriangles[0] = SenceTriangleMake(vertexA, vertexB, vertexD);
        senceTriangles[1] = SenceTriangleMake(vertexB, vertexC, vertexF);
        senceTriangles[2] = SenceTriangleMake(vertexD, vertexB, vertexE);
        senceTriangles[3] = SenceTriangleMake(vertexE, vertexB, vertexF);
        senceTriangles[4] = SenceTriangleMake(vertexD, vertexE, vertexH);
        senceTriangles[5] = SenceTriangleMake(vertexE, vertexF, vertexH);
        senceTriangles[6] = SenceTriangleMake(vertexG, vertexD, vertexH);
        senceTriangles[7] = SenceTriangleMake(vertexH, vertexF, vertexI);
        
        
        
        buffer = AGLKVertexAttribArrayBuffer(stride: MemoryLayout<SenceVertex>.stride,
                                             numberOfVertices: Int32(senceTriangles.count) * 3,
                                             dataPtr: senceTriangles,
                                             usage: GLenum(GL_DYNAMIC_DRAW))
        
        extraBuffer = AGLKVertexAttribArrayBuffer(stride: MemoryLayout<SenceVertex>.stride,
                                                  numberOfVertices: 0,
                                                  dataPtr: [SenceTriangle](),
                                                  usage: GLenum(GL_DYNAMIC_DRAW))
    }
    
    func drawNormals() {
        var normalLineVertices = [GLKVector3](repeating: GLKVector3Make(0,0,0), count: NUM_LINE_VERTS)
        let position = withUnsafeMutablePointer(to: &(baseEffect.light0.position.v.0), {$0})
        glCheckError()
        // 基于8个三角形计算50个顶点
        SceneTrianglesNormalLinesUpdate(someTriangles: senceTriangles,
                                        lightPosition: GLKVector3MakeWithArray(position),
                                        someNormalLineVectices: &normalLineVertices)
        extraBuffer?.reinit(stride: MemoryLayout<GLKVector3>.stride,
                            numberOfVertices: GLsizei(NUM_LINE_VERTS),
                            bytes: normalLineVertices)
        

        extraBuffer?.prepareToDraw(withArrib: GLuint(GLKVertexAttrib.position.rawValue),
                                   numberofCoordinates: 3,
                                   attribOffset: 0,
                                   shouldEnable: true)
        
        extraEffect?.useConstantColor = GLboolean(GL_TRUE)
        extraEffect?.constantColor = GLKVector4Make(0, 1, 0, 1)
        extraEffect?.prepareToDraw()
        
        extraBuffer?.drawArray(with: GLenum(GL_LINES),
                               startVertexIndex: 0,
                               numberOfVertices: GLsizei(NUM_NORMAL_LINE_VERTS))
        extraEffect?.constantColor = GLKVector4Make(1, 1, 0, 1)

        extraEffect?.prepareToDraw()
        extraBuffer?.drawArray(with: GLenum(GL_LINES),
                               startVertexIndex: GLint(NUM_NORMAL_LINE_VERTS),
                               numberOfVertices: GLint(NUM_LINE_VERTS - NUM_NORMAL_LINE_VERTS))
    }

    @IBAction func takeCenterVectexHeight(_ sender: UISlider) {
        centerVertexHeight = GLfloat(CGFloat(sender.value))
    }
    @IBAction func switchDrawnFaceNormals(_ sender: UISwitch) {
        shouldDrawNormals = sender.isOn
    }
    @IBAction func switchUseFaceNormals(_ sender: UISwitch) {
        shouldUseFaceNormals = sender.isOn
    }
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        context.clear(mask: GLbitfield(GL_COLOR_BUFFER_BIT))
        
        /// 重点: 这个 offset 一定要用 MemoryLayout 的 offset 函数来取, 直接用 stride 来取的话,是错误的值
        guard let offset = MemoryLayout<SenceVertex>.offset(of: \SenceVertex.normal) else { return }
        guard let positionOffset = MemoryLayout<SenceVertex>.offset(of: \SenceVertex.positionCoords) else {
            return
        }
        glCheckError()
        buffer?.prepareToDraw(withArrib: GLuint(GLKVertexAttrib.position.rawValue), numberofCoordinates: 3, attribOffset: positionOffset, shouldEnable: true)
        glCheckError()
        buffer?.prepareToDraw(withArrib: GLuint(GLKVertexAttrib.normal.rawValue), numberofCoordinates: 3, attribOffset: offset, shouldEnable: true)
        glCheckError()
        baseEffect.prepareToDraw()
        glCheckError()
        buffer?.drawArray(with: GLenum(GL_TRIANGLES), startVertexIndex: 0, numberOfVertices: GLsizei(senceTriangles.count * 3))
        
        if shouldDrawNormals {
            drawNormals()
        }
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

func SenceTriangleMake(_ vertexA: SenceVertex,_ vertexB: SenceVertex,_ vertexC: SenceVertex) -> SenceTriangle {
    return SenceTriangle(vertexA: vertexA, vertexB: vertexB, vertexC: vertexC)
}

func SenceTriangleFaceNormal(triangle: SenceTriangle) -> GLKVector3 {
    
    // 两个点组成的向量
    let vectorA = GLKVector3Subtract(triangle.vertexB.positionCoords,
                                     triangle.vertexA.positionCoords)
    
    let vectorB = GLKVector3Subtract(triangle.vertexC.positionCoords,
                                     triangle.vertexA.positionCoords)
    // 获取单位法向量
    return SenceVetor3UnitNormal(vectorA: vectorA, vectorB: vectorB)
}

func SenceVetor3UnitNormal(vectorA: GLKVector3, vectorB: GLKVector3) -> GLKVector3 {
    // 计算叉积然后单位向量化,即单位法向量
    return GLKVector3Normalize(GLKVector3CrossProduct(vectorA, vectorB))
}

/// 计算8个三角形的单位法向量,然后更新每一个点结构体的法向量数据
func SenceTriangleUpdateFaceNormals(someTriangles: inout [SenceTriangle]) {
    let count = someTriangles.count
    for i in 0..<count {
        let faceNormal = SenceTriangleFaceNormal(triangle: someTriangles[i])
        someTriangles[i].vertexA.normal = faceNormal
        someTriangles[i].vertexB.normal = faceNormal
        someTriangles[i].vertexC.normal = faceNormal
    }
}
/// 计算8个三角形的单位法向量,然后根据每个三角形的单位法向量更新每个顶点
func SenceTriangleUpdateVertexNormals(someTriangles: inout [SenceTriangle]) {
    var newVertexA = vertexA
    var newVertexB = vertexB
    var newVertexC = vertexC
    var newVertexD = vertexD
    var newVertexE = someTriangles[3].vertexA
    var newVertexF = vertexF
    var newVertexG = vertexG
    var newVertexH = vertexH
    var newVertexI = vertexI
    
    let count = someTriangles.count
    var faceNormals = Array<GLKVector3>.init(repeating: GLKVector3Make(0, 0, 0), count: count)
    // 计算出每个三角形的单位法向量并保存起来
    for i in 0..<count {
        faceNormals[i] = SenceTriangleFaceNormal(triangle: someTriangles[i])
    }
    newVertexA.normal = faceNormals[0]
    newVertexB.normal = GLKVector3MultiplyScalar(
        GLKVector3Add(
            GLKVector3Add(
                GLKVector3Add(faceNormals[0],
                              faceNormals[1]),
                faceNormals[2]),
            faceNormals[3]),
        0.25)
    newVertexC.normal = faceNormals[1]
    newVertexD.normal = GLKVector3MultiplyScalar(
        GLKVector3Add(
            GLKVector3Add(
                GLKVector3Add(faceNormals[0],
                              faceNormals[2]),
                faceNormals[4]),
            faceNormals[6]),
        0.25)
    newVertexE.normal = GLKVector3MultiplyScalar(
        GLKVector3Add(
            GLKVector3Add(
                GLKVector3Add(faceNormals[2],
                              faceNormals[3]),
                faceNormals[4]),
            faceNormals[5]),
        0.25)
    newVertexF.normal = GLKVector3MultiplyScalar(
        GLKVector3Add(
            GLKVector3Add(
                GLKVector3Add(faceNormals[1],
                              faceNormals[3]),
                faceNormals[5]),
            faceNormals[7]),
        0.25)
    newVertexG.normal = faceNormals[6];
    newVertexH.normal = GLKVector3MultiplyScalar(
        GLKVector3Add(
            GLKVector3Add(
                GLKVector3Add(
                    faceNormals[4],
                    faceNormals[5]),
                faceNormals[6]),
            faceNormals[7]), 0.25);
    newVertexI.normal = faceNormals[7];
    
    // 重新创建关联了法向量的三角形
    someTriangles[0] = SenceTriangleMake(
       newVertexA,
       newVertexB,
       newVertexD);
    someTriangles[1] = SenceTriangleMake(
       newVertexB,
       newVertexC,
       newVertexF);
    someTriangles[2] = SenceTriangleMake(
       newVertexD,
       newVertexB,
       newVertexE);
    someTriangles[3] = SenceTriangleMake(
       newVertexE,
       newVertexB,
       newVertexF);
    someTriangles[4] = SenceTriangleMake(
       newVertexD,
       newVertexE,
       newVertexH);
    someTriangles[5] = SenceTriangleMake(
       newVertexE,
       newVertexF,
       newVertexH);
    someTriangles[6] = SenceTriangleMake(
       newVertexG,
       newVertexD,
       newVertexH);
    someTriangles[7] = SenceTriangleMake(
       newVertexH,
       newVertexF,
       newVertexI);
}
/// 初始化
func SceneTrianglesNormalLinesUpdate(someTriangles: [SenceTriangle],
                                     lightPosition: GLKVector3,
                                     someNormalLineVectices: inout [GLKVector3]) {
    
    var lineVertexIndex: Int = 0
    for trianglesIndex in 0..<someTriangles.count {
        
        someNormalLineVectices[lineVertexIndex] = someTriangles[trianglesIndex].vertexA.positionCoords
        lineVertexIndex += 1
        
        someNormalLineVectices[lineVertexIndex] = GLKVector3Add(
            someTriangles[trianglesIndex].vertexA.positionCoords,
            GLKVector3MultiplyScalar(someTriangles[trianglesIndex].vertexA.normal, 0.5))
        lineVertexIndex += 1
        
        someNormalLineVectices[lineVertexIndex] =
           someTriangles[trianglesIndex].vertexB.positionCoords;
        lineVertexIndex += 1
        
        someNormalLineVectices[trianglesIndex] =
           GLKVector3Add(
              someTriangles[trianglesIndex].vertexB.positionCoords,
              GLKVector3MultiplyScalar(
                 someTriangles[trianglesIndex].vertexB.normal,
                 0.5));
        lineVertexIndex += 1
        
        someNormalLineVectices[lineVertexIndex] =
           someTriangles[trianglesIndex].vertexC.positionCoords;
        lineVertexIndex += 1
        
        someNormalLineVectices[lineVertexIndex] =
           GLKVector3Add(
              someTriangles[trianglesIndex].vertexC.positionCoords,
              GLKVector3MultiplyScalar(
                 someTriangles[trianglesIndex].vertexC.normal,
                 0.5));
        lineVertexIndex += 1
    }
    
    // 添加一条线表示灯光方向
    someNormalLineVectices[lineVertexIndex] = lightPosition
    lineVertexIndex += 1
    someNormalLineVectices[lineVertexIndex] = GLKVector3Make(0, 0, -0.5)
}
