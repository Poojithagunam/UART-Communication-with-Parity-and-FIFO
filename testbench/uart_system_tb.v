`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.11.2026 11:13:16
// Design Name: 
// Module Name: uart_system_tb
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


`timescale 1ns / 1ps

module uart_system_tb;

    reg clk;
    reg rst;
    reg tx_start;
    reg [7:0] tx_data;
    reg fifo_rd_en;

    wire tx;
    wire tx_done;
    wire [7:0] fifo_data_out;
    wire fifo_full;
    wire fifo_empty;
    wire rx_done;
    wire parity_error;

    uart_top dut (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .fifo_rd_en(fifo_rd_en),
        .tx(tx),
        .tx_done(tx_done),
        .fifo_data_out(fifo_data_out),
        .fifo_full(fifo_full),
        .fifo_empty(fifo_empty),
        .rx_done(rx_done),
        .parity_error(parity_error)
    );

    // 100 MHz clock
    always #5 clk = ~clk;

    // Task to transmit and verify one byte
    task send_and_check;
        input [7:0] test_data;

        begin
            @(negedge clk);
            tx_data = test_data;
            tx_start = 1;

            @(negedge clk);
            tx_start = 0;

            wait(tx_done == 1);
            wait(rx_done == 1);

            if (parity_error == 0)
                $display("PASS: Parity correct for %h", test_data);
            else
                $display("FAIL: Parity error for %h", test_data);

            // Wait until FIFO receives the byte
            wait(fifo_empty == 0);

            // Read FIFO
            @(negedge clk);
            fifo_rd_en = 1;

            @(negedge clk);
            fifo_rd_en = 0;

            #1;

            // Verify FIFO output
            if (fifo_data_out == test_data && parity_error == 0)
                $display("PASS: Sent = %h, FIFO Output = %h",
                         test_data, fifo_data_out);
            else
                $display("FAIL: Sent = %h, FIFO Output = %h",
                         test_data, fifo_data_out);

        end
    endtask

    initial begin

        clk = 0;
        rst = 1;
        tx_start = 0;
        tx_data = 0;
        fifo_rd_en = 0;

        #100;
        rst = 0;

        // Test five different data bytes
        send_and_check(8'h3C);
        send_and_check(8'hC3);
        send_and_check(8'h00);
        send_and_check(8'hFF);
        send_and_check(8'hA5);

        $display("--------------------------------");
        $display("UART SYSTEM TEST COMPLETED");
        $display("--------------------------------");

        #100;
        $finish;

    end

endmodule


