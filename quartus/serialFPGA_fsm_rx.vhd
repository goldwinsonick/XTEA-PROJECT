library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity serialFPGA_fsm_rx is
    port(
        rst, clk        : in std_logic;
        i_recvByte      : in std_logic_vector(7 downto 0);
        i_recv          : in std_logic;
        o_reg_data      : out std_logic_vector(7 downto 0);
        o_reg_sel       : out std_logic_vector(1 downto 0);
        o_reg_en        : out std_logic;
        o_proceed       : out std_logic
    );
end entity;

architecture behavioral of serialFPGA_fsm_rx is
    type states is (
        init, s_waiting, s_command, s_reading1, s_reading2
    );
    signal nextState, currentState : states;
    signal cnt : integer := 0;
    -- signal test : std_logic;
    signal msg_mode : std_logic;

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

    process(i_recv, currentState)
    begin
        o_reg_en <='0';
        case currentState is
            when init =>
                nextState <= s_waiting;
            when s_waiting =>
                msg_mode <= '1';
                cnt <= 0;
                if(i_recv = '0')then
                    if(i_recvByte = "00000001")then
                        nextState <= s_command;
                    end if;
                end if;
            when s_command =>
                if(i_recv = '0')then
                    if(i_recvByte = "00000001")then -- msg
                        msg_mode <= '1';
                        o_reg_sel <= "01";
                    elsif(i_recvByte = "00000010")then -- key
                        o_reg_sel <= "10";
                    elsif(i_recvByte = "00000011")then -- ende
                        o_reg_sel <= "11";
                    end if;
                    nextState <= s_reading1;
                end if;
            when s_reading1 =>
                if(i_recv = '0')then
                    if(i_recvByte = "00000011")then
                        nextState <= s_waiting;
                    else
                        o_reg_data <= i_recvByte;
                        o_reg_en <= '1';
                        if(msg_mode = '1')then
                            cnt <= cnt+1;
                            if(cnt = 7)then
                                o_proceed <= '1';
                                cnt <= 0;
                            end if;
                        end if;
                        nextState <= s_reading2;
                    end if;
                end if;
            when s_reading2 =>
                o_proceed     <= '0';
                o_reg_en    <= '0';
                nextState <= s_reading1;
        end case;
    end process;
end behavioral;