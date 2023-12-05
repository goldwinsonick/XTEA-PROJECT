library ieee;
use ieee.std_logic_1164.all;
 
entity mux_4in is
    generic(
        n: integer := 32
    );
    port(
        i_0 : in std_logic_vector(n-1 downto 0);
        i_1 : in std_logic_vector(n-1 downto 0);
        i_2 : in std_logic_vector(n-1 downto 0);
        i_3 : in std_logic_vector(n-1 downto 0);

        sel: in std_logic_vector(1 downto 0);
        o_data: out std_logic_vector(n-1 downto 0)
    );
end entity;

architecture behavioral of mux_4in is
begin
process(i_0,i_1,i_2,i_3,sel) is
begin
    if(sel = "00") then
        o_data <= i_0;
    elsif(sel = "01") then
        o_data <= i_1;
    elsif(sel = "10") then
        o_data <= i_2;
    elsif(sel = "11") then
        o_data <= i_3;
    end if;
end process;
end architecture behavioral;