library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity serialFPGA_fsm_rx is
    port(
        rst_n, clk      : in std_logic;
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
        s_waiting, s_command, s_reading
    );
    signal currentState         : states := s_waiting;

    signal receive_c, receive   : std_logic;
    signal receive_data         : std_logic_vector(7 downto 0);
    signal mode                 : integer := 0;
    signal cnt                  : integer := 0;
    -- mode 0 = msg
    -- mode 1 = key
    -- mode 2 = ende

begin
    receive <= i_recv;          -- Recieve Signal
    receive_data <= i_recvByte; -- Recieved Data

    process(rst_n, clk)
    begin
        -- if(rst_n = '0')then
        --     currentState <= s_waiting;
        -- end if;

        -- Cek recieve data
		if ((clk = '1') and clk'event) then
            -- Variabel o_reg_en dan o_proceed di nol kan sehingga 1 dalam 1 klok saja.
            o_reg_en <= '0';
            o_proceed <= '0';
			receive_c <= receive;
			if ((receive = '0') and (receive_c = '1'))then
                case currentState is
                    when s_waiting =>
                        if(receive_data = "00100011")then
                            currentState <= s_command;
                        else
                            currentState <= s_waiting;
                        end if;
                    when s_command =>
                        if(receive_data = "01101101")then
                            mode <= 0;
                            o_reg_sel <= "00";
                        elsif(receive_data = "01101011")then
                            mode <= 1;
                            o_reg_sel <= "10";
                        elsif(receive_data = "01100101")then
                            mode <= 2;
                            o_reg_sel <= "01";
                        else
                            mode <= 3; -- Error
                        end if;
                        currentState <= s_reading;
                    when s_reading =>
                        -- Jika Stopbyte
                        if(receive_data = "00100011")then
                            currentState <= s_waiting;
                        else
                            o_reg_data <= receive_data;
                            o_reg_en <= '1';
                            if(mode = 0)then
                                if(cnt = 7)then
                                    o_proceed <= '1';
                                    cnt <= 0;
                                else
                                    cnt <= cnt+1;
                                end if;
                            end if;
                        end if;
                end case;
			end if;
		end if;
    end process;
end behavioral;