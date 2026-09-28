#include "PhysicsWorld.h"
#include <cassert>
#include <cmath>
using namespace odyssey;

static void tick(PhysicsWorld& w, PlayerBody& p, Vec3 wish, int frames){
    for(int i=0;i<frames;++i) w.step(p,wish,1.0f/60.0f,false,false);
}

int main(){
    {
        PhysicsWorld w;
        w.addBox({{0,0.15f,2.0f},{1.5f,0.15f,0.5f},true});
        PlayerBody p; p.position={0,0.875f,0}; p.grounded=true;
        tick(w,p,{0,0,1},60);
        assert(p.position.z>2.0f);
        assert(std::abs((p.position.y-p.height*0.5f)-0.3f)<0.08f);
        assert(p.grounded);
    }
    {
        PhysicsWorld w;
        w.addRamp({{0,1.6f,5.0f},{3.0f,1.6f,4.5f},3.2f,true});
        PlayerBody p; p.position={0,0.875f,0}; p.grounded=true;
        tick(w,p,{0,0,1},90);
        assert(p.climbing || p.position.y>1.0f);
    }
    {
        PhysicsWorld w;
        PlayerBody p; p.position={0,0.875f,-5.5f}; p.grounded=true;
        tick(w,p,{0,0,-1},30);
        assert(p.swimming);
        assert(p.position.y<1.0f);
    }
    return 0;
}
