//
//  Shader.swift
//  CaptureDemo
//
//  Created by 壹九科技1 on 2020/4/16.
//  Copyright © 2020 zxf. All rights reserved.
//

attribute vec4 position;
attribute vec4 videoTextureCoordinate;

uniform mat4 mvpMatrix;
varying vec2 textureCoordinate;

void main() {
    textureCoordinate = videoTextureCoordinate;
    gl_Position = mvpMatrix * position
}
