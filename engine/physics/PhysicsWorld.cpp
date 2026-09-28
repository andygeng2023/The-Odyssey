#include "PhysicsWorld.h"
#include <algorithm>
#include <cmath>
namespace odyssey {
namespace { constexpr float GROUND=0.0f, GRAVITY=22.0f, INTERNAL_DT=1.0f/120.0f, MAX_SLOPE_COS=0.6691306f;
float clamp01(float v){return std::clamp(v,0.0f,1.0f);}
bool inside(float x,float z,const Vec3& c,const Vec3& h,float pad){return std::abs(x-c.x)<=h.x+pad&&std::abs(z-c.z)<=h.z+pad;}
}
void PhysicsWorld::addBox(const BoxCollider& b){boxes_.push_back(b);}
void PhysicsWorld::addRamp(const RampCollider& r){ramps_.push_back(r);}
bool PhysicsWorld::isWater(float,float z) const{return z<-6.0f;}
Vec3 PhysicsWorld::cameraPosition(const Vec3& target,const Vec3& desired,float radius) const{
 Vec3 delta=desired-target; const float len=delta.length(); if(len<0.001f)return target;
 const Vec3 dir=delta*(1.0f/len); float safe=len; constexpr int samples=32;
 for(int i=1;i<=samples;++i){const float t=static_cast<float>(i)/static_cast<float>(samples);const Vec3 p=target+delta*t;bool blocked=false;
  for(const auto& box:boxes_) if(std::abs(p.x-box.center.x)<=box.half.x+radius&&std::abs(p.y-box.center.y)<=box.half.y+radius&&std::abs(p.z-box.center.z)<=box.half.z+radius){blocked=true;break;}
  if(blocked){safe=std::max(0.2f,len*(static_cast<float>(i-1)/static_cast<float>(samples))-radius);break;}
 }
 return target+dir*safe;
}
SurfaceHit PhysicsWorld::surfaceAt(const PlayerBody&,float x,float z) const{
 SurfaceHit best; best.y=GROUND;
 for(const auto& r:ramps_) if(inside(x,z,r.center,r.half,0)){
  float t=clamp01((z-(r.center.z-r.half.z))/std::max(0.001f,2*r.half.z));
  float y=r.center.y-r.height*0.5f+t*r.height;
  if(!best.hit||y>best.y){float s=r.height/std::max(0.001f,2*r.half.z);best={true,y,Vec3{0,1,-s}.normalized(),r.climbable};}
 }
 for(const auto& b:boxes_) if(inside(x,z,b.center,b.half,0)){
  float y=b.center.y+b.half.y; if(!best.hit||y>best.y) best={true,y,{0,1,0},b.climbable};
 }
 return best;
}
bool PhysicsWorld::collidesAt(const PlayerBody& p,const Vec3& pos) const{
 float hh=p.height*0.5f,bottom=pos.y-hh,top=pos.y+hh;
 if(bottom<GROUND-0.01f)return true;
 for(const auto& b:boxes_){
  float cx=std::clamp(pos.x,b.center.x-b.half.x,b.center.x+b.half.x),cz=std::clamp(pos.z,b.center.z-b.half.z,b.center.z+b.half.z);
  float dx=pos.x-cx,dz=pos.z-cz; if(dx*dx+dz*dz>p.radius*p.radius)continue;
  if(top<=b.center.y-b.half.y||bottom>=b.center.y+b.half.y)continue; return true;
 }
 for(const auto& r:ramps_) if(inside(pos.x,pos.z,r.center,r.half,p.radius)){
  float t=clamp01((pos.z-(r.center.z-r.half.z))/std::max(0.001f,2*r.half.z));
  float surface=r.center.y-r.height*0.5f+t*r.height;
  if(bottom<surface&&top>r.center.y-r.height*0.5f)return true;
 }
 return false;
}
bool PhysicsWorld::collidesHorizontal(const PlayerBody& p,const Vec3& pos) const{return collidesAt(p,{pos.x,p.position.y,pos.z});}
bool PhysicsWorld::tryStep(PlayerBody& p,const Vec3& motion){
 if(motion.lengthSq()<0.000001f)return false; Vec3 target=p.position+motion;
 if(!collidesHorizontal(p,target))return false; SurfaceHit s=surfaceAt(p,target.x,target.z);
 float current=p.position.y-p.height*0.5f,delta=s.y-current;
 if(!s.hit||delta<=0.015f||delta>p.stepHeight)return false;
 Vec3 raised=p.position;raised.y+=delta+0.015f;if(collidesAt(p,raised))return false;
 Vec3 landed=raised+motion;if(collidesAt(p,landed))return false;
 p.position=landed;p.position.y=s.y+p.height*0.5f+0.015f;p.velocity.y=0;p.grounded=true;return true;
}
bool PhysicsWorld::tryClimb(const PlayerBody& p,const Vec3& dir) const{
 if(dir.lengthSq()<0.0001f)return false;Vec3 d=dir.normalized();
 Vec3 foot=p.position+Vec3{0,-0.55f,0}+d*0.72f,hand=p.position+Vec3{0,0.38f,0}+d*0.72f;
 for(const auto& b:boxes_){bool near=std::abs(foot.x-b.center.x)<=b.half.x+0.04f&&std::abs(foot.z-b.center.z)<=b.half.z+0.04f;
  bool blocked=std::abs(hand.x-b.center.x)<=b.half.x&&std::abs(hand.z-b.center.z)<=b.half.z;
  if(near&&blocked&&b.climbable)return true;}
 return steepSurfaceAhead(p,d);
}
bool PhysicsWorld::steepSurfaceAhead(const PlayerBody& p,const Vec3& dir) const{
 SurfaceHit s=surfaceAt(p,p.position.x+dir.x*0.78f,p.position.z+dir.z*0.78f);
 return s.hit&&s.normal.y>0&&s.normal.y<MAX_SLOPE_COS&&s.climbable;
}
void PhysicsWorld::resolveGround(PlayerBody& p){
 SurfaceHit s=surfaceAt(p,p.position.x,p.position.z);if(!s.hit)return;
 float desired=s.y+p.height*0.5f+0.015f,delta=desired-p.position.y;
 if(delta<=0.10f&&delta>=-0.35f&&p.velocity.y<=1.0f){p.position.y=desired;p.velocity.y=0;p.grounded=true;if(s.normal.y<MAX_SLOPE_COS)p.climbing=true;}
 else p.grounded=false;
}
void PhysicsWorld::step(PlayerBody& p,Vec3 wish,float dt,bool jump,bool sprint){
 dt=std::clamp(dt,0.0f,0.05f);wish.y=0;if(wish.lengthSq()>1)wish=wish.normalized();p.swimming=isWater(p.position.x,p.position.z);
 if(p.swimming){p.climbing=false;float speed=sprint?5:3.5f;Vec3 target=wish*speed;p.velocity.x=moveToward(p.velocity.x,target.x,14*dt);p.velocity.z=moveToward(p.velocity.z,target.z,14*dt);p.velocity.y=moveToward(p.velocity.y,(0.2f-p.position.y)*7,12*dt);p.position+=p.velocity*dt;return;}
 float speed=sprint?7:4.6f;Vec3 target=wish*speed;float accel=p.grounded?30:12;p.velocity.x=moveToward(p.velocity.x,target.x,accel*dt);p.velocity.z=moveToward(p.velocity.z,target.z,accel*dt);
 if(p.grounded&&jump){p.velocity.y=7.2f;p.grounded=false;p.climbing=false;} p.climbing=!jump&&tryClimb(p,wish);if(p.climbing)p.velocity.y=2.6f;else p.velocity.y-=GRAVITY*dt;
 int n=std::clamp(static_cast<int>(std::ceil(dt/INTERNAL_DT)),1,8);float sub=dt/static_cast<float>(n);
 for(int i=0;i<n;++i){Vec3 h{p.velocity.x*sub,0,p.velocity.z*sub};if(!p.climbing&&p.grounded&&tryStep(p,h))continue;Vec3 next=p.position+Vec3{h.x,p.velocity.y*sub,h.z};
  if(!collidesAt(p,next))p.position=next;else{Vec3 x=p.position+Vec3{h.x,0,0},z=p.position+Vec3{0,0,h.z};if(!collidesAt(p,x))p.position=x;else p.velocity.x=0;if(!collidesAt(p,z))p.position=z;else p.velocity.z=0;}}
 resolveGround(p);if(p.climbing)p.grounded=false;
}
}