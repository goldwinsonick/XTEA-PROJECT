LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY xtea_engine_1 IS
    GENERIC (
        num_rounds      : INTEGER := 32;
        N               : INTEGER := 32 -- 8 byte
    );
    PORT(
        i_clk           : IN STD_LOGIC;
        reset           : IN STD_LOGIC;
        en_de           : IN STD_LOGIC; -- 0 for encrypt, 1 for decrypt
        v0, v1          : IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
        k1, k2, k3, k4  : IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
        out_0, out_1    : OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0);
        done            : OUT STD_LOGIC
    );
END xtea_engine_1;

ARCHITECTURE engine of xtea_engine_1 IS
    TYPE executionStage IS (
        s0, s1, s_op_1, s_op_2, s_done, s_sum
    );

    SIGNAL currentState, nextState : executionStage;

    CONSTANT delta          : STD_LOGIC_VECTOR(N-1 DOWNTO 0) := x"9E3779B9";
    SIGNAL sum              : STD_LOGIC_VECTOR(N-1 DOWNTO 0) := (others => '0');
    SIGNAL t_sum        : unsigned(N-1 DOWNTO 0);

    SIGNAL t_v0         : STD_LOGIC_VECTOR(N-1 DOWNTO 0);
    SIGNAL t1_v0        : unsigned(N-1 DOWNTO 0);
    SIGNAL t2_v0        : unsigned(N-1 DOWNTO 0);
    SIGNAL t3_v0        : unsigned(N-1 DOWNTO 0);

    SIGNAL t_v1         : STD_LOGIC_VECTOR(N-1 DOWNTO 0);
    SIGNAL t1_v1        : unsigned(N-1 DOWNTO 0);
    SIGNAL t2_v1        : unsigned(N-1 DOWNTO 0);
    SIGNAL t3_v1        : unsigned(N-1 DOWNTO 0); 

    SIGNAL key_sel      : unsigned(N-1 DOWNTO 0);
    -- SIGNAL key          : unsigned(N-1 DOWNTO 0);

    SIGNAL count        : INTEGER;

    BEGIN
    state_transition: PROCESS(i_clk)
    BEGIN
        IF (reset = '1') THEN
            currentState <= s0;
        ELSIF rising_edge(i_clk) THEN
            currentState <= nextState;
        END IF;
    END PROCESS;

    state : PROCESS(currentState)
    BEGIN
        CASE currentState IS
            WHEN s0 =>
                t_v0  <= v0;
                t1_v0 <= unsigned(v0);
                t2_v0 <= unsigned(v0);
                t3_v0 <= unsigned(v0);
                t_v1  <= v1;
                t1_v1 <= unsigned(v1);
                t2_v1 <= unsigned(v1);
                t3_v1 <= unsigned(v1);
                t_sum <= unsigned(sum);
                count <= 0;
                IF (en_de = '1') THEN
                    nextState <= s_op_1;
                ELSIF (en_de = '0') THEN
                    nextState <= s_op_2;
                END IF;
            WHEN s1 =>
                count <= count + 1;
                t1_v0 <= unsigned(t_v0);
                t2_v0 <= unsigned(t_v0);
                t3_v0 <= unsigned(t_v0);
                t1_v1 <= unsigned(t_v1);
                t2_v1 <= unsigned(t_v1);
                t3_v1 <= unsigned(t_v1);
                IF (count < num_rounds - 1) THEN
                    IF (en_de = '1') THEN
                        nextState <= s_op_1;
                    ELSIF (en_de = '0') THEN
                        nextState <= s_op_2;
                    END IF;
                ELSE
                    nextState <= s_done;
                END IF;
            WHEN s_sum =>
                IF (en_de = '1') THEN
                    sum <= STD_LOGIC_VECTOR(unsigned(sum) + unsigned(delta));
                    nextState <= s_op_2;
                ELSE
                    sum <= STD_LOGIC_VECTOR(unsigned(sum) - unsigned(delta));
                    nextState <= s_op_1;
                END IF;
            WHEN s_op_1 =>
                t1_v1 <= shift_left(t1_v1, 4);
                t2_v1 <= shift_right(t2_v1, 5);
                t3_v1 <= t1_v1 XOR t2_v1;
                t3_v1 <= unsigned(t3_v1) + unsigned(t_v1);

                key_sel <= unsigned(sum AND x"00000003");
                IF (key_sel(1 DOWNTO 0) = "00") THEN
                    t_sum <= unsigned(sum) + unsigned(k1);
                ELSIF (key_sel(1 DOWNTO 0) = "01") THEN
                    t_sum <= unsigned(sum) + unsigned(k2);
                ELSIF (key_sel(1 DOWNTO 0) = "10") THEN
                    t_sum <= unsigned(sum) + unsigned(k3);
                ELSE
                    t_sum <= unsigned(sum) + unsigned(k4);
                END IF;

                IF (en_de = '1') THEN
                    t_v0 <= STD_LOGIC_VECTOR(unsigned(t_v0) + unsigned(t3_v1 XOR t_sum));
                    nextState <= s_sum;
                ELSE
                    t_v0 <= STD_LOGIC_VECTOR(unsigned(t_v0) - unsigned(t3_v1 XOR t_sum));
                    nextState <= s1;
                END IF;
            WHEN s_op_2 =>
                t1_v0 <= shift_left(t1_v0, 4);
                t2_v0 <= shift_right(t2_v0, 5);
                t3_v0 <= t1_v0 XOR t2_v0;
                t3_v0 <= unsigned(t3_v0) + unsigned(t_v0);

                t_sum <= shift_right(unsigned(sum), 11); -- shift right 11-bits
                key_sel <= unsigned(t_sum AND x"0000_0003");
                IF (key_sel(1 DOWNTO 0) = "00") THEN
                    t_sum <= unsigned(sum) + unsigned(k1);
                ELSIF (key_sel(1 DOWNTO 0) = "01") THEN
                    t_sum <= unsigned(sum) + unsigned(k2);
                ELSIF (key_sel(1 DOWNTO 0) = "10") THEN
                    t_sum <= unsigned(sum) + unsigned(k3);
                ELSE
                    t_sum <= unsigned(sum) + unsigned(k4);
                END IF;

                IF (en_de = '1') THEN
                    t_v1 <= STD_LOGIC_VECTOR(unsigned(t_v1) + unsigned(t3_v0 XOR t_sum));
                    nextState <= s1;
                ELSE
                    t_v1 <= STD_LOGIC_VECTOR(unsigned(t_v1) - unsigned(t3_v0 XOR t_sum));
                    nextState <= s_sum;
                END IF;
            WHEN s_done =>
                done <= '1';
                out_0 <= t_v0;
                out_1 <= t_v1;
        END CASE;
    END PROCESS;
END ARCHITECTURE;