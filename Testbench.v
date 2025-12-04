`timescale 1ns/1ps

module FIFO_tb();

  reg clk, rst;
  reg wr_en, rd_en;
  reg [7:0] buf_in;
  wire [7:0] buf_out;
  wire buf_empty, buf_full;
  wire [7:0] fifo_counter;

  // Instantiate DUT
  FIFO dut (
    .clk(clk),
    .rst(rst),
    .buf_in(buf_in),
    .buf_out(buf_out),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .buf_empty(buf_empty),
    .buf_full(buf_full),
    .fifo_counter(fifo_counter)
  );

  // Clock generation
  always #5 clk = ~clk;   // 10ns clock

  initial begin
    $dumpfile("fifo_tb.vcd");
    $dumpvars(0, FIFO_tb);

    // Init
    clk = 0;
    rst = 0;
    wr_en = 0;
    rd_en = 0;
    buf_in = 0;

    // Apply reset
    $display("=== Reset FIFO ===");
    #2 rst = 1;   

    // Write 4 elements
    $display("=== Write 4 elements ===");
    repeat(4) begin
      @(posedge clk);
      wr_en = 1;
      buf_in = buf_in + 8'd10;
      #1 $display("WRITE: in=%0d full=%0d counter=%0d",
          buf_in, buf_full, fifo_counter);
    end

    @(posedge clk);
    wr_en = 0;
    #1;

    // Check full condition
    #1 $display("buf_full=%0d, fifo_counter=%0d End is here", buf_full, fifo_counter);

    // Read 4 elements
    $display("=== Read 4 elements ===");
    repeat(4) begin
      @(posedge clk);
      rd_en = 1;
      #1 $display("READ: out=%0d empty=%0d counter=%0d",
          buf_out, buf_empty, fifo_counter);
    end

    @(posedge clk);
    rd_en = 0;
    #1;

    // Check empty
    $display("buf_empty=%0d, fifo_counter=%0d", buf_empty, fifo_counter);

    // Test simultaneous read + write
    $display("=== Simultaneous read & write ===");
    repeat(3) begin
      @(posedge clk);
      wr_en = 1; 
      rd_en = 1;
      buf_in = buf_in + 8'd10;
      #1 $display("SIM: out=%0h counter=%0d", buf_out, fifo_counter);
    end

    wr_en = 0;
    rd_en = 0;

    // Multiple writes + wrap testing
    $display("=== Write 4 more elements for wrap-around ===");
    buf_in = 8'd10;
    repeat(4) begin
      @(posedge clk);
      wr_en = 1;
      buf_in = buf_in + 1;
      #1 $display("WRITE: in=%0h counter=%0d", buf_in, fifo_counter);
    end
    wr_en = 0;

    // Read again
    $display("=== Read again to verify wrap-around ===");
    repeat(4) begin
      @(posedge clk);
      rd_en = 1;
      #1 $display("READ: out=%0h counter=%0d", buf_out, fifo_counter);
    end
    rd_en = 0;

    $display("=== Test Complete ===");
    #20 $finish;
  end

endmodule
