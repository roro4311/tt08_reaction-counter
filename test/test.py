import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer
import random  # Add this import

@cocotb.test()
async def test_reaction_timer(dut):
    """Test the reaction timer"""

    # Create a 50 MHz clock
    cocotb.start_soon(Clock(dut.clk, 20, units="ns").start())

    # Reset the DUT
    dut.reset.value = 1
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.reset.value = 0

    # Initialize inputs
    dut.button.value = 0

    # Wait for reset to deassert
    await Timer(100, units='ns')

    # Time limit for the test (10 seconds)
    time_limit = 10 * 1000  # 10 seconds in milliseconds
    time_elapsed = 0

    while time_elapsed < time_limit:
        # Wait for the LED to turn on
        while not dut.led.value:
            await RisingEdge(dut.clk)

        # Simulate reaction time by pressing the button after a random delay
        reaction_delay = random.randint(10, 1000)  # Delay in milliseconds
        await Timer(reaction_delay, units='ms')
        dut.button.value = 1
        await RisingEdge(dut.clk)
        dut.button.value = 0

        # Verify the reaction time
        expected_reaction_time = reaction_delay
        actual_reaction_time = int(dut.reaction_time.value)
        assert actual_reaction_time == expected_reaction_time, f"Expected {expected_reaction_time}, got {actual_reaction_time}"

        print(f"Reaction time: {actual_reaction_time} ms")

        # Simulate random button press delay
        random_button_delay = random.randint(1, 5000)  # Random delay between 1 ms and 5 seconds
        await Timer(random_button_delay, units='ms')

        # Update the elapsed time
        time_elapsed += reaction_delay + random_button_delay + 1  # Adding 1 ms for the button press handling time

    # Stop the simulation by raising an exception
    raise Exception("Test completed after 10 seconds")

