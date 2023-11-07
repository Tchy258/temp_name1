extends Button


signal emit_self
@export var trap: TrapManager.traps
@export var trap_props: Dictionary = {
	"scale": Vector2(1,1),
	"can_be_rotated": false
}
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_button_pressed():
	emit_self.emit(self)
	disabled = true
