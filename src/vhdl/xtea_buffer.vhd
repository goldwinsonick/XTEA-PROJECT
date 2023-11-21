LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY xtea_buffer IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        data_in : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        data_out : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        load : IN STD_LOGIC;
        read : IN STD_LOGIC
    );
END xtea_buffer;

ARCHITECTURE Behavioral OF xtea_buffer IS
    SIGNAL BUFFER : STD_LOGIC_VECTOR (31 DOWNTO 0);
BEGIN

    PROCESS (clk, reset)
    BEGIN
        IF reset = '1' THEN
            BUFFER <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            IF load = '1' THEN
                BUFFER <= data_in;
            END IF;
        END IF;
    END PROCESS;

    PROCESS (clk, reset)
    BEGIN
        IF reset = '1' THEN
            data_out <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            IF read = '1' THEN
                data_out <= BUFFER;
            END IF;
        END IF;
    END PROCESS;
    
END Behavioral;