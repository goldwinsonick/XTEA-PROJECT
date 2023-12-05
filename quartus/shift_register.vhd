library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity shift_register is
    generic(
        N            : integer := 32
    );
    port(
        i_clk, i_rst    : in std_logic;
        i_data          : in std_logic_vector(7 downto 0);
        i_en            : in std_logic;
        o_data          : out std_logic_vector(N-1 downto 0)
    );
end entity;

architecture behavioral of shift_register is
    signal reg_data : std_logic_vector(N-1 downto 0);
begin
    process(i_clk)
    begin
        if(i_rst = '1')then
            reg_data <= (others => '0');
        elsif (rising_edge(i_clk)) then
            if(i_en = '1') then
                reg_data <= reg_data(N-9 downto 0) & i_data;
            end if;
        end if;
    end process;
    o_data <= reg_data;
end behavioral;