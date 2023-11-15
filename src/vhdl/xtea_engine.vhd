LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY xtea_engine IS
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
END xtea_engine;

ARCHITECTURE behavioral OF xtea_engine IS
    type FSM IS (
        s0, s1, s2, s3, s4, s5, s6, s7
    );

    SIGNAL currentState, nextState : FSM;
    
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
    SIGNAL key          : STD_LOGIC_VECTOR(N-1 DOWNTO 0);

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

    state: PROCESS(currentState)
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
                    nextState <= s1;
                ELSIF (en_de = '0') THEN
                    nextState <= s4;
                END IF;
            WHEN s1 =>
                -- start modifying v0
                t1_v1 <= t1_v1(N-1-4 DOWNTO 0) & "0000"; -- shift left 4-bits
                t2_v1 <= "0000" & t2_v1(N-1 DOWNTO 5); -- shift right 5-bits
                t3_v1 <= t1_v1 XOR t2_v1;
                t3_v1 <= unsigned(t3_v1) + unsigned(t_v1);
                
                key_sel <= unsigned(sum AND x"0000_0003");
                IF (key_sel(1 DOWNTO 0) = "00") THEN
                        key <= k1;
                    ELSIF (key_sel(1 DOWNTO 0) = "01") THEN
                        key <= k2;
                    ELSIF (key_sel(1 DOWNTO 0) = "10") THEN
                        key <= k3;
                    ELSE
                        key <= k4;
                END IF;

                t_sum <= unsigned(sum) + unsigned(key);
                t_v0 <= STD_LOGIC_VECTOR(unsigned(t_v0) + unsigned(t3_v1 XOR t_sum));
                -- end modifying v0

                nextState <= s2;
            WHEN s2 =>
                sum <= STD_LOGIC_VECTOR(unsigned(sum) + unsigned(delta));

                nextState <= s3;
            WHEN s3 =>
                -- start modifying v1
                t1_v0 <= t1_v0(N-1-4 DOWNTO 0) & "0000"; -- shift left 4-bits
                t2_v0 <= "0000" & t2_v0(N-1 DOWNTO 5); -- shift right 5-bits
                t3_v0 <= t1_v0 XOR t2_v0;
                t3_v0 <= unsigned(t3_v0) + unsigned(t_v0);

                t_sum <= unsigned(x"B" & sum(N-1 DOWNTO 11)); -- shift right 11-bits
                key_sel <= unsigned(t_sum AND x"0000_0003");
                IF (key_sel(1 DOWNTO 0) = "00") THEN
                    key <= k1;
                ELSIF (key_sel(1 DOWNTO 0) = "01") THEN
                    key <= k2;
                ELSIF (key_sel(1 DOWNTO 0) = "10") THEN
                    key <= k3;
                ELSE
                    key <= k4;
                END IF;

                t_sum <= unsigned(sum) + unsigned(key);
                t_v1 <= STD_LOGIC_VECTOR(unsigned(t_v1) + unsigned(t3_v1 XOR t_sum));
                -- end modifying v1
                IF (count < num_rounds-1) THEN
                    count <= count + 1;
                    nextState <= s1;
                ELSE
                    nextState <= s7;
                END IF;
            WHEN s4 =>
                -- start modifying v1
                t1_v0 <= t1_v0(N-1-4 DOWNTO 0) & "0000"; -- shift left 4-bits
                t2_v0 <= "0000" & t2_v0(N-1 DOWNTO 5); -- shift right 5-bits
                t3_v0 <= t1_v0 XOR t2_v0;
                t3_v0 <= unsigned(t3_v0) + unsigned(t_v0);

                t_sum <= unsigned(x"B" & sum(N-1 DOWNTO 11)); -- shift right 11-bits
                key_sel <= unsigned(t_sum AND x"0000_0003");
                IF (key_sel(1 DOWNTO 0) = "00") THEN
                    key <= k1;
                ELSIF (key_sel(1 DOWNTO 0) = "01") THEN
                    key <= k2;
                ELSIF (key_sel(1 DOWNTO 0) = "10") THEN
                    key <= k3;
                ELSE
                    key <= k4;
                END IF;

                t_sum <= unsigned(sum) + unsigned(key);
                t_v1 <= STD_LOGIC_VECTOR(unsigned(t_v1) - unsigned(t3_v1 XOR t_sum));
                -- end modifying v1
                nextState <= s5;
            WHEN s5 =>
                sum <= STD_LOGIC_VECTOR(unsigned(sum) - unsigned(delta));

                nextState <= s6;
            WHEN s6 =>
                -- start modifying v0
                t1_v1 <= t1_v1(N-1-4 DOWNTO 0) & "0000"; -- shift left 4-bits
                t2_v1 <= "0000" & t2_v1(N-1 DOWNTO 5); -- shift right 5-bits
                t3_v1 <= t1_v1 XOR t2_v1;
                t3_v1 <= unsigned(t3_v1) + unsigned(t_v1);
                
                key_sel <= unsigned(sum AND x"0000_0003");
                IF (key_sel(1 DOWNTO 0) = "00") THEN
                        key <= k1;
                    ELSIF (key_sel(1 DOWNTO 0) = "01") THEN
                        key <= k2;
                    ELSIF (key_sel(1 DOWNTO 0) = "10") THEN
                        key <= k3;
                    ELSE
                        key <= k4;
                END IF;

                t_sum <= unsigned(sum) + unsigned(key);
                t_v0 <= STD_LOGIC_VECTOR(unsigned(t_v0) - unsigned(t3_v1 XOR t_sum));
                -- end modifying v0
                IF (count < num_rounds-1) THEN
                    count <= count + 1;
                    nextState <= s4;
                ELSE
                    nextState <= s7;
                END IF;
            WHEN s7 =>
                out_0 <= t_v0;
                out_1 <= t_v1;
                done <= '1';
                nextState <= s7;
        END CASE;
    END PROCESS;
END ARCHITECTURE;
            