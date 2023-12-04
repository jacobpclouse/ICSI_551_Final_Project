from ev3dev.ev3 import *

# Connect motors and sensors to the appropriate ports
left_motor = LargeMotor(OUTPUT_B)
right_motor = LargeMotor(OUTPUT_C)
touch_sensor = TouchSensor(INPUT_1)

# Check if the touch sensor is pressed
while not touch_sensor.is_pressed:
    # Move the motors forward
    left_motor.run_forever(speed_sp=300)
    right_motor.run_forever(speed_sp=300)

# Stop the motors when the touch sensor is pressed
left_motor.stop()
right_motor.stop()
