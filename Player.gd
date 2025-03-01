extends CharacterBody2D

signal food_updated(value: float)

const SPEED = 180

const run_speed = 1000
var food: float
const STEPS_FOR_HUNGER = 100
var step_count = 0

const moving = false
var is_mining = false
@onready var animations = $AnimationPlayer


var facing_direction: Vector2 # Saves last moved direction
func _process(delta):
	var direction = process_direction()

	self.velocity = direction * SPEED

	var movement_collides = null
	if !is_mining:
		movement_collides = move_and_collide(self.velocity * delta)
	
	if Input.is_action_pressed("run"):  # Corremos con "shift"
		self.velocity = direction * run_speed

	if Input.is_action_pressed("mine"):
		is_mining = true
		
		play_mine_animation()
		await animations.animation_finished
		is_mining = false
		return
		
	var movement_intent_exists: bool = direction.x != 0 || direction.y != 0
	trigger_hunger(movement_collides, movement_intent_exists)

	if !is_mining:
		if direction != Vector2(0,0):
			play_movement_animation()
		else:
			animations.stop(true)

func process_direction():
	if Input.is_action_pressed("left"):
		facing_direction = Vector2.LEFT
	elif Input.is_action_pressed("right"):
		facing_direction = Vector2.RIGHT
	elif Input.is_action_pressed("up"):
		facing_direction = Vector2.UP
	elif Input.is_action_pressed("down"):
		facing_direction = Vector2.DOWN
	else: 
		return Vector2.ZERO

	return facing_direction

func play_movement_animation():
	animations.play("walk" + direction_string(self.facing_direction))

func play_mine_animation():
	animations.play("mine" + direction_string(self.facing_direction))

func _ready():
	food = 100


# movement_collides is null when there was no collision
func trigger_hunger(movement_collides: KinematicCollision2D, movement_intent_exists: bool):
	if !movement_collides and movement_intent_exists and !is_mining:
		print('[player] step count++ ', step_count, ' ',food)
		step_count += 1
		if step_count >= STEPS_FOR_HUNGER:
			step_count = 0
			food -= 1
			emit_signal("food_updated", food)

func direction_string(direction: Vector2):
	if direction == Vector2.LEFT:
		return "Left"
	elif direction == Vector2.RIGHT:
		return "Right"
	elif direction == Vector2.UP:
		return "Up"
	elif direction == Vector2.DOWN:
		return "Down"
