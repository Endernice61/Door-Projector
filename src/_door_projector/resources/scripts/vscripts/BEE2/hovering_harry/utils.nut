DoIncludeScript("BEE2/hovering_harry/cuboid",this);
DoIncludeScript("BEE2/hovering_harry/matrix",this);

class Position {
	center = Vector(0,0,0)
	forward = Vector(0,0,1)
	left = Vector(1,0,0)
	up = Vector(0,1,0)
	constructor(c, f, l, u) {
		center = c
		forward = f
		left = l
		up = u
	}
}

function getPosition(e) {
	return Position(e.GetCenter(), e.GetForwardVector(), e.GetLeftVector(), e.GetUpVector());
}

function getPositionO(e) {
	return Position(e.GetOrigin(), e.GetForwardVector(), e.GetLeftVector(), e.GetUpVector());
}

::HH_GetPosition <- getPosition.bindenv(this);
::HH_GetPositionO <- getPositionO.bindenv(this);

function min(first, second) {
	if (first < second) return first;
	return second;
}

function findLinkedPortal(portal) {
	foreach (pair in ::BEE_GetPortalPairs()) {
		if (pair[0] == portal) return pair[1];
		if (pair[1] == portal) return pair[0];
	}
	return null;
}

function reposition(position,source,out) {
	local reposition = clone(out);
	local relative = position.center - source.center;
	local left_origin = source.left.Dot(relative);
	local up_origin = source.up.Dot(relative);
	reposition.center += out.up*up_origin-out.left*left_origin;

	return reposition;
}

function absvec(vec) {
	return Vector(abs(vec.x),abs(vec.y),abs(vec.z));
}