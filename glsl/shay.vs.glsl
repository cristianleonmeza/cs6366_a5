out vec3 vcsPosition;
out vec3 vcsNormal;
out vec2 texCoord;

void main() {

    vcsNormal = normalMatrix * normal;                              //q1a
    vcsPosition = vec3(modelViewMatrix*vec4(position, 1.0));        //q1a
    texCoord = vec2(uv.x, 1.0 - uv.y);                              //q1a: texture flipped on the y-axis
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
 }