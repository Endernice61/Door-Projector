//self.ValidateScriptScope();

/*self.SetOrigin(::temp_projector.center+::temp_projector.forward*::temp_distance);
self.SetForwardVector(::temp_projector.forward);*/

//self.GetMoveParent().SetOrigin(::temp_projector.center);
//self.GetMoveParent().SetForwardVector(Vector(1,0,0));
//EntFireByHandle(self,"SetLocalOrigin",(::temp_projector.forward*::temp_distance).ToKVString(),0,null,null);

//::temp_spawner.GetScriptScope().beams.push(self);

function remove() {
	EntFireByHandle(self.GetMoveParent(),"Kill","",0,null,null);
}

function moveBack() {
	EntFireByHandle(self,"SetLocalOrigin",(::temp_projector.forward*(::temp_distance-64)).ToKVString(),0,null,null);
}