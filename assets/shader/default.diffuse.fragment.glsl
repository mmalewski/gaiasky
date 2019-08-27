#version 330 core

#define TEXTURE_LOD_BIAS 0.0

#if defined(colorFlag)
in vec4 v_color;
#endif

#ifdef blendedFlag
in float v_opacity;
#endif //blendedFlag

#if defined(diffuseTextureFlag) || defined(specularTextureFlag)
#define textureFlag
in vec2 v_texCoords0;
#endif

#ifdef diffuseColorFlag
uniform vec4 u_diffuseColor;
#endif

#ifdef diffuseTextureFlag
uniform sampler2D u_diffuseTexture;
#endif

#ifdef lightingFlag
in vec3 v_lightDiffuse;

#if	defined(ambientLightFlag) || defined(ambientCubemapFlag) || defined(sphericalHarmonicsFlag)
#define ambientFlag
#endif //ambientFlag

#ifdef specularFlag
in vec3 v_lightSpecular;
#endif //specularFlag

#if defined(ambientFlag) && defined(separateAmbientFlag)
in vec3 v_ambientLight;
#endif //separateAmbientFlag

#endif //lightingFlag

#include shader/lib_logdepthbuff.glsl

in vec3 v_fragPosView;

out vec4 fragColor;


void main() {
	#if defined(diffuseTextureFlag) && defined(diffuseColorFlag) && defined(colorFlag)
		vec4 diffuse = texture(u_diffuseTexture, v_texCoords0, TEXTURE_LOD_BIAS) * u_diffuseColor * v_color;
	#elif defined(diffuseTextureFlag) && defined(diffuseColorFlag)
		vec4 diffuse = texture(u_diffuseTexture, v_texCoords0, TEXTURE_LOD_BIAS) * u_diffuseColor;
	#elif defined(diffuseTextureFlag) && defined(colorFlag)
		vec4 diffuse = texture(u_diffuseTexture, v_texCoords0, TEXTURE_LOD_BIAS) * v_color;
	#elif defined(diffuseTextureFlag)
		vec4 diffuse = texture(u_diffuseTexture, v_texCoords0, TEXTURE_LOD_BIAS);
	#elif defined(diffuseColorFlag) && defined(colorFlag)
		vec4 diffuse = u_diffuseColor * v_color;
	#elif defined(diffuseColorFlag)
		vec4 diffuse = u_diffuseColor;
	#elif defined(colorFlag)
		vec4 diffuse = v_color;
	#else
		vec4 diffuse = vec4(1.0);
	#endif

	fragColor.rgb = diffuse.rgb;

	#ifdef blendedFlag
		fragColor.a = diffuse.a * v_opacity;
	#else
		fragColor.a = 1.0;
	#endif

	fragColor.rgb *= fragColor.a;
	
	// Prevent saturation
    fragColor = clamp(fragColor, 0.0, 1.0);

	gl_FragDepth = getDepthValue(length(v_fragPosView));
}