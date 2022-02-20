#version 450

uniform sampler2D tex;
uniform float comp;
in vec2 texCoord;
in vec4 color;
out vec4 FragColor;

void main() {
    vec4 texC = texture(tex, texCoord);

    texC.r = texC.r + comp * texC.a;
    texC.g = texC.g + comp * texC.a;
    texC.b = texC.b + comp * texC.a;

    FragColor = texC;
}