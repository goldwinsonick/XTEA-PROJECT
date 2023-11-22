library ieee;
use ieee.std_logic_1164.all;
 
entity mux_2in is
    generic(
        n: integer := 32
    );
    port(
        i_0 : in std_logic_vector(n-1 downto 0);
        i_1 : in std_logic_vector(n-1 downto 0);

        sel: in std_logic;
        o_data: out std_logic_vector(n-1 downto 0)
    );
end entity;

architecture behavioral of mux_2in is
begin
process(i_0,i_1,sel) is
begin
    if(sel = '0') then
        o_data <= i_0;
    elsif(sel = '1') then
        o_data <= i_1;
    end if;
end process;
end architecture behavioral;