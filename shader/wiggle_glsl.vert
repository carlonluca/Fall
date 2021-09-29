#version 440                                                                       // 1
 
layout(location = 0) in vec4 position;                                             // 2
layout(location = 1) in vec2 texcoord;
 
layout(location = 0) out vec2 coord;                                               // 3
 
layout(std140, binding = 0) uniform buf {                                          // 4
    mat4 qt_Matrix;                                                                // 5
    float qt_Opacity;
 
    float strength;
    float time;
} ubuf;
 
out gl_PerVertex { vec4 gl_Position; };                                            //6
 
float noise(vec2 uv){
    return fract(sin(dot(uv, vec2(12.9898,78.233))) * 43758.5453123);
}
 
void main() {
    coord = texcoord;
    vec4 pos = position;
    float angle = 2. * 3.141 * (noise(pos.xy) + ubuf.time / 100.0);                // 7
    float strengthWithVariation = ubuf.strength * noise(pos.yx);
    pos.x += cos(angle) * strengthWithVariation;
    pos.y += sin(angle) * strengthWithVariation;
    gl_Position = ubuf.qt_Matrix * pos;
} 