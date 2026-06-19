function axisAlignedVec(vec) {
	local zeros = 0;
	if (vec.x == 0) zeros += 1;
	if (vec.y == 0) zeros += 1;
	if (vec.z == 0) zeros += 1;
	if (zeros == 2) return true;
	return false;
}
getroottable().axisAlignedVec <- axisAlignedVec;
getroottable().getx <- function(vec) { return vec.x; }
getroottable().gety <- function(vec) { return vec.y; }
getroottable().getz <- function(vec) { return vec.z; }
function vectonator(vec1,vec2) {
	if (vec1.x > vec2.x) { return false; }
	if (vec1.y > vec2.y) { return false; }
	if (vec1.z > vec2.z) { return false; }
	return true;
}
getroottable().allLessThan <- vectonator;
class Segment {
	origin = Vector(0,0,0)
	destination = Vector(1,0,0)
	constructor(o,d) {
		origin = o
		destination = d
	}
}
getroottable().Plane <- class {
	norm = Vector(1,0,0)
	dist = 0
	constructor(n,d) {
		norm = n
		dist = d
	}
	
	function traceRay(start, end) {
		local s = norm.Dot(start);
		local e = norm.Dot(end);

		local d = dist-s;
		e -= s;
		
		if (e == 0.0) { return -9999.0; }
		return d/e;
	}
	function tostring() {
		return "Plane: \n\tNormal: "+norm.tostring()+"\n\tDistance: "+dist;
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
		if (axisAlignedVec(forward) && axisAlignedVec(left) && axisAlignedVec(up)) return true;
		return false;
	}
	function pointInside(point) {
		local relative = point-origin;
		foreach (i in [[forward,getx],[left,gety],[up,getz]]) {
			local away = i[0].Dot(relative);
			if (away<i[1](mins)) { return false; }
			if (away>i[1](maxs)) { return false; }
		}
		return true;
	}
	function center() {
		return origin+(forward*mins.x+forward*maxs.x)*0.5+(left*mins.y+left*maxs.y)*0.5+(up*mins.z+up*maxs.z)*0.5;
	}
	function Planes() {
		if (planes != null) return planes;
		planes = [];
		foreach (i in [[forward,getx],[left,gety],[up,getz]]) {
			planes.push(Plane(i[0]*-1,-i[0].Dot(origin)-i[1](mins)));
			planes.push(Plane(i[0],i[0].Dot(origin)+i[1](maxs)));
		}
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
	function closestVertex(vec) {
		local closest_vertex = origin;
		foreach (i in [[forward,getx],[left,gety],[up,getz]]) {
			if (vec.Dot(i[0])<0) {
				closest_vertex += i[0]*i[1](maxs);
			} else {
				closest_vertex += i[0]*i[1](mins);
			}
		}
		return closest_vertex;
	}
	function minDot(vec) {
		local closest = vec.Dot(origin);
		foreach (i in [[forward,getx],[left,gety],[up,getz]]) {
			local dot = vec.Dot(i[0]);
			if (dot<0) {
				closest += dot*i[1](maxs);
			} else {
				closest += dot*i[1](mins);
			}
		}
		return closest;
	}
	function outside(plane) {
		return plane.dist<minDot(plane.norm);
	}
	function separates(vec,cuboid) {
		if (vec.LengthSqr()==0) { return false; }
		local invec = vec*-1;
		local bound1 = minDot(vec);
		local bound2 = -minDot(invec);
		local cubound1 = cuboid.minDot(vec);
		if ((bound1<cubound1)!=(bound2<cubound1)) { return false; }
		local cubound2 = -cuboid.minDot(invec);
		if ((bound1<cubound2)!=(bound2<cubound2)) { return false; }
		return (bound1<cubound1)==(bound1<cubound2);//It is sufficient to check three
	}
	function intersectCuboid(cuboid) {
		foreach (p in Planes()) {
			if (cuboid.outside(p)) {
				/*	printl("First cuboid's planes proved the two cuboids do not intersect: ");
					printl(cuboid.tostring());
					printl(p.tostring());*/
				return false;
			}
		}
		foreach (p in cuboid.Planes()) {
			if (outside(p)) {
				/*	printl("Second cuboid's planes proved the two cuboids do not intersect: ");
					printl(tostring());
					printl(p.tostring());*/
				return false;
			}
		}
		foreach (i in [forward,left,up]) {
			foreach (j in [cuboid.forward,cuboid.left,cuboid.up]) {
				if (separates(i.Cross(j),cuboid)) {
					/*	printl("Found plane that separates the two cuboids: ");
						printl("\tNormal: "+i.Cross(j).tostring());
						printl(tostring());
						printl(cuboid.tostring());*/
					return false;
				}
			}
		}
		//printl("\nCuboids intersect!\n");
		return true;
	}
	function intersectAABBCuboids(cuboid) {
		if (!allLessThan(mins+origin,cuboid.maxs+cuboid.origin)) { return false; }
		if (!allLessThan(cuboid.mins+cuboid.origin,maxs+origin)) { return false; }
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
		local str = "Cuboid: \n\tOrigin: "+origin.tostring()+"\n\tVertices: ";
		foreach (i in Vertices()) {
			str += "\n\t\t"+i.tostring();
		}
		return str;
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