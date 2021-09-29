float noise(vec2 uv){
    return fract(sin(dot(uv, vec2(12.9898,78.233))) * 43758.5453123);
}

uniform highp mat4 qt_Matrix;
uniform lowp float strength;
uniform lowp float time;
attribute highp vec4 qt_Vertex;
attribute highp vec2 qt_MultiTexCoord0;
varying highp vec2 qt_TexCoord0;
void main() {
    qt_TexCoord0 = qt_MultiTexCoord0;
    highp vec4 pos = qt_Vertex;
    lowp float angle = 2. * 3.141 * (noise(pos.xy) + time / 100.0);
    lowp float strengthWithVariation = strength * noise(pos.yx);
    pos.x += cos(angle) * strengthWithVariation;
    pos.y += sin(angle) * strengthWithVariation;
    gl_Position = qt_Matrix * pos;
}
