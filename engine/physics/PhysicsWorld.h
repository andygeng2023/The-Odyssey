#pragma once
#include "../math/Vec3.h"
#include <vector>
namespace odyssey {
struct BoxCollider { Vec3 center; Vec3 half; bool climbable{true}; };
struct PlayerBody {
 Vec3 position{0,1.0f,5.0f}, velocity{};
 float radius{0.38f}, height{1.75f}, stepHeight{0.36f};
 bool grounded{false}, climbing{false}, swimming{false};
};
class PhysicsWorld {
public:
 void addBox(const BoxCollider& b);
 void step(PlayerBody& p, Vec3 wish, float dt, bool jump, bool sprint);
 bool isWater(float x,float z) const;
private:
 std::vector<BoxCollider> boxes_;
 bool collidesAt(const PlayerBody& p, const Vec3& pos) const;
 bool tryStep(PlayerBody& p,const Vec3& motion);
 bool tryClimb(const PlayerBody& p,const Vec3& dir) const;
};
}
