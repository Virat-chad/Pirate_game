shader_type sky;

uniform vec3 top_color : source_color = vec3(0.1, 0.45, 0.95);
uniform vec3 horizon_color : source_color =vec3(0.75, 0.95, 1.2);
uniform vec3 bottom_color : source_color = vec3(0.05, 0.08, 0.15);
uniform sampler2D cloud_tex;
uniform float cloud_speed = 0.01;
uniform float cloud_scale = 2.0;


void sky() {
    vec3 dir = EYEDIR;

    float horizon = smoothstep(-0.2, 0.4, dir.y);

    vec3 col = mix(bottom_color, horizon_color, horizon);
    col = mix(col, top_color, smoothstep(0.0, 0.8, dir.y));



  vec2 uv = dir.xz * 2.0 + vec2(TIME * cloud_speed, 0.0);
    float clouds = texture(cloud_tex, uv).r;

    clouds = smoothstep(0.5, 0.7, clouds);

    col += clouds * 0.2; // cloud brightness

    COLOR = col;

    COLOR = col * 2.0;
	float horizonGlow = pow(1.0 - abs(dir.y), 4.0);
col += vec3(1.0, 0.5, 0.2) * horizonGlow * 0.25;

float sun_amount = max(dot(EYEDIR, LIGHT0_DIRECTION), 0.0);

float glow =
    pow(sun_amount, 32.0) * 0.4 +
    pow(sun_amount, 128.0) * 0.8;

col += vec3(1.0, 0.9, 0.6) * glow;
}