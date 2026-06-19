$modelname "props_map_editor/hovering_harry/door_projector"
$casttextureshadows
$origin 0 0 0 0
$model mesh "door_projector.smd"
$surfaceprop "glass"
$cdmaterials "models/props_map_editor/plastic"
$cdmaterials "models/props_map_editor/lights"

$sequence "idle" {
	"door_projector_anims\idle.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
}

$sequence "explodeIn" {
	"door_projector_anims\idle.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
}

$sequence "explodeOut" {
	"door_projector_anims\explodeOut.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
}