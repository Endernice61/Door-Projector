function axisAlignedVec(vec) {
	local zeros = 0;
	if (vec.x == 0) zeros += 1;
	if (vec.y == 0) zeros += 1;
	if (vec.z == 0) zeros += 1;
	if (zeros == 2) return true;
	return false;
}
::axisAlignedVec <- axisAlignedVec;
class Plane {
	norm = Vector(1,0,0)
	dist = 0
	constructor(n,d) {
		norm = o
		dist = d
	}
}
class Cuboid {
	origin = Vector(0,0,0)
	forward = Vector(1,0,0)
	left = Vector(0,1,0)
	up = Vector(0,0,1)
	mins = Vector(0,0,0)
	maxs = Vector(1,1,1)
	planes = null;
	axis_aligned = false;
	constructor(o, min, max) {
		origin = o
		forward = Vector(1,0,0)
		left = Vector(0,1,0)
		up = Vector(0,0,1)
		mins = min
		maxs = max
		axis_aligned = true
	}
	function axisAligned() {
		if (::axisAlignedVec(forward) && ::axisAlignedVec(left) && ::axisAlignedVec(up)) return true;
		return false;
	}
	function pointInside(point) {
		local relative = point-origin;
		if (forward.Dot(relative-forward*mins.x)<0) return false;
		if (left.Dot(relative-left*mins.y)<0) return false;
		if (up.Dot(relative-up*mins.z)<0) return false;
		if (forward.Dot(relative-forward*maxs.x)>0) return false;
		if (left.Dot(relative-left*maxs.y)>0) return false;
		if (up.Dot(relative-up*maxs.z)>0) return false;
		return true;
	}
	function center() {
		return origin+(forward*mins.x+forward*maxs.x)*0.5+(left*mins.y+left*maxs.y)*0.5+(up*mins.z+up*maxs.z)*0.5;
	}
	function planes() {
		if (planes != null) return planes;
		planes = [];
		planes.push(Plane(forward*-1,-forward.Dot(origin)-mins.x));
		planes.push(Plane(left*-1,-left.Dot(origin)-mins.y));
		planes.push(Plane(up*-1,-up.Dot(origin)-mins.z));
		planes.push(Plane(forward,forward.Dot(origin)+maxs.x));
		planes.push(Plane(left,left.Dot(origin)+maxs.y));
		planes.push(Plane(up,up.Dot(origin)+maxs.z));
		return planes;
	}
	function AABB() {
		
	}
	function bestVertex(value,score) {
		//print("I am: ");
		//printl(this);
		local first = 1;
		local best = null;
		local best_score = 0;
		foreach (i in Vertices()) {
			if (first) {
				first = 0;
				best = i;
				best_score = score(i,value);
			} else if (score(i,value) > best_score) {
				best = i;
				best_score = score(i,value);
			}
		}
		return best;
	}
	function intersectCuboid(cuboid) {
		if (pointInside(cuboid.origin)) return true;
		if (cuboid.pointInside(origin)) return true;
		//Assert(axis_aligned, "Not implemented");
		if (axis_aligned && cuboid.axis_aligned) { return intersectAABBCuboids(cuboid); }
		//If they do not intersect, a plane exists in which one cuboid is completely on one side while the other is on the other side
		local important = center()-cuboid.center();//A normal of a plane which is likely to not interect, we can "tip" the plane later
		/*	print("Important: ");
			printl(important);*/
		local best = bestVertex(important,function(a,b) { return -a.Dot(b); });
		local bestdot = important.Dot(best);
		/*	print("Best: ");
			print(best);*/
		local otherbest = cuboid.bestVertex(important,function(a,b) { return a.Dot(b); });
		local otherbestdot = important.Dot(otherbest);
		/*	print("\nOther best: ");
			printl(otherbest);*/
		if (bestdot > otherbestdot) return false;
		//Tip the plane
		local parallel = best-otherbest;
		parallel.Norm();
		local normal = important-parallel*parallel.Dot(important);//Does not need to be normalized
		bestdot = normal.Dot(best);
		foreach (i in Vertices()) {
			if (normal.Dot(i) < bestdot) return true;
		}
		foreach (i in cuboid.Vertices()) {
			if (normal.Dot(i) > bestdot) return true;
		}
		return false;
	}
	function intersectAABBCuboids(cuboid) {
		if (mins.x+origin>cuboid.maxs.x+cuboid.origin) return false;
		if (mins.y+origin>cuboid.maxs.y+cuboid.origin) return false;
		if (mins.z+origin>cuboid.maxs.z+cuboid.origin) return false;
		if (maxs.x+origin<cuboid.mins.x+cuboid.origin) return false;
		if (maxs.y+origin<cuboid.mins.y+cuboid.origin) return false;
		if (maxs.z+origin<cuboid.mins.z+cuboid.origin) return false;
		return true;
	}
	function Vertices() {
		local vertices = [];
		local f = [forward*mins.x,forward*maxs.x];
		local l = [left*mins.y,left*maxs.y];
		local u = [up*mins.z,up*maxs.z];
		local v = 0;
		while (v<8) {
			vertices.push(origin+f[v&1]+l[v&2>>1]+u[v&4>>2]);
			v += 1;
		}
		return vertices;
	}
	function tostring() {
		return "cuboid: origin: "+origin.tostring();
	}
}

function CuboidDirEnt(o, e, min, max) {
	local construct = Cuboid(o,min,max);
	construct.forward = e.GetForwardVector();
	construct.left = e.GetLeftVector();
	construct.up = e.GetUpVector();
	construct.axis_aligned = construct.axisAligned();
	return construct;
}
function CuboidDir(o, f, l, u, min, max) {
	local construct = Cuboid(o,min,max);
	construct.forward = f;
	construct.left = l;
	construct.up = u;
	construct.axis_aligned = construct.axisAligned();
	return construct;
}

function getCuboid(e) {
	return CuboidDir(e.GetOrigin(), e.GetForwardVector(), e.GetLeftVector(), e.GetUpVector(), e.GetBoundingMins(), e.GetBoundingMaxs());
}

function getAxisAlignedCuboid(e) {
	return Cuboid(e.GetOrigin(),e.GetBoundingMins(), e.GetBoundingMaxs());
}