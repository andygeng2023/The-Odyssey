#pragma once
#include "../physics/PhysicsWorld.h"
#include <raylib.h>
namespace odyssey {
class Renderer {
public:
 void draw(const PlayerBody& p,float yaw,float pitch) const;
};
}
