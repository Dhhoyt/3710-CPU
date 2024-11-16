module rayCast_tb();

  // Inputs
  reg signed [15:0] r1x;
  reg signed [15:0] r1y;
  reg signed [15:0] r2x;
  reg signed [15:0] r2y;
  reg signed [15:0] w1x;
  reg signed [15:0] w1y;
  reg signed [15:0] w2x;
  reg signed [15:0] w2y;


  // Outputs
  wire intersection;
  wire [15:0] ray_distance;
  wire [7:0] uv_x;
  wire signed [31:0] t;
  wire signed [31:0] u;

  // Instantiate the module under test (MUT)
  rayCast uut (
    .x1(r1x),
    .y1(r1y),
    .x2(r2x),
    .y2(r2y),
    .x3(w1x),
    .y3(w1y),
    .x4(w2x),
    .y4(w2y),
    .t(t),
    .u(u),
    .intersection(intersection),
    .ray_distance(ray_distance),
    .uv_x(uv_x)
  );

  // Stride size
  parameter integer stride = (1 << 12) - 1;
  parameter integer bound = (1 << 12);

  // Loop variables
  integer i, j, k, l, m, n, o, p;

  initial begin
    // Print header for easier reading of output
    $display("r1x, r1y, r2x, r2y, w1x, w1y, w2x, w2y -> intersection, ray_distance, uv_x");

    // 8 nested loops
    for (i = -bound; i <= bound - 1; i = i + stride) begin
      for (j = -bound; j <= bound - 1; j = j + stride) begin
        for (k = -bound; k <= bound - 1; k = k + stride) begin
          for (l = -bound; l <= bound - 1; l = l + stride) begin
            for (m = -bound; m <= bound - 1; m = m + stride) begin
              for (n = -bound; n <= bound - 1; n = n + stride) begin
                for (o = -bound; o <= bound - 1; o = o + stride) begin
                  for (p = -bound; p <= bound - 1; p = p + stride) begin
                    // Apply test values to inputs
                    r1x = i;
                    r1y = j;
                    r2x = k;
                    r2y = l;
                    w1x = m;
                    w1y = n;
                    w2x = o;
                    w2y = p;

                    // Wait for a timestep to simulate propagation delay
                    #1;

                    // Output the results to the console
                    $display("%h, %h, %h, %h, %h, %h, %h, %h, %h, %h, %h, %h, %h",
                      r1x, r1y, r2x, r2y, w1x, w1y, w2x, w2y,
                      t, u,
                      intersection, ray_distance, uv_x);
                  end
                end
              end
            end
          end
        end
      end
    end

    // End simulation
    $finish;
  end

endmodule