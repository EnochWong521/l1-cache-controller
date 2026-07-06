`timescale 1ns / 1ps

module cache_lookup #(
    parameter int ADDR_W = 32,
    parameter int NUM_LINES = 64,
    parameter int LINE_BYTES = 16
)(
    input logic clk,
    input logic rst_n,
    input logic [$clog2(LINE_BYTES) - 1:0] offset,
    input logic [$clog2(NUM_LINES) - 1: 0] index,
    input logic [ADDR_W - $clog2(NUM_LINES) - $clog2(LINE_BYTES) - 1:0] tag,
    
    output logic [$clog2(LINE_BYTES * 8) - 1:0] data,
    output logic dirty,
    output logic valid,
    output logic hit
);
    int i;
    // tag array
    localparam TAG_W = ADDR_W - $clog2(NUM_LINES) - $clog2(LINE_BYTES);
    logic [TAG_W - 1:0] tag_arr [NUM_LINES];
    
    // data array
    localparam DATA_W = LINE_BYTES * 8;
    logic [DATA_W - 1:0] data_arr [NUM_LINES];
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // zero out array
            for (i = 0; i < NUM_LINES; i++) begin
                tag_arr[i] <= '0;
                data_arr[i] <= '0;
            end
            // reset outputs
            data <= '0;
            dirty <= 1'b0;
            valid <= 1'b0;
            hit <= 1'b0;
        end else if (valid && tag_arr[index] == tag) begin
            hit <= 1'b1;
            data <= data_arr[index];
        end else begin
            hit <= 1'b0;
        end
    end
          
endmodule
