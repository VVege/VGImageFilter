/*
	Copyright (C) 2015 Apple Inc. All Rights Reserved.
	See LICENSE.txt for this sample’s licensing information
	
	Abstract:
	Fragment shader that adjusts the luminance value based on the input sliders and renders the input texture.
 */

varying highp vec2 texCoordVarying;
precision mediump float;

uniform sampler2D SamplerY;
uniform sampler2D SamplerUV;
uniform mat3 colorConversionMatrix;

/*
vec3 textureColorFromYUV(vec3 yuv){
    //正常的转化方式，来自苹果
    lowp vec3 textureColor;
    yuv.x = texture2D(SamplerY, texCoordVarying).r - (16.0/255.0);
    yuv.yz = texture2D(SamplerUV, texCoordVarying).rg - vec2(0.5,0.5);
    textureColor = colorConversionMatrix * yuv;
    return textureColor;
}
 */

vec3 textureColorFromYUV(vec3 yuv){
    //GPUImageMovie的转化方式
    // 黑色转化不错，绿色去除不够彻底，绿色可使用 上方
    lowp vec3 textureColor;
    yuv.x = texture2D(SamplerY, texCoordVarying).r;
    yuv.yz = texture2D(SamplerUV, texCoordVarying).ra - vec2(0.5,0.5);
    textureColor = colorConversionMatrix * yuv;
    return textureColor;
}

void main()
{
	mediump vec3 yuv;

    vec3 textureColor = textureColorFromYUV(yuv);
    gl_FragColor = vec4(textureColor.rgb, 1.0);
}
