# UART Communication with Even Parity and FIFO Buffering

## About
A UART communication system designed using Verilog HDL. It includes data transmission, reception, even parity error detection and FIFO buffering.

## Features
- UART transmitter and receiver
- Even parity generation and checking
- Parity error detection
- FIFO buffering
- Full and empty status flags

## Modules
- `uart_tx_with_parity.v` – Transmitter
- `uart_rx_with_parity.v` – Receiver with parity checking
- `uart_fifo.v` – FIFO buffer
- `uart_top.v` – Top-level integration

## Simulation Results

Tested data: `3C`, `C3`, `00`, `FF`, `A5`

All five test cases passed.

Incorrect parity detection was also verified.

## Tools Used
- Verilog HDL
- Xilinx Vivado

## Author
Poojitha G

