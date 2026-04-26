//Q1d implement the whole thing to map the depth texture to a quad
// TODO:

uniform sampler2D tDiffuse;
uniform sampler2D tDepth;

in vec2 texCoord;                                   //q1d

void main() {

    float d = texture(tDepth, texCoord).r;          //q1d
    gl_FragColor = vec4(vec3(d), 1.0);              //q1d
    //gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);      //q1d
}