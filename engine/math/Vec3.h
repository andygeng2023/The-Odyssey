#pragma once
#include <algorithm>
#include <cmath>
namespace odyssey {
struct Vec3 {
 float x{0}, y{0}, z{0};
 Vec3 operator+(const Vec3& o) const { return {x+o.x,y+o.y,z+o.z}; }
 Vec3 operator-(const Vec3& o) const { return {x-o.x,y-o.y,z-o.z}; }
 Vec3 operator*(float s) const { return {x*s,y*s,z*s}; }
 Vec3& operator+=(const Vec3& o) { x+=o.x; y+=o.y; z+=o.z; return *this; }
 float lengthSq() const { return x*x+y*y+z*z; }
 float length() const { return std::sqrt(lengthSq()); }
 Vec3 normalized() const { float l=length(); return l>0.0001f ? (*this)*(1.0f/l) : Vec3{}; }
};
inline float moveToward(float a,float b,float d){return a<b?std::min(a+d,b):a>b?std::max(a-d,b):b;}
}
