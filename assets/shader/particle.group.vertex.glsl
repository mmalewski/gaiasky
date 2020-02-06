#version 330 core

#include shader/lib_geometry.glsl
#include shader/lib_colmap.glsl

in vec4 a_position;
in vec4 a_color;
// Additional attributes:
// x - size
// y - colmap_attribute_value
in vec2 a_additional;

uniform float u_alpha;

uniform mat4 u_projModelView;
uniform vec3 u_camPos;
uniform vec3 u_camDir;
uniform float u_sizeFactor;
uniform int u_cubemap;
uniform float u_minSize;
uniform float u_vrScale;
// Color map code, negative to not apply colormap
uniform int u_cmap;
uniform vec2 u_cmapMinMax;

#ifdef relativisticEffects
    #include shader/lib_relativity.glsl
#endif // relativisticEffects

#ifdef gravitationalWaves
    #include shader/lib_gravwaves.glsl
#endif // gravitationalWaves
    
out vec4 v_col;

#ifdef velocityBufferFlag
#include shader/lib_velbuffer.vert.glsl
#endif

void main() {
    vec3 pos = a_position.xyz - u_camPos;

    // Distance to point - watch out, if position contains large values, this produces overflow!
    // Downscale before computing length()
    float dist = length(pos * 1e-15) * 1e15;

    float cubemapSizeFactor = 1.0;
    if(u_cubemap == 1) {
        // Cosine of angle between star position and camera direction
        // Correct point primitive size error due to perspective projection
        float cosphi = pow(dot(u_camDir, pos) / dist, 2.0);
        cubemapSizeFactor = 1.0 - cosphi * 0.65;
    }

    #ifdef relativisticEffects
        pos = computeRelativisticAberration(pos, dist, u_velDir, u_vc);
    #endif // relativisticEffects
    
    #ifdef gravitationalWaves
        pos = computeGravitationalWaves(pos, u_gw, u_gwmat3, u_ts, u_omgw, u_hterms);
    #endif // gravitationalWaves
    
    // Color map if needed
    if(u_cmap < 0){
        v_col = vec4(a_color.rgb, a_color.a * u_alpha);
    } else {
        v_col = vec4(colormap(u_cmap, a_additional.y, u_cmapMinMax), u_alpha);
    }

    float viewAngle = a_additional.x / dist;

    vec4 gpos = u_projModelView * vec4(pos, 1.0);

    gl_Position = u_projModelView * vec4(pos, 0.0);
    gl_PointSize = max(viewAngle * u_sizeFactor * cubemapSizeFactor, u_minSize * a_additional.x);

    #ifdef velocityBufferFlag
    velocityBuffer(gpos, a_position.xyz, dist, vec2(1e10, 1e12), 1.0);
    #endif
}
