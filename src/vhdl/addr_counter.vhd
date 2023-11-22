library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity addr_counter is
    port(
        i_clk, i_rst : in std_logic;
        o_addr       : in std_logic_vector(11 downto 0);
    );
    signal cnt_int : integer;
end entity;

architecture behavioral of addr_counter is
    process(i_clk, i_rst)
    begin
        if(i_rst = '1')then
            cnt_int <= 0;
        elsif(rising_edge(i_clk))then
            cnt_int <= cnt_int + 1;
        end if;
    end process;
    o_addr <= std_logic_vector(to_unsigned(cnt_int));
end architecture;