extends TextureRect

@onready var area = $ColorArea

# Called when the node enters the scene tree for the first time.
func _ready():
	area.connect("body_entered",_on_body_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_body_entered(body:Node2D):
	body.modulate = self.modulate
