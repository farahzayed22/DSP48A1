module DSP48A1( A, B,BCIN, D, C, CARRYIN, clk, OPMODE, CEA, CEB, CEC, CECARRYIN, CED, CEM, CEOPMODE, CEP,
                RSTA, RSTB, RSTC, RSTCARRYIN, RSTD, RSTM, RSTOPMODE, RSTP, PCIN, PCOUT, BCOUT, M, P, CARRYOUT, CARRYOUTF);

    parameter A0REG = 1'b0;
    parameter A1REG = 1'b1;
    parameter B0REG = 1'b0;
    parameter B1REG = 1'b1;
    parameter CREG  = 1'b1;
    parameter DREG  = 1'b1;
    parameter MREG  = 1'b1;
    parameter PREG  = 1'b1;
    parameter CARRYINREG = 1'b1;
    parameter CARRYOUTREG = 1'b1;
    parameter OPMODEREG = 1'b1;
    parameter CARRYINSEL = "OPMODE5";
    parameter B_INPUT = "DIRECT";
    parameter RSTTYPE = "SYNC";

    // Data Input Ports
    input [17:0] A, B, BCIN, D;
    input [47:0] C;
    input CARRYIN;
    
    // Control Input Ports
    input clk;
    input [7:0] OPMODE;
    
    // Clock Enable Input Ports
    input CEA, CEB, CEC, CECARRYIN, CED, CEM, CEOPMODE, CEP;
    
    // Reset Input Ports
    input RSTA, RSTB, RSTC, RSTCARRYIN, RSTD, RSTM, RSTOPMODE, RSTP;
    
    // Cascade Ports
    input  [47:0] PCIN;
    output [47:0] PCOUT;
    output [17:0] BCOUT;
    
    // Data Output Ports
    output [35:0] M;
    output [47:0] P;
    output CARRYOUT, CARRYOUTF;
    
    reg  [47:0] X, Z;
    reg  [47:0] p_reg_in;
    reg  cyo_in_reg;
    wire [17:0] a0_reg_out, b0_reg_in, b0_reg_out, d_reg_out;
    wire [47:0] c_reg_out;
    wire [17:0] add_sub_sg1;
    wire [7:0]  opmode_reg_out;
    wire carryin_reg_out;
    wire [17:0] b1_reg_in, b1_reg_out;
    wire [17:0] a1_reg_out;
    wire [35:0] m_reg_in, m_reg_out;
    wire [47:0] p_reg_out;
    wire cin_mux_out;
    
    ////////////////////////////////////////////////////////////////////////////////
    // Stage 1
    assign b0_reg_in = (B_INPUT == "DIRECT") ? B : BCIN;
    assign add_sub_sg1 = (opmode_reg_out[6] == 1'b0) ? (b0_reg_out + d_reg_out) : (d_reg_out - b0_reg_out);
    
    FF_MUX_BLK #(.DATA_WIDTH(18), .PIPELINE(DREG),       .RSTTYPE(RSTTYPE)) D_BLK      (.d(D),          .clk(clk), .rst(RSTD),      .en(CED),      .q(d_reg_out));
    FF_MUX_BLK #(.DATA_WIDTH(18), .PIPELINE(B0REG),      .RSTTYPE(RSTTYPE)) B0_BLK     (.d(b0_reg_in),  .clk(clk), .rst(RSTB),      .en(CEB),      .q(b0_reg_out));
    FF_MUX_BLK #(.DATA_WIDTH(18), .PIPELINE(A0REG),      .RSTTYPE(RSTTYPE)) A0_BLK     (.d(A),          .clk(clk), .rst(RSTA),      .en(CEA),      .q(a0_reg_out));
    FF_MUX_BLK #(.DATA_WIDTH(48), .PIPELINE(CREG),       .RSTTYPE(RSTTYPE)) C_BLK      (.d(C),          .clk(clk), .rst(RSTC),      .en(CEC),      .q(c_reg_out));
    FF_MUX_BLK #(.DATA_WIDTH(8),  .PIPELINE(OPMODEREG),  .RSTTYPE(RSTTYPE)) OPMODE_BLK (.d(OPMODE),     .clk(clk), .rst(RSTOPMODE), .en(CEOPMODE), .q(opmode_reg_out));
   
    ////////////////////////////////////////////////////////////////////////////////
    // Stage 2
    FF_MUX_BLK #(.DATA_WIDTH(18), .PIPELINE(B1REG),      .RSTTYPE(RSTTYPE)) B1_BLK     (.d(b1_reg_in),  .clk(clk), .rst(RSTB),      .en(CEB),      .q(b1_reg_out));
    FF_MUX_BLK #(.DATA_WIDTH(18), .PIPELINE(A1REG),      .RSTTYPE(RSTTYPE)) A1_BLK     (.d(a0_reg_out), .clk(clk), .rst(RSTA),      .en(CEA),      .q(a1_reg_out));

    assign b1_reg_in = (opmode_reg_out[4] == 1'b1) ? add_sub_sg1 : b0_reg_out;
    assign m_reg_in  = b1_reg_out * a1_reg_out;
    assign BCOUT     = b1_reg_out;

    ////////////////////////////////////////////////////////////////////////////////
    // Stage 3
    FF_MUX_BLK #(.DATA_WIDTH(36), .PIPELINE(MREG),       .RSTTYPE(RSTTYPE)) M_BLK      (.d(m_reg_in),   .clk(clk), .rst(RSTM),      .en(CEM),      .q(m_reg_out));
    FF_MUX_BLK #(.DATA_WIDTH(1),  .PIPELINE(CARRYINREG), .RSTTYPE(RSTTYPE)) Cin_BLK    (.d(cin_mux_out),.clk(clk), .rst(RSTCARRYIN),.en(CECARRYIN),.q(carryin_reg_out));

    assign M = m_reg_out;
    assign cin_mux_out = (CARRYINSEL == "OPMODE5") ? opmode_reg_out[5] : ((CARRYINSEL == "CARRYIN") ? CARRYIN : 1'b0); 

    ////////////////////////////////////////////////////////////////////////////////
    // Stage 4
    always @* begin
        case(opmode_reg_out[1:0])
            2'b00:   X = 48'b0;
            2'b01:   X = {12'b0, m_reg_out}; // Zero-extend 36-bit M to 48-bit X
            2'b10:   X = PCOUT;
            2'b11:   X = {d_reg_out[11:0], a0_reg_out, b0_reg_out};
            default: X = 48'b0;
        endcase
    end 

    always @* begin
        case(opmode_reg_out[3:2])
            2'b00:   Z = 48'b0;
            2'b01:   Z = PCIN;
            2'b10:   Z = PCOUT;
            2'b11:   Z = c_reg_out;
            default: Z = 48'b0;
        endcase
    end 
    
    ////////////////////////////////////////////////////////////////////////////////
    // Stage 5
    always @* begin 
        if( X == 0)      {cyo_in_reg, p_reg_in}= Z ;
        else if (Z == 0) {cyo_in_reg, p_reg_in}= X ;
        else begin
        if (opmode_reg_out[7] == 1'b0)
             {cyo_in_reg, p_reg_in} = X + Z + carryin_reg_out;
        else 
             {cyo_in_reg, p_reg_in} = Z - (X + carryin_reg_out);
        end
    end

    FF_MUX_BLK #(.DATA_WIDTH(1), .PIPELINE(CARRYOUTREG), .RSTTYPE(RSTTYPE)) CYO_BLK (.d(cyo_in_reg), .clk(clk), .rst(RSTCARRYIN), .en(CECARRYIN), .q(CARRYOUT));
    assign CARRYOUTF = CARRYOUT;
    
    ////////////////////////////////////////////////////////////////////////////////
    // Stage 6
    FF_MUX_BLK #(.DATA_WIDTH(48), .PIPELINE(PREG), .RSTTYPE(RSTTYPE)) P_BLK (.d(p_reg_in), .clk(clk), .rst(RSTP), .en(CEP), .q(p_reg_out));
    assign PCOUT = p_reg_out;
    assign P     = p_reg_out;

endmodule
