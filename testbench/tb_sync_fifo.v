module tb_sync_fifo;

    parameter DATA_WIDTH = 8;
    parameter DEPTH      = 16;

    reg                    clk;
    reg                    rst_n;
    reg                    wr_en;
    reg                    rd_en;
    reg  [DATA_WIDTH-1:0]  wr_data;
    wire [DATA_WIDTH-1:0]  rd_data;
    wire                   full;
    wire                   empty;
    wire [$clog2(DEPTH):0] count;

    
    sync_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .wr_data(wr_data),
        .rd_data(rd_data),
        .full(full),
        .empty(empty),
        .count(count)
    );

    
    always #5 clk = ~clk;

    integer i;
    integer err_count = 0;

    
    task write(input [DATA_WIDTH-1:0] data);
        begin
            @(posedge clk);
            wr_en   <= 1;
            wr_data <= data;
            @(posedge clk);
            wr_en   <= 0;
        end
    endtask

    
    task read_and_check(input [DATA_WIDTH-1:0] expected);
        begin
            @(posedge clk);
            rd_en <= 1;
            @(posedge clk);
            rd_en <= 0;
            @(negedge clk); 
            if (rd_data !== expected) begin
                $display("[FAIL] Expected %0h, Got %0h at time %0t", expected, rd_data, $time);
                err_count = err_count + 1;
            end else
                $display("[PASS] Read %0h", rd_data);
        end
    endtask

    initial begin
        
        clk     = 0;
        rst_n   = 0;
        wr_en   = 0;
        rd_en   = 0;
        wr_data = 0;

        
        repeat(3) @(posedge clk);
        rst_n = 1;
        @(posedge clk);

       
        $display("\n--- TEST 1: Empty flag after reset ---");
        if (empty !== 1 || full !== 0 || count !== 0)
            $display("[FAIL] Flags wrong after reset");
        else
            $display("[PASS] empty=1, full=0, count=0");

        
        $display("\n--- TEST 2: Write 4, read 4 (FIFO order) ---");
        for (i = 0; i < 4; i = i + 1)
            write(8'hA0 + i);

        if (count !== 4)
            $display("[FAIL] Count should be 4, got %0d", count);
        else
            $display("[PASS] Count = 4 after 4 writes");

        for (i = 0; i < 4; i = i + 1)
            read_and_check(8'hA0 + i);

        
        $display("\n--- TEST 3: Fill FIFO to full ---");
        for (i = 0; i < DEPTH; i = i + 1)
            write(i[DATA_WIDTH-1:0]);

        @(posedge clk);
        if (full !== 1 || count !== DEPTH)
            $display("[FAIL] full=%0b, count=%0d", full, count);
        else
            $display("[PASS] FIFO full, count=%0d", count);

        
        $display("\n--- TEST 4: Write when full (overflow guard) ---");
        write(8'hFF);
        @(posedge clk);
        if (count !== DEPTH)
            $display("[FAIL] Count changed on full write: %0d", count);
        else
            $display("[PASS] Write ignored when full");

        
        $display("\n--- TEST 5: Drain entire FIFO ---");
        for (i = 0; i < DEPTH; i = i + 1)
            read_and_check(i[DATA_WIDTH-1:0]);

        @(posedge clk);
        if (empty !== 1)
            $display("[FAIL] Not empty after drain");
        else
            $display("[PASS] FIFO empty after drain");

        
        $display("\n--- TEST 6: Read when empty (underflow guard) ---");
        @(posedge clk);
        rd_en <= 1;
        @(posedge clk);
        rd_en <= 0;
        @(posedge clk);
        if (count !== 0)
            $display("[FAIL] Count changed on empty read: %0d", count);
        else
            $display("[PASS] Read ignored when empty");

        
        $display("\n--- TEST 7: Simultaneous read/write ---");
        write(8'hBB); 
        @(posedge clk);
        wr_en   <= 1;
        rd_en   <= 1;
        wr_data <= 8'hCC;
        @(posedge clk);
        wr_en <= 0;
        rd_en <= 0;
        @(negedge clk);
        if (count !== 1)
            $display("[FAIL] Count should stay 1, got %0d", count);
        else
            $display("[PASS] Simultaneous r/w, count stable at 1");

        
        read_and_check(8'hCC);

        
        $display("\n===========================");
        if (err_count == 0)
            $display("ALL TESTS PASSED");
        else
            $display("%0d FAILURES", err_count);
        $display("===========================\n");

        $finish;
    end

    // Waveform dump
    initial begin
        $dumpfile("sync_fifo_tb.vcd");
        $dumpvars(0, tb_sync_fifo);
    end

endmodule
