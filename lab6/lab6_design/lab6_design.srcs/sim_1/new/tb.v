module tb();
reg clk;
reg rst;
reg I_step, I_flag;
reg [15 : 0] I_data;
wire [15 : 0] O_led;

/*
module cpu_one_cycle( // ������ CPU
    input clk,        // ʱ�ӣ���������Ч��
    input rst,        // �첽��λ���ߵ�ƽ��Ч
    input I_step, I_flag, // btn
    input [15 : 0] I_data,
    output [15 : 0] O_led,
);
*/
cpu_one_cycle cpu(
    .clk(clk),
    .rst(rst),
    .I_step(I_step),
    .I_flag(I_flag),
    .I_data(I_data),
    .O_led(O_led)
);
parameter PERIOD = 10;
initial
begin
    rst = 1;
    # (PERIOD*1);
    rst = 0;
end

initial
begin
    clk = 0;
    repeat (400) // ����
        #(PERIOD/2) clk = ~clk;
    $finish;
end

/*
btn1 I_step�ߵ�ƽ �� flag_data �� flag_place
btn2 I_flag�ߵ�ƽ ����SW ��16λSW�� input_addr
*/
initial
begin
    I_data = 16'h9abc; // test
    I_flag = 0;
    # (PERIOD*2);
    I_flag = 1; // �ı���input_data
    I_step = 0;
    # (PERIOD);
    I_flag = 0;
    # (PERIOD*5);
    repeat(10)
    begin
        I_step = 1;
        # (PERIOD*6);
        I_step = 0;
        # (PERIOD*10);  
    end
end
endmodule