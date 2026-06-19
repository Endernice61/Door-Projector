door_projector <- null;
projecting_entity <- null;
distance <- 0;


function PostSpawn(entities) {
	foreach (targetname, handle in entities) {
		if (handle.GetClassname() == "logic_script") {
			handle.ValidateScriptScope();
			door_projector.GetScriptScope().beams.push(handle);
			EntFireByHandle(handle,"SetLocalOrigin",(projecting_entity.forward*distance).ToKVString(),0,null,null);
			handle.GetScriptScope().remove <- function() { EntFireByHandle(self.GetMoveParent(),"Kill","",0,null,null); };
		} else if (handle.GetClassname() == "env_beam") {
			handle.SetOrigin(projecting_entity.center);
			handle.SetForwardVector(Vector(1,0,0));
		}
		//printl(targetname + ": "+handle);
	}
}

function PreSpawnInstance(classname,targetname) {
	//printl(classname+": "+targetname);
}