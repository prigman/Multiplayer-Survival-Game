class_name ItemDataWeapon extends ItemData

@export var item_type: ItemType = ItemType.weapon
@export var anim_activate: String
@export var anim_scope: String
@export var anim_reload: String
@export var anim_idle: String
@export var anim_player_activate: String
@export var anim_player_scope: String
@export var anim_player_reload: String
@export var anim_player_idle: String

@export var ammo_current: int
@export var ammo_max: int
@export var damage: float

@export var weapon_type: WeaponType

@export var fire_modes: Array[WeaponFireModes]
@export var fire_mode_current: WeaponFireModes

@export var recoil_rotation_x: Curve
@export var recoil_rotation_z: Curve
@export var recoil_position_z: Curve
@export var recoil_amplitude := Vector3(1, 1, 1)
@export var lerp_speed: float = 1
@export var recoil_speed: float = 1
@export var sight_mesh: Mesh
@export var muzzle_mesh: Mesh

@export var position : Vector3
