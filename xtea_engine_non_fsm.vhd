library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity xtea_engine_non_fsm is
    generic(
        num_rounds                          : integer := 32
    );
    port(
        i_clk, i_rst, i_start               : in std_logic;
        i_v0, i_v1                          : in std_logic_vector(31 downto 0);
        i_ende                              : in std_logic;
        i_key0, i_key1, i_key2, i_key3      : in std_logic_vector(31 downto 0);
        o_out0, o_out1                      : out std_logic_vector(31 downto 0);
        o_done                              : out std_logic
    );
end xtea_engine_non_fsm;

architecture rtl of xtea_engine_non_fsm is
    type fsm is (s_init, s_reload,
        s_op_1, s_op_1_load, 
        s_key, s_sum,
        s_op_2, s_op_2_load,
        s_done);
    signal currentState, nextState      : fsm;

    constant delta                      : unsigned(31 downto 0) := x"9E3779B9";
    signal sum, t_sum, ta_sum           : std_logic_vector(31 downto 0);

    signal t_v0, ta_v0, tb_v0, tc_v0    : std_logic_vector(31 downto 0);
    signal t_v1, ta_v1, tb_v1, tc_v1    : std_logic_vector(31 downto 0);
    signal key                          : std_logic_vector(31 downto 0);
    signal t_out0, t_out1               : std_logic_vector(31 downto 0);

    signal done                         : std_logic;
    signal lanjut                       : std_logic := '0';

    signal count                        : integer := 0;
    signal t_start                      : std_logic;

begin

    o_done <= done;
    o_out0 <= t_out0;
    o_out1 <= t_out1;

    process(i_clk)
    begin
        if (i_rst = '1') then
            currentState <= s_init;
        elsif rising_edge(i_clk) then
            t_start <= i_start;
            currentState <= nextState;
        end if;
    end process;

    process(t_start, currentState)
    begin
        case currentState is
            when s_init =>
                done    <= '0';
                t_v0    <= i_v0;
                ta_v0   <= i_v0;
                tb_v0   <= i_v0;
                tc_v0   <= i_v0;
                t_v1    <= i_v1;
                ta_v1   <= i_v1;
                tb_v1   <= i_v1;
                tc_v1   <= i_v1;
                -- if rising_edge(i_start) then
                -- t_start <= i_start;
                if (t_start = '1') then
                    if (i_ende = '1') then
                        sum     <= (others => '0');
                        t_sum   <= sum;
                        ta_sum  <= sum;
                        nextState <= s_op_1;
                    else
                        sum     <= x"C6EF3720";
                        t_sum   <= sum;
                        ta_sum  <= sum;
                        nextState <= s_op_2;
                    end if;
                end if;
            when s_reload =>
                -- t_v0    <= i_v0;
                ta_v0   <= t_v0;
                tb_v0   <= t_v0;
                tc_v0   <= t_v0;
                -- t_v1    <= i_v1;
                ta_v1   <= t_v1;
                tb_v1   <= t_v1;
                tc_v1   <= t_v1;
                if (count < num_rounds-1) then
                    count <= count + 1;
                    if (i_ende = '1') then
                        nextState <= s_op_1;
                    else
                        nextState <= s_op_2;
                    end if;
                else
                    nextState <= s_done;
                end if;
            when s_op_1 =>
                ta_v1 <= std_logic_vector(shift_left(unsigned(t_v1), 4));
                tb_v1 <= std_logic_vector(shift_right(unsigned(t_v1), 5));
                t_sum <= sum and x"0000_0011";
                nextState <= s_key;
            when s_key =>
                if (t_sum(1 downto 0) = "00") then
                    key <= i_key0;
                elsif (t_sum(1 downto 0) = "01") then
                    key <= i_key1;
                elsif (t_sum(1 downto 0) = "10") then
                    key <= i_key2;
                elsif (t_sum(1 downto 0) = "11") then
                    key <= i_key3;
                end if;
                if (i_ende = '1') then
                    if (lanjut = '0') then
                        nextState <= s_op_1_load;
                    else
                        nextState <= s_op_2_load;
                    end if;
                else
                    if (lanjut = '0') then
                        nextState <= s_op_2_load;
                    else
                        nextState <= s_op_1_load;
                    end if;
                end if;
            when s_op_1_load =>
                lanjut <= not(lanjut);
                if (i_ende = '1') then
                    t_v0 <= std_logic_vector(unsigned(t_v0) + ((unsigned(ta_v1 xor tb_v1) + unsigned(tc_v1)) xor (unsigned(sum) + unsigned(key))));
                    nextState <= s_sum;
                else
                    t_v0 <= std_logic_vector(unsigned(t_v0) - ((unsigned(ta_v1 xor tb_v1) + unsigned(tc_v1)) xor (unsigned(sum) + unsigned(key))));
                    nextState <= s_reload;
                end if;
            when s_sum =>
                if (i_ende = '1') then
                    sum <= std_logic_vector(unsigned(sum) + delta);
                    nextState <= s_op_2;
                else
                    sum <= std_logic_vector(unsigned(sum) - delta);
                    nextState <= s_op_1;
                end if;
            when s_op_2 =>
                ta_v0 <= std_logic_vector(shift_left(unsigned(t_v1), 4));
                tb_v0 <= std_logic_vector(shift_right(unsigned(t_v1), 5));
                t_sum <= std_logic_vector(shift_right(unsigned(sum), 11) and x"0000_0011");
                nextState <= s_key;
            when s_op_2_load =>
                lanjut <= not(lanjut);
                if (i_ende = '1') then
                    t_v1 <= std_logic_vector(unsigned(t_v1) + ((unsigned(ta_v0 xor tb_v0) + unsigned(tc_v0)) xor (unsigned(sum) + unsigned(key))));
                    nextState <= s_reload;
                else
                    t_v1 <= std_logic_vector(unsigned(t_v1) - ((unsigned(ta_v0 xor tb_v0) + unsigned(tc_v0)) xor (unsigned(sum) + unsigned(key))));
                    nextState <= s_sum;
                end if;
            when s_done =>
                done <= '1';
                t_out0 <= t_v0;
                t_out1 <= t_v1;
                count <= 0;
                nextState <= s_init;
        end case;
    end process;
end architecture;