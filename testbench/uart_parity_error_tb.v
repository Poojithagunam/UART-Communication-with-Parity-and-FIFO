
`timescale 1ns / 1ps

module uart_parity_error_tb;

reg clk = 0;
reg rst = 0;
reg rx = 1;

wire [7:0] rx_data;
wire rx_done;
wire parity_error;

// Use a small baud limit to speed up simulation
always #5 clk = ~clk;

uart_rx #(
    .BAUD_LIMIT(16),
    .HALF_BAUD(8)
) DUT (
    .clk(clk),
    .rst(rst),
    .rx(rx),
    .rx_data(rx_data),
    .rx_done(rx_done),
    .parity_error(parity_error)
);

// Task to send one UART bit
task send_bit;
    input bit_value;
    begin
        @(negedge clk);
        rx = bit_value;
        repeat(16) @(negedge clk);
    end
endtask

// Send a complete UART frame
task send_frame;
    input [7:0] data;
    input parity;

    integer i;

    begin
        // Start bit
        send_bit(1'b0);

        // Send 8 data bits, LSB first
        for (i = 0; i < 8; i = i + 1)
            send_bit(data[i]);

        // Send parity bit
        send_bit(parity);

        // Stop bit
        send_bit(1'b1);

        wait(rx_done == 1);
        #1;

        $display("Received Data = %h", rx_data);
        $display("Parity Error  = %b", parity_error);

        if (parity_error == 1'b1)
            $display("PASS: Parity error detected!");
        else
            $display("FAIL: Parity error not detected!");

        wait(rx_done == 0);
        repeat(4) @(negedge clk);
    end
endtask

initial begin

    // Reset
    rst = 1;
    #50;
    rst = 0;

    repeat(5) @(negedge clk);

    // A5 has four 1s, so correct even parity is 0.
    // Intentionally send incorrect parity = 1.
    send_frame(8'hA5, 1'b1);

    $display("--------------------------------");
    $display("PARITY ERROR TEST COMPLETED!");
    $display("--------------------------------");

    #50;
    $finish;

end

endmodule

