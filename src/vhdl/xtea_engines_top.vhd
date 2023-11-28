library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity xtea_engines_top is
    generic(
        rep : integer := 4
    );
end entity;
architecture structural of xtea_engines_top is

    component mux4in is
        generic(
            n: integer := 32
        );
        port(
            i_0 : in std_logic_vector(n-1 downto 0);
            i_1 : in std_logic_vector(n-1 downto 0);
            i_2 : in std_logic_vector(n-1 downto 0);
            i_3 : in std_logic_vector(n-1 downto 0);

            sel: in std_logic_vector(1 downto 0);
            o_data: out std_logic_vector(n-1 downto 0)
        );
    end component;

    component demux4in is
        generic(
            n: integer := 32
        );
        port(
            i_data : in std_logic_vector(n-1 downto 0);

            sel: in std_logic_vector(1 downto 0);
            o_data0: out std_logic_vector(n-1 downto 0);
            o_data1: out std_logic_vector(n-1 downto 0);
            o_data2: out std_logic_vector(n-1 downto 0);
            o_data3: out std_logic_vector(n-1 downto 0)
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

    xtea_0
    xtea_1
    xtea_2
    xtea_3

    begin


end architecture;
