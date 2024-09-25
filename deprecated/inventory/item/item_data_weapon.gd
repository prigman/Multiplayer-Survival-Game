class_name ItemDataWeapon1 extends ItemData1

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
#@export var weapon_spread_data: PlayerWeaponSpread
@export var recoil_rotation_x: Curve
@export var recoil_rotation_z: Curve
@export var recoil_position_z: Curve
@export var recoil_amplitude := Vector3(1, 1, 1)
@export var lerp_speed: float = 1
@export var recoil_speed: float = 1
@export var sight_mesh: Mesh
@export var muzzle_mesh: Mesh

@export var position : Vector3


func serialize_item_data() -> Dictionary:
	return {
		"quality": quality,
		"damage": damage,
		"ammo_current": ammo_current
	}

func deserialize_item_data(data: Dictionary) -> void:
	quality = data["quality"]
	damage = data["damage"]
	ammo_current = data["ammo_current"]
