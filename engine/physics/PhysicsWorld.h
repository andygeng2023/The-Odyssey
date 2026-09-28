#pragma once
#include "../math/Vec3.h"
#include <vector>
namespace odyssey {
struct BoxCollider { Vec3 center; Vec3 half; bool climbable{true}; };
struct RampCollider { Vec3 center; Vec3 half; float height{1.0f}; bool climbable{true}; };
struct SurfaceHit { bool hit{false}; float y{0.0f}; Vec3 normal{0.0f,1.0f,0.0f}; bool climbable{false}; };
struct PlayerBody {
 Vec3 position{0,0.875f,5.0f}, velocity{};
 float radius{0.38f}, height{1.75f}, stepHeight{0.36f};
 bool grounded{true}, climbing{false}, swimming{false};
};
class PhysicsWorld {
public:
 void addBox(const BoxCollider& b); void addRamp(const RampCollider& r);
 void step(PlayerBody& p, Vec3 wish, float dt, bool jump, bool sprint);
 bool isWater(float x,float z) const;
 Vec3 cameraPosition(const Vec3& target,const Vec3& desired,float radius) const;
 Vec3 cameraPosition(const Vec3& target,const Vec3& desired,float radius) const;
private:
 std::vector<BoxCollider> boxes_; std::vector<RampCollider> ramps_;
 bool collidesAt(const PlayerBody& p,const Vec3& pos) const;
 bool collidesHorizontal(const PlayerBody& p,const Vec3& pos) const;
 bool tryStep(PlayerBody& p,const Vec3& motion);
 bool tryClimb(const PlayerBody& p,const Vec3& dir) const;
 SurfaceHit surfaceAt(const PlayerBody& p,float x,float z) const;
 bool steepSurfaceAhead(const PlayerBody& p,const Vec3& dir) const;
 void resolveGround(PlayerBody& p);
};
}