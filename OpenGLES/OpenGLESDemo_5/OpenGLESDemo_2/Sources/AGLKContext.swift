//
//  AGLKContext.swift
//  OpenGLESDemo_2
//
//  Created by 壹九科技1 on 2020/4/18.
//  Copyright © 2020 zxf. All rights reserved.
//

import GLKit

class AGLKContext: EAGLContext {
    
    var _clearColor: GLKVector4?
    
    var clearColor: GLKVector4? {
        set {
            _clearColor = newValue
            if let clearC = newValue {
                glClearColor(clearC.r, clearC.g, clearC.b, clearC.a)
            }
        }
        get {
            _clearColor
        }
    }
    func clear(mask: GLbitfield) {
        assert(AGLKContext.current() == self, "Receving context required to be current context")
        glClear(mask)
    }
}
