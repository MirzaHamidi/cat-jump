class_name ApartmentChunk
extends Node2D

const CHUNK_HEIGHT: float = 800.0

@export var chunk_id: StringName = &""
@export_range(1, 10, 1) var difficulty: int = 1

@onready var entry_point: Marker2D = $EntryPoint
@onready var exit_point: Marker2D = $ExitPoint
