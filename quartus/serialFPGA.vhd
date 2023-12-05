library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity serialFPGA is
    port(
        -- clockk and reset
        i_clk, i_rst    : in std_logic;

        -- PC Serial
        i_rx            : in std_logic;
        o_tx            : out std_logic;

        -- Data to send and recieve
        -- i_send_data     : in std_logic_vector(7 downto 0);
        -- i_send_en       : in std_logic;
        i_v0                : in std_logic_vector(31 downto 0);
        i_v1                : in std_logic_vector(31 downto 0);
        i_done              : in std_logic;
        o_reg_data          : out std_logic_vector(7 downto 0);
        o_reg_en            : out std_logic;
        o_reg_sel           : out std_logic_vector(1 downto 0);
        o_proceed           : out std_logic
    );
end entity;

architecture serialFPGA_arc of serialFPGA is
    component my_uart_top is
        port(
            clk 			: in std_logic;
            rst_n 		: in std_logic;
            -- paralel part
            send 			: in std_logic;
            send_data	    : in std_logic_vector(7 downto 0) ;
            receive 		: out std_logic;
            receive_data    : out std_logic_vector(7 downto 0);
            -- serial part
            rs232_rx 	: in std_logic;
            rs232_tx 	: out std_logic;
            tx_ready    : out std_logic
        );
    end component;

    component serialFPGA_fsm_rx is
        port(
            rst, clk        : in std_logic;
            i_recvByte      : in std_logic_vector(7 downto 0);
            i_recv          : in std_logic;
            o_reg_data      : out std_logic_vector(7 downto 0);
            o_reg_sel       : out std_logic_vector(1 downto 0);
            o_reg_en        : out std_logic;
            o_proceed       : out std_logic
        );
    end component;

    component serialFPGA_fsm_tx is
        port(
            rst, clk        : in std_logic;
            i_v0            : in std_logic_vector(31 downto 0); 
            i_v1            : in std_logic_vector(31 downto 0);
            i_done          : in std_logic;
            i_tx_ready      : in std_logic;
            o_sendByte      : out std_logic_vector(7 downto 0);
            o_send          : out std_logic
        );
    end component;

    -- signal send         : std_logic;
    -- signal send_data    : std_logic_vector(7 downto 0);
    signal receive      : std_logic;
    signal receive_data : std_logic_vector(7 downto 0);

    signal send         : std_logic;
    signal send_data    : std_logic_vector(7 downto 0);
    signal tx_ready     : std_logic;
begin
    uart_top : my_uart_top
        port map(
            clk             => i_clk,
            rst_n           => i_rst,
            send            => send,
            send_data       => send_data,
            receive         => receive,
            receive_data    => receive_data,
            rs232_rx        => i_rx,
            rs232_tx        => o_tx,
            tx_ready        => tx_ready
        );
    serialFPGA_fsm_rx1 : serialFPGA_fsm_rx
        port map(
            rst             => i_rst,
            clk             => i_clk,
            i_recvByte      => receive_data,
            i_recv          => receive,
            o_reg_data      => o_reg_data,
            o_reg_sel       => o_reg_sel,
            o_reg_en        => o_reg_en,
            o_proceed       => o_proceed
        );
    serialFPGA_fsm_tx1  : serialFPGA_fsm_tx
        port map(
            rst             => i_rst,
            clk             => i_clk,
            i_v0            => i_v0,
            i_v1            => i_v1,
            i_done          => i_done,
            i_tx_ready      => tx_ready,
            o_sendByte      => send_data,
            o_send          => send
        );

end serialFPGA_arc;
