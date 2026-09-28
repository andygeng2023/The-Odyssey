#include "Game.h"
#include <raylib.h>
#include <algorithm>
#include <cmath>
namespace odyssey {
bool Game::init(){InitWindow(1280,720,"The Odyssey — Own Engine");SetTargetFPS(60);DisableCursor();buildWorld();return !WindowShouldClose();}
void Game::buildWorld(){
 physics_.addBox({{-48,0.075f,16.0f},{1.8f,0.075f,1.8f}});
 physics_.addBox({{-48,0.14f,17.2f},{1.8f,0.14f,1.8f}});
 physics_.addBox({{-48,0.17f,18.4f},{1.8f,0.17f,1.8f}});
 physics_.addBox({{-32,1.25f,28.0f},{3.0f,1.25f,4.5f},true});
}
void Game::update(float dt){
 Vector2 mouse=GetMouseDelta(); cameraYaw_-=mouse.x*0.0035f; cameraPitch_=std::clamp(cameraPitch_-mouse.y*0.0025f,-0.15f,0.75f);
 float forward=(IsKeyDown(KEY_W)?1.0f:0.0f)-(IsKeyDown(KEY_S)?1.0f:0.0f);
 float right=(IsKeyDown(KEY_D)?1.0f:0.0f)-(IsKeyDown(KEY_A)?1.0f:0.0f);
 Vec3 fwd{-std::sin(cameraYaw_),0,-std::cos(cameraYaw_)};
 Vec3 side{std::cos(cameraYaw_),0,-std::sin(cameraYaw_)};
 physics_.step(player_,fwd*forward+side*right,dt,IsKeyPressed(KEY_SPACE),IsKeyDown(KEY_LEFT_SHIFT));
 if(player_.position.y<-10||std::abs(player_.position.x)>120||std::abs(player_.position.z)>80){player_.position={0,0.875f,5};player_.velocity={};player_.grounded=true;player_.climbing=false;}
}
void Game::run(){while(!WindowShouldClose()){float dt=std::min(GetFrameTime(),0.033f);update(dt);BeginDrawing();renderer_.draw(player_,cameraYaw_,cameraPitch_);EndDrawing();}CloseWindow();}
}
