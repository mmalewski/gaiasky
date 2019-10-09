#version 330 core

#include shader/lib_math.glsl
#include shader/lib_geometry.glsl
#include shader/lib_colmap.glsl

in vec3 a_position;
in vec3 a_pm;
in vec4 a_color;
// Additional attributes:
// x - size
// y - magnitude
// z - colmap_attribute_value
// w - additional
in vec4 a_additional;

uniform int u_t; // time in days since epoch
uniform mat4 u_projModelView;
uniform vec3 u_camPos;
uniform vec3 u_camDir;
uniform int u_cubemap;

uniform vec2 u_pointAlpha;
uniform float u_thAnglePoint;

// Color map code, negative to not apply colormap
uniform int u_cmap;
uniform vec2 u_cmapMinMax;

uniform float u_magLimit = 22.0;

#ifdef relativisticEffects
    uniform vec3 u_velDir; // Velocity vector
    uniform float u_vc; // Fraction of the speed of light, v/c
    #include shader/lib_relativity.glsl
#endif // relativisticEffects

#ifdef gravitationalWaves
    uniform vec4 u_hterms; // hpluscos, hplussin, htimescos, htimessin
    uniform vec3 u_gw; // Location of gravitational wave, cartesian
    uniform mat3 u_gwmat3; // Rotation matrix so that u_gw = u_gw_mat * (0 0 1)^T
    uniform float u_ts; // Time in seconds since start
    uniform float u_omgw; // Wave frequency
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

#include shader/lib_velbuffer.vert.glsl

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

    // Discard vertex if too close or mag out of bounds
    float v_discard = 1.0;
    if(dist < len0 * u_vrScale || a_additional.y > u_magLimit) {
        v_discard = 0.0;
        v_col *= 0.0;
    }

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
    float opacity = pow(lint2(viewAngleApparent, 0.0, u_thAnglePoint, u_pointAlpha.x, u_pointAlpha.y), 1.2);

    float fadeout = smoothstep(dist, l0, l1);

    // Color map if needed
    if(u_cmap < 0){
        v_col = vec4(a_color.rgb, opacity * u_alphaSizeFovBr.x * fadeout);
    } else {
        v_col = vec4(colormap(u_cmap, a_additional.z, u_cmapMinMax), u_alphaSizeFovBr.x * fadeout);
    }

    vec4 gpos = u_projModelView * vec4(pos, 1.0);

    gl_Position = gpos * v_discard;
    gl_PointSize = u_alphaSizeFovBr.y * sizefactor;

    velocityBuffer(gpos, a_position, dist, pm, vec2(500.0, 3000.0), 1.0);
}
