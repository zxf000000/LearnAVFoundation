
uniform sampler2D texture;
varying highp vec2 textureCoordinate;

void main() {
    gl_FragColor = texture2D(texture, textureCoordinate);
}
