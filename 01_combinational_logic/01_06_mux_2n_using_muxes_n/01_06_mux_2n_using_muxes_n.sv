//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module mux_2_1
(
  input  [3:0] d0, d1,
  input        sel,
  output [3:0] y
);

  assign y = sel ? d1 : d0;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module mux_4_1
(
  input  [3:0] d0, d1, d2, d3,
  input  [1:0] sel,
  output [3:0] y
);

  // Task:
  // Implement mux_4_1 using three instances of mux_2_1

  logic [3:0] LSB_1;
  logic [3:0] LSB_2;

  mux_2_1 LSB1 (
      d0,
      d1,
      sel[0],
      LSB_1
  );
  mux_2_1 LSB2 (
      d2,
      d3,
      sel[0],
      LSB_2
  );

  mux_2_1 MSB (
      LSB_1,
      LSB_2,
      sel[1],
      y
  );


endmodule
