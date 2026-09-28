#include "Renderer.h"
#include <cmath>
namespace odyssey {
void Renderer::draw(const PlayerBody& p,float yaw,float pitch,const Vec3& cameraPosition) const{
 ClearBackground(Color{176,211,220,255});const Vector3 target{p.position.x,p.position.y+0.65f,p.position.z};const float d=7;Camera3D cam{};
 cam.position={cameraPosition.x,cameraPosition.y,cameraPosition.z};cam.target=target;cam.up={0,1,0};cam.fovy=58;cam.projection=CAMERA_PERSPECTIVE;
 BeginMode3D(cam);DrawPlane({0,0,40},{240,150},Color{126,151,105,255});DrawPlane({0,0.06f,-12},{240,16},Color{220,199,148,255});DrawPlane({0,0.5f,-28},{240,44},Color{72,143,166,220});
 DrawCube({-48,0.075f,16},{3.6f,0.15f,3.6f},Color{145,126,96,255});DrawCube({-48,0.14f,17.2f},{3.6f,0.28f,3.6f},Color{145,126,96,255});DrawCube({-48,0.17f,18.4f},{3.6f,0.34f,3.6f},Color{145,126,96,255});DrawCube({-32,1.6f,28},{6,3.2f,9},Color{111,98,81,255});DrawCubeWires({-32,1.6f,28},{6,3.2f,9},Color{70,60,50,255});
 for(int i=0;i<22;++i){float a=i*0.9f;DrawCube({std::sin(a*2.1f)*55,0.7f,12+std::cos(a*1.7f)*45},1.4f,1.4f,1.4f,Color{96,87,72,255});}
 DrawCapsule({p.position.x,p.position.y,p.position.z},{p.position.x,p.position.y+p.height*0.62f,p.position.z},p.radius,8,12,p.climbing?Color{203,168,104,255}:Color{192,176,146,255});EndMode3D();
 DrawText("THE ODYSSEY — OWN ENGINE 0.2",24,22,22,Color{35,35,35,255});DrawText("WASD move | Shift sprint | Space jump | Mouse camera",24,52,18,Color{45,45,45,255});const char* state=p.swimming?"SWIM":p.climbing?"CLIMB":p.grounded?"GROUND":"AIR";DrawText(state,24,78,18,Color{35,35,35,255});
}
}