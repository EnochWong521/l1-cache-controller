`timescale 1ns / 1ps

module cache_lookup #(
    parameter int ADDR_W = 32,
    parameter int NUM_LINES = 64,
    parameter int LINE_BYTES = 16
)(
    input logic clk,
    input logic rst_n,
    input logic [$clog2(NUM_LINES) - 1: 0] index,
    input logic [ADDR_W - $clog2(NUM_LINES) - $clog2(LINE_BYTES) - 1:0] tag,
    
    input logic fill_en,
    input logic [$clog2(NUM_LINES) - 1: 0] fill_index, 
    input logic [ADDR_W - $clog2(NUM_LINES) - $clog2(LINE_BYTES) - 1:0] fill_tag,
    input logic [$clog2(LINE_BYTES * 8) - 1:0] fill_data,
    
    output logic [$clog2(LINE_BYTES * 8) - 1:0] data,
    output logic dirty,
    output logic valid,
    output logic hit
);
    localparam TAG_W = ADDR_W - $clog2(NUM_LINES) - $clog2(LINE_BYTES);
    localparam DATA_W = $clog2(LINE_BYTES * 8);
    
    typedef struct {
        logic [TAG_W - 1:0] tag;
        logic [DATA_W - 1:0] data;
        logic valid;
        logic dirty;
    } cache_line_t;
    
    cache_line_t cache_arr [NUM_LINES];
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            foreach (cache_arr[i]) begin
                cache_arr[i].tag = '0;
                cache_arr[i].data = '0;
                cache_arr[i].valid = 0;
                cache_arr[i].dirty = 0;
            end
        end
        else begin
            if (fill_en) begin
                if (fill_tag == cache_arr[fill_index].tag) begin
                    cache_arr[fill_index].data <= fill_data;
                    cache_arr[fill_index].dirty <= 1'b1;
                    valid <= 1'b1;
                    dirty <= 1'b0;
                    hit <= 1'b0;
                end
            end
            else if (cache_arr[index].valid & cache_arr[index].tag == tag) begin
                data <= cache_arr[index].data;    
                hit <= 1'b1;
                valid <= 1'b1;
                dirty <= cache_arr[index].dirty;
            end
        end
    end
endmodule
