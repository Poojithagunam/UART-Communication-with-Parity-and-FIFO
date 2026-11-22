`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.11.2026 08:40:57
// Design Name: 
// Module Name: uart_top
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



module uart_top (
    input clk,
    input rst,

    // Transmitter inputs
    input tx_start,
    input [7:0] tx_data,

    // FIFO read control
    input fifo_rd_en,

    // Outputs
    output tx,
    output tx_done,

    output [7:0] fifo_data_out,
    output fifo_full,
    output fifo_empty,

    output rx_done,
    output parity_error
);

    // Internal connections
    wire [7:0] rx_data;
    wire fifo_wr_en;

    // Write to FIFO only when received data has correct parity
    assign fifo_wr_en = rx_done && !parity_error;

    // UART Transmitter
    uart_tx_with_parity tx_inst (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(tx),
        .tx_done(tx_done)
    );

    // UART Receiver
    uart_rx_with_parity rx_inst (
        .clk(clk),
        .rst(rst),
        .rx(tx),
        .rx_data(rx_data),
        .rx_done(rx_done),
        .parity_error(parity_error)
    );

    // FIFO Buffer
    uart_fifo fifo_inst (
        .clk(clk),
        .rst(rst),
        .wr_en(fifo_wr_en),
        .rd_en(fifo_rd_en),
        .data_in(rx_data),
        .data_out(fifo_data_out),
        .full(fifo_full),
        .empty(fifo_empty)
    );

endmodule

