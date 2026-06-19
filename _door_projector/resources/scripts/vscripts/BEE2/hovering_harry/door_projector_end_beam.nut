function setLocal(x,y,z) {
	EntFireByHandle(self,"SetLocalOrigin",(::temp_projector.left*x+::temp_projector.up*y+::temp_projector.forward*z).ToKVString(),0,null,null);
}