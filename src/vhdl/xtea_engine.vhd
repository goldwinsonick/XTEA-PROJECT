library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity xtea_engine is
    port(
        i_clk, i_rst, i_start               : in std_logic;
        i_v0, i_v1                          : in std_logic_vector(31 downto 0);
        i_ende                              : in std_logic;
        i_key0, i_key1, i_key2, i_key3      : in std_logic_vector(31 downto 0);
        o_out0, o_out1                      : out std_logic_vector(31 downto 0);
        o_done                              : out std_logic
    );
end xtea_engine;

architecture xtea_engine_arc OF xtea_engine IS
    component mux_4in is
        generic(
            n : integer := 32
        );
        port(
            i_0 : in std_logic_vector(n-1 downto 0);
            i_1 : in std_logic_vector(n-1 downto 0);
            i_2 : in std_logic_vector(n-1 downto 0);
            i_3 : in std_logic_vector(n-1 downto 0);

            sel: in std_logic_vector(1 downto 0);
            o_data: out std_logic_vector(n-1 downto 0)
        );
    end component;

    component mux_2in is
        generic(
        n: integer := 32
        );
        port(
            i_0 : in std_logic_vector(n-1 downto 0);
            i_1 : in std_logic_vector(n-1 downto 0);

            sel: in std_logic;
            o_data: out std_logic_vector(n-1 downto 0)
        );
    end component;

    component register32 is
        port(
            rst, clk, enable : in std_logic;
            input            : in std_logic_vector(31 downto 0);
            output           : out std_logic_vector(31 downto 0)
        );
    end component;

    component xtea_engine_fsm is
        generic(
            num_rounds  : integer := 32
        );
        port(
            rst, clk, start, ende               : in std_logic;
            operation, sel_v0, sel_v1, sel_sum  : out std_logic;
            en_v0, en_v1, en_sum, done          : out std_logic 
        );
    end component;

    constant delta      : std_logic_vector(31 downto 0) := x"9E3779B9";
    constant num_rounds  : integer := 32;
    constant mul_first_sum : std_logic_vector(31 downto 0) := x"C6EF3720";

    -- Controller Signals
    signal operation         : std_logic; -- operation 1 (v0 <= something)
    signal sel_v0, sel_v1    : std_logic; -- selector input register v0 dan v1 (i_v0 i_v1 or operation final)
    signal sel_sum           : std_logic;
    signal en_v0, en_v1      : std_logic; -- enable register v0 dan v1
    signal en_sum            : std_logic; -- enable sum_reg
    signal done              : std_logic;

    -- Register and Operation Signals
    signal v0_mux_out                               : std_logic_vector(31 downto 0);
    signal v1_mux_out                               : std_logic_vector(31 downto 0);
    signal v0_out                                   : std_logic_vector(31 downto 0);
    signal v1_out                                   : std_logic_vector(31 downto 0);
    signal op_mux_out                               : std_logic_vector(31 downto 0);
    signal op2_mux_out                              : std_logic_vector(31 downto 0);
    signal op_temp1                                 : std_logic_vector(31 downto 0);
    signal op_temp2                                 : std_logic_vector(31 downto 0);
    signal op_out                                   : std_logic_vector(31 downto 0);
    signal add_op_out, sub_op_out                   : std_logic_vector(31 downto 0);
    signal operation_final                          : std_logic_vector(31 downto 0);

    -- Key Signals
    signal key_sel_out                              : std_logic_vector(31 downto 0);
    signal key_mux_out                              : std_logic_vector(31 downto 0);
    signal first_sum                                : std_logic_vector(31 downto 0);
    signal sum_mux_out                              : std_logic_vector(31 downto 0);
    signal sum_in, sum_out                          : std_logic_vector(31 downto 0);
    signal shifted_sum                              : std_logic_vector(31 downto 0);
    signal add_sum_delta, sub_sum_delta             : std_logic_vector(31 downto 0);

    signal key_sel                                  : std_logic_vector(1 downto 0);

    begin


    fsm : xtea_engine_fsm
        generic map(
            num_rounds => num_rounds
        )
        port map(
            rst             => i_rst,
            clk             => i_clk,
            start           => i_start,
            ende            => i_ende,
            operation       => operation,
            sel_v0          => sel_v0,
            sel_v1          => sel_v1,
            sel_sum         => sel_sum,
            en_v0           => en_v0,
            en_v1           => en_v1,
            en_sum          => en_sum,
            done            => done
        );

    o_done <= done;
    out0_reg : register32
        port map(
            rst     => i_rst,
            clk     => i_clk,
            enable  => done,
            input   => v0_out,
            output  => o_out0
        );

    out1_reg : register32
        port map(
            rst     => i_rst,
            clk     => i_clk,
            enable  => done,
            input   => v1_out,
            output  => o_out1
        );
        
    v0_mux : mux_2in
        generic map(
            n => 32
        )
        port map(
            i_0 => operation_final,
            i_1 => i_v0,
            sel => sel_v0,
            o_data => v0_mux_out
        );

    v1_mux : mux_2in
        generic map(
            n => 32
        )
        port map(
            i_0 => operation_final,
            i_1 => i_v1,
            sel => sel_v1,
            o_data => v1_mux_out
        );
    
    v0_reg : register32
        port map(
            rst     => i_rst,
            clk     => i_clk,
            enable  => en_v0,
            input   => v0_mux_out,
            output  => v0_out
        );

    v1_reg : register32
        port map(
            rst     => i_rst,
            clk     => i_clk,
            enable  => en_v1,
            input   => v1_mux_out,
            output  => v1_out
        );

    op_mux : mux_2in
        generic map(
            n => 32
        )
        port map(
            i_0 => v1_out,
            i_1 => v0_out,
            sel => operation,
            o_data => op_mux_out
        );

    op_mux2 : mux_2in
        generic map(
            n => 32
        )
        port map(
            i_0 => v0_out,
            i_1 => v1_out,
            sel => operation,
            o_data => op2_mux_out
        );
    
    op_temp1 <= std_logic_vector((shift_left(unsigned(op_mux_out), 4) XOR shift_right(unsigned(op_mux_out), 5)) + unsigned(op_mux_out));

    first_sum_mux : mux_2in
        generic map(
            n => 32
        )
        port map(
            i_0 => mul_first_sum,
            i_1 => (others=>'0'),
            sel => i_ende,
            o_data => first_sum
        );
    
    sum_mux : mux_2in
        generic map(
            n => 32
        )
        port map(
            i_0 => sum_in,
            i_1 => first_sum,
            sel => sel_sum,
            o_data => sum_mux_out
        );

    sum_reg : register32
        port map(
            rst => i_rst,
            clk => i_clk,
            enable => en_sum,
            input => sum_mux_out,
            output => sum_out
        );
    
    add_sum_delta <= std_logic_vector(unsigned(sum_out) + unsigned(delta));
    sub_sum_delta <= std_logic_vector(unsigned(sum_out) - unsigned(delta));

    sum_delta_mux : mux_2in
        generic map(
            n => 32
        )
        port map(
            i_0 => sub_sum_delta,
            i_1 => add_sum_delta,
            sel => i_ende,
            o_data => sum_in
        );

    shifted_sum <= std_logic_vector(shift_right(unsigned(sum_out), 11));
    
    key_sel_mux : mux_2in
        generic map(
            n => 32
        )
        port map(
            i_0 => sum_out,
            i_1 => shifted_sum,
            sel => operation,
            o_data => key_sel_out
        );

    key_sel <= key_sel_out(1 downto 0) AND "11";
    
    key_mux : mux_4in
        generic map(
            n=> 32
        )
        port map(
            i_0 => i_key0,
            i_1 => i_key1,
            i_2 => i_key2,
            i_3 => i_key3,
            sel => key_sel,
            o_data => key_mux_out
        );

    op_temp2 <= std_logic_vector(unsigned(sum_out) + unsigned(key_mux_out));
    op_out <= op_temp1 XOR op_temp2;

    add_op_out <= std_logic_vector(unsigned(op2_mux_out) + unsigned(op_out));
    sub_op_out <= std_logic_vector(unsigned(op2_mux_out) - unsigned(op_out));

    to_reg_mux : mux_2in
        generic map(
            n => 32
        )
        port map(
            i_0 => sub_op_out,
            i_1 => add_op_out,
            sel => i_ende,
            o_data => operation_final
        );

end xtea_engine_arc;