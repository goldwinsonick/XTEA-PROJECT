library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity serialFPGA_fsm_tx is
    port(
        rst_n, clk      : in std_logic;
        i_v0            : in std_logic_vector(31 downto 0); 
        i_v1            : in std_logic_vector(31 downto 0);
        i_done          : in std_logic;
        i_tx_ready      : in std_logic;
        o_sendByte      : out std_logic_vector(7 downto 0);
        o_send          : out std_logic
    );
end entity;

architecture behavioral of serialFPGA_fsm_tx is
    type states is (
        s_waiting, s_startbyte, s_reading, s_stopbyte
    );
    signal currentState         : states := s_waiting;
    signal i_done_c             : std_logic;

    signal cnt      : integer := 0;
begin
    process(clk)
    begin
        o_send <= '1';
        if i_tx_ready='1' then
            case currentState is
                when s_waiting =>
                    i_done_c <= i_done;
                    if(i_done_c='0' and i_done='1')then
                        currentState <= s_startbyte;
                    end if;
                    -- if(i_done = '1')then
                    --     currentState <= s_startbyte;
                    -- end if;
                when s_startbyte =>
                    o_sendByte  <= "00100011";
                    o_send      <= '0';
                    cnt <= 0;
                    currentState <= s_reading;
                when s_reading =>
                    if(cnt < 4)then
                        o_sendByte <= i_v0( 8*(cnt+1)-1 downto 8*cnt);
                    elsif(4 <= cnt and cnt < 7)then
                        o_sendByte <= i_v1( 8*(cnt+1)-1 downto 8*cnt);
                    else -- cnt > 7
                        currentState <= s_stopbyte;
                    end if;
                    o_send <= '0';
                when s_stopbyte =>
                    o_sendByte <= "00100011";
                    o_send <= '0';
                    currentState <= s_waiting;
            end case;
        end if;
    end process;
end behavioral;