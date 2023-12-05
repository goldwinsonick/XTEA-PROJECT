library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity serialFPGA_fsm_tx is
    port(
        rst, clk        : in std_logic;
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
        init, s_waiting, s_read_1, s_read_2
    );
    signal nextState, currentState : states;
    signal cnt      : integer := 0;
    signal vidx     : std_logic;
begin
    process(rst, clk)
    begin
        -- test <= '0';
        if (rst = '1') then
            currentState <= init;
        elsif rising_edge(clk) then
            currentState <= nextState;
        end if;
    end process;

    process(i_done, i_tx_ready, currentState)
    begin
        case currentState is
            when init =>
                nextState <= s_waiting;
            when s_waiting =>
                if rising_edge(i_done) then
                    vidx    <= '0';
                    cnt     <= 0;
                    nextState <= s_read_1;
                end if;
            when s_read_1 =>
                if i_tx_ready = '1' then
                    if(vidx = '0')then
                        o_sendByte  <= i_v0( 8*(cnt+1)-1 downto 8*cnt);
                    else
                        o_sendByte  <= i_v1( 8*(cnt+1)-1 downto 8*cnt);
                    end if;
                    o_send      <= '0';

                    cnt <= cnt + 1;
                    if(cnt = 3)then
                        if(vidx <= '0')then
                            vidx<='1';
                            nextState <= s_read_2;
                            cnt <= 0;
                        else
                            nextState <= s_waiting;
                        end if;
                    else 
                        nextState <= s_read_2;
                    end if;
                end if;
            when s_read_2 =>
                o_send  <= '1';
                nextState <= s_read_1;
        end case;
    end process;
end behavioral;