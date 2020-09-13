module ALU
#(parameter WIDTH = 32) 	//���ݿ��
(output reg [WIDTH-1:0] y, 		//������
output reg zf, 					//���־
output reg cf, 					//��λ/��λ��־
output reg of, 					//�����־
input [WIDTH-1:0] a, b,		//��������
input [2:0] m		    	//��������
);
always@(*)
    begin
        case(m)
            3'b000: // +
            begin
                {cf, y} = a + b;
                of = (~a[WIDTH-1] & ~b[WIDTH-1] & y[WIDTH-1])
                    | (a[WIDTH-1] & b[WIDTH-1] & ~y[WIDTH-1]);
                zf = ~|y;
            end
            3'b001: // -
            begin
                {cf, y} = a - b;
                of = (~a[WIDTH-1] & b[WIDTH-1] & y[WIDTH-1])
                    | (a[WIDTH-1] & ~b[WIDTH-1] & ~y[WIDTH-1]);
                zf = ~|y;
            end
            3'b010: // &
            begin
                y = a & b;
                zf = ~|y;
                cf = 0;
                of = 0;
            end
            3'b011: // |
            begin
                y = a | b;
                zf = ~|y;
                cf = 0;
                of = 0;
            end
            3'b100: // ^
            begin
                y = a ^ b;
                zf = ~|y;
                cf = 0;
                of = 0;
            end
            3'b101: // <<
            begin
                y = b << a;
                zf = ~|y;
                cf = 0; //todo
                of = 0; //todo
            end
            3'b110: // >> �߼�����
            begin
                y = b >> a;
                zf = ~|y;
                cf = 0; //todo
                of = 0; //todo
            end
            default:
            begin
                y = 0;
                zf = 0;
                cf = 0;
                of = 0;
            end
        endcase
end
endmodule

module Registers				//32 x WIDTH�Ĵ�����
#(parameter WIDTH = 32) 	        //���ݿ��
(
    input clk,						//ʱ�ӣ���������Ч��
    input [4:0] ra0,				//���˿�0��ַ
    output reg [WIDTH-1:0] rd0,    	    //���˿�0����
    input [4:0] ra1, 				//���˿�1��ַ
    output reg [WIDTH-1:0] rd1,      	//���˿�1����
    input [4:0] wa, 				//д�˿ڵ�ַ
    input we,				    	//дʹ�ܣ��ߵ�ƽ��Ч
    input [WIDTH-1:0] wd 	    	//д�˿�����
);
reg [WIDTH-1:0] mem [255:0];
// ��ʼ�� RAM ������
initial
begin
    //$readmemh("C:/Users/mi/Desktop/text.txt", mem, 0, 255);
    $readmemh("C:/Users/mi/Desktop/lab6_design/initReg.vec", mem, 0, 255);
end
// �첽��
always@(*)
begin
    rd0 = mem[ra0];
    rd1 = mem[ra1];
end
// ͬ��д
always@(posedge clk)
begin
    if(we & wa!=0)
        mem[wa] <= wd; 
end
endmodule

module Mux5(
    input control,
    input [4:0] in1, in0,
    output [4:0] out
);
assign out = control? in1:in0;
endmodule

module Mux32(
    input control,
    input [31:0] in1, in0,
    output [31:0] out
);
assign out = control? in1:in0;
endmodule

module Sign_extend(
    input [15:0] imm,
    output [31:0] extendImm
);
assign extendImm[15:0] = imm;
assign extendImm[31:16] = imm[15] ? 16'hffff : 16'h0000;
endmodule

module Control(
    input [5:0] instruction,
    output reg RegDst,
    output reg ALUSrc,
    output reg MemtoReg,
    output reg RegWrite,
    output reg MemRead,
    output reg MemWrite,
    output reg Branch,
    output reg ALUOp1, ALUOp0,
    output reg Jump
);
// add addi lw sw beq j srl sll xor
// x ����Ϊ 0
always @(instruction)
begin
    case(instruction)
        6'b000000: // add func=100000
            {RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, 
            MemWrite, Branch, ALUOp1, ALUOp0, 
            Jump} <= 10'b1001000100;
        6'b100011: // lw
            {RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, 
            MemWrite, Branch, ALUOp1, ALUOp0, Jump} <= 10'b0111100000;
        6'b101011: // sw
            {RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, 
            MemWrite, Branch, ALUOp1, ALUOp0, Jump} <= 10'bx1x0010000;
        6'b000100: // beq
            {RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, 
            MemWrite, Branch, ALUOp1, ALUOp0, Jump} <= 10'bx0x0001010;
        6'b001000: // addi
            {RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, 
            MemWrite, Branch, ALUOp1, ALUOp0, Jump} <= 10'b0101000000;
        6'b000010: // j
            {RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, 
            MemWrite, Branch, ALUOp1, ALUOp0, Jump} <= 10'bxxx000x011;
        /*6'b000000: // xor func=100110
            {RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, 
            MemWrite, Branch, ALUOp1, ALUOp0, Jump} <= 10'b1001000??0;
        6'b000000: // func sll 000000 srl 000001
        */
    endcase
end
endmodule

module ALUControl(
    input Op1, Op0,
    input [5 : 0] funct,
    output reg [2 : 0] ALUOp,
    output reg ShamtSignal
);
always@(*)
begin
    case({Op1, Op0})
        2'b00: ALUOp <= 3'b000;
        2'b01: ALUOp <= 3'b001;
        2'b10: begin
            case(funct)
                6'b100000: ALUOp <= 3'b000; // +
                6'b100010: ALUOp <= 3'b001; // -
                6'b100100: ALUOp <= 3'b010; // and
                6'b100101: ALUOp <= 3'b011; // or
                6'b100110: ALUOp <= 3'b100; // xor
                6'b000000: ALUOp <= 3'b101; // <<
                6'b000010: ALUOp <= 3'b110; // >>
                default: ALUOp <= 3'b111;
            endcase
        end
    endcase
end
always@(*)
    if(funct == 6'b000000 | funct == 6'b000010)
        ShamtSignal <= 1'b1;
    else
        ShamtSignal <= 1'b0;
endmodule

module PC(
    input clk,
    input rst,
    input [31:0] new_addr,
    output reg [31:0] cur_addr
);
initial
    cur_addr <= 0;
always@(posedge clk or posedge rst)
begin
    if(rst)
        cur_addr <= 0;
    else
        cur_addr <= new_addr;
end
endmodule