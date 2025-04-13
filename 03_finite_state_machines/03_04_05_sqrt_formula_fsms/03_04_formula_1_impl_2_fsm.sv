//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_1_impl_2_fsm
(
    input               clk,
    input               rst,

    input               arg_vld,
    input        [31:0] a,
    input        [31:0] b,
    input        [31:0] c,

    output logic        res_vld,
    output logic [31:0] res,

    // isqrt interface

    output logic        isqrt_1_x_vld,
    output logic [31:0] isqrt_1_x,

    input               isqrt_1_y_vld,
    input        [15:0] isqrt_1_y,

    output logic        isqrt_2_x_vld,
    output logic [31:0] isqrt_2_x,

    input               isqrt_2_y_vld,
    input        [15:0] isqrt_2_y
);

    // Task:
    // Implement a module that calculates the formula from the `formula_1_fn.svh` file
    // using two instances of the isqrt module in parallel.
    //
    // Design the FSM to calculate an answer and provide the correct `res` value
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm


    enum logic [2:0] {
        idle,
        calc_ab,
        wait_ab,
        calc_c,
        wait_c,
        done
    } 
    state, new_state;

    logic [31:0] a_reg,  b_reg,  c_reg;
    logic [15:0] a_sqrt, b_sqrt, c_sqrt;

    always_comb 
    begin
        new_state = state;

        res_vld = 0;
        res = 0;
        isqrt_1_x_vld = 0;
        isqrt_2_x_vld = 0;
        isqrt_1_x = 0;
        isqrt_2_x = 0;

        case (state)
            idle: 
            begin
                if (arg_vld) 
                    new_state = calc_ab;
            end

            calc_ab: 
            begin
                isqrt_1_x_vld = 1;
                isqrt_1_x = a_reg;
                isqrt_2_x_vld = 1;
                isqrt_2_x = b_reg;
                new_state = wait_ab;
            end

            wait_ab: 
                if (isqrt_1_y_vld && isqrt_2_y_vld) 
                    new_state = calc_c;

            calc_c: 
            begin
                isqrt_1_x_vld = 1;
                isqrt_1_x = c_reg;
                new_state = wait_c;
            end

            wait_c: 
                if (isqrt_1_y_vld) 
                    new_state = done;

            done: 
            begin
                res_vld = 1;
                res = a_sqrt + b_sqrt + c_sqrt;
                new_state = idle;
            end
        endcase
    end


    always_ff @(posedge clk) 
    begin
        if (rst)
            state <= idle;
        else
            state <= new_state;

        if (arg_vld && state == idle) 
        begin
            a_reg <= a;
            b_reg <= b;
            c_reg <= c;
        end

        if (state == wait_ab) 
        begin
            if (isqrt_1_y_vld) 
                a_sqrt <= isqrt_1_y;
            if (isqrt_2_y_vld) 
                b_sqrt <= isqrt_2_y;
        end

        if (state == wait_c && isqrt_1_y_vld) 
            c_sqrt <= isqrt_1_y;
    end


endmodule
