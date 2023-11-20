library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity xtea_engine_fsm is
    generic(
        num_rounds  : integer := 32
    );
    port(
        rst, clk, start, ende               : in std_logic;
        operation, sel_v0, sel_v1           : out std_logic;
        en_v0, en_v1, en_sum_delta, done    : out std_logic 
    );
end xtea_engine_fsm;

architecture fsm of xtea_engine_fsm is
    type states is (
        init, s_load, s_op_1, s_op_2, s_sum, s_load_op, s_done
    );
    signal nextState, currentState : states;

    signal count : integer;

    begin
    process(rst, clk)
    begin
        if (rst = '1') then
            currentState <= init;
        elsif rising_edge(clk) then
            currentState <= nextState;
        end if;
    end process;

    process(start, currentState)
    begin
        case currentState is
            when init =>
                if (start = '0') then
                    nextState <= init;
                else
                    nextState <= s_load;
                end if;

            when s_load =>
                en_v0       <= '1';
                en_v1       <= '1';
                sel_v0      <= '1';
                sel_v1      <= '1';
                operation   <= '0';
                done        <= '0';
                en_sum_delta<= '0';
                if (ende = '1') then
                    nextState <= s_op_1;
                else
                    nextState <= s_op_2;
                end if;

            when s_load_op =>
                en_v0       <= '1';
                en_v1       <= '1';
                sel_v0      <= '0';
                sel_v1      <= '0';
                operation   <= '0';
                done        <= '0';
                en_sum_delta<= '0';
                count       <= count + 1;
                if (count < num_rounds) then
                    if (ende = '1') then
                        nextState <= s_op_1;
                    else
                        nextState <= s_op_2;
                    end if;
                else
                    nextState <= s_done;
                end if;

            when s_op_1 =>
                en_v0       <= '0';
                en_v1       <= '0';
                sel_v0      <= '0';
                sel_v1      <= '0';
                operation   <= '0';
                done        <= '0';
                en_sum_delta<= '0';
                if (ende = '1') then
                    nextState <= s_sum;
                else
                    nextState <= s_load;
                end if;

            when s_sum =>
                en_v0       <= '0';
                en_v1       <= '0';
                sel_v0      <= '0';
                sel_v1      <= '0';
                operation   <= '1';
                done        <= '0';
                en_sum_delta<= '1';
                if (ende = '1') then
                    operation <= '1';
                else
                    operation <= '0';
                end if;

            when s_op_2 =>
                en_v0       <= '0';
                en_v1       <= '0';
                sel_v0      <= '0';
                sel_v1      <= '0';
                operation   <= '1';
                done        <= '0';
                en_sum_delta<= '0';
                if (ende = '1') then
                    nextState <= s_load_op;
                else
                    nextState <= s_sum;
                end if;

            when s_done =>
                en_v0       <= '0';
                en_v1       <= '0';
                sel_v0      <= '0';
                sel_v1      <= '0';
                operation   <= '0';
                done        <= '1';
                en_sum_delta<= '0';

        end case;
    end process;
end architecture;