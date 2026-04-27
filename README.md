# CS 6366 Assignment 5: Textures and Shadows

**Student Name:** Cristian Leon Meza
**Student Number:** 2021813809
**NetID:** cfl240000

## Assignment Overview

This assignment extends knowledge of rendering techniques. Implementation of texture, environment and shadow mapping are executed. 

## Part 1: Required Elements (100 pts)

### (a) Texture Mapping with ShaderMaterial (20 pts)

**Requirements:**
- Apply texture mapping to Shay D. Pixel using custom shaders

**Implementation:**
I loaded the color and normal textures for Shay in `A5.js` and passed them to `shayDMaterial` as uniforms. In `shay.vs.glsl`, I passed UVs, normal and view space position to the fragment shader, including y-flip correction. In `shay.fs.glsl`, I sampled from `colorMap` and multiplied with the diffuse term befor combining ambient, diffuse and specular.

**Files Modified:**
- `A5.js`
- `glsl/shay.vs.glsl` 
- `glsl/shay.fs.glsl`

**Key Code Snippets:**
```javascript
// A5.js
const shayDMaterial = new THREE.ShaderMaterial({
  side: THREE.DoubleSide,
  uniforms: {

    lightColor: lightColorUniform,                
    ambientColor: ambientColorUniform,           

    kAmbient: kAmbientUniform,
    kDiffuse: kDiffuseUniform,
    kSpecular: kSpecularUniform,
    shininess: shininessUniform,
    cameraPos: cameraPositionUniform,
    lightPosition: lightPositionUniform,
    lightDirection: lightDirectionUniform,

    colorMap: {type: "t", value: shayDColorTexture },  
    normalMap: {type: "t", value: shayDNormalTexture },
  }
});              
```
```glsl
// glsl/shay.vs.glsl
void main() {
    vcsNormal = normalMatrix * normal;                            
    vcsPosition = vec3(modelViewMatrix*vec4(position, 1.0));      
    texCoord = vec2(uv.x, 1.0 - uv.y);                             
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
 }
```
```glsl
// glsl/shay.fs.glsl
void main() {
	vec3 abd = texture(colorMap, texCoord).rgb;					
	light_DFF = light_DFF*abd;									
}
```
---

### (b) Skybox (20 pts)

**Requirements:**
- Load cubemap textures 
- Implement skybox shaders

**Implementation:**
I loaded the six cubemap faces with `THREE.CubeTextureLoader()` in the proper order and set `scene.background = skyboxCubemap`. I also implemented the skybox shader logic.

**Files Modified:**
- `A5.js`
- `glsl/skybox.vs.glsl` 
- `glsl/skybox.fs.glsl`

**Key Code Snippets:**
```javascript
// A5.js
const skyboxCubemap = new THREE.CubeTextureLoader().load([  
  'images/cubemap/posx.jpg',                                
  'images/cubemap/negx.jpg',                                
  'images/cubemap/posy.jpg',                              
  'images/cubemap/negy.jpg',                                
  'images/cubemap/posz.jpg',                              
  'images/cubemap/negz.jpg',                             
]);                 
```

```glsl
// glsl/skybox.vs.glsl
void main() {
    wcsPosition = position;													
    vec3 worldPos = position + cameraPos;								
    gl_Position = projectionMatrix * viewMatrix * vec4(worldPos, 1.0);
}
```
```glsl
// glsl/skybox.fs.glsl
void main() {
    vec3 dir = normalize(wcsPosition);	
    gl_FragColor = texture(skybox, dir);
}
```
---

### (c) Shiny Bunny (20 pts)

**Requirements:**
- Implement reflective environment mapping usign the cubemap
- Apply handedness fix (flip reflected ray) 

**Implementation:**
I passed cubemap and camera world matrix to `envmapMaterial`. In `envmap.fs.glsl`, I computed the reflected direction with `reflect(V, N)`, transformed it to world space, and then flipped x to account for handedness mismatch. The bunny ends up with reflective appearance by using `texture(skybox, Rw)`.

**Files Modified:**
- `A5.js`
- `glsl/envmap.fs.glsl`

**Key Code Snippets:**
```javascript
// A5.js
const envmapMaterial = new THREE.ShaderMaterial({
  uniforms: {
    skybox: {type: "t", value: skyboxCubemap},                   
    matrixWorld: {type: "m4", value: camera.matrixWorld}    
  }
});
```

```glsl
// glsl/envmap.fs.glsl
void main( void ) {
  vec3 N = normalize(vcsNormal);                         
  vec3 V = normalize(vcsPosition);           
  vec3 Rv = reflect(V, N);                     
  vec3 Rw = normalize((matrixWorld*vec4(Rv, 0.0)).xyz);    
  Rw.x = -Rw.x;                      
  gl_FragColor = texture(skybox, Rw);      
}
```
---

### (d) Shadow Mapping (40 pts)

**Requirements:**
- Render and visualize depth map (scene 2)
- Use depth map for projected shadows and smooth shadows with PCF (scene 3)

**Implementation:**
I used two render passes for shadows, rendering from light camera into renderTarget to get a depth map and then using that depth map in the floor shader to decide whether the floor pixel is in light or in shadow. For scene 2, I show the depth map on full screen and for scene 3, I use the depth map to draw shadows on the floor.
To make shadows smoother, I used 3x3 PCF, checking the current pixel and 8 nearby pixels in the shadow map. The I took the average result to darken the diffuse + specular light. 

**Files Modified:**
- `A5.js`
- `glsl/render.vs.glsl`
- `glsl/render.fs.glsl`
- `glsl/floor.fs.glsl`

**Key Code Snippets:**
```javascript
// A5.js
else if (sceneHandler == 2) 
  {
    renderer.setRenderTarget(renderTarget);    
    renderer.clear();                            
    renderer.render(shadowScene, shadowCam);  
    postMaterial.uniforms.tDepth.value = renderTarget.depthTexture;  
    renderer.setRenderTarget(null);                             
    renderer.clear();                                                 
    renderer.render(postScene, postCam);                         
  }
  else if (sceneHandler == 3) 
  {
    renderer.setRenderTarget(renderTarget);          
    renderer.clear();                                
    renderer.render(shadowScene, shadowCam);      
    floorMaterial.uniforms.shadowMap.value = renderTarget.depthTexture; 
    floorMaterial.uniforms.textureSize.value = renderTarget.width;   
    renderer.setRenderTarget( null );
    renderer.clear();                                       
    renderer.render( scene, camera );
  } 
```
```glsl
// glsl/render.vs.glsl
out vec2 texCoord;        
void main() {
    texCoord = uv;                                         
    gl_Position = vec4(position, 1.0);                   
}
```
```glsl
// glsl/render.fs.glsl
in vec2 texCoord;  
void main() {
    float d = texture(tDepth, texCoord).r;  
    gl_FragColor = vec4(vec3(d), 1.0);      
    //gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);   
}
```
```glsl
// glsl/floor.fs.glsl
float inShadow(vec3 fragCoord, vec2 offset) {
    vec2 uv = fragCoord.xy + offset / textureSize;
    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) return 0.0;	
    float closest = texture(shadowMap, uv).r;			
    float current = fragCoord.z;							
    float bias = 0.0015; // tweak if acne/peter-panning appears		
    return current - bias > closest ? 1.0 : 0.0;				
}

float calculateShadow() {
    vec3 proj = lightSpaceCoords.xyz / lightSpaceCoords.w;					
    proj = proj*0.5 + 0.5;												
    if (proj.z > 1.0) return 0.0;											
    float occluded = 0.0;										
    for (int x = -1; x <= 1; x++) {						
        for (int y = -1; y <= 1; y++) {						
            occluded += inShadow(proj, vec2(float(x), float(y)));	
        }											
    }												
    return occluded / 9.0; 	
}

void main() {
    //...
	float shadowAmount = calculateShadow();					
	float shadow = 1.0 - shadowAmount;						
	light_DFF *= texture(colorMap, texCoord).xyz;
	vec3 TOTAL = light_AMB + shadow * (light_DFF + light_SPC);
	gl_FragColor = vec4(TOTAL, 1.0);
}
```
---

## Screenshots
- **Q1a:** [Example Image](screenshots/q1a.png)
- **Q1b:** [Example Image](screenshots/q1b.png)
- **Q1c:** [Example Image](screenshots/q1c.png)
- **Q1d:** [Example Image](screenshots/q1d_scene2.png)
- **Q1d:** [Example Image](screenshots/q1d_scene3.png)
