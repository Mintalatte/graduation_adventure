//------------------------------------------------------------------------------
// Company:          UIUC ECE Dept.
// Engineer:         Stephen Kempf
//
// Create Date:    17:44:03 10/08/06
// Design Name:    ECE 385 Lab 6 Given Code - Incomplete ISDU
// Module Name:    ISDU - Behavioral
//
// Comments:
//    Revised 03-22-2007
//    Spring 2007 Distribution
//    Revised 07-26-2013
//    Spring 2015 Distribution
//    Revised 02-13-2017
//    Spring 2017 Distribution
//------------------------------------------------------------------------------


module state_machine (   input logic         Clk, 
									Reset,
									Run,
									Continue,
									
				input logic         key_pressed,
                input logic         game_over,
                input logic         JMP_END,

                output logic        JMP_START,
                output logic [1:0]  dino_pose,          // used to draw different dino
                output logic [8:0]  shifted_x           // byte !!!!!!!									
				);

	enum logic [4:0] {  start_state,
                        
                        run1,
                        run2,    
                        jump,
                        
                        stop
                    
                    }   State, Next_state;   // Internal state logic
						
		
always_ff @ (posedge Clk)
begin
    if (Reset) 
        State <= start_state;
    else 
        State <= Next_state;
end

always_ff @ (posedge Clk)
begin
    if (Reset)
        shifted_x <= 9'b0; // Reset shifted_x to 0 when Reset is asserted
    else
        shifted_x <= shifted_x + 1; // Increment shifted_x on each clock cycle
end

always_comb
begin 
    // Default next state is staying at current state
    Next_state = State;
    
    // Default controls signal values
    JMP_START = 1'b0;
    dino_pose = 2'b00;

    // Assign next state
    unique case (State)
        start_state : 
        begin
            if (key_pressed) 
                Next_state = run1;    
        end

        run1 : 
        begin
            if (game_over)
                Next_state = stop;
            else if (key_pressed)
                Next_state = jump;
            else
                Next_state = run2;
        end

        run2 : 
        begin
            if (game_over)
                Next_state = stop;
            else if (key_pressed)
                Next_state = jump;
            else
                Next_state = run1;
        end

        jump : 
        begin
            if (game_over)
                Next_state = stop;
            else if (JMP_END)
                Next_state = run1;
            else
                Next_state = jump;
        end

        stop :
        begin
            if (key_pressed)
                Next_state = start_state;
            else 
                Next_state = stop;
        end  
        default : ;
    endcase
    
    // Assign control signals based on current state
    case (State)
        start_state: 
        begin
            JMP_START = 1'b0;
        end
        run1:  
        begin
            dino_pose = 2'b00;
        end
        run2:
        begin
            dino_pose = 2'b01;
        end
        jump:
        begin
            dino_pose = 2'b10;
            JMP_START = 1'b1;
        end
        stop:
        begin
            dino_pose = 2'b11;
        end
        default : ;
    endcase
end 

	
endmodule
