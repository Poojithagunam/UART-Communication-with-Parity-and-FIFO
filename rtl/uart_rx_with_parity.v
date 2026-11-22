`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.11.2026 08:53:09
// Design Name: 
// Module Name: uart_rx_with_parity
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


module uart_rx_with_parity (
    input  clk,
    input  rst,
    input  rx,
    output reg [7:0] rx_data,
    output reg rx_done,
    output reg parity_error
);

parameter BAUD_LIMIT = 10416;
parameter HALF_BAUD  = 5208;

// Receiver states
localparam IDLE   = 3'd0;
localparam START  = 3'd1;
localparam DATA   = 3'd2;
localparam PARITY = 3'd3;
localparam STOP   = 3'd4;

reg [2:0] state = IDLE;
reg [13:0] baud_count = 0;
reg [2:0] bit_index = 0;

reg [7:0] shift_reg = 0;
reg received_parity = 0;

always @(posedge clk) begin

    if (rst) begin
        state           <= IDLE;
        baud_count      <= 0;
        bit_index       <= 0;
        shift_reg       <= 0;
        received_parity <= 0;
        rx_data         <= 0;
        rx_done         <= 0;
        parity_error    <= 0;
    end
    else begin

        rx_done <= 0;

        case (state)

            // Wait for start bit
            IDLE: begin
                baud_count <= 0;

                if (!rx) begin
                    state      <= START;
                    baud_count <= 0;
                end
            end

            // Check the centre of start bit
            START: begin
                if (baud_count == HALF_BAUD - 1) begin
                    baud_count <= 0;

                    if (!rx) begin
                        state     <= DATA;
                        bit_index <= 0;
                    end
                    else begin
                        state <= IDLE;
                    end
                end
                else begin
                    baud_count <= baud_count + 1;
                end
            end

            // Receive 8 data bits, LSB first
            DATA: begin
                if (baud_count == BAUD_LIMIT - 1) begin
                    baud_count <= 0;
                    shift_reg[bit_index] <= rx;

                    if (bit_index == 7) begin
                        state <= PARITY;
                    end
                    else begin
                        bit_index <= bit_index + 1;
                    end
                end
                else begin
                    baud_count <= baud_count + 1;
                end
            end

            // Receive parity bit
            PARITY: begin
                if (baud_count == BAUD_LIMIT - 1) begin
                    baud_count      <= 0;
                    received_parity <= rx;
                    state           <= STOP;
                end
                else begin
                    baud_count <= baud_count + 1;
                end
            end

            // Check stop bit and parity
            STOP: begin
                if (baud_count == BAUD_LIMIT - 1) begin
                    baud_count <= 0;
                    state      <= IDLE;

                    if (rx == 1'b1) begin
                        rx_data      <= shift_reg;
                        rx_done      <= 1;

                        if (received_parity != (^shift_reg))
                            parity_error <= 1;
                        else
                            parity_error <= 0;
                    end
                end
                else begin
                    baud_count <= baud_count + 1;
                end
            end

            default: state <= IDLE;

        endcase
    end
end

endmodule
