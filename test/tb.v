`default_nettype none
`timescale 1ns / 1ps

module tb ();

  // Dump the signals to a VCD file. You can view it with gtkwave.
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
    #1;
  end

  // Wire up the inputs and outputs:
  reg clk;
  reg reset;
  reg button;
  wire led;
  wire [7:0] lcd_data;
  wire lcd_rs;
  wire lcd_en;
  wire [15:0] reaction_time;

  // Instantiate the DUT (Device Under Test)
  tt_um_reaction_timer uut (
      .clk    (clk),
      .reset  (reset),
      .button (button),
      .led    (led),
      .reaction_time (reaction_time),
      .lcd_data (lcd_data),
      .lcd_rs (lcd_rs),
      .lcd_en (lcd_en)
  );

  // Generate clock
  initial begin
    clk = 0;
    forever #10 clk = ~clk; // 50 MHz clock
  end

  // Initial conditions
  initial begin
    reset = 0;
    button = 0;
    #100 reset = 0;
    #300 button = 1;
    #500 button = 0;
    #550 reset = 1;
    #600 reset = 0;
    #700 button = 1;
  end

  // Generate button signal with random debounce and delay after LED is turned on
  reg [31:0] delay_counter;
  reg [31:0] debounce_counter;
  reg button_state;
  reg button_debounce;

  initial begin
    delay_counter = 0;
    debounce_counter = 0;
    button_state = 0;
    button_debounce = 0;

    while (1) begin
      // Wait for LED to turn on
      while (!led) begin
        @(posedge clk);
      end

      // Introduce a random debounce delay
      debounce_counter = $random % 1000; // Random debounce delay between 0 and 1000 clock cycles
      while (debounce_counter > 0) begin
        @(posedge clk);
        debounce_counter = debounce_counter - 1;
      end

      // Introduce a random delay before pressing the button
      delay_counter = $random % 1000; // Random delay between 0 and 1000 clock cycles
      while (delay_counter > 0) begin
        @(posedge clk);
        delay_counter = delay_counter - 1;
      end

      // Simulate button press
      button_state = 1;
      button = button_state;
      @(posedge clk);
      button = 0;
      button_state = 0;

      // Wait for a random time before potentially pressing the button again
      delay_counter = $random % 1000; // Random delay between 0 and 1000 clock cycles
      while (delay_counter > 0) begin
        @(posedge clk);
        delay_counter = delay_counter - 1;
      end

      // Optionally, press the button again randomly
      if ($random % 2 == 0) begin
        button = 1;
        @(posedge clk);
        button = 0;
      end

      // Delay to simulate button release
      @(posedge clk);
    end
  end

  // Stop simulation after 10 seconds
  initial begin
    #100000000; // 10 seconds in nanoseconds (10 * 10^9 ns)
    $finish;
  end

endmodule

