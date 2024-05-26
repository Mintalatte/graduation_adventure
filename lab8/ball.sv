//-------------------------------------------------------------------------
//    Ball.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//                                                                       --
//    Modified by Stephen Kempf 03-01-2006                               --
//                              03-12-2007                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  12-08-2017                               --
//    Spring 2018 Distribution                                           --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    UIUC ECE Department                                                --
//-------------------------------------------------------------------------


module  ball ( input         Clk,                // 50 MHz clock
                             Reset,              // Active-high reset signal
                             frame_clk,          // The clock indicating a new frame (~60Hz)
               input [9:0]   DrawX, DrawY,       // Current pixel coordinates
               input [7:0]   keycode,				 // Keycode
					output logic  is_ball,             // Whether current pixel belongs to ball or background
					output logic  is_tree
              );
    
	 // TODO: change original position
    parameter [9:0] Ball_X_Center = 10'd160;  // Center position on the X axis
    parameter [9:0] Ball_Y_Center = 10'd430;  // Center position on the Y axis
    parameter [9:0] Ball_X_Min = 10'd0;       // Leftmost point on the X axis
    parameter [9:0] Ball_X_Max = 10'd639;     // Rightmost point on the X axis
	 parameter [9:0] Ball_Y_Min = 10'd250;       // Topmost point on the Y axis
    parameter [9:0] Ball_Y_Max = 10'd470;     // Bottommost point on the Y axis
    parameter [9:0] Ball_X_Step = 10'd1;      // Step size on the X axis
    parameter [9:0] Ball_Y_Step = 10'd3;      // Step size on the Y axis
	 
	 parameter [9:0] Tree_X_Center = 10'd639;  // Center position on the X axis
    parameter [9:0] Tree_Y_Center = 10'd425;  // Center position on the Y axis
    parameter [9:0] Tree_X_Min = 10'd0;       // Leftmost point on the X axis
    parameter [9:0] Tree_X_Max = 10'd639;     // Rightmost point on the X axis
	 parameter [9:0] Tree_X_Step = 10'd2;      // Step size on the X axis
    parameter [9:0] Tree_Y_Step = 10'd1;      // Step size on the Y axis
	 
	 parameter [9:0] dino_width = 10'd20;        
	 parameter [9:0] dino_height = 10'd40;       
	 
	 parameter [9:0] tree_width = 10'd15;        
	 parameter [9:0] tree_height = 10'd45;   
	 
    
    logic [9:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion;
    logic [9:0] Ball_X_Pos_in, Ball_X_Motion_in, Ball_Y_Pos_in, Ball_Y_Motion_in;
	 
	 logic [9:0] Tree_X_Pos, Tree_X_Motion, Tree_Y_Pos, Tree_Y_Motion;
	 logic [9:0] Tree_X_Pos_in, Tree_X_Motion_in, Tree_Y_Pos_in, Tree_Y_Motion_in;
    
    // Detect rising edge of frame_clk
    logic frame_clk_delayed, frame_clk_rising_edge;
    always_ff @ (posedge Clk) begin
        frame_clk_delayed <= frame_clk;
        frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
    end
    // Update registers
    always_ff @ (posedge Clk)
    begin
        if (Reset)
        begin
            Ball_X_Pos <= Ball_X_Center;
            Ball_Y_Pos <= Ball_Y_Center;
            Ball_X_Motion <= 10'd0;
            Ball_Y_Motion <= 10'd0;
				
				Tree_X_Pos <= Tree_X_Center;
            Tree_Y_Pos <= Tree_Y_Center;
            Tree_X_Motion <= (~(Tree_X_Step) + 1'b1);
            Tree_Y_Motion <= 10'd0;
        end
        else if (~(is_ball && is_tree))
        begin
            Ball_X_Pos <= Ball_X_Pos_in;
            Ball_Y_Pos <= Ball_Y_Pos_in;
            Ball_X_Motion <= Ball_X_Motion_in;
            Ball_Y_Motion <= Ball_Y_Motion_in;
				
				Tree_X_Pos <= Tree_X_Pos_in;
            Tree_Y_Pos <= Tree_Y_Pos_in;
            Tree_X_Motion <= Tree_X_Motion_in;
            Tree_Y_Motion <= Tree_Y_Motion_in;
        end
		  else
		  begin
            Ball_X_Motion <= 0;
            Ball_Y_Motion <= 0;
				
            Tree_X_Motion <= 0;
            Tree_Y_Motion <= 0;
		  end
    end
    
    // You need to modify always_comb block.
    always_comb
    begin
        // By default, keep motion and position unchanged
        Ball_X_Pos_in = Ball_X_Pos;
        Ball_Y_Pos_in = Ball_Y_Pos;
        Ball_X_Motion_in = Ball_X_Motion;
        Ball_Y_Motion_in = Ball_Y_Motion;
        
		  Tree_X_Pos_in = Tree_X_Pos;
        Tree_Y_Pos_in = Tree_Y_Pos;
        Tree_X_Motion_in = Tree_X_Motion;
        Tree_Y_Motion_in = Tree_Y_Motion;
		  
        // Update position and motion only at rising edge of frame clock
        if (frame_clk_rising_edge)
        begin
			   if( Ball_Y_Pos + dino_height >= Ball_Y_Max && (keycode != 8'h2c) )  // Ball is at the bottom edge, BOUNCE!
                Ball_Y_Motion_in = 0;
            else if ( Ball_Y_Pos <= Ball_Y_Min + dino_height )  // Ball is at the top edge, BOUNCE!
                Ball_Y_Motion_in = Ball_Y_Step;
				else if( Ball_Y_Pos + dino_height >= Ball_Y_Max &&  (keycode == 8'h2c))
					begin
					Ball_Y_Motion_in = (~Ball_Y_Step + 1'b1);
					Ball_X_Motion_in = 0;
					end
					
					
				// Tree	
            if ( Tree_X_Pos <= Tree_X_Min)  // Ball is at the top edge, BOUNCE!
                Tree_X_Pos_in = Tree_X_Max;

					 // Update the ball's position with its motion
            Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion;	
            Tree_X_Pos_in = Tree_X_Pos + Tree_X_Motion;
        end

    end

    always_comb begin
		 if ( (DrawX <= Ball_X_Pos + dino_width) && ( DrawX >= Ball_X_Pos) && (DrawY <= Ball_Y_Pos + dino_height) && ( DrawY >= Ball_Y_Pos) )
            is_ball = 1'b1;
       else
            is_ball = 1'b0;
			  
		 if ( (DrawX <= Tree_X_Pos + tree_width) && ( DrawX >= Tree_X_Pos) && (DrawY <= Tree_Y_Pos + tree_height) && ( DrawY >= Tree_Y_Pos) )
            is_tree = 1'b1;
       else
            is_tree = 1'b0;
    end
    
	 
endmodule
