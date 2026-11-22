
`timescale 1ns/1ps

module uart_tx_tb;

    // Testbench inputs
    reg clk;
    reg rst;
    reg tx_start;
    reg [7:0] tx_data;

    // Transmitter outputs
    wire tx;
    wire tx_done;

    // Timing parameters
    parameter BAUD_LIMIT = 10416;
    parameter CLK_PERIOD = 10;
    parameter BIT_TIME = BAUD_LIMIT * CLK_PERIOD;

    reg [7:0] received_data;
    reg done_seen;
    integer i;

    // Instantiate UART transmitter
    uart_tx dut (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(tx),
        .tx_done(tx_done)
    );

    // Generate 100 MHz clock
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // Monitor completion pulse
    initial done_seen = 0;

    always @(posedge clk) begin
        if (tx_done)
            done_seen <= 1;
    end

    // Apply test inputs and check transmission
    initial begin

        rst = 1;
        tx_start = 0;
        tx_data = 8'hA5;
        received_data = 0;

        // Apply reset
        repeat(5) @(negedge clk);
        rst = 0;

        // Start transmission
        @(negedge clk);
        tx_start = 1;

        @(negedge clk);
        tx_start = 0;

        // Wait for start bit
        @(negedge tx);

        // Check start bit at its middle
        #(BIT_TIME/2);

        if (tx !== 0)
            $display("FAIL: Start bit incorrect");

        // Sample 8 data bits, LSB first
        for (i = 0; i < 8; i = i + 1) begin
            #(BIT_TIME);
            received_data[i] = tx;
        end

        // Check stop bit
        #(BIT_TIME);

        if (tx !== 1)
            $display("FAIL: Stop bit incorrect");

        // Check received data
        if (received_data == tx_data && done_seen) begin
            $display("PASS: UART TX working correctly!");
            $display("Transmitted Data = %h", received_data);
        end
        else begin
            $display("FAIL: UART TX verification failed");
            $display("Expected = %h, Received = %h",
                     tx_data, received_data);
        end

        $finish;
    end

endmodule
