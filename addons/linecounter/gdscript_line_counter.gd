@tool
extends EditorPlugin

var top_bar_hbox: HBoxContainer
var loc_button: Button
var line_count:int


func _ready() -> void:
	var editor_title_bar = EditorInterface.get_base_control().get_child(0).get_child(0)
	loc_button = Button.new()
	loc_button.text = "LOC"
	editor_title_bar.add_child(loc_button)
	editor_title_bar.move_child(loc_button, 1)
	loc_button.pressed.connect(clear_line_count)
	loc_button.pressed.connect(read_through_all_directories.bind("res://"))
	line_count = 0


func clear_line_count():
	line_count = 0


func read_through_all_directories(path: String):
	var root_directory = DirAccess.open(path)
	if root_directory:
		root_directory.list_dir_begin()
		var file_name = root_directory.get_next()
		while file_name != "":
			if root_directory.current_is_dir() and file_name != "addons":
				#print("Found directory: " + file_name)
				read_through_all_directories(path + "/" + file_name)
			elif file_name.get_extension() == "gd":
				#print("Found file: " + file_name)
				line_count += count_lines_of_code(path + "/" + file_name)

			file_name = root_directory.get_next()
	else:
		print("An error occurred when trying to access the path.")

	loc_button.text = "LOC: " + str(line_count)


func count_lines_of_code(script_path: String) -> int:
	var lines = 0
	var file = FileAccess.open(script_path, FileAccess.READ)
	var contents = file.get_as_text()
	while not file.eof_reached():
		var next_line = file.get_line()
		if next_line.is_empty():
			continue
		elif next_line.begins_with("#"):
			continue
		elif next_line.begins_with("extends") or next_line.begins_with("class_name"):
			continue
		else:
			lines += 1
	return lines


func _exit_tree() -> void:
	if loc_button:
		loc_button.queue_free()
