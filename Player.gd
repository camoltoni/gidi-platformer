extends KinematicBody2D

const GRAVITY = 8
var velocity = Vector2()
var SPEED = 80.0
var JUMP_X_SPEED = SPEED * .66

func _physics_process(_delta):
	var action_right = Input.is_action_pressed("run_right")
	var action_left = Input.is_action_pressed("run_left")
	
	var action_jump = Input.is_action_just_pressed("action_jump")
	
	if is_on_floor():
		if action_right and !action_left:
			velocity.x = SPEED
		elif action_left and !action_right:
			velocity.x = -SPEED
		else:
			velocity.x = lerp(velocity.x, 0, 0.1)
			
		if (action_right or action_left):
			$AnimationPlayer.play("steps")
		
		$AnimatedSprite.flip_h = velocity.x < 0
		
		if action_jump:
			velocity.y = -150
			$AnimationPlayer.play("jump")
	else:
		velocity.y += GRAVITY
		if action_right and !$AnimatedSprite.flip_h:
			velocity.x = JUMP_X_SPEED
		elif action_left and $AnimatedSprite.flip_h:
			velocity.x = -JUMP_X_SPEED

	velocity = move_and_slide(velocity, Vector2.UP)
