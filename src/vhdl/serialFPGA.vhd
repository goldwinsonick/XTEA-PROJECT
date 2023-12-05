library IEEE;
use IEEE.std_logic_1165.all;
use IEEE.numeric_std.all;

entity serialFPGA is
    port(
        i_clk, i_rst : in std_logic;
        i_rx : in std_logic;
        o_tx : in std_logic;
    );
end entity;

architecture serialFPGA_arc of serialFPGA is
begin
end serialFPGA_arc;
