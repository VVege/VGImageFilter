varying highp vec2 texCoordVarying;
precision mediump float;
uniform sampler2D Sampler;
uniform int type;

float greenBgAlpha(vec4 textureColor) {
    
    vec3 colorToReplace = vec3(0.0,1.0,0.0);
    
    float thresholdSensitivity = 0.3, smoothing = 0.1;
    
    float maskY = 0.2989 * colorToReplace.r + 0.5866 * colorToReplace.g + 0.1145 * colorToReplace.b;
    float maskCr = 0.7132 * (colorToReplace.r - maskY);
    float maskCb = 0.5647 * (colorToReplace.b - maskY);
    
    float Y = 0.2989 * textureColor.r + 0.5866 * textureColor.g + 0.1145 * textureColor.b;
    float Cr = 0.7132 * (textureColor.r - Y);
    float Cb = 0.5647 * (textureColor.b - Y);
    
    float blendValue = smoothstep(thresholdSensitivity, thresholdSensitivity + smoothing, distance(vec2(Cr, Cb), vec2(maskCr, maskCb)));
    return blendValue;
}

float blackBgAlpha(vec4 textureColor) {
    
    float alpha = max(max(textureColor.r, textureColor.g), textureColor.b);
    return alpha;
}

void main()
{
    mediump vec3 yuv;
    
    float alpha = 1.0;
    vec4 textureColor = texture2D(Sampler, texCoordVarying);
    if (type == 0) {
        alpha = blackBgAlpha(textureColor);
    }else{
        alpha = greenBgAlpha(textureColor);
    }
    gl_FragColor = vec4(textureColor.rgb, alpha);
}
