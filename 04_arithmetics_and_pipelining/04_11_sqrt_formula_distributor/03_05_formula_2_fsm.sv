//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_2_fsm
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

    output logic        isqrt_x_vld,
    output logic [31:0] isqrt_x,

    input               isqrt_y_vld,
    input        [15:0] isqrt_y
);
    // Task:
    // Implement a module that calculates the formula from the `formula_2_fn.svh` file
    // using only one instance of the isqrt module.
    //
    // Design the FSM to calculate answer step-by-step and provide the correct `res` value
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm

    enum logic [2:0] {
       idle,
        calc_c,
        wait_c,
        calc_b,
        wait_b,
        calc_a,
        wait_a,
        done 
    }
    state, next;

    logic [31:0] a_reg, b_reg, c_reg;
    logic [31:0] bc_sum;
    logic [31:0] abc_sum;

    always_comb 
    begin
        next = state;

        res_vld = 0;
        res = 0;
        isqrt_x_vld = 0;
        isqrt_x = 0;

        case (state)
            idle: 
                if (arg_vld) 
                    next = calc_c;

            calc_c: 
            begin
                isqrt_x_vld = 1;
                isqrt_x = c_reg;
                next = wait_c;
            end

            wait_c: 
                if (isqrt_y_vld) 
                    next = calc_b;

            calc_b: 
            begin
                isqrt_x_vld = 1;
                isqrt_x = bc_sum;
                next = wait_b;
            end

            wait_b: 
                if (isqrt_y_vld) 
                    next = calc_a;

            calc_a: 
            begin
                isqrt_x_vld = 1;
                isqrt_x = abc_sum;
                next = wait_a;
            end

            wait_a: 
                if (isqrt_y_vld) 
                    next =  done;

             done: 
            begin
                res_vld = 1;
                res = isqrt_y;
                next = idle;
            end
        endcase
    end

    always_ff @(posedge clk) 
    begin
        if (rst)
            state <= idle;
        else
            state <= next;
    end

    always_ff @(posedge clk) 
    begin
        if (state == idle && arg_vld) 
        begin
            a_reg <= a;
            b_reg <= b;
            c_reg <= c;
        end

        if (state == wait_c && isqrt_y_vld) 
        begin
            bc_sum <= b_reg + isqrt_y;
        end

        if (state == wait_b && isqrt_y_vld) 
        begin
            abc_sum <= a_reg + isqrt_y;
        end
    end


endmodule
