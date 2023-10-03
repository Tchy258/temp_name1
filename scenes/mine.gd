extends Node2D

var active: bool = false
var exploding: bool = false
var total_time: int = 160
var beep_max_time: float = 28
var beep_time: float = beep_max_time
var beep_spd: float = 1.22
var light: bool = false
var light_percent: float = 1.0 / 3
var light_max_time: float = beep_max_time * light_percent
var light_time:float = light_max_time

var beep : AudioStreamPlayer
var boom : AudioStreamPlayer
var mine_spr : Sprite2D
var explosion_spr : Sprite2D
var animation : AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	beep = get_node("Beep")
	boom = get_node("Boom")
	mine_spr = get_node("Sprite")
	explosion_spr = get_node("Explosion")
	animation = get_node("Animation")
	explosion_spr.frame = 72

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if active && !exploding:

		# Contador total de tiempo. Al terminar, explota
		if total_time <= 0:
			# queue_free()
			animation.play("Explosion")
			boom.play()
			exploding = true
			mine_spr.frame = 0
			return
		else:
			total_time -= 1

		# Contador del sonido. Se acelera tras cada beep.
		if beep_time <= 0:
			beep.play()
			beep_max_time /= beep_spd
			beep_time = beep_max_time
			mine_spr.frame = 1
			light_max_time = beep_max_time * light_percent
			light_time = light_max_time
		else:
			beep_time -= 1

		# Contador de luz. Se acelera tras cada beep
		if light_time <= 0:
			light = false
			mine_spr.frame = 0
		else: 
			light_time -= 1

func _on_area_2d_body_entered(_body:Node2D):
	if !active && !exploding:
		active = true
		beep.play()
		mine_spr.frame = 1
