//
//  ContextManager.swift
//  WriteReadMedia
//
//  Copyright © 2020 zxf. All rights reserved.
//

import GLKit
import CoreImage

class ContextManager {
    static let shared = ContextManager()
    
    var eaglContext: EAGLContext!
    var ciContext: CIContext!
    
    init() {
        eaglContext = EAGLContext(api: .openGLES3)
        let options = [CIContextOption.workingColorSpace: nil] as [CIContextOption : Any?]
        ciContext = CIContext(eaglContext: eaglContext, options: options as [CIContextOption : Any])
    }
}

