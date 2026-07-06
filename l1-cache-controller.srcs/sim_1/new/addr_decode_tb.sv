`timescale 1ns / 1ps

module addr_decode_tb();
    // cache specs
    localparam int ADDR_W = 32;
    localparam int NUM_LINES = 64;
    localparam int LINE_BYTES = 16;
    
    // cache signals
    localparam INDEX_W = $clog2(NUM_LINES);
    localparam OFFSET_W = $clog2(LINE_BYTES);
    logic [ADDR_W - 1:0] addr;
    logic [ADDR_W - INDEX_W - OFFSET_W - 1:0] tag;
    logic [INDEX_W - 1:0] index;
    logic [OFFSET_W - 1:0] offset;
    
    int p = 0;
    int f = 0;
    
    addr_decode dut (
        .*
    );
    
    
    bit clk = 0;
    
    always #5 clk = ~clk;
    
    task automatic set_addr(input logic [ADDR_W - 1:0] addr_test);
        @(posedge clk);
        addr = addr_test;
    endtask
    
    task automatic compare_addr(input logic [ADDR_W - 1:0] addr_test);
        @(negedge clk);
        if (offset !== addr_test[OFFSET_W - 1:0] ||
            index !== addr_test[INDEX_W + OFFSET_W - 1:OFFSET_W] ||
            tag !== addr_test[ADDR_W - 1:INDEX_W + OFFSET_W]
        ) begin
            f++;
            $display(
                "FAIL, Got: tag=%0h, index=%0h, offset=%0h",
                tag, index, offset
            );
            $display(
                "Expected: tag=%0h, index=%0h, offset=%0h", 
                addr_test[31:10], addr_test[9:4], addr_test[3:0]
            );
        end else begin
            p++;
            $display(
                "PASS, tag=%0h, index=%0h, offset=%0h", 
                tag, index, offset
            );
        end
    endtask
    
    initial begin
        // initialize address
        set_addr(32'b0000000000000000000000_000000_0000);
        // begin directed test
        set_addr(32'b0000000000000000000111_000011_0001);
        compare_addr(32'b0000000000000000000111_000011_0001);
        set_addr(32'b1000000000000000000000_100000_1000);
        compare_addr(32'b1000000000000000000000_100000_1000);
        $display("PASS=%d, FAIL=%d", p, f);
        $finish;
    end
    
endmodule