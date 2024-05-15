module  counter (  input logic     counter_clk,
                        input logic     reset,   
                        output logic [7:0] counter_value
                     );
    always @ (posedge counter_clk) begin
        if (reset)
            counter_value <=0;
        else
            counter_value <= counter_value + 1;
    end
    
endmodule