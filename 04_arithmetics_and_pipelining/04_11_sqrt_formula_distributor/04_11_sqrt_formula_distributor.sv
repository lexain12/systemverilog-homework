module sqrt_formula_distributor
# (
    parameter formula = 1,
              impl    = 1
)
(
    input         clk,
    input         rst,

    input         arg_vld,
    input  [31:0] a,
    input  [31:0] b,
    input  [31:0] c,

    output logic res_vld,
    output logic [31:0] res
);

    // Task:
    //
    // Implement a module that will calculate formula 1 or formula 2
    // based on the parameter values. The module must be pipelined.
    // It should be able to accept new triple of arguments a, b, c arriving
    // at every clock cycle.
    //
    // The idea of the task is to implement hardware task distributor,
    // that will accept triplet of the arguments and assign the task
    // of the calculation formula 1 or formula 2 with these arguments
    // to the free FSM-based internal module.
    //
    // The first step to solve the task is to fill 03_04 and 03_05 files.
    //
    // Note 1:
    // Latency of the module "formula_1_isqrt" should be clarified from the corresponding waveform
    // or simply assumed to be equal 50 clock cycles.
    //
    // Note 2:
    // The task assumes idealized distributor (with 50 internal computational blocks),
    // because in practice engineers rarely use more than 10 modules at ones.
    // Usually people use 3-5 blocks and utilize stall in case of high load.
    //
    // Hint:
    // Instantiate sufficient number of "formula_1_impl_1_top", "formula_1_impl_2_top",
    // or "formula_2_top" modules to achieve desired performance.
    localparam N = (formula == 1) ? 13 : 51;
    
    logic [31:0] ar_a  [N];
    logic [31:0] ar_b  [N];
    logic [31:0] ar_c  [N];
    logic ar_arg_vld [N];

    logic [31:0] ar_res [N];
    logic        ar_res_vld [N];


    logic [5:0] cnt;

// -- counter --
always_ff @(posedge clk) begin
    if (rst) begin
        cnt <= '0;
    end 

    if (cnt == N - 1)
        cnt <= '0;
    else 
        cnt++;
end 

    always_comb begin 
        for (int i = 0; i < N; i++)
            ar_arg_vld[i] = '0;
        
        ar_a [cnt] = a;
        ar_b [cnt] = b;
        ar_c [cnt] = c;
        ar_arg_vld[cnt] = arg_vld;

        res_vld = ar_res_vld [cnt];
        res = ar_res[cnt];
    end

// -- pipelining --
  generate
    genvar i;
  	if (formula == 1)
        for (i = 0; i < 13; i++) begin
            formula_1_impl_2_fsm formula_1 (.clk(clk), .rst(rst), .a(ar_a[i]), .b(ar_b[i]), .c(ar_c[i]), .arg_vld(ar_arg_vld[i]), .res_vld(ar_res_vld[i]), .res(ar_res[i]));
        end 
    else if (formula == 2)
        for (i = 0; i < 51; i++) begin
            formula_2_fsm formula_2 (.clk(clk), .rst(rst), .a(ar_a[i]), .b(ar_b[i]), .c(ar_c[i]), .arg_vld(ar_arg_vld[i]), .res_vld(ar_res_vld[i]), .res(ar_res[i]));
        end
  endgenerate

endmodule
