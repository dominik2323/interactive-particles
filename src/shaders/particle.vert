precision highp float;

attribute float pindex;
attribute vec3 position;
attribute vec3 offset;
attribute vec2 uv;
attribute float angle;

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;

uniform float uTime;
uniform float uForce;
uniform float uRandom;
uniform float uDepth;
uniform float uSize;
uniform vec2 uTextureSize;
uniform sampler2D uTexture;
uniform sampler2D uTouch;

varying vec2 vPUv;
varying vec2 vUv;

#pragma glslify: snoise2 = require(glsl-noise/simplex/2d)

float random(float n) {
	return fract(sin(n) * 43758.5453123);
}


void main() {
	vUv = uv;


	// particle uv
	vec2 puv = offset.xy / uTextureSize;
	vPUv = puv;

	// pixel color
	vec4 colA = texture2D(uTexture, puv);
	float grey = colA.r * 0.21 + colA.g * 0.71 + colA.b * 0.07;

	// displacement
	vec3 displaced = offset;
	// randomise
	// displaced.xy += vec2(random(pindex) - 0.5, random(offset.x + pindex) - 0.5) * uRandom;
	float rndz = (random(pindex) + snoise_1_2(vec2(pindex * 0.1, uTime * 0.1)));
	// displaced.z += rndz * (uDepth);
	// center
	displaced.xy -= uTextureSize * 0.5;
	// displaced.y *= uv.y * 1.0;

	// touch
	float force = 40.0 * uForce;
	// float t = .8 - texture2D(uTouch, puv).r;
	float t = texture2D(uTouch, puv).r * 2.0;
	// displaced.z += t * force * rndz;
	float grad = vPUv.x * 5.0;
	displaced.x += cos(angle) * t * force  * 1.0 * grad;
	displaced.y += sin(angle) * t * force  * 1.0 * grad;


	// particle size
	// float psize = (snoise_1_2(vec2(uTime, pindex) * 0.5) + 2.0);
	float psize = 0.6;
	psize *= uSize;

	// final position
	vec4 mvPosition = modelViewMatrix * vec4(displaced, 1.0);
	mvPosition.xyz += position * psize;
	vec4 finalPosition = projectionMatrix * mvPosition;

	gl_Position = finalPosition;
}
