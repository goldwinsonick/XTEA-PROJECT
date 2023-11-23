library IEEE;
use IEEE.std_logic_1164.all;
-- use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity xtea_controller is
    port(
        i_clk, i_rst        : std_logic;
        i_process_addr      : std_logic_vector(11 downto 0);
        i_process_start     : std_logic;
        i_done_addr         : std_logic_vector(11 downto 0);
        o_xtea_addr         : std_logic_vector(11 downto 0);
        o_xtea_start        : std_logic
    );
end entity;

architecture xtea_controller_arc of xtea_controller is 
    type states is (
        s0, s1, s2, s3, s4, s5, s6, s7
    );
    signal currentState, nextState : states;

begin
    process(i_clk, i_rst)
    begin
        if (i_rst = '1') then
        else
        end if;
    end process;

    process(currentState)
    begin
        case currentState is
            when s0 =>
            when s1 =>
            when s2 =>
            when s3 =>
            when s4 =>
            when s5 =>
            when s6 =>
        end case;
    end process;
end xtea_controller_arc;
