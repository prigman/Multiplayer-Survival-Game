extends ItemData

class_name ItemDataWeapon

@export var item_type : ItemType = ItemType.weapon
@export var weapon_name: String
@export var anim_activate : String
@export var anim_shoot : String
@export var anim_scope : String
@export var anim_reload : String
@export var anim_deactivate : String
@export var anim_out_of_ammo : String

@export var ammo_current : int
@export var ammo_reserve : int
@export var ammo_max: int
@export var magazine : int
@export var damage : float

@export var fire_mode_auto : bool

@export var recoil_rotation_x : Curve
@export var recoil_rotation_z : Curve
@export var recoil_position_z : Curve
@export var recoil_amplitude := Vector3(1,1,1)
@export var lerp_speed : float = 1
@export var recoil_speed : float = 1

