$modelname "props_map_editor/hovering_harry/door_projector"
<<<<<<< HEAD
=======
$staticprop
>>>>>>> 99a0a72 (Making puzzlemaker models)
$casttextureshadows
$origin 0 0 0 0
$model mesh "door_projector.smd"
$surfaceprop "glass"
$cdmaterials "models/props_map_editor/plastic"
$cdmaterials "models/props_map_editor/lights"

<<<<<<< HEAD
=======
$collisionmodel "door_projector_phys.smd"
{
	$automass
	$concave
	$remove2d
	$maxconvexpieces 1000000
}


>>>>>>> 99a0a72 (Making puzzlemaker models)
$sequence "idle" {
	"door_projector_anims\idle.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
<<<<<<< HEAD
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
=======
>>>>>>> 99a0a72 (Making puzzlemaker models)
}