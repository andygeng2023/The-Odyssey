#include "PhysicsWorld.h"
#include <algorithm>
#include <cmath>
namespace odyssey {
void PhysicsWorld::addBox(const BoxCollider& b){boxes_.push_back(b);}
bool PhysicsWorld::isWater(float,float z) const{return z < -6.0f;}
bool PhysicsWorld::collidesAt(const PlayerBody& p,const Vec3& pos) const{
 const float hh=p.height*0.5f,bottom=pos.y-hh,top=pos.y+hh;
 for(const auto& b:boxes_){
  const float cx=std::clamp(pos.x,b.center.x-b.half.x,b.center.x+b.half.x);
  const float cz=std::clamp(pos.z,b.center.z-b.half.z,b.center.z+b.half.z);
  const float dx=pos.x-cx,dz=pos.z-cz;
  if(dx*dx+dz*dz>p.radius*p.radius) continue;
  if(top<b.center.y-b.half.y||bottom>b.center.y+b.half.y) continue;
  return true;
 }
 return false;
}
bool PhysicsWorld::tryStep(PlayerBody& p,const Vec3& motion){
 if(motion.lengthSq()<0.00001f||!collidesAt(p,p.position+motion)) return false;
 Vec3 raised=p.position; raised.y+=p.stepHeight;
 if(collidesAt(p,raised)||collidesAt(p,raised+motion)) return false;
 p.position=raised; p.grounded=true; p.velocity.y=0; return true;
}
bool PhysicsWorld::tryClimb(const PlayerBody& p,const Vec3& dir) const{
 if(dir.lengthSq()<0.001f) return false;
 const Vec3 d=dir.normalized();
 const Vec3 foot=p.position+Vec3{0,-0.55f,0}+d*0.75f;
 const Vec3 hand=p.position+Vec3{0,0.35f,0}+d*0.75f;
 for(const auto& b:boxes_){
  const bool footInside=std::abs(foot.x-b.center.x)<=b.half.x&&std::abs(foot.z-b.center.z)<=b.half.z;
  const bool handClear=std::abs(hand.x-b.center.x)>b.half.x||std::abs(hand.z-b.center.z)>b.half.z;
  if(footInside&&handClear&&b.climbable) return true;
 }
 return false;
}
void PhysicsWorld::step(PlayerBody& p,Vec3 wish,float dt,bool jump,bool sprint){
 wish.y=0; wish=wish.normalized(); p.swimming=isWater(p.position.x,p.position.z);
 if(p.swimming){
  const float speed=sprint?5.0f:3.5f; const Vec3 target=wish*speed;
  p.velocity.x=moveToward(p.velocity.x,target.x,10.0f*dt);
  p.velocity.z=moveToward(p.velocity.z,target.z,10.0f*dt);
  const float targetY=0.20f; p.velocity.y=moveToward(p.velocity.y,(targetY-p.position.y)*8.0f,10.0f*dt);
  p.position+=p.velocity*dt; return;
 }
 const float speed=sprint?7.0f:4.6f; const Vec3 target=wish*speed;
 const float accel=p.grounded?28.0f:10.0f;
 p.velocity.x=moveToward(p.velocity.x,target.x,accel*dt);
 p.velocity.z=moveToward(p.velocity.z,target.z,accel*dt);
 if(p.grounded&&jump){p.velocity.y=7.2f;p.grounded=false;}
 if(!p.grounded&&!p.climbing)p.velocity.y-=22.0f*dt;
 const Vec3 horizontal{p.velocity.x*dt,0,p.velocity.z*dt};
 p.climbing=!p.grounded&&tryClimb(p,wish);
 if(p.climbing)p.velocity.y=2.6f; else if(p.grounded)tryStep(p,horizontal);
 Vec3 next=p.position+Vec3{horizontal.x,p.velocity.y*dt,horizontal.z};
 if(!collidesAt(p,next))p.position=next;
 else {Vec3 slide=p.position+Vec3{horizontal.x,0,horizontal.z}; if(!collidesAt(p,slide))p.position=slide; else {p.velocity.x=0;p.velocity.z=0;}}
 const float groundY=0.875f;
 if(p.position.y<=groundY){p.position.y=groundY;p.velocity.y=0;p.grounded=true;p.climbing=false;} else p.grounded=false;
}
}
