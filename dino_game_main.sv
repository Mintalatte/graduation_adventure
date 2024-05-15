
module dino_game_main( input               CLOCK_50,
             // VGA Interface 
             output logic [7:0]  VGA_R,        //VGA Red
                                 VGA_G,        //VGA Green
                                 VGA_B,        //VGA Blue
             output logic        VGA_CLK,      //VGA Clock
                                 VGA_SYNC_N,   //VGA Sync signal
                                 VGA_BLANK_N,  //VGA Blank signal
                                 VGA_VS,       //VGA virtical sync signal
                                 VGA_HS,       //VGA horizontal sync signal
             // CY7C67200 Interface
             inout  wire  [15:0] OTG_DATA,     //CY7C67200 Data bus 16 Bits
             output logic [1:0]  OTG_ADDR,     //CY7C67200 Address 2 Bits
             output logic        OTG_CS_N,     //CY7C67200 Chip Select
                                 OTG_RD_N,     //CY7C67200 Write
                                 OTG_WR_N,     //CY7C67200 Read
                                 OTG_RST_N,    //CY7C67200 Reset
             input               OTG_INT,      //CY7C67200 Interrupt
             // SDRAM Interface for Nios II Software
             output logic [12:0] DRAM_ADDR,    //SDRAM Address 13 Bits
             inout  wire  [31:0] DRAM_DQ,      //SDRAM Data 32 Bits
             output logic [1:0]  DRAM_BA,      //SDRAM Bank Address 2 Bits
             output logic [3:0]  DRAM_DQM,     //SDRAM Data Mast 4 Bits
             output logic        DRAM_RAS_N,   //SDRAM Row Address Strobe
                                 DRAM_CAS_N,   //SDRAM Column Address Strobe
                                 DRAM_CKE,     //SDRAM Clock Enable
                                 DRAM_WE_N,    //SDRAM Write Enable
                                 DRAM_CS_N,    //SDRAM Chip Select
                                 DRAM_CLK      //SDRAM Clock
                    );
    
    logic Reset_h, Clk;
    logic [7:0] keycode;

    logic key_pressed;
    logic game_over;
    logic JMP_START, JMP_END;
    logic [1:0] dino_pose;
    logic [7:0] counter_value;

    logic occupied;             // by ball or obstacle
    logic state_machine_clock;
    
    assign Clk = CLOCK_50;

    // used for state_machine
    always_ff @ (posedge Clk)
    begin
        if (keycode == 8'h04) begin
            key_pressed = 1;
        end
        else begin
            key_pressed = 0;
        end
    end

    // state_machine_clock generation
    counter main_clock_counter(
        .counter_clk(Clk),
        .reset(0),
        .counter_value(counter_value)
    );
    always_ff @ (posedge Clk or posedge Reset_h)
    begin
        if (Reset_h)
            state_machine_clock <= 0;
        else if (counter_value[2] & counter_value[1] & counter_value[0])
            state_machine_clock <= ~ (state_machine_clock);
    end

    logic [1:0] hpi_addr;
    logic [15:0] hpi_data_in, hpi_data_out;
    logic hpi_r, hpi_w, hpi_cs, hpi_reset;
	 
	logic [9:0] DrawX, DrawY;
    logic [9:0] shifted_x;            // address using byte
    
    // Interface between NIOS II and EZ-OTG chip
    hpi_io_intf hpi_io_inst(
                            .Clk(Clk),
                            .Reset(Reset_h),
                            // signals connected to NIOS II
                            .from_sw_address(hpi_addr),
                            .from_sw_data_in(hpi_data_in),
                            .from_sw_data_out(hpi_data_out),
                            .from_sw_r(hpi_r),
                            .from_sw_w(hpi_w),
                            .from_sw_cs(hpi_cs),
                            .from_sw_reset(hpi_reset),
                            // signals connected to EZ-OTG chip
                            .OTG_DATA(OTG_DATA),    
                            .OTG_ADDR(OTG_ADDR),    
                            .OTG_RD_N(OTG_RD_N),    
                            .OTG_WR_N(OTG_WR_N),    
                            .OTG_CS_N(OTG_CS_N),
                            .OTG_RST_N(OTG_RST_N)
    );
     
     // You need to make sure that the port names here match the ports in Qsys-generated codes.
     final_soc nios_system(
                             .clk_clk(Clk),         
                             .reset_reset_n(1'b1),    // Never reset NIOS
                             .sdram_wire_addr(DRAM_ADDR), 
                             .sdram_wire_ba(DRAM_BA),   
                             .sdram_wire_cas_n(DRAM_CAS_N),
                             .sdram_wire_cke(DRAM_CKE),  
                             .sdram_wire_cs_n(DRAM_CS_N), 
                             .sdram_wire_dq(DRAM_DQ),   
                             .sdram_wire_dqm(DRAM_DQM),  
                             .sdram_wire_ras_n(DRAM_RAS_N),
                             .sdram_wire_we_n(DRAM_WE_N), 
                             .sdram_clk_clk(DRAM_CLK),
                             .keycode_export(keycode),  
                             .otg_hpi_address_export(hpi_addr),
                             .otg_hpi_data_in_port(hpi_data_in),
                             .otg_hpi_data_out_port(hpi_data_out),
                             .otg_hpi_cs_export(hpi_cs),
                             .otg_hpi_r_export(hpi_r),
                             .otg_hpi_w_export(hpi_w),
                             .otg_hpi_reset_export(hpi_reset)
    );
    
    // Use PLL to generate the 25MHZ VGA_CLK.
    // You will have to generate it on your own in simulation.
    vga_clk vga_clk_instance(.inclk0(Clk), .c0(VGA_CLK));
    
    // TODO: Fill in the connections for the rest of the modules 
    VGA_controller vga_controller_instance(// input
	                                        .Clk(Clk),         
                                           .Reset(Reset_h), 
														 .VGA_CLK(VGA_CLK),
							                      //output							 
                                           .VGA_HS(VGA_HS),      
                                           .VGA_VS(VGA_VS), 
                                           .VGA_BLANK_N(VGA_BLANK_N), 
                                           .VGA_SYNC_N(VGA_SYNC_N), 
                                           .DrawX(DrawX),       
                                           .DrawY(DrawY)
														 );
    
    // Which signal should be frame_clk?
    dino dino_instance(// input
	                    .Clk(Clk),         
	                    .Reset(Reset_h),				  
	                    .frame_clk(VGA_VS),   
	                    .DrawX(DrawX), 
						.DrawY(DrawY),
                        .dino_pose(dino_pose[1:0]),
							  // output
	                    .occupied(occupied)   
						     );	
							
							
    state_machine states(
                        .Clk(state_machine_clock),
                        .key_pressed(key_pressed),		
                        .game_over(game_over),
                        .JMP_END(JMP_END),
                        .JMP_START(JMP_START),
                        .dino_pose(dino_pose[1:0]),
                        .shifted_x(shifted_x[8:0])  
	 );
    

    color_mapper color_instance(// input
                                .occupied(occupied),                 
                                .DrawX(DrawX), 
                                .DrawY(DrawY),
                                    // output				  
                                .VGA_R(VGA_R), 
                                .VGA_G(VGA_G), 
                                .VGA_B(VGA_B)
	 );
    /**************************************************************************************
        ATTENTION! Please answer the following quesiton in your lab report! Points will be allocated for the answers!
        Hidden Question #1/2:
        What are the advantages and/or disadvantages of using a USB interface over PS/2 interface to
             connect to the keyboard? List any two.  Give an answer in your Post-Lab.
    **************************************************************************************/
endmodule
