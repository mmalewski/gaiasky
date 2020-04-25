#version 330 core

#include shader/lib_math.glsl
#include shader/lib_geometry.glsl

in vec3 a_position;
in vec3 a_pm;
in vec4 a_color;
// Additional attributes:
// x - size
// y - magnitude
in vec2 a_additional;

uniform int u_t; // time in days since epoch
uniform mat4 u_projModelView;
uniform vec3 u_camPos;
uniform vec3 u_camDir;
uniform int u_cubemap;

uniform vec2 u_pointAlpha;
uniform vec2 u_thAnglePoint;

uniform float u_brPow;

// VR scale factor
uniform float u_vrScale;

uniform float u_magLimit = 22.0;

#ifdef relativisticEffects
#include shader/lib_relativity.glsl
#endif // relativisticEffects

#ifdef gravitationalWaves
#include shader/lib_gravwaves.glsl
#endif // gravitationalWaves

// 0 - alpha
// 1 - point size
// 2 - fov factor
// 3 - star brightness
uniform vec4 u_alphaSizeFovBr;

out vec4 v_col;

#define len0 170000.0
#define day_to_year 1.0 / 365.25

#ifdef velocityBufferFlag
#include shader/lib_velbuffer.vert.glsl
#endif

void main() {
	// Lengths
	float l0 = len0 * u_vrScale;
	float l1 = l0 * 100.0;

    vec3 pos = a_position - u_camPos;

    // Proper motion
    vec3 pm = a_pm * float(u_t) * day_to_year;
    pos = pos + pm;

    // Distance to star
    float dist = length(pos);

    float sizefactor = 1.0;
    if(u_cubemap == 1) {
        // Cosine of angle between star position and camera direction
        // Correct point primitive size error due to perspective projection
        float cosphi = pow(dot(u_camDir, pos) / dist, 2.0);
        sizefactor = 1.0 - cosphi * 0.65;
    }
    
    #ifdef relativisticEffects
    	pos = computeRelativisticAberration(pos, dist, u_velDir, u_vc);
    #endif // relativisticEffects
    
    #ifdef gravitationalWaves
        pos = computeGravitationalWaves(pos, u_gw, u_gwmat3, u_ts, u_omgw, u_hterms);
    #endif // gravitationalWaves

    float viewAngleApparent = atan((a_additional.x * u_alphaSizeFovBr.w) / dist) / u_alphaSizeFovBr.z;
    float opacity = clamp(lint2(viewAngleApparent, u_thAnglePoint.x, u_thAnglePoint.y, u_pointAlpha.x, u_pointAlpha.y), 0.0, 1.0);

    float fadeout = smoothstep(dist, l0, l1);

    v_col = vec4(a_color.rgb, clamp(opacity * u_alphaSizeFovBr.x * fadeout, 0.0, 1.0));

    vec4 gpos = u_projModelView * vec4(pos, 1.0);
    gl_Position = gpos;
    gl_PointSize = pow(viewAngleApparent * 1e8, u_brPow) * u_alphaSizeFovBr.y * sizefactor / u_alphaSizeFovBr.z;

    #ifdef velocityBufferFlag
    velocityBuffer(gpos, a_position, dist, pm, vec2(500.0, 3000.0), 1.0);
    #endif

    if(dist < len0 * u_vrScale || a_additional.y > u_magLimit){
        // The pixels of this star will be discarded in the fragment shader
        v_col = vec4(0.0, 0.0, 0.0, 0.0);
    }
}
