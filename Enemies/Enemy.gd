extends KinematicBody2D

export var health = 3

func damage(amount):
	health -= amount
	print("ow")
	if health<=0:
		queue_free()
