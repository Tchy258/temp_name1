extends ParallaxBackground

func _ready():
	Game.background = self
	if Game.get_current_player().role == Game.Role.ROLE_B:
		scale = 1.25 * Vector2.ONE * 3
