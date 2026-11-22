`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.11.2026 20:35:49
// Design Name: 
// Module Name: uart_fifo_tb
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

module uart_fifo_tb;

reg clk = 0;
reg rst = 0;
reg wr_en = 0;
reg rd_en = 0;
reg [7:0] data_in = 0;

wire [7:0] data_out;
wire full;
wire empty;

integer i;

always #5 clk = ~clk;

// FIFO DUT
uart_fifo DUT (
    .clk(clk),
    .rst(rst),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .data_in(data_in),
    .data_out(data_out),
    .full(full),
    .empty(empty)
);

// Write one byte
task write_byte;
    input [7:0] data;
    begin
        @(negedge clk);
        data_in = data;
        wr_en = 1;

        @(negedge clk);
        wr_en = 0;
    end
endtask

// Read and check one byte
task read_byte;
    input [7:0] expected;
    begin
        @(negedge clk);
        rd_en = 1;

        @(posedge clk);
        #1;

        if (data_out == expected)
            $display("PASS: Read = %h", data_out);
        else
            $display("FAIL: Expected = %h, Got = %h",
                     expected, data_out);

        @(negedge clk);
        rd_en = 0;
    end
endtask

initial begin

    // Reset
    rst = 1;
    repeat(2) @(negedge clk);
    rst = 0;

    // Check initial empty condition
    #1;
    if (empty)
        $display("PASS: FIFO initially EMPTY");

    // Write 16 bytes
    for (i = 0; i < 16; i = i + 1)
        write_byte(i);

    #1;
    if (full)
        $display("PASS: FIFO FULL after 16 writes");
    else
        $display("FAIL: FIFO did not become FULL");

    // Read all 16 bytes in order
    for (i = 0; i < 16; i = i + 1)
        read_byte(i);

    #1;
    if (empty)
        $display("PASS: FIFO EMPTY after 16 reads");
    else
        $display("FAIL: FIFO did not become EMPTY");

    $display("--------------------------------");
    $display("FIFO TEST COMPLETED!");
    $display("--------------------------------");

    #50;
    $finish;

end

endmodule

