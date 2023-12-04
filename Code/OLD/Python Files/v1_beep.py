from ev3dev2.sound import Sound
from time import sleep

# pip install python-ev3dev2


def beep_test():
    sound = Sound()

    print("Starting beep test...")

    try:
        # Beep twice with a short delay in between
        sound.beep()
        sleep(0.5)
        sound.beep()

        # Beep with different frequencies and durations
        sound.beep(440, 500)  # 440 Hz for 500 milliseconds
        sleep(0.5)
        sound.beep(880, 200)  # 880 Hz for 200 milliseconds

        # Beep in a loop
        for _ in range(3):
            sound.beep()
            sleep(0.2)

    except Exception as e:
        print(f"An error occurred: {e}")
    finally:
        print("Beep test completed.")

if __name__ == "__main__":
    beep_test()
