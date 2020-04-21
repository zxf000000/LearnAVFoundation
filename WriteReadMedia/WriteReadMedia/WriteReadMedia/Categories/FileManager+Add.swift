//
//  FileManager+Add.swift
//  WriteReadMedia
//
//  Created by 壹九科技1 on 2020/4/21.
//  Copyright © 2020 zxf. All rights reserved.
//

import Foundation


extension FileManager {
    func temporaryDirectoryWithTemplateString(_ string: String) -> URL {
        let mkdTemplate = temporaryDirectory.appendingPathComponent(string)
        return mkdTemplate
    }
}
