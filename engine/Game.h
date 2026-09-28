#pragma once
#include "physics/PhysicsWorld.h"
#include "render/Renderer.h"
namespace odyssey {
class Game {
public:
 bool init();
 void run();
private:
 PhysicsWorld physics_;
 PlayerBody player_;
 Renderer renderer_;
 float cameraYaw_{0.0f},cameraPitch_{0.22f};
 void buildWorld();
 void update(float dt);
};
}
