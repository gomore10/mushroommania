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
enum states {stand, walk, fall, jump, kick}
var state = states.fall

#inputs
var walk_input_vec = Vector2.ZERO
var jump_input = false
var end_jump_input = false
var kick_input = false

onready var Sprite = $Sprite
onready var Animate = $AnimationPlayer
onready var HitboxCollision = $Hitbox/CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready():
	HitboxCollision.disabled = true

func _process(_delta):
	walk_input_vec = Vector2.ZERO
	walk_input_vec.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	walk_input_vec.y = 0
	walk_input_vec=walk_input_vec.normalized()
	jump_input = Input.is_action_just_pressed("jump")
	end_jump_input = Input.is_action_just_released("jump")
	kick_input = Input.is_action_just_pressed("kick")

func _physics_process(delta):
	"""move left and right"""
	var walk_velocity = Vector2.ZERO
	if onground and state!=states.kick: #walk left and right on teh ground
		#if pressing to move a direction
		if walk_input_vec != Vector2.ZERO:
			#visuals
			state=states.walk
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
					state=states.stand
			elif velocity.x>0: #if going right, slow towards left
				walk_velocity = -ground_accel
				velocity.x+=walk_velocity*delta
				if velocity.x<=0: #if reversed direction stop
					velocity.x=0
					state=states.stand
	elif onground==false and state!=states.kick: #move in midair
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
	if jump_input and onground and state!=states.kick:
		onground = false
		velocity.y += -jump_force*delta
		state=states.jump
	#end jump early
	if state==states.jump and end_jump_input:
		velocity.y /= 2.5
		state=states.fall
	
	#kick
	if kick_input and onground and state!=states.kick:
		velocity.x = 0
		state=states.kick
		
	#gravity
	velocity.y += gravity_force*delta
	
	var old_velocity = velocity
	
	velocity=move_and_slide(velocity)
	
	if old_velocity.y>0 and velocity.y==0: #if hit the floor
		onground = true
		if state!=states.kick and state!=states.walk: state=states.stand
	elif velocity.y>0: #if falling
		onground = false
		state=states.fall
	
	if old_velocity.x!=0 and velocity.x==0: #if hit a wall
		if state==states.walk: state=states.stand
	
	#set animation
	swap_animation()

func swap_animation():
	#choose animation based on state
	var anim_name = "Idle"
	match state:
		states.walk:
			anim_name = "Walk"
		states.stand:
			anim_name = "Idle"
		states.jump:
			anim_name = "Jump"
		states.fall:
			anim_name = "Jump"
		states.kick:
			if not Sprite.flip_h:
				anim_name = "KickRight"
			else:
				anim_name = "KickLeft"
	#swap to an animation only if you aren't already in that animation
	if Animate.current_animation!=anim_name:
		Animate.play(anim_name)

#Hit an enemy with your hitbox
func _on_Hitbox_area_entered(area):
	area.get_parent().damage(1)

func set_state(new_state): #
	state = new_state

#hit into enemy
func _on_Hurtbox_area_entered(area):
	print("player ow")
