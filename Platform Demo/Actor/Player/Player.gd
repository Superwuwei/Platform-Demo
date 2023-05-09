extends KinematicBody2D

var Gravity = 10
var Speed = Vector2(80, 200)
var Velocity = Vector2.ZERO
var can_jump = false
var PushTime = 0
var Pushed = false
var PushDIR = 0
var PushForce = 200
const SSlotP = [-896, -697, -498, -299, -100, 99, 298, 497, 696, 895]
const MaxPushForce = 100
const PushMaxTime = 20
const LMRItemRPos = [Vector2(-9,4), Vector2(9,4)]
const WALL_SLIDE_ACCELERATION = 50
const MAX_WALL_SLIDE_SPEED = 120

onready var SSlotPos = $Slots/SSlot

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
		
	if event.is_action_pressed("0"):
		SSlotPos.position.x = SSlotP[9]
	elif event.is_action_pressed("1"):
		SSlotPos.position.x = SSlotP[0]
	elif event.is_action_pressed("2"):
		SSlotPos.position.x = SSlotP[1]
	elif event.is_action_pressed("3"):
		SSlotPos.position.x = SSlotP[2]
	elif event.is_action_pressed("4"):
		SSlotPos.position.x = SSlotP[3]
	elif event.is_action_pressed("5"):
		SSlotPos.position.x = SSlotP[4]
	elif event.is_action_pressed("6"):
		SSlotPos.position.x = SSlotP[5]
	elif event.is_action_pressed("7"):
		SSlotPos.position.x = SSlotP[6]
	elif event.is_action_pressed("8"):
		SSlotPos.position.x = SSlotP[7]
	elif event.is_action_pressed("9"):
		SSlotPos.position.x = SSlotP[8]

func _physics_process(delta):
	$PlayerItem.look_at(get_global_mouse_position())
	
	if get_global_mouse_position().x >= position.x+9:
		$PlayerItem.position = LMRItemRPos[1]
		$PlayerItem/Sprite.flip_v = false
		$PlayerItem/Sprite.position = Vector2(LMRItemRPos[1].x + 2, 0)
	elif get_global_mouse_position().x <= position.x-9:
		$PlayerItem.position = LMRItemRPos[0]
		$PlayerItem/Sprite.flip_v = true
		$PlayerItem/Sprite.position = Vector2(LMRItemRPos[0].x + 20, 0)
	
	var Dir = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	Velocity.x = Speed.x * Dir
	
	if is_on_wall() and (Input.is_action_pressed("ui_left")||Input.is_action_pressed("ui_right")):
		can_jump = true
		if Velocity.y >= 0:
			Velocity.y = min(Velocity.y + WALL_SLIDE_ACCELERATION, MAX_WALL_SLIDE_SPEED)
		else:
			Velocity.y += Gravity
	else:
		Velocity.y += Gravity
	
	if Input.is_action_just_pressed("ui_up") and can_jump:
		Velocity.y = -Speed.y
		if is_on_wall() and Input.is_action_pressed("ui_left"):
			Pushed = true
			PushDIR = 1
		elif is_on_wall() and Input.is_action_pressed("ui_right"):
			Pushed = true
			PushDIR = -1
	
	if Pushed and PushTime < PushMaxTime:
		PushForce -= PushTime
		Velocity.x += PushForce * PushDIR
		PushTime += 1
	else:
		PushForce = MaxPushForce
		Pushed = false
		PushTime = 0
		PushDIR = 0
	
	if is_on_floor():
		can_jump = true
	elif not (is_on_floor() and is_on_wall()):
		can_jump = false
	
	Velocity = move_and_slide(Velocity, Vector2.UP)
