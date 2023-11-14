extends Button


signal emit_self
@export var trap: TrapManager.traps
@export var trap_props: Dictionary = {
	"scale": Vector2(1,1),
	"can_be_rotated": false
}
@export var action_name: String
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if is_multiplayer_authority() and Input.is_action_just_pressed(action_name):
		_on_button_pressed()

func _on_button_pressed():
	emit_self.emit(self)
	disabled = true
