module tt_um_reaction_timer (
    input clk,           // System clock
    input reset,         // System reset
    input button,        // Button input
    output reg led,      // LED output
    output reg [15:0] reaction_time, // Reaction time output in milliseconds
    output reg [7:0] lcd_data, // LCD data output
    output reg lcd_rs,   // LCD register select
    output reg lcd_en    // LCD enable
);

// Parameters
parameter CLOCK_FREQ = 50000000; // 50 MHz clock frequency
parameter MAX_WAIT_TIME = 500000000; // Max wait time for LED to turn on (10 seconds)

// Internal signals
reg [31:0] random_counter;
reg [31:0] reaction_counter;
reg led_on;
reg [31:0] random_delay;

// Random delay generation
always @(posedge clk or posedge reset) begin
    if (reset) begin
        random_counter <= 32'd0;
        random_delay <= 32'd0;
    end else begin
        random_counter <= random_counter + 32'd1;
        if (random_counter >= MAX_WAIT_TIME) begin
            random_counter <= 32'd0;
            random_delay <= $random % MAX_WAIT_TIME;
        end
    end
end

// LED control and reaction time measurement
always @(posedge clk or posedge reset) begin
    if (reset) begin
        led <= 1'b0;
        led_on <= 1'b0;
        reaction_counter <= 32'd0;
        reaction_time <= 16'd0;
    end else begin
        if (random_counter == random_delay && !led_on) begin
            led <= 1'b1;
            led_on <= 1'b1;
            reaction_counter <= 32'd0;
        end

        if (led_on) begin
            reaction_counter <= reaction_counter + 32'd1;
            if (button) begin
                led <= 1'b0;
                led_on <= 1'b0;
                reaction_time <= reaction_counter / (CLOCK_FREQ / 1000); // Convert to milliseconds
            end
        end
    end
end

// LCD display logic (simplified for example purposes)
always @(posedge clk or posedge reset) begin
    if (reset) begin
        lcd_data <= 8'd0;
        lcd_rs <= 1'b0;
        lcd_en <= 1'b0;
    end else begin
        lcd_data <= reaction_time[7:0]; // Display lower 8 bits of reaction time for simplicity
        lcd_rs <= 1'b1;
        lcd_en <= 1'b1;
    end
end

endmodule

