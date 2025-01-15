extends AudioStreamPlayer3D


@onready var playback : AudioStreamPlayback = null
var sample_hz := 22050.0

@export var pulse_hz1 := 342.0
var phase1 := 0.0
var increment1 : float

@export var pulse_hz2 := 2.0
var phase2 := 0.0
var increment2 : float

@export var pulse_hz3 := 0.05
var phase3 := 0.0
var increment3 : float
var offset := randf_range(0, TAU)


func _ready():
	stream.mix_rate = sample_hz
	pitch_scale += pitch_scale * randf_range(0.07, -0.07)
	play()
	
	await get_tree().physics_frame
	
	playback = get_stream_playback()
	_set_increments()
	_fill_buffer()


func _set_increments() -> void:
	increment1 = pulse_hz1 / sample_hz
	increment2 = pulse_hz2 / sample_hz
	increment3 = pulse_hz3 / sample_hz


func _process(_delta):
	_fill_buffer()


func _fill_buffer():
	var to_fill = playback.get_frames_available()
	while to_fill > 0:
		playback.push_frame(Vector2.ONE * sin(phase1 * TAU) * \
						cos(phase2 * TAU) * (1.0 + sin(phase3 * TAU + offset) / 2))
		phase1 = fmod(phase1 + increment1, 1.0)
		phase2 = fmod(phase2 + increment2, 1.0)
		phase3 = fmod(phase3 + increment3, 1.0)
		to_fill -= 1
