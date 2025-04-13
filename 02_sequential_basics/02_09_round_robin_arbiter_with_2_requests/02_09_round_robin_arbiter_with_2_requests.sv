//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module round_robin_arbiter_with_2_requests
(
    input        clk,
    input        rst,
    input  [1:0] requests,
    output logic [1:0] grants
);
    // Task:
    // Implement a "arbiter" module that accepts up to two requests
    // and grants one of them to operate in a round-robin manner.
    //
    // The module should maintain an internal register
    // to keep track of which requester is next in line for a grant.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.
    //
    // Example:
    // requests -> 01 00 10 11 11 00 11 00 11 11
    // grants   -> 01 00 10 01 10 00 01 00 10 01

 logic priority_flag;

always_comb begin
    if (requests == 2'b00) 
        assign grants = 2'b00;
    else if (requests == 2'b01) 
        assign grants = 2'b01 ;
    else if (requests == 2'b10)
        assign grants = 2'b10;
    else if (priority_flag == 1'b0) 
        assign grants =  2'b10;
    else 
        assign grants = 2'b01;
end

    always_ff @(posedge clk) 
    begin
        if (rst)
            priority_flag <= 0;
        else if (requests == 2'b01)
            priority_flag <= 0;
        else if (requests == 2'b10)
            priority_flag <= 1;
        else if (requests == 2'b11)
            priority_flag <= ~priority_flag;
    end



endmodule
