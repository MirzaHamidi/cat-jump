extends CanvasLayer

const META_KEY := &"cat_jump_crt_enabled"

@onready var filter_rect: ColorRect = $Filter


func _ready() -> void:
    filter_rect.visible = bool(Engine.get_meta(META_KEY, false))


func _unhandled_key_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo and (event.keycode == KEY_F6 or event.physical_keycode == KEY_F6):
        var enabled := not bool(Engine.get_meta(META_KEY, false))
        Engine.set_meta(META_KEY, enabled)
        filter_rect.visible = enabled
        get_viewport().set_input_as_handled()
