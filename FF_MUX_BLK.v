module FF_MUX_BLK(d,clk,rst,en,q);
    parameter DATA_WIDTH= 18;
    parameter PIPELINE= 1'b1;
    parameter RSTTYPE= "SYNC";

    input [DATA_WIDTH-1:0] d;
    input clk,rst,en;
    output reg [DATA_WIDTH-1:0] q;
    
    generate
        if (PIPELINE== 1'b1) begin
            if(RSTTYPE=="SYNC")begin
                always @(posedge clk)begin
                    if(rst) q<=0;
                    else if(en) q<=d;
                end
            end
            else if (RSTTYPE=="ASYNC") begin
                always @(posedge clk or posedge rst) begin
                    if(rst) q<=0;
                    else if (en) q<=d;
                end
            end
        end

        else begin
            always @* begin
               if(en) q=d;
            end
        end
    endgenerate
    
endmodule