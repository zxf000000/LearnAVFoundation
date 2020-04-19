//
//  ErrorHelp.swift
//  OpenGLESDemo_2
//
//  Created by mr.zhou on 2020/4/19.
//  Copyright © 2020 zxf. All rights reserved.
//

import GLKit

func glCheckError()
{
    
    let errorCode = Int32(glGetError())
    
    switch errorCode {
    case GL_NO_ERROR:
        break
    case   GL_INVALID_ENUM:
        print("INVALID_ENUM")
    case GL_INVALID_VALUE:
        print("INVALID_VALUE")

    case GL_INVALID_OPERATION:
        print("INVALID_OPERATION")

    case GL_STACK_OVERFLOW:
        print("STACK_OVERFLOW")

    case GL_STACK_UNDERFLOW:
        print("GL_STACK_UNDERFLOW")

    case GL_OUT_OF_MEMORY:
        print("GL_OUT_OF_MEMORY")
    default:
        break
    }
    

}
