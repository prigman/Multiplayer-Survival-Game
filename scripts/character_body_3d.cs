using Godot;

public partial class character_body_3d : CharacterBody3D
{
	private float speed = 5.0f;
	private float jumpVelocity = 4.5f;
	private float rotationX = 0f;
	private float rotationY = 0f;
	private float sensitivity = 0.01f;

	// Get the gravity from the project settings to be synced with RigidBody nodes.
	private float gravity = ProjectSettings.GetSetting("physics/3d/default_gravity").AsSingle();

	private Node3D cameraController;
	private Camera3D cam;

	public override void _Ready()
	{
		cameraController = GetNode<Node3D>("CameraController");
		cam = cameraController.GetNode<Camera3D>("Camera3D");
	}

	public override void _Input(InputEvent @event)
	{
		if (@event is InputEventMouseMotion mouseMotion)
		{
			RotateY(Mathf.DegToRad(-mouseMotion.Relative.X + sensitivity));
			cameraController.RotateX(Mathf.DegToRad(-mouseMotion.Relative.Y + sensitivity));
		}
	}

	public override void _PhysicsProcess(double delta)
	{
		Vector3 velocity = Velocity;

		// Add the gravity.
		if (!IsOnFloor())
			velocity.Y -= gravity * (float)delta;

		// Handle Jump.
		if (Input.IsActionJustPressed("space") && IsOnFloor())
			velocity.Y = jumpVelocity;

		// Get the input direction and handle the movement/deceleration.
		// As good practice, you should replace UI actions with custom gameplay actions.
		Vector2 inputDir = Input.GetVector("move_left", "move_right", "move_forward", "move_backward");
		Vector3 direction = (Transform.Basis * new Vector3(inputDir.X, 0, inputDir.Y)).Normalized();
		if (direction != Vector3.Zero)
		{
			velocity.X = direction.X * speed;
			velocity.Z = direction.Z * speed;
		}
		else
		{
			velocity.X = Mathf.MoveToward(velocity.X, 0, speed);
			velocity.Z = Mathf.MoveToward(velocity.Z, 0, speed);
		}

		Velocity = velocity;
		MoveAndSlide();
	}
}
