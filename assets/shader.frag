#include <flutter/runtime_effect.glsl>

#define PI 3.14159265359
#define BLACK vec4(0.0, 0.0, 0.0, 1.0)

#define WIDTH_R 0.3
#define LIGHT_R 0.02
#define SPREAD_R 0.12
#define RING_R 0.02
#define MARGIN 0.19
#define ANGLE PI * 15 / 11
#define STAGE 0.3

uniform vec2 uSize;
uniform float uProgress;
uniform sampler2D uTexture;

out vec4 fragColor;

void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;
  float r2 = 1.0 - MARGIN;
  float r = r2 / 2.0;
  float angle =
      2.0 * PI * clamp((uProgress - STAGE) / (1 - STAGE), 0.0, 1.0) + ANGLE;
  vec2 rv = (vec2(r2 * cos(angle), r2 * sin(angle)) + 1.0) / 2.0;
  vec4 tx = texture(uTexture, uv);
  float ar = SPREAD_R * clamp(uProgress / STAGE, 0.0, 1.0);
  float lightr = LIGHT_R * clamp(uProgress / STAGE, 0.0, 1.0);

  vec4 color;
  float c;
  if (tx != BLACK) {
    float h = RING_R * uProgress;
    float f = 0.5 + sin(angle) * h;
    float di = sqrt(pow(uv.x - f, 2.0) + pow(uv.y - f, 2.0));
    if (r - h <= di && r + h >= di) {
      c = pow(1.0 - ((di - r + h) / (h * 2)), 2);
    } else {
      c = 0.0;
    }
    color = vec4(c, c, c, c);
  }

  float d = sqrt(pow(rv.x - uv.x, 2.0) + pow(rv.y - uv.y, 2.0));
  if (tx == BLACK) {
    if (d <= lightr) {
      c = pow(1.0 - clamp(d / lightr, 0.0, 1.0), 2.0);
    }
    if (c <= 0.2) {
      float di = sqrt(pow(uv.x - 0.5, 2.0) + pow(uv.y - 0.5, 2.0));
      float h = (1.0 - clamp(d / ar, 0.0, 1.0)) * 0.01;
      if (r - h <= di && r + h >= di) {
        c = 0.2;
      } else {
        c = 0.0;
      }
    }
  } else {
    if (d <= lightr) {
      c = 1.0;
    } else {
      c = pow(1.0 - clamp(d / ar, 0.0, 1.0), 2);
    }
  }
  color += vec4(c, c, c, c);
  fragColor = tx + color;
}
