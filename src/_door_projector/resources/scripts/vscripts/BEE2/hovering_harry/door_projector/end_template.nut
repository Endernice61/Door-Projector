door_projector <- null;
projecting_entity <- null;
distance <- 0;

function PostSpawn(entities) {
	local positions = [Vector(30,54,63),Vector(-30,54,63),Vector(-30,-54,63),Vector(30,-54,63)];
	foreach (targetname, handle in entities) {
		if (handle.GetClassname() == "env_sprite") {
			handle.SetForwardVector(Vector(1,0,0));			EntFireByHandle(handle,"SetParent",door_projector.GetScriptScope().beams[door_projector.GetScriptScope().beams.len()-1].GetName(),0,null,null);
			EntFireByHandle(handle,"SetLocalOrigin","0 0 0",0,null,null);
		} else if (handle.GetClassname() == "env_beam") {
			local pos = positions.pop();
			EntFireByHandle(handle,"SetLocalOrigin",
				(projecting_entity.left*pos.x+projecting_entity.up*pos.y+projecting_entity.forward*pos.z)
			.ToKVString(),0,null,null);
		}
	}
}

function PreSpawnInstance(classname,targetname) {}