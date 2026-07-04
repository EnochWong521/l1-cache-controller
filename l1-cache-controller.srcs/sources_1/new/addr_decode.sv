`timescale 1ns / 1ps

module addr_decode #(
    parameter int ADDR_W = 32, 
    parameter int DATA_W = 32,
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
    // words offset in cache line
    localparam int WORDS_PER_LINE = LINE_BYTES / (DATA_W / 8);
    localparam int WORD_OFFSET_W = $clog2(WORDS_PER_LINE);
    
    // byte offset in cache line 
    localparam int BYTES_PER_LINE = DATA_W / 8;
    localparam int BYTE_OFFSET_W = $clog2(BYTES_PER_LINE);
    
    // offset bits
    assign byte_offset = addr[BYTE_OFFSET_W - 1:0];
    assign word_offset = addr[
        BYTE_OFFSET_W + WORD_OFFSET_W - 1:BYTE_OFFSET_W
    ];
    assign offset = {word_offset, byte_offset};
    
    // index bits
    localparam LINE_INDEX_W = $clog2(NUM_LINES);
    assign index = addr[
        BYTE_OFFSET_W + WORD_OFFSET_W + LINE_INDEX_W - 1:
        BYTE_OFFSET_W + WORD_OFFSET_W
    ];
    
    // tag bits
    assign tag = addr[
        ADDR_W - 1:
        BYTE_OFFSET_W + WORD_OFFSET_W + LINE_INDEX_W
    ];
endmodule
