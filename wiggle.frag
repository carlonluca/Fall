varying highp vec2 qt_TexCoord0;
uniform lowp float qt_Opacity;
uniform lowp sampler2D source;
void main() {
    gl_FragColor = texture2D(source, qt_TexCoord0) * qt_Opacity;
}
