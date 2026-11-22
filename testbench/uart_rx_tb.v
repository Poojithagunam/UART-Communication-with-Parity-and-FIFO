`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.11.2026 15:56:34
// Design Name: 
// Module Name: uart_rx_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



`timescale 1ns/1ps

module uart_rx_tb;

reg clk;
reg rst;
reg rx;

wire [7:0] rx_data;
wire rx_done;

parameter BAUD_LIMIT = 10416;
parameter CLK_PERIOD = 10;
parameter BIT_TIME = BAUD_LIMIT * CLK_PERIOD;

reg [7:0] tx_data;
integer i;

uart_rx dut (
    .clk(clk),
    .rst(rst),
    .rx(rx),
    .rx_data(rx_data),
    .rx_done(rx_done)
);

// Clock generation
initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end

// Test procedure
initial begin

    rst = 1;
    rx = 1;
    tx_data = 8'hA5;

    repeat(5) @(negedge clk);
    rst = 0;

    repeat(5) @(negedge clk);

    // Send START bit
    rx = 0;
    #(BIT_TIME);

    // Send 8 data bits (LSB first)
    for (i = 0; i < 8; i = i + 1) begin
        rx = tx_data[i];
        #(BIT_TIME);
    end

    // Send STOP bit
    rx = 1;

    // Wait for receiver completion
    wait(rx_done == 1);

    #1;

    if (rx_data == tx_data) begin
        $display("PASS: UART RX working correctly!");
        $display("Received Data = %h", rx_data);
    end
    else begin
        $display("FAIL: UART RX verification failed");
        $display("Expected = %h, Received = %h",
                 tx_data, rx_data);
    end

    #100;
    $finish;

end

endmodule

