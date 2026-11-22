`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.11.2026 20:33:06
// Design Name: 
// Module Name: uart_fifo
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



module uart_fifo (
    input clk,
    input rst,

    input wr_en,
    input rd_en,

    input [7:0] data_in,
    output reg [7:0] data_out,

    output full,
    output empty
);

parameter DEPTH = 16;
parameter ADDR_WIDTH = 4;

reg [7:0] memory [0:DEPTH-1];

reg [ADDR_WIDTH-1:0] write_ptr;
reg [ADDR_WIDTH-1:0] read_ptr;

reg [ADDR_WIDTH:0] count;

// FIFO status
assign full  = (count == DEPTH);
assign empty = (count == 0);

// FIFO operations
always @(posedge clk) begin

    if (rst) begin
        write_ptr <= 0;
        read_ptr  <= 0;
        count     <= 0;
        data_out  <= 0;
    end

    else begin

        // Write operation
        if (wr_en && !full) begin
            memory[write_ptr] <= data_in;
            write_ptr <= write_ptr + 1'b1;
        end

        // Read operation
        if (rd_en && !empty) begin
            data_out <= memory[read_ptr];
            read_ptr <= read_ptr + 1'b1;
        end

        // Update FIFO count
        case ({wr_en && !full, rd_en && !empty})

            2'b10: count <= count + 1'b1;

            2'b01: count <= count - 1'b1;

            default: count <= count;

        endcase

    end
end

endmodule

