/*******************************************************************************
* Sine/Cosine Calculator using Quarter-Wave Symmetry
*
* This module efficiently computes sine and cosine values using a lookup table
* and quarter-wave symmetry properties. It reduces memory requirements by storing
* only the first quarter of the sine wave and deriving other values through symmetry.
*
* Fixed-Point Format:
* - Input angle and outputs use Q8.8 format (8 integer bits, 8 fractional bits)
* - Input angle range is interpreted as [0, 2π) in radians
* - Output range is [-1, 1] in fixed-point representation
*
* Memory Optimization:
* - Uses 512-entry LUT for first quadrant (0 to π/2)
* - Other quadrants derived through symmetry rules
* - Shared LUT between sine and cosine calculations
*******************************************************************************/

module sin_cos(
   input signed [15:0] angle,   // Input angle in Q8.8 format, [0, 2π)
   output signed [15:0] sine,   // Sine output in Q8.8 format, [-1, 1]
   output signed [15:0] cosine  // Cosine output in Q8.8 format, [-1, 1]
);
   // LUT with 512 entries storing first quadrant of sine wave
   // Values are in Q8.8 format for [-1, 1] range
   reg signed [15:0] sin_lut [511:0];

   // Initialize LUT from precomputed values
   initial begin
       $readmemh("sin_lut.hex", sin_lut);
   end

   // Extract normalized angle components
   wire [10:0] norm_angle = angle[10:0];    // Normalize to [0, 2π)
   wire [8:0] lut_index = angle[8:0];       // Index into LUT (0-511)

   // Determine quadrant from upper bits of normalized angle
   // 00: 0 to π/2     - First quadrant
   // 01: π/2 to π     - Second quadrant
   // 10: π to 3π/2    - Third quadrant
   // 11: 3π/2 to 2π   - Fourth quadrant
   wire [1:0] quadrant = norm_angle[10:9];

   // Calculate sine using quarter-wave symmetry:
   // Q1: direct lookup
   // Q2: mirror index (511 - index)
   // Q3: negative of Q1
   // Q4: negative of Q2
   assign sine = (quadrant == 2'b00) ? sin_lut[lut_index] :           // Q1
                (quadrant == 2'b01) ? sin_lut[511 - lut_index] :      // Q2
                (quadrant == 2'b10) ? -sin_lut[lut_index] :           // Q3
                                    -sin_lut[511 - lut_index];        // Q4

   // Calculate cosine using same LUT but shifted by π/2
   // This is equivalent to sine(x + π/2), implemented by:
   // Q1: lookup from end of table (511 - index)
   // Q2: negative lookup from start
   // Q3: negative lookup from end
   // Q4: direct lookup from start
   assign cosine = (quadrant == 2'b00) ? sin_lut[511 - lut_index] :   // Q1
                  (quadrant == 2'b01) ? -sin_lut[lut_index] :         // Q2
                  (quadrant == 2'b10) ? -sin_lut[511 - lut_index] :   // Q3
                                      sin_lut[lut_index];            // Q4
endmodule
