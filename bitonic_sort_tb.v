`timescale 1ns/10ps
`define HALF_CYCLE 5.0
`define CYCLE (`HALF_CYCLE * 2.0)
`define N_PAT 10

module bitonic_sort_tb;

    parameter DATA_WIDTH = 16;
    parameter CHAN_NUM   = 8; 
    parameter DIR        = 0;
    parameter SIGNED     = 0;
    parameter PIPE_REG   = 1;
    parameter DEBUG      = 1;

    localparam K = $clog2(CHAN_NUM);
    localparam TOTAL_STAGES = K * (K + 1) / 2;

    reg clk, reset;
    reg [DATA_WIDTH*CHAN_NUM-1:0] din;
    wire [DATA_WIDTH*CHAN_NUM-1:0] dout;
    
    reg [DATA_WIDTH-1:0] pat [0:(`N_PAT * CHAN_NUM * 2)-1];
    
    integer i, j, k, err;
    reg latency_found;
    reg [DATA_WIDTH-1:0] actual;
    reg [DATA_WIDTH-1:0] expected;

    // DUT 實例化
    bitonic_sort #(
        .DATA_WIDTH(DATA_WIDTH),
        .CHAN_NUM(CHAN_NUM),
        .DIR(DIR),
        .SIGNED(SIGNED),
        .PIPE_REG(PIPE_REG)
    ) dut (
        .clk(clk),
        .data_in(din),
        .data_out(dout)
    );

    // 產生clock
    initial clk = 0;
    always #(`HALF_CYCLE) clk = ~clk;

    // 1. 加入 SDF 時間延遲檔案 (use whn GLS)
    initial begin
        `ifdef GATE
            $sdf_annotate("bitonic_sort_syn.sdf", dut);
        `endif
    end

    // 波形記錄
    initial begin
        $fsdbDumpfile("bitonic_sort.fsdb");
        $fsdbDumpvars;
        $fsdbDumpMDA;
    end


    // wait rest and circuit latency
    initial begin
        latency_found = 0;
        wait(reset == 0);
        // 等待 Pipeline 填滿 (TOTAL_STAGES 拍)
        repeat(TOTAL_STAGES) @(posedge clk);
        #1; // 避開正緣切換
        latency_found = 1;
    end

    // 主測試流程
    initial begin
        $readmemh("IN.DAT", pat);
        reset = 1'b1;
        din = 0;
        err = 0;
        #(`CYCLE * 5) reset = 1'b0; // 給時間初始化

        $display("========================================");
        $display("Bitonic Sort Gate-Level Simulation");
        $display("========================================");

        // 送入測試patterns
        for (i = 0; i < `N_PAT; i = i + 1) begin
            @(negedge clk); // 在負緣給資料，確保符合 Setup Time
            for (k = 0; k < CHAN_NUM; k = k + 1) begin
                din[k*DATA_WIDTH +: DATA_WIDTH] = pat[i*CHAN_NUM + k];
            end
        end
        @(negedge clk) din = 0;
    end

    // 在 negedge 檢查，確保資料已經穩定
    initial begin
        wait(latency_found);
        
        $display("Starting Output Verification (Latency: %0d)...", TOTAL_STAGES);

        for (j = 0; j < `N_PAT; j = j + 1) begin
            @(negedge clk); // 在負緣採樣 GLS 的輸出
            
            if (DEBUG) $display("\nChecking Set %0d:", j);
            
            for (k = 0; k < CHAN_NUM; k = k + 1) begin
                actual = dout[k*DATA_WIDTH +: DATA_WIDTH];
                expected = pat[(`N_PAT * CHAN_NUM) + (j * CHAN_NUM) + k];
                
                if (actual !== expected) begin
                    err = err + 1;
                    $display("  [%0d] Got: %h, Exp: %h <- ERROR", k, actual, expected);
                end else begin
                    $display("  [%0d] Got: %h, Exp: %h <- CORRECT", k, actual, expected);
                end
            end
        end

        // 輸出結果
        $display("========================================");
        $display("Errors Found: %0d", err);
        if (err == 0) $display("*** TEST PASSED *** :)");
        else $display("*** TEST FAILED ***");
        $display("========================================");
        #(`CYCLE * 5);
        $finish;
    end

endmodule
