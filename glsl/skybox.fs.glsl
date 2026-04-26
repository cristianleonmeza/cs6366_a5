// The cubmap texture is of type SamplerCube

uniform samplerCube skybox;
in vec3 wcsPosition;

void main() {
	// HINT : Sample the texture from the samplerCube object, rememeber that cubeMaps are sampled 
	// using a direction vector that you calculated in the vertex shader 
	// TODO: q1b
	gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);  //Q1b looking up shader color from texturemap
}