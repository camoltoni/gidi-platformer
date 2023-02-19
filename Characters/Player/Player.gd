extends KinematicBody2D

enum States {AIR, FLOOR, LADDER, WALL}

var state = States.AIR

var velocity = Vector2()

export(float, 0.5, 2.0, 0.1) var speed_factor = 1.0
export(float, 0.5, 10.0, 0.1) var jump_y_factor = 2.8
export(float, 0.1, 1.0, 0.1) var jump_x_factor = 0.66
export(float, 5.0, 50.0, 1.0) var accel_factor = 10.0
export(float, 1.0, 40.0, 1.0) var drag_x_factor = 20.0

var SPEED = Globals.BASE_SPEED * speed_factor
var JUMP_Y_SPEED = SPEED * jump_y_factor
var JUMP_X_SPEED = SPEED * jump_x_factor
var ACCELERATION = SPEED / accel_factor
var DRAG_X = SPEED / drag_x_factor

var isOnFloor = false

onready var update_func = funcref(self, "on_air")

func _physics_process(_delta):
	var action_jump = Input.is_action_just_pressed("action_jump")
	var action_x = float(Input.is_action_pressed("run_right")) - float(Input.is_action_pressed("run_left"))
	
	update_func.call_funcv([action_x, action_jump])
	
	velocity.y += Globals.GRAVITY
	velocity = move_and_slide(velocity, Vector2.UP, false, 2, 0.5)
	var col_shape = $CollisionShape2D.shape as CapsuleShape2D
	position.x = clamp(position.x, col_shape.radius, 960 - col_shape.radius)

func on_air(run_status:float, _jump_status:bool):
	if is_on_floor():
		update_func.function = "on_floor"
	else:
		if run_status and sign(run_status) == (-1 if $AnimatedSprite.flip_h else 1):
			velocity.x = JUMP_X_SPEED * run_status

func on_floor(run_status:float, jump_status:bool):
	if jump_status:
		velocity.y = -JUMP_Y_SPEED
		$AnimationPlayer.play("jump")
		update_func.function = "on_air"
	else:
		if run_status:
			velocity.x = move_toward(velocity.x, SPEED * run_status, ACCELERATION)
			$AnimatedSprite.flip_h = run_status < 0
			$AnimationPlayer.play("steps")
		else:
			velocity.x = move_toward(velocity.x, 0.0, DRAG_X)
			$AnimationPlayer.play("idle")
