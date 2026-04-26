in vec3 vcsNormal;
in vec3 vcsPosition;

uniform vec3 lightDirection;

uniform samplerCube skybox;

uniform mat4 matrixWorld;

void main( void ) {

  // Q1c : Calculate the vector that can be used to sample from the cubemap
  // TODO:

  vec3 N = normalize(vcsNormal);                              //q1c: view-space normal
  vec3 V = normalize(vcsPosition);                            //q1c: eye to fragment in view space
  vec3 Rv = reflect(V, N);                                    //q1c: reflected ray in view space
  vec3 Rw = normalize((matrixWorld * vec4(Rv, 0.0)).xyz);     //q1c: from view space ray to world space ray
  Rw.x = -Rw.x;                                               //q1c: handedness fix

  gl_FragColor = texture(skybox, Rw);                         //q1c
  //gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);                  //q1c
}