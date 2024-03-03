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

@export var sight_mesh : Mesh

