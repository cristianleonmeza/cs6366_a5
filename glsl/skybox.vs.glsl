uniform vec3 cameraPos;
out vec3 wcsPosition;

void main() {
	// TODO: Q1b
    wcsPosition = position;													//q1b: cubemap lookup direction
    vec3 worldPos = position + cameraPos;									//q1b: keep skybox centered on camera

    gl_Position = projectionMatrix * viewMatrix * vec4(worldPos, 1.0);
	//gl_Position = projectionMatrix * viewMatrix * vec4(position, 1.0);
}