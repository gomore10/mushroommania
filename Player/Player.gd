extends KinematicBody2D

#movement constants
var ground_speed = 6500
var ground_accel = 800
var air_speed = 6500
var air_accel = 800
var jump_force = 21000
var gravity_force = 1000

var velocity = Vector2.ZERO
var onground = false

#inputs
var walk_input_vec = Vector2.ZERO
var jump_input = false
var end_jump_input = false

onready var Sprite = $Sprite
onready var Animate = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(_delta):
	walk_input_vec = Vector2.ZERO
	walk_input_vec.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	walk_input_vec.y = 0
	walk_input_vec=walk_input_vec.normalized()
	jump_input = Input.is_action_just_pressed("jump")
	end_jump_input = Input.is_action_just_released("jump")

func _physics_process(delta):
	"""move left and right"""
	var walk_velocity = Vector2.ZERO
	if onground: #walk left and right on teh ground
		#if pressing to move a direction
		if walk_input_vec != Vector2.ZERO:
			#visuals
			if Animate.current_animation!="Walk": Animate.play("Walk")
			Sprite.flip_h=false
			#walk right
			if walk_input_vec.x>0:
				#only accelerate if not already moving at max speed in that direction
				if velocity.x<ground_speed*delta:
					walk_velocity = ground_accel
					velocity.x+=walk_velocity*delta
				#if over max speed, slow down
				if velocity.x>ground_speed*delta:
					walk_velocity = -ground_accel
					velocity.x+=walk_velocity*delta
					if velocity.x<ground_speed*delta: #don't go under max speed
						velocity.x=ground_speed*delta
			else: #walk left
				Sprite.flip_h=true
				if velocity.x>-ground_speed*delta:
					walk_velocity = -ground_accel
					velocity.x+=walk_velocity*delta
				#if over max speed, slow down
				if velocity.x<-ground_speed*delta:
					walk_velocity = ground_accel
					velocity.x+=walk_velocity*delta
					if velocity.x>-ground_speed*delta: #don't go under max speed
						velocity.x=-ground_speed*delta
		else: #slow down if on ground and not trying to move
			if velocity.x<0: #if going left, slow toward right
				walk_velocity = ground_accel
				velocity.x+=walk_velocity*delta
				if velocity.x>=0: #if reversed direction stop
					velocity.x=0
					Animate.play("Idle")
			elif velocity.x>0: #if going right, slow towards left
				walk_velocity = -ground_accel
				velocity.x+=walk_velocity*delta
				if velocity.x<=0: #if reversed direction stop
					velocity.x=0
					Animate.play("Idle")
	else: #move in midair
		#if pressing to move a direction
		if walk_input_vec != Vector2.ZERO:
			Sprite.flip_h=false
			#walk right
			if walk_input_vec.x>0:
				#only accelerate if not already moving at max speed in that direction
				if velocity.x<air_speed*delta:
					walk_velocity = air_accel
					velocity.x+=walk_velocity*delta
					#in air you only go down to max speed if you are trying accelerate towards it by normal means
					if velocity.x>air_speed*delta:
						velocity.x=air_speed*delta
			else: #walk left
				Sprite.flip_h=true
				if velocity.x>-air_speed*delta:
					walk_velocity = -air_accel
					velocity.x+=walk_velocity*delta
					#in air you only go down to max speed if you are trying accelerate towards it by normal means
					if velocity.x<-air_speed*delta:
						velocity.x=-air_speed*delta
		else: #slow down if in air and not trying to move
			if velocity.x<0: #if going left, slow toward right
				walk_velocity = air_accel
				velocity.x+=walk_velocity*delta
				if velocity.x>=0: #if reversed direction stop
					velocity.x=0
			elif velocity.x>0: #if going right, slow towards left
				walk_velocity = -air_accel
				velocity.x+=walk_velocity*delta
				if velocity.x<=0: #if reversed direction stop
					velocity.x=0
	
	#jump
	if jump_input and onground:
		velocity.y += -jump_force*delta
	#end jump early
	if velocity.y < 0 and end_jump_input:
		velocity.y /= 2.5
	
	#gravity
	velocity.y += gravity_force*delta
	
	var expected_pos = position+velocity*delta
	
	velocity=move_and_slide(velocity)
	
	if position.y<expected_pos.y: #if hit the floor
		onground = true
	else:
		onground = false
