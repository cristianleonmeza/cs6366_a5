uniform vec3 cameraPos;
out vec3 wcsPosition;

void main() {
	// TODO: Q1b

	gl_Position = projectionMatrix * viewMatrix * vec4(position, 1.0);
}