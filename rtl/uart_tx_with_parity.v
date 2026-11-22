`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.11.2026 08:56:55
// Design Name: 
// Module Name: uart_tx_with_parity
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
/////////////////////////////////////////////////////////////////////////////////
module uart_tx_with_parity (
    input  clk,
    input  rst,
    input  tx_start,
    input  [7:0] tx_data,
    output reg tx,
    output reg tx_done
);

parameter BAUD_LIMIT = 10416;

reg [13:0] baud_count = 0;
reg [3:0]  bit_index = 0;
reg [10:0] shift_reg = 0;  // 11-bit frame
reg sending = 0;
reg baud_tick = 0;

// Baud rate generator
always @(posedge clk) begin
    if (rst) begin
        baud_count <= 0;
        baud_tick  <= 0;
    end
    else if (baud_count == BAUD_LIMIT - 1) begin
        baud_count <= 0;
        baud_tick  <= 1;
    end
    else begin
        baud_count <= baud_count + 1;
        baud_tick  <= 0;
    end
end

// UART transmitter with even parity
always @(posedge clk) begin
    if (rst) begin
        tx        <= 1;
        tx_done   <= 0;
        sending   <= 0;
        bit_index <= 0;
        shift_reg <= 0;
    end
    else begin
        tx_done <= 0;

        if (tx_start && !sending) begin
            // Frame: Stop + Parity + Data + Start
            // ^tx_data calculates the even parity bit
            shift_reg <= {1'b1, (^tx_data), tx_data, 1'b0};

            sending   <= 1;
            bit_index <= 0;
        end

        if (sending && baud_tick) begin
            tx        <= shift_reg[0];
            shift_reg <= shift_reg >> 1;
            bit_index <= bit_index + 1;

            if (bit_index == 10) begin
                sending <= 0;
                tx_done <= 1;
            end
        end
    end
end

endmodule

