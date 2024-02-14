extends GameScene2D


var rng: RandomNumberGenerator = RandomNumberGenerator.new()
@onready var ball: RigidBody2D = $Ball


func _ready() -> void:
    var ball_speed = rng.randf_range(160.0, 180.0)
    var ball_velocity = Vector2.UP * ball_speed
    ball_velocity = ball_velocity.rotated(rng.randf_range(0.0, 2.0 * PI))

    ball.set_linear_velocity(ball_velocity)
