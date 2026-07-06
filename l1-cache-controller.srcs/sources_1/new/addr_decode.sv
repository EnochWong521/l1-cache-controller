`timescale 1ns / 1ps

module addr_decode #(
    parameter int ADDR_W = 32, 
    parameter int NUM_LINES = 64,
    parameter int LINE_BYTES = 16
) (
    input logic [ADDR_W - 1:0] addr,
    output logic [
        ADDR_W - $clog2(NUM_LINES) - $clog2(LINE_BYTES) - 1:0
    ] tag, 
    output logic [$clog2(NUM_LINES) - 1:0] index, 
    output logic [$clog2(LINE_BYTES) - 1:0] offset
);
    // offset bits 
    localparam int OFFSET_W = $clog2(LINE_BYTES);
    assign offset = addr[OFFSET_W - 1:0];
    
    // index bits
    localparam INDEX_W = $clog2(NUM_LINES);
    assign index = addr[
        OFFSET_W + INDEX_W - 1:OFFSET_W
    ];
    
    // tag bits
    assign tag = addr[
        ADDR_W - 1:OFFSET_W + INDEX_W
    ];
endmodule
