@tool
extends Button

signal option_selected(option: String)
@onready var panel := PanelContainer.new()
@onready var margin := MarginContainer.new()
@onready var vbox := VBoxContainer.new()


@export var items: Array[String]:
	set(value):
		items = value
		if vbox:
			for child in vbox.get_children():
				vbox.remove_child(child)
				child.queue_free()
			for item in items:
				var button = Button.new()
				button.text = item
				button.pressed.connect(_on_option_selected.bind(item))
				var prev_button := vbox.get_child(vbox.get_child_count() - 1) as Button
				vbox.add_child(button)
				if prev_button:
					prev_button.focus_neighbor_bottom = button.get_path()
					button.focus_neighbor_top = prev_button.get_path()
			if vbox.get_child_count():
				var first_button := vbox.get_child(0) as Button
				var last_button := vbox.get_child(vbox.get_child_count() - 1) as Button
				first_button.focus_neighbor_top = last_button.get_path()
				last_button.focus_neighbor_bottom = first_button.get_path()

		if panel:
			panel.size = Vector2.ZERO
			# await get_tree().process_frame
			size.x = panel.size.x
			print(panel.size.x)


func _ready() -> void:

	# comment if using theme
	###
	var separation = 4
	margin.add_theme_constant_override("margin_top", separation)
	margin.add_theme_constant_override("margin_left", separation)
	margin.add_theme_constant_override("margin_bottom", separation)
	margin.add_theme_constant_override("margin_right", separation)
	vbox.add_theme_constant_override("separation", separation)
	###

	add_child(panel)
	panel.add_child(margin)
	margin.add_child(vbox)
	pressed.connect(_on_select_pressed)
	panel.hide()
	text = " "
	await get_tree().process_frame
	text = ""
	items = items
	text = "Choose a stage"

func _on_select_pressed():
	if not panel.visible:
		var new_position_y = global_position.y + size.y
		if new_position_y + panel.size.y > get_viewport_rect().size.y:
			new_position_y = get_viewport_rect().size.y - panel.size.y
		panel.global_position.y = new_position_y
		if vbox.get_child_count():
			focus_neighbor_top = vbox.get_child(vbox.get_child_count() - 1).get_path()
	panel.visible = !panel.visible


func _on_option_selected(option: String) -> void:
	text = option
	option_selected.emit(option)
	panel.hide()
	grab_focus()
	focus_neighbor_top = NodePath("")
