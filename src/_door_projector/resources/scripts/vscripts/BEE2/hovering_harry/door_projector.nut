/*
EntityGroup:
0: door_entry(linked_portal_door)
1: door_exit(linked_portal_door)
2: projector(info_target) - Where to start projecting from
3: projector_beam_spawner(env_entity_maker) - Spawns a beam
4: door_branch(logic_branch) - False closes the door, True opens it
5: projector_end_spawner(env_entity_maker) - Idk how to turn beams off lol so I just spawn and kill them. This spawns the beams connecting to the door's corners
6: projector_beam_template(point_template) - Template for the beam spawned by projector_beam_spawner
7: door_frame(func_brush) - Frame for the side
8: projector_end_template(point_template) - Template for the end beams
*/

EntGroup <- {
	door_entry = EntityGroup[0],
	door_exit = EntityGroup[1],
	projector = EntityGroup[2],
	projector_beam_spawner = EntityGroup[3],
	door_branch = EntityGroup[4],
	projector_end_spawner = EntityGroup[5],
	projector_beam_template = EntityGroup[6],
	door_frame = EntityGroup[7],
	projector_end_template = EntityGroup[8]
}

function PostSpawn() {
	EntFire("__pgun_port_detect_*","AddOutput","OnEndTouchPortal "+self.GetName()+",RunScriptCode,placeBlue(),0.01,-1",0,null);
	//EntFire("__pgun_port_detect_*","AddOutput","OnStartTouchPortal "+self.GetName()+",RunScriptCode,placeBlue(),0.01,-1",0,null);
	
	EntGroup.projector_beam_template.ValidateScriptScope();
	EntGroup.projector_beam_template.GetScriptScope().door_projector <- self;
	EntGroup.projector_end_template.ValidateScriptScope();
	EntGroup.projector_end_template.GetScriptScope().door_projector <- self;
}

beams <- [];
enabled <- 0;
self.ValidateScriptScope();

const PROJECTION_DISTANCE = 3200;
const HALF_HEIGHT = 51.47;
const HALF_WIDTH = 27.47;

DoIncludeScript("BEE2/hovering_harry/utils",this);

function placeBlue() {
	if (enabled) project(getPosition(EntGroup.projector),0);
}

function placeOrange() {
	if (enabled) project(getPosition(EntGroup.projector),0);
}

function enable() {
	enabled <- 1;
	placeOrange();
}

function disable() {
	enabled <- 0;
	while (beams.len() > 0) {
		beams.pop().GetScriptScope().remove();
	}
	close();
}

function projectThroughPortal(portal,entry_point,depth) {
	local projector = findLinkedPortal(portal);
	
	if (projector == null || projector.GetScriptScope().__pgun_active == 0) {
		while (beams.len() > depth) {
			beams.pop().GetScriptScope().remove();
		}
		close();
		return;
	}

	project(reposition(entry_point,getPositionO(portal),getPositionO(projector)),depth);
}

function getDoorCenter() {
	return (EntGroup.door_exit.GetOrigin()+EntGroup.door_entry.GetOrigin())*0.5;
}

function getDoorDifference() {
	return EntGroup.door_exit.GetOrigin()-EntGroup.door_entry.GetOrigin();
}

function getDoorDistance() {
	return getDoorDifference().Length();
}

function getDoorBounds() {
	return absvec(getDoorDifference()*0.5+EntGroup.door_entry.GetLeftVector()*32+EntGroup.door_entry.GetUpVector()*64);
}

function getDoorCuboid() {
	local dist = getDoorDistance();
	return CuboidDirEnt(getDoorCenter(),EntGroup.door_entry,Vector(-32,-64,dist/-2),Vector(32,64,dist/2));
}

//Gets the player p unstuck
function unstuck(p) {
	local hole_pos = getDoorCenter();
	
	local door_cuboid = getDoorCuboid();
	local player_cuboid = getAxisAlignedCuboid(p);
	
	if (!door_cuboid.intersectCuboid(player_cuboid)) { return; }
	//print("Unstucking the player!\n");

	local smallest = player_cuboid.bestVertex(door_cuboid.forward,function(a,b) { return -b.Dot(a); });
	local biggest = player_cuboid.bestVertex(door_cuboid.forward,function(a,b) { return b.Dot(a); });
	
	smallest = door_cuboid.forward.Dot(hole_pos)-door_cuboid.forward.Dot(smallest);
	biggest = door_cuboid.forward.Dot(hole_pos)-door_cuboid.forward.Dot(biggest);
	
	if (abs(smallest)<abs(biggest)) {
		p.SetOrigin(p.GetOrigin()+door_cuboid.forward*(smallest+getDoorDistance()/2+0.03));
	} else {
		p.SetOrigin(p.GetOrigin()+door_cuboid.forward*(biggest-getDoorDistance()/2-0.03));
	}
}

function close() {
	EntFireByHandle(EntityGroup[4],"SetValueTest","0",0,null,null);
	
	if (IsMultiplayer()) {
		local blue = Entities.FindByClassname(null, "player");
		unstuck(blue);
		unstuck(Entities.FindByClassname(blue, "player"));
	} else unstuck(player);
}

function canGoThroughPortal(e,pos) {
	if (e.GetScriptScope().__pgun_active == 0) { return false; }
	local cuboid = getCuboid(e);
	cuboid.mins.x = -1;
	cuboid.maxs.x = 1;
	return cuboid.pointInside(pos);
}

function TraceAll(origin, dir, distance) {
	local hit = TraceLine(origin,origin+dir*distance,null);
	hit *= distance;
	local hit_barrier = ::BEE_TraceRay(origin,dir*distance,::BEECollide.GLASS+::BEECollide.GRATING);
	if (hit_barrier == null) { hit_barrier = distance; }
	else { hit_barrier = hit_barrier.distance; }
	return min(hit,hit_barrier);
}

function assignBeamTemplate(projector,hit) {
	EntGroup.projector_beam_template.GetScriptScope().door_projector <- self;
	EntGroup.projector_beam_template.GetScriptScope().projecting_entity <- projector;
	EntGroup.projector_beam_template.GetScriptScope().distance <- hit;
}

//Empty space check in an X shape in a 28x52 area 4 units behind the wall
function xAvailable(projector) {
	local left = projector.left;
	local up = projector.up;
	local origin = projector.center;
	local dir = projector.forward;
	local hit = TraceLine(origin+dir*4-up*HALF_HEIGHT-left*HALF_WIDTH,origin+dir*4+up*HALF_HEIGHT+left*HALF_WIDTH,null);
	if (hit < 1) { return false; }
	hit = TraceLine(origin+dir*4+up*HALF_HEIGHT-left*HALF_WIDTH,origin+dir*4-up*HALF_HEIGHT+left*HALF_WIDTH,null);
	if (hit < 1) { return false; }
	return true;
}

function project(projector,depth) {
	//close();

	local dir = projector.forward;
	local origin = projector.center;
		/*print("Direction: ");print(dir);print("Origin: ");print(origin);*/

	local hit = TraceAll(origin,dir,PROJECTION_DISTANCE);
	
	origin += dir*hit;

	if (beams.len() <= depth) {
		assignBeamTemplate(projector,hit);
		EntGroup.projector_beam_spawner.SpawnEntity();
	} else if ((projector.center - beams[depth].GetCenter()).LengthSqr() >= 1) {
		close();
		while (beams.len() > depth) {
			beams.pop().GetScriptScope().remove();
		}
		assignBeamTemplate(projector,hit);
		EntGroup.projector_beam_spawner.SpawnEntity();
	}
	

	projector.center = origin;

	for (local portal = Entities.FindByClassnameWithin(null,"prop_portal",origin,96); portal != null; portal = Entities.FindByClassnameWithin(portal,"prop_portal",origin,128)) {
		if (canGoThroughPortal(portal,origin)) {
			projectThroughPortal(portal,projector,depth+1);
			return;
		}
	}

	while (beams.len() > depth+1) {
		beams.pop().GetScriptScope().remove();
	}
	close();

	//Empty space check in an X shape in a 28x52 area 4 units behind the wall
	if (!xAvailable(projector)) { return; }
	
	EntFireByHandle(beams[depth],"SetLocalOrigin",(projector.forward*(hit-64)).ToKVString(),0,null,null);

	EntGroup.projector_end_template.GetScriptScope().door_projector <- self;
	EntGroup.projector_end_template.GetScriptScope().projecting_entity <- projector;
	EntGroup.projector_end_spawner.SpawnEntity();

	hit = TraceAll(origin+dir*4,dir*-1,4)/4;
	local dist = (1-hit)*4;
	EntGroup.door_entry.SetOrigin(origin-dir);
	EntGroup.door_exit.SetOrigin(origin+dir*dist+dir);
	EntGroup.door_entry.SetForwardVector(dir*-1);
	EntGroup.door_exit.SetForwardVector(dir);
	EntFireByHandle(EntGroup.door_branch,"SetValueTest","1",0,null,null);
	if (dist > 2) {
		EntGroup.door_frame.SetOrigin(origin+dir*(dist/2));
		EntGroup.door_frame.SetForwardVector(dir);
		EntFireByHandle(EntGroup.door_frame,"Enable","",0.01,null,null);
	}

	function clip(offset,up,action) {
		if (TraceAll(offset+up*56,up,9) < 9) {
			EntFireByHandle(EntGroup.door_branch,action,"",0,null,null);
		}
	}
	//Entry bottom clip
	clip(origin-dir,projector.up*-1,"FireUser3");
	//Exit bottom clip
	clip(origin+dir*(1+dist),projector.up*-1,"FireUser1");
	//Entry top clip
	clip(origin-dir,projector.up,"FireUser4");
	//Exit top clip
	clip(origin+dir*(1+dist),projector.up,"FireUser2");
}