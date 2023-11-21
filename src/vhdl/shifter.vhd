library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity shifter is
    port(
        i_data      : in std_logic_vector(31 downto 0);
        n_bit       : in integer;
        l_r         : in std_logic;
        o_data      : out std_logic_vector(31 downto 0)
    );
end shifter;

architecture shifter_arc of shifter is
begin
    process is
    begin
        if l_r = '0' then
            o_data <= std_logic_vector(shift_left(i_data, n_bit));
        else
            o_data <= std_logic_vector(shift_right(i_data, n_bit));
        end if;
    end process;
end architecture;