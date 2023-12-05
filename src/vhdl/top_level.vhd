library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity top_level is
    port(
        i_rst, i_clk : in std_logic; -- reset and clock
        i_rx : in std_logic; -- RX to PC
        o_tx : out std_logic -- TX to PC
    );
end entity;

architecture top_level_arc of top_level is
    component serialFPGA is
        port(
            i_clk, i_rst        : in std_logic;
            i_rx                : in std_logic;
            o_tx                : out std_logic;
            i_v0                : in std_logic_vector(31 downto 0);
            i_v1                : in std_logic_vector(31 downto 0);
            i_done              : in std_logic;
            o_reg_data          : out std_logic_vector(7 downto 0);
            o_reg_en            : out std_logic;
            o_reg_sel           : out std_logic_vector(1 downto 0);
            o_proceed           : out std_logic
        );
    end component;

    component shift_register is
        generic(
            N            : integer := 32
        );
        port(
            i_clk, i_rst    : in std_logic;
            i_data          : in std_logic_vector(7 downto 0);
            i_en            : in std_logic;
            o_data          : out std_logic_vector(N-1 downto 0)
        );
    end component;

    component demux_4in is
        generic(
            n       : integer := 32
        );
        port(
            i_data  : in std_logic_vector(n-1 downto 0);
            sel     : in std_logic_vector(1 downto 0);

            o_data0     : out std_logic_vector(n-1 downto 0);
            o_data1     : out std_logic_vector(n-1 downto 0);
            o_data2     : out std_logic_vector(n-1 downto 0);
            o_data3     : out std_logic_vector(n-1 downto 0)
        );
    end component;

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

    signal reg_data     : std_logic_vector(7 downto 0);
    signal reg_en       : std_logic;
    signal reg_sel      : std_logic_vector(1 downto 0);
    signal xtea_start   : std_logic;
    signal xtea_out0, xtea_out1     : std_logic_vector(31 downto 0);
    signal xtea_done                : std_logic;

    signal in_sreg_msg      : std_logic_vector(7 downto 0);
    signal en_sreg_msg      : std_logic;
    signal out_sreg_msg     : std_logic_vector(63 downto 0);

    signal in_sreg_key      : std_logic_vector(7 downto 0);
    signal en_sreg_key      : std_logic;
    signal out_sreg_key     : std_logic_vector(127 downto 0);

    signal in_sreg_ende     : std_logic_vector(7 downto 0);
    signal en_sreg_ende     : std_logic;
    signal out_sreg_ende    : std_logic_vector(7 downto 0);

begin
    serialFPGA1 : serialFPGA
        port map(
            i_clk               => i_clk,
            i_rst               => i_rst,
            i_rx                => i_rx,
            o_tx                => o_tx,
            i_v0                => xtea_out0,
            i_v1                => xtea_out1,
            i_done              => xtea_done,
            o_reg_data          => reg_data,
            o_reg_en            => reg_en,
            o_reg_sel           => reg_sel,
            o_proceed           => xtea_start
        );
    
    demux_data : demux_4in
        generic map(
            n           => 8
        )
        port map(
            i_data      => reg_data,
            sel         => reg_sel,

            o_data1     => in_sreg_msg,
            o_data2     => in_sreg_key,
            o_data3     => in_sreg_ende
        );

    demux_en : demux_4in
        generic map(
            n           => 1
        )
        port map(
            i_data(0)      => reg_en,
            sel         => reg_sel,

            o_data1(0)     => en_sreg_msg,
            o_data2(0)     => en_sreg_key,
            o_data3(0)     => en_sreg_ende
        );

    sreg_msg : shift_register
        generic map(
            N   => 64
        )
        port map(
            i_clk           => i_clk,
            i_rst           => i_rst,
            i_data          => in_sreg_msg,
            i_en            => en_sreg_msg,
            o_data          => out_sreg_msg
        );
    
    sreg_key : shift_register
        generic map(
            N   => 128
        )
        port map(
            i_clk           => i_clk,
            i_rst           => i_rst,
            i_data          => in_sreg_key,
            i_en            => en_sreg_key,
            o_data          => out_sreg_key
        );

    sreg_ende : shift_register
        generic map(
            N   => 8
        )
        port map(
            i_clk           => i_clk,
            i_rst           => i_rst,
            i_data          => in_sreg_ende,
            i_en            => en_sreg_ende,
            o_data          => out_sreg_ende
        );

    xtea_engine1 : xtea_engine
        port map(
            i_clk           => i_clk,
            i_rst           => i_rst,
            i_start         => xtea_start,
            i_v0            => out_sreg_msg(63 downto 32),
            i_v1            => out_sreg_msg(31 downto 0),
            i_ende          => out_sreg_ende(0),
            i_key0          => out_sreg_key(127 downto 96),
            i_key1          => out_sreg_key(95 downto 64),
            i_key2          => out_sreg_key(63 downto 32),
            i_key3          => out_sreg_key(31 downto 0),
            o_out0          => xtea_out0,
            o_out1          => xtea_out1,
            o_done          => xtea_done
        );
end top_level_arc;