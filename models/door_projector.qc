$modelname "props_map_editor/hovering_harry/door_projector"
<<<<<<< HEAD
<<<<<<< HEAD
=======
$staticprop
>>>>>>> 99a0a72 (Making puzzlemaker models)
=======
>>>>>>> 3dc5b88 (Fix orientation)
$casttextureshadows
$origin 0 0 0 0
$model mesh "door_projector.smd"
$surfaceprop "glass"
$cdmaterials "models/props_map_editor/plastic"
$cdmaterials "models/props_map_editor/lights"

<<<<<<< HEAD
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
=======
>>>>>>> cc621c0 (Remove collision model)
$sequence "idle" {
	"door_projector_anims\idle.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> 4d464b0 (Add explode anims)
}

$sequence "explodeIn" {
	"door_projector_anims\idle.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
}

$sequence "explodeOut" {
<<<<<<< HEAD
<<<<<<< HEAD
	"door_projector_anims\explodeOut.smd"
	fadein 0.2
	fadeout 0.2
	fps 30
=======
>>>>>>> 99a0a72 (Making puzzlemaker models)
=======
	"door_projector_anims\idle.smd"
=======
	"door_projector_anims\explodeOut.smd"
>>>>>>> 3dc5b88 (Fix orientation)
	fadein 0.2
	fadeout 0.2
	fps 30
>>>>>>> 4d464b0 (Add explode anims)
}