#include "Game.h"
#include <raylib.h>
#include <algorithm>
#include <cmath>
namespace odyssey {
bool Game::init(){InitWindow(1280,720,"The Odyssey - Own Engine");SetTargetFPS(60);DisableCursor();buildWorld();return !WindowShouldClose();}
void Game::buildWorld(){physics_.addBox({{-48,0.075f,16},{1.8f,0.075f,1.8f}});physics_.addBox({{-48,0.14f,17.2f},{1.8f,0.14f,1.8f}});physics_.addBox({{-48,0.17f,18.4f},{1.8f,0.17f,1.8f}});physics_.addRamp({{-32,1.6f,28},{3,1.6f,4.5f},3.2f,true});}
Vec3 Game::cameraPosition() const{const Vec3 target=player_.position+Vec3{0,0.65f,0};const float d=7.0f,cp=std::cos(cameraPitch_);Vec3 desired{player_.position.x-std::sin(cameraYaw_)*cp*d,player_.position.y+std::sin(cameraPitch_)*d+1.5f,player_.position.z-std::cos(cameraYaw_)*cp*d};return physics_.cameraPosition(target,desired,0.28f);}
void Game::update(float dt){Vector2 mouse=GetMouseDelta();cameraYaw_-=mouse.x*0.0035f;cameraPitch_=std::clamp(cameraPitch_-mouse.y*0.0025f,-0.15f,0.75f);float f=(IsKeyDown(KEY_W)?1.0f:0.0f)-(IsKeyDown(KEY_S)?1.0f:0.0f),r=(IsKeyDown(KEY_D)?1.0f:0.0f)-(IsKeyDown(KEY_A)?1.0f:0.0f);Vec3 fw{-std::sin(cameraYaw_),0,-std::cos(cameraYaw_)},side{std::cos(cameraYaw_),0,-std::sin(cameraYaw_)};accumulator_+=std::min(dt,0.05f);Vec3 wish=fw*f+side*r;bool jump=IsKeyPressed(KEY_SPACE),sprint=IsKeyDown(KEY_LEFT_SHIFT);while(accumulator_>=fixedDt_){physics_.step(player_,wish,fixedDt_,jump,sprint);accumulator_-=fixedDt_;jump=false;}if(player_.position.y<-10||std::abs(player_.position.x)>120||std::abs(player_.position.z)>90){player_.position={0,0.875f,5};player_.velocity={};player_.grounded=true;player_.climbing=false;}}
void Game::run(){while(!WindowShouldClose()){update(GetFrameTime());BeginDrawing();renderer_.draw(player_,cameraYaw_,cameraPitch_,cameraPosition());EndDrawing();}CloseWindow();}
}