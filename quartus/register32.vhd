library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all; -- vhdl-linter-disable-line not-declared
use IEEE.std_logic_arith.all; -- vhdl-linter-disable-line not-declared

entity register32 is
    port(
        rst, clk, enable : in std_logic;
        input            : in std_logic_vector(31 downto 0);
        output           : out std_logic_vector(31 downto 0)
    );
end register32;

architecture behavioral of register32 is
    begin
    process( rst, clk, enable, input )
    begin
    if( rst = '1' ) then
            output <= (others => '0');
    elsif( clk'event and clk = '1') then
        if( enable = '1' ) then
            output <= input;
        end if;
    end if;
end process;
end behavioral; 