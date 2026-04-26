//Q1d implement the whole thing to map the depth texture to a quad
// TODO:

uniform mat4 lightProjMatrix;
uniform mat4 lightViewMatrix;

out vec2 texCoord;                                                                          //q1d

void main() {

    texCoord = uv;                                                                          //q1d
    gl_Position = vec4(position, 1.0);                                                      //q1d  
    //gl_Position = projectionMatrix * viewMatrix * modelMatrix * vec4( position, 1.0 );    //q1d

}