LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY RX_XTEA IS
    PORT (
        clk : IN STD_LOGIC; -- clock input
        reset : IN STD_LOGIC; -- reset input
        rx : IN STD_LOGIC; -- serial input from PC
        mode : OUT STD_LOGIC; -- mode output (0 for encrypt, 1 for decrypt)
        key : OUT STD_LOGIC_VECTOR(63 DOWNTO 0); -- key output (64 bits)
        message : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- message output (32 bits)
        valid : OUT STD_LOGIC -- valid output (indicates when message is ready)
    );
END RX_XTEA;

ARCHITECTURE behav OF RX_XTEA IS

    -- define the states of the FSM
    TYPE state_type IS (idle, start_byte, mode_select, key_input, message_input, encrypt_decrypt);
    SIGNAL state : state_type; -- current state
    SIGNAL next_state : state_type; -- next state

    -- define the constants for the baud rate and the bit period
    CONSTANT baud_rate : INTEGER := 9600; -- baud rate in bits per second
    CONSTANT bit_period : INTEGER := 100000000 / baud_rate; -- bit period in clock cycles (assuming 100 MHz clock)

    -- define the signals for the serial input
    SIGNAL rx_reg : STD_LOGIC_VECTOR(7 DOWNTO 0); -- register to store the received byte
    SIGNAL rx_bit_count : INTEGER RANGE 0 TO 8; -- counter to keep track of the received bits
    SIGNAL rx_done : STD_LOGIC; -- flag to indicate when a byte is received
    SIGNAL rx_sample : STD_LOGIC; -- signal to sample the serial input
    SIGNAL rx_d1, rx_d2 : STD_LOGIC; -- delayed signals for edge detection

    -- define the signals for the mode, key, and message inputs
    SIGNAL mode_reg : STD_LOGIC; -- register to store the mode bit
    SIGNAL key_reg : STD_LOGIC_VECTOR(63 DOWNTO 0); -- register to store the key bits
    SIGNAL key_bit_count : INTEGER RANGE 0 TO 64; -- counter to keep track of the key bits
    SIGNAL message_reg : STD_LOGIC_VECTOR(31 DOWNTO 0); -- register to store the message bits
    SIGNAL message_bit_count : INTEGER RANGE 0 TO 32; -- counter to keep track of the message bits

BEGIN

    -- process to implement the serial receiver
    serial_receiver : PROCESS (clk, reset)
    BEGIN
        IF reset = '1' THEN -- asynchronous reset
            rx_reg <= (OTHERS => '0'); -- clear the register
            rx_bit_count <= 0; -- reset the counter
            rx_done <= '0'; -- clear the flag
            rx_sample <= '0'; -- clear the sample signal
            rx_d1 <= '0'; -- clear the delayed signal
            rx_d2 <= '0'; -- clear the delayed signal
        ELSIF rising_edge(clk) THEN -- synchronous logic
            rx_d1 <= rx; -- update the delayed signal
            rx_d2 <= rx_d1; -- update the delayed signal
            IF rx_d2 = '0' AND rx_d1 = '1' THEN -- detect the falling edge (start bit)
                rx_sample <= '1'; -- set the sample signal
            ELSIF rx_sample = '1' AND rx_bit_count = 8 THEN -- detect the stop bit
                rx_sample <= '0'; -- clear the sample signal
                rx_done <= '1'; -- set the flag
            ELSIF rx_sample = '1' AND rx_bit_count < 8 THEN -- receive the data bits
                rx_reg(rx_bit_count) <= rx; -- store the data bit
                rx_bit_count <= rx_bit_count + 1; -- increment the counter
            END IF;
            IF rx_sample = '1' THEN -- generate the bit period
                rx_sample <= '0'; -- clear the sample signal
            ELSIF rx_bit_count > 0 THEN -- wait for the next bit
                rx_sample <= NOT rx_sample; -- toggle the sample signal
                IF rx_sample = '1' AND rx_bit_count = 8 THEN -- end of the byte
                    rx_bit_count <= 0; -- reset the counter
                END IF;
            END IF;
        END IF;
    END PROCESS serial_receiver;

    -- process to implement the state transition logic
    state_transition : PROCESS (clk, reset)
    BEGIN
        IF reset = '1' THEN -- asynchronous reset
            state <= idle; -- initial state
        ELSIF rising_edge(clk) THEN -- synchronous logic
            state <= next_state; -- update the state
        END IF;
    END PROCESS state_transition;

    -- process to implement the state output logic
    state_output : PROCESS (state, rx_reg, rx_done, mode_reg, key_reg, key_bit_count, message_reg, message_bit_count)
    BEGIN
        -- default outputs
        next_state <= state; -- no state change
        mode <= '0'; -- default mode (encrypt)
        key <= (OTHERS => '0'); -- default key
        message <= (OTHERS => '0'); -- default message
        valid <= '0'; -- default valid signal

        CASE state IS
            WHEN idle => -- idle state
                IF rx_done = '1' AND rx_reg = x"AA" THEN -- start byte received
                    next_state <= start_byte; -- go to start byte state
                END IF;
            WHEN start_byte => -- start byte state
                IF rx_done = '1' THEN -- mode byte received
                    mode_reg <= rx_reg(3); -- store the mode bit
                    next_state <= mode_select; -- go to mode select state
                END IF;
            WHEN mode_select => -- mode select state
                IF rx_done = '1' THEN -- key byte received
                    key_reg(key_bit_count + 7 DOWNTO key_bit_count) <= rx_reg; -- store the key byte
                    key_bit_count <= key_bit_count + 8; -- increment the key bit count
                    IF key_bit_count = 64 THEN -- end of the key
                        next_state <= key_input; -- go to key input state
                    END IF;
                END IF;
            WHEN key_input => -- key input state
                IF rx_done = '1' THEN -- message byte received
                    message_reg(message_bit_count + 7 DOWNTO message_bit_count) <= rx_reg; -- store the message byte
                    message_bit_count <= message_bit_count + 8; -- increment the message bit count
                    IF message_bit_count = 32 THEN -- end of the message
                        next_state <= message_input; -- go to message input state
                    END IF;
                END IF;
            WHEN message_input => -- message input state
                mode <= mode_reg; -- output the mode
                key <= key_reg; -- output the key
                message <= message_reg; -- output the message
                valid <= '1'; -- output the valid signal
                next_state <= encrypt_decrypt; -- go to encrypt/decrypt state
            WHEN encrypt_decrypt => -- encrypt/decrypt state
                IF rx_done = '1' AND rx_reg = x"55" THEN -- stop byte received
                    next_state <= idle; -- go back to idle state
                END IF;
        END CASE;
    END PROCESS state_output;

END behav;