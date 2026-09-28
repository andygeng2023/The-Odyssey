#pragma once
#include "physics/PhysicsWorld.h"
#include "render/Renderer.h"
namespace odyssey {
class Game {
public: bool init(); void run();
private: PhysicsWorld physics_; PlayerBody player_; Renderer renderer_; float cameraYaw_{0},cameraPitch_{0.22f},accumulator_{0};
 static constexpr float fixedDt_=1.0f/60.0f;
 void buildWorld();
 Vec3 cameraPosition() const;
 Vec3 cameraPosition() const; void update(float dt);
};
}