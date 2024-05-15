
module  dino ( input         Clk,                // 50 MHz clock
                             Reset,              // Active-high reset signal
                             frame_clk,          // The clock indicating a new frame (~60Hz)
               input [9:0]   DrawX, DrawY,       // Current pixel coordinates
               input [9:0]   shifted_x,          // shifted_x in BYTES
			   output logic  occupied             
              );
    
    logic[7:0]  map_byte;
    logic       map_occupy;
    logic       dino_occupy;
    // deal with map first
    map_rom full_map(.addr(Address),
					 .data(map_byte)
						);	

    assign Address = {DrawY[9:0], 9'b000000000} + shifted_x + DrawX[9:3];         // map_rom is byte addressable
    assign map_occupy = map_byte[DrawX[2:0]];           // pixel index within one byte

    // TODO: only for map. Should modify after dino finished
    assign occupied = map_occupy;

endmodule
