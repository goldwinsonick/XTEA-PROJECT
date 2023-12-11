library ieee;
use ieee.std_logic_1164.all;

-- entity
entity top_level is
	port(
		clk 			: in std_logic;
		rst_n 			: in std_logic;
		button 			: in std_logic;
		Seven_Segment	: out std_logic_vector(7 downto 0) ;
		Digit_SS		: out std_logic_vector(3 downto 0) ;
		rs232_rx 		: in std_logic;
		rs232_tx 		: out std_logic;
        led1            : out std_logic
	);
end entity;
architecture RTL of top_level is
	component my_uart_top is
	port(
			clk 		: in std_logic;
			rst_n 		: in std_logic;
			send 		: in std_logic;
			send_data	: in std_logic_vector(7 downto 0) ;
			receive 	: out std_logic;
			receive_data: out std_logic_vector(7 downto 0) ;
			rs232_rx 	: in std_logic;
			rs232_tx 	: out std_logic
	);
	end component;
	
    signal send         : std_logic;
    signal send_data    : std_logic_vector(7 downto 0);
	signal receive		: std_logic;
	signal receive_data	: std_logic_vector(7 downto 0);
	signal receive_c	: std_logic;

    -- Registers
    signal reg_msg      : std_logic_vector(63 downto 0);
    signal reg_key      : std_logic_vector(127 downto 0);
    signal reg_ende     : std_logic;
    signal reg_out      : std_logic_vector(63 downto 0);

    signal rst : std_logic;
    -- XTEA
    component xtea_engine is
        port(
            i_clk, i_rst, i_start               : in std_logic;
            i_v0, i_v1                          : in std_logic_vector(31 downto 0);
            i_ende                              : in std_logic;
            i_key0, i_key1, i_key2, i_key3      : in std_logic_vector(31 downto 0);
            o_out0, o_out1                      : out std_logic_vector(31 downto 0);
            o_done                              : out std_logic
        );
    end component;

    -- RX
    type rxStates is (
        s_waiting, s_command, s_key, s_msg, s_ende, s_proceed
    );
    signal rxState          : rxStates := s_waiting;
    signal o_proceed        : std_logic;
    signal cnt : integer := 0;

    -- TX
    type txStates is (
        s_waiting, s_send, s_stop
    );
    signal txState         : txStates := s_waiting;
    signal cnt_tx   : integer := 0;
    signal idx_tx   : integer := 0;

    signal xtea_done    : std_logic;

begin
    led1    <= reg_ende;
    rst     <= not(rst_n);

	UART: my_uart_top 
	port map (
			clk 			=> clk,
			rst_n 		=> rst_n,
			send 			=> send,
			send_data	=> send_data,
			receive 		=> receive,
			receive_data=> receive_data,
			rs232_rx 	=> rs232_rx,
			rs232_tx 	=> rs232_tx
	);

	rxprocess : process(clk)
	begin
		if ((clk = '1') and clk'event) then
			receive_c <= receive;
			if ((receive = '0') and (receive_c = '1'))then
                case rxState is
                    when s_waiting =>
                        cnt <= 0;
                        o_proceed <= '0';
                        if(receive_data = "00100011")then
                            rxState <= s_command;
                        end if;
                    when s_command =>
                        if(receive_data = "01101101")then -- msg
                            rxState <= s_msg;
                        elsif(receive_data = "01101011")then -- key
                            rxState <= s_key;
                        elsif(receive_data = "01100101")then -- ende
                            rxState <= s_ende;
                        elsif(receive_data = "01110000")then -- proceed
                            rxState <= s_proceed;
                        end if;

                    when s_ende =>
                        if(receive_data = "00100011")then
                            rxState <= s_waiting;
                        elsif(receive_data = "00110001")then
                            reg_ende <= '1';
                        elsif(receive_data = "00110000")then
                            reg_ende <= '0';
                        end if;

                    when s_msg =>
                        -- seven_segment <= "00000101";
                        if(receive_data = "00100011")then
                            rxState <= s_waiting;
                        else
                            if(cnt<8)then
                                -- reg_msg(8*(cnt+1)-1 downto 8*cnt) <= receive_data;
                                reg_msg(8*(cnt+1)-1 downto 8*cnt) <= receive_data;
                                cnt <= cnt + 1;
                            else
                                cnt <= 0;
                            end if;
                        end if;

                    when s_proceed =>
                        if(receive_data = "00100011")then
                            rxState <= s_waiting;
                        else
                            o_proceed <= '1';
                        end if;

                    when s_key =>
                        -- seven_segment <= "00001001";
                        if(receive_data = "00100011")then
                            rxState <= s_waiting;
                        else
                            reg_key(8*(cnt+1)-1 downto 8*cnt)<= receive_data;
                            cnt <= cnt + 1;
                        end if;
                end case;
			end if;
		end if;
	end process;

    txprocess : process(clk)
    begin
		if ((clk = '1') and clk'event) then
            case txState is
                when s_waiting =>
                    send <= '1';
                    cnt_tx <= 0;
                    idx_tx <= 0;
                    if(xtea_done = '1')then
                        txState <= s_send;
                    end if;
                when s_send =>
                    if(cnt_tx < 100000)then
                        cnt_tx <= cnt_tx + 1;
                        send <= '1';
                    else
                        if(idx_tx < 8)then
                            send_data <= reg_out(8*(idx_tx+1)-1 downto 8*idx_tx);
                            send <= '0';
                            idx_tx <= idx_tx + 1;
                        else
                            txState <= s_stop;
                        end if;
                        cnt_tx<=0;
                    end if;
                when s_stop =>
                    idx_tx <= 0;
                    send_data <= "00100011";
                    send <= '0';
                    txState <= s_waiting;
            end case;
        end if;
    end process;

    xtea_engine1 : xtea_engine
        port map(
            i_clk   => clk,
            i_rst   => rst,
            i_start => o_proceed,
            i_v1    => reg_msg(63 downto 32),
            i_v0    => reg_msg(31 downto 0),
            i_ende  => reg_ende,
            i_key3  => reg_key(127 downto 96),
            i_key2  => reg_key(95 downto 64),
            i_key1  => reg_key(63 downto 32),
            i_key0  => reg_key(31 downto 0),
            o_out1  => reg_out(63 downto 32),
            o_out0  => reg_out(31 downto 0),
            o_done  => xtea_done
        );
        seven_segment<= reg_out(7 downto 0);

end architecture;


