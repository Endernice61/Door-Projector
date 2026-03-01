self.SetForwardVector(Vector(1,0,0));
EntFireByHandle(self,"SetParent",::temp_spawner.GetScriptScope().beams[::temp_spawner.GetScriptScope().beams.len()-1].GetName(),0,null,null);
EntFireByHandle(self,"SetLocalOrigin","0 0 0",0,null,null);