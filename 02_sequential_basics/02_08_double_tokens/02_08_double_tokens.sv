//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module double_tokens
(
    input        clk,
    input        rst,
    input        a,
    output       b,
    output logic overflow
);
    // Task:
    // Implement a serial module that doubles each incoming token '1' two times.
    // The module should handle doubling for at least 200 tokens '1' arriving in a row.
    //
    // In case module detects more than 200 sequential tokens '1', it should assert
    // an overflow error. The overflow error should be sticky. Once the error is on,
    // the only way to clear it is by using the "rst" reset signal.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.
    //
    // Example:
    // a -> 10010011000110100001100100
    // b -> 11011011110111111001111110
    logic [7:0] count;
    logic b_r;

    always_ff @(posedge clk) 
    begin 
        if (rst) begin
            count <= 0;
            overflow <= 0;
        end
        else if (a) begin
            count <= count + 2;
            if (count > 200)
                overflow <= 1;
        end
        if (count > 0) begin
            count <= count - 1;
            b_r <= 1;
        end
        else 
            b_r <= 0;
    
    end

    assign b = b_r;

endmodule
