extends GameScene2D


var rng: RandomNumberGenerator = RandomNumberGenerator.new()
@onready var ball: RigidBody2D = $Ball


func _ready() -> void:
    var velocity = Vector2.UP * rng.randf_range(160.0, 180.0) 
    velocity = velocity.rotated(rng.randf_range(0.0, 2.0 * PI))

    ball.set_linear_velocity(velocity)
