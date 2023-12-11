library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity xtea_engine_fsm is
    generic(
        num_rounds  : integer := 32
    );
    port(
        rst, clk, start, ende               : in std_logic;
        operation, sel_v0, sel_v1, sel_sum  : out std_logic;
        en_v0, en_v1, en_sum      , done    : out std_logic 
    );
end xtea_engine_fsm;

architecture fsm of xtea_engine_fsm is
    type states is (
        init, s_waiting,  s_load, s_op_0, s_op_1, s_sum, s_op_done, s_done
    );
    signal state : states := init;
    signal count : integer := 0;

    begin
    process(clk)
    begin
        if(rising_edge(clk))then
            case state is
                when init => -- Waiting for start
                    state <= s_waiting;

                when s_waiting =>
                    done        <= '0';
                    if (start='1') then
                        state <= s_load;
                    end if;

                when s_load => -- loading data to registers
                    en_v0       <= '1';
                    en_v1       <= '1';
                    en_sum      <= '1';
                    sel_v0      <= '1';
                    sel_v1      <= '1';
                    sel_sum     <= '1';
                    operation   <= '0';
                    done        <= '0';
                    count       <= 0;
                    if (ende = '1') then
                        state <= s_op_0;
                    else
                        state <= s_op_1;
                    end if;

                when s_op_done => -- Finish 1 num_round
                    en_v0       <= '0';
                    en_v1       <= '0';
                    en_sum      <= '0';
                    sel_v0      <= '0';
                    sel_v1      <= '0';
                    sel_sum     <= '0';
                    operation   <= '0';
                    done        <= '0';
                    if (count < num_rounds-1) then
                        if (ende = '1') then
                            state <= s_op_0;
                        else
                            state <= s_op_1;
                        end if;
                        count       <= count + 1;
                    else
                        state <= s_done;
                    end if;

                when s_op_0 =>
                    en_v0       <= '1';
                    en_v1       <= '0';
                    en_sum      <= '0';
                    sel_v0      <= '0';
                    sel_v1      <= '0';
                    sel_sum     <= '0';
                    operation   <= '0';
                    done        <= '0';
                    if (ende = '1') then
                        state <= s_sum;
                    else
                        state <= s_op_done;
                    end if;

                when s_sum =>
                    en_v0       <= '0';
                    en_v1       <= '0';
                    en_sum      <= '1';
                    sel_v0      <= '0';
                    sel_v1      <= '0';
                    sel_sum     <= '0';
                    operation   <= '0';
                    done        <= '0';
                    if (ende = '1') then
                        state <= s_op_1;
                    else
                        state <= s_op_0;
                    end if;

                when s_op_1 =>
                    en_v0       <= '0';
                    en_v1       <= '1';
                    en_sum      <= '0';
                    sel_v0      <= '0';
                    sel_v1      <= '0';
                    sel_sum     <= '0';
                    operation   <= '1';
                    done        <= '0';
                    if (ende = '1') then
                        state <= s_op_done;
                    else
                        state <= s_sum;
                    end if;

                when s_done =>
                    en_v0       <= '0';
                    en_v1       <= '0';
                    en_sum      <= '0';
                    sel_v0      <= '0';
                    sel_v1      <= '0';
                    sel_sum     <= '0';
                    operation   <= '0';
                    done        <= '1';
                    state   <= s_waiting;
                
            end case;
        end if;
    end process;
end architecture;