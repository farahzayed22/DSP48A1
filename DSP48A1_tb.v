module DSP48A1_tb();
    // Data input Ports
    reg [17:0] A, B, BCIN, D;
    reg [47:0] C;
    reg CARRYIN;
    
    // Control input Ports
    reg clk;
    reg [7:0] OPMODE;
    
    // Clock Enable input Ports
    reg CEA, CEB, CEC, CECARRYIN, CED, CEM, CEOPMODE, CEP;
    
    // Reset input Ports
    reg RSTA, RSTB, RSTC, RSTCARRYIN, RSTD, RSTM, RSTOPMODE, RSTP;
    
    // Cascade Ports
    reg  [47:0] PCIN;
    wire [47:0] PCOUT;
    wire [17:0] BCOUT;
    
    // Data output Ports
    wire [35:0] M;
    wire [47:0] P;
    wire CARRYOUT, CARRYOUTF;

    DSP48A1 #( .A0REG(1'b0), .A1REG(1'b1), .B0REG(1'b0), .B1REG(1'b1), .CREG(1'b1), .DREG(1'b1), .MREG(1'b1), .PREG(1'b1),
                .CARRYINREG(1'b1), .CARRYOUTREG(1'b1), .OPMODEREG(1'b1), .CARRYINSEL("OPMODE5"), .B_INPUT("DIRECT"),
                .RSTTYPE("SYNC")) dut(
        .A(A), .B(B), .BCIN(BCIN), .D(D), .C(C), .CARRYIN(CARRYIN), .clk(clk), .OPMODE(OPMODE),
        .CEA(CEA), .CEB(CEB), .CEC(CEC), .CECARRYIN(CECARRYIN), .CED(CED), .CEM(CEM),
        .CEOPMODE(CEOPMODE), .CEP(CEP),
        .RSTA(RSTA), .RSTB(RSTB), .RSTC(RSTC), .RSTCARRYIN(RSTCARRYIN),
        .RSTD(RSTD), .RSTM(RSTM), .RSTOPMODE(RSTOPMODE), .RSTP(RSTP),
        .PCIN(PCIN), .PCOUT(PCOUT), .BCOUT(BCOUT),
        .M(M), .P(P), .CARRYOUT(CARRYOUT), .CARRYOUTF(CARRYOUTF)
    );
    always #5 clk = ~clk;

    initial begin 
        clk=0;
        RSTA=1'b1;
        RSTB=1'b1;
        RSTC=1'b1;
        RSTCARRYIN=1'b1;
        RSTD=1'b1;
        RSTM=1'b1;
        RSTOPMODE=1'b1;
        RSTP=1'b1;
        A= $random;
        B= $random;
        BCIN= $random;
        D= $random;
        C= $random; 
        CARRYIN= $random;
        OPMODE= $random;
        PCIN= $random;

        @(negedge clk);
        if(BCOUT | PCOUT | M | P | CARRYOUT | CARRYOUTF) begin
            $display("Error: Outputs should be zero after reset");
        end

        @(negedge clk);
        RSTA=1'b0;
        RSTB=1'b0;  
        RSTC=1'b0;
        RSTCARRYIN=1'b0;    
        RSTD=1'b0;
        RSTM=1'b0;
        RSTOPMODE=1'b0;
        RSTP=1'b0;
        CEA=1'b1;
        CEB=1'b1;
        CEC=1'b1;
        CECARRYIN=1'b1;
        CED=1'b1;
        CEM=1'b1;
        CEOPMODE=1'b1;
        CEP=1'b1; 
        
        //DSP PATH1
        @(negedge clk);
        OPMODE=  8'b11011101;
        A = 20; B = 10; C = 350; D = 25;
        PCIN= $random;
        BCIN= $random;
        CARRYIN= $random;
        repeat(4) @(negedge clk);
        if( BCOUT != 18'hf || M != 36'h12c||  P !=48'h32 || PCOUT != 48'h32|| CARRYOUT !=1'b0  ||CARRYOUTF != 1'b0)
            $display("Error: Outputs for Path 1 arenot correct, BCOUT=%h, M=%h, P=%h, PCOUT=%h, CARRYOUT=%b, CARRYOUTF=%b", BCOUT, M, P, PCOUT, CARRYOUT, CARRYOUTF);
        else $display("Path 1 outputs are correct");


        //DSP PATH2
        @(negedge clk);
        OPMODE = 8'b00010000;
        PCIN= $random;
        BCIN= $random;
        CARRYIN= $random;
        repeat(3) @(negedge clk);
        if( BCOUT != 18'h23 || M != 36'h2bc||  P !=48'h0 || PCOUT != 48'h0|| CARRYOUT !=1'b0  ||CARRYOUTF != 1'b0)
            $display("Error: Outputs for Path 2 arenot correct, BCOUT=%h, M=%h, P=%h, PCOUT=%h, CARRYOUT=%b, CARRYOUTF=%b", BCOUT, M, P, PCOUT, CARRYOUT, CARRYOUTF);
        else $display("Path 2 outputs are correct");


        //DSP PATH3
        @(negedge clk);
        OPMODE = 8'b00001010;
        PCIN= $random;
        BCIN= $random;
        CARRYIN= $random;
        repeat(3) @(negedge clk);
        if( BCOUT != 18'ha || M != 36'hc8||  P !=PCOUT || CARRYOUT !=CARRYOUTF)
            $display("Error: Outputs for Path 3 arenot correct, BCOUT=%h, M=%h, P=%h, PCOUT=%h, CARRYOUT=%b, CARRYOUTF=%b", BCOUT, M, P, PCOUT, CARRYOUT, CARRYOUTF);
        else $display("Path 3 outputs are correct");


        //DSP PATH4
        @(negedge clk);
        OPMODE = 8'b10100111;
        A = 5; B = 6; C = 350; D = 25;  PCIN = 3000 ;
        BCIN= $random;
        CARRYIN= $random;
        repeat(3) @(negedge clk);
        if( BCOUT != 18'h6 || M != 36'h1e||  P !=48'hfe6fffec0bb1 || PCOUT != 48'hfe6fffec0bb1|| CARRYOUT !=1'b1  ||CARRYOUTF != 1'b1)
            $display("Error: Outputs for Path 4 arenot correct, BCOUT=%h, M=%h, P=%h, PCOUT=%h, CARRYOUT=%b, CARRYOUTF=%b", BCOUT, M, P, PCOUT, CARRYOUT, CARRYOUTF);
        else $display("Path 4 outputs are correct");

        #10 $stop;

    end
    initial begin
        $monitor("Time=%0t, A=%h, B=%h, BCIN=%h,BCOUT=%h, D=%h, C=%h, CARRYIN=%b, OPMODE=%b, PCIN=%h, M=%h, P=%h,PCOUT=%h, CARRYOUT=%b, CARRYOUTF=%b", $time, A, B, BCIN,BCOUT, PCOUT, D, C, CARRYIN, OPMODE, PCIN, M, P, PCOUT, CARRYOUT, CARRYOUTF);
    end
endmodule 