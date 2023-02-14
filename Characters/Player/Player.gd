extends KinematicBody2D

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

func _physics_process(_delta):
	var action_jump = Input.is_action_just_pressed("action_jump")
	var action_x = float(Input.is_action_pressed("run_right")) - float(Input.is_action_pressed("run_left"))
	
	if is_on_floor():
		if action_x:
			velocity.x = move_toward(velocity.x, SPEED * action_x, ACCELERATION)
			$AnimatedSprite.flip_h = action_x < 0
			$AnimationPlayer.play("steps")
		else:
			velocity.x = move_toward(velocity.x, 0.0, DRAG_X)
			if !$AnimationPlayer.is_playing():
				$AnimationPlayer.play("idle")
		
		if action_jump:
			velocity.y = -JUMP_Y_SPEED
			$AnimationPlayer.play("jump")
	else:
		velocity.y += Globals.GRAVITY
		if action_x and sign(action_x) == (-1 if $AnimatedSprite.flip_h else 1):
			velocity.x = JUMP_X_SPEED * action_x
	velocity = move_and_slide(velocity, Vector2.UP, false, 2, 0.5)
	var col_shape = $CollisionShape2D.shape as CapsuleShape2D
	position.x = clamp(position.x, col_shape.radius, 960 - col_shape.radius)
	
