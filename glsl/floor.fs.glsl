in vec3 vcsNormal;
in vec3 vcsPosition;
in vec2 texCoord;
in vec4 lightSpaceCoords;

uniform vec3 lightColor;
uniform vec3 ambientColor;

uniform float kAmbient;
uniform float kDiffuse;
uniform float kSpecular;
uniform float shininess;

uniform vec3 cameraPos;
uniform vec3 lightPosition;
uniform vec3 lightDirection;

// Textures are passed in as uniforms
uniform sampler2D colorMap;
uniform sampler2D normalMap;

// Added ShadowMap
uniform sampler2D shadowMap;
uniform float textureSize;

//Q1d do the shadow mapping
//Q1d iii do PCF
// Returns 1 if point is occluded (saved depth value is smaller than fragment's depth value)
float inShadow(vec3 fragCoord, vec2 offset) {

    vec2 uv = fragCoord.xy + offset / textureSize;

    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) return 0.0;	//q1d: outside shadow map (not shadowed)

    float closest = texture(shadowMap, uv).r;								//q1d
    float current = fragCoord.z;											//q1d
    float bias = 0.0015; // tweak if acne/peter-panning appears				//q1d

    return current - bias > closest ? 1.0 : 0.0;							//q1d
	//return 0.0;															//q1d
}

// TODO: Returns a value in [0, 1], 1 indicating all sample points are occluded
float calculateShadow() {
	
    vec3 proj = lightSpaceCoords.xyz / lightSpaceCoords.w;					//q1d: perspective divide to NDC
    proj = proj * 0.5 + 0.5;												//q1d: NDC [-1,1] to texture [0,1]

    if (proj.z > 1.0) return 0.0;											//q1d: if behind light far plane

    float occluded = 0.0;													//q1d
    for (int x = -1; x <= 1; x++) {											//q1d
        for (int y = -1; y <= 1; y++) {										//q1d
            occluded += inShadow(proj, vec2(float(x), float(y)));			//q1d
        }																	//q1d
    }																		//q1d
    return occluded / 9.0; 													//q1d: PCF
	//return 0.0;															//q1d
}

void main() {
	//PRE-CALCS
	vec3 N = normalize(vcsNormal);
	vec3 Nt = normalize(texture(normalMap, texCoord).xyz * 2.0 - 1.0);
	vec3 L = normalize(vec3(viewMatrix * vec4(lightDirection, 0.0)));
	vec3 V = normalize(-vcsPosition);
	vec3 H = normalize(V + L);

	//AMBIENT
	vec3 light_AMB = ambientColor * kAmbient;

	//DIFFUSE
	vec3 diffuse = kDiffuse * lightColor;
	vec3 light_DFF = diffuse * max(0.0, dot(N, L));

	//SPECULAR
	vec3 specular = kSpecular * lightColor;
	vec3 light_SPC = specular * pow(max(0.0, dot(H, N)), shininess);

	//SHADOW
	// TODO:
	float shadowAmount = calculateShadow();											//q1d
	float shadow = 1.0 - shadowAmount;												//q1d
	//float shadow = 1.0;															//q1d

	//TOTAL
	light_DFF *= texture(colorMap, texCoord).xyz;
	vec3 TOTAL = light_AMB + shadow * (light_DFF + light_SPC);

	gl_FragColor = vec4(TOTAL, 1.0);
}