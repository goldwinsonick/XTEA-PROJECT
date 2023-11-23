library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity top_level_vhd is
    port(
        i_clk, i_rst : std_logic
    );
end entity;

architecture structural of top_level_vhd is
    component bram is
        generic (
            DATA    : integer := 32;
            ADDR    : integer := 12);
        port (
            -- Port A
            wclkA  : in std_logic;
            wr_enA   : in std_logic;
            addrA  : in std_logic_vector(ADDR-1 downto 0);
            wr_dataA   : in std_logic_vector(DATA-1 downto 0);
            rd_dataA  : out std_logic_vector(DATA-1 downto 0);

            -- Port B
            wr_enB   : in std_logic;
            addrB  : in std_logic_vector(ADDR-1 downto 0);
            wr_dataB   : in std_logic_vector(DATA-1 downto 0);
            rd_dataB  : out std_logic_vector(DATA-1 downto 0)
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

    component addr_counter is
        port(
            i_clk, i_rst: in std_logic;
            o_addr      : out std_logic_vector(11 downto 0);
        );
    end component;

    component xtea_controller is
        port(
            i_clk, i_rst        : std_logic;
            i_process_addr      : std_logic_vector(11 downto 0);
            i_process_start     : std_logic;
            i_done_addr         : std_logic_vector(11 downto 0);
            o_xtea_addr         : std_logic_vector(11 downto 0);
            o_xtea_start        : std_logic
        );
    end component;

    signal wr_enA                   : std_logic;
    signal wr_dataA, rd_dataA       : std_logic_vector(31 downto 0);
    signal addrA                    : std_logic_vector(11 downto 0);
    signal wr_enB                   : std_logic;
    signal wr_dataB, rd_dataB       : std_logic_vector(31 downto 0);
    signal addrB                    : std_logic_vector(11 downto 0);
    
    begin
        bram1 : bram
            generic map(
                DATA => 32,
                ADDR => 12
            )
            port map(
                -- Port A
                wclkA       => i_clk,
                wr_enA      => wr_enA,
                addrA       => addrA,
                wr_dataA    => wr_dataA,
                rd_dataA    => rd_dataA,
                -- Port B
                wr_enB      => wr_dataB,
                addrB       => addrB,
                wr_dataB    => wr_dataB,
                rd_dataB    => rd_dataB
            );

        
end structural;
