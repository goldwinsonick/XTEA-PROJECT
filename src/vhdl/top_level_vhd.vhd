library IEEE;
use IEEE.std_logic_1164.all;

entity top_level_vhd is
    port(
        clk : in std_logic;
        rst : in std_logic;
        rx  : in std_logic;
        tx  : out std_logic;
    );
end entity;

architecture structural of top_level_vhd is
    -- Components
    component shift_register is
        generic(
            size : 8;
        );
        port(
            clk : in std_logic;
            rst : in std_logic;
            shift_in  : in std_logic_vector(size-1 downto 0);
            shift_r   : in std_logic;
            shift_l   : in std_logic;
            shift_out : out std_logic_vector(size-1 downto 0);
        );
    end component;

    component dual_port_BRAM is
        port(
            clkA : in std_logic;
            wr_enA : in std_logic;
            addrA : in std_logic_vector(8 downto 0);
            wr_dataA : in std_logic_vector(31 downto 0);
            rd_dataA : out std_logic_vector(31 downto 0);

            clkB : in std_logic;
            wr_enB : in std_logic;
            addrB : in std_logic_vector(8 downto 0);
            wr_dataB : in std_logic_vector(31 downto 0);
            rd_dataB : out std_logic_vector(31 downto 0);
        );
    end component;

    component controller_xtea is
        port(
            i_clk : in std_logic;
            i_rst : in std_logic;
            i_addr` : in std_logic;
            o_v0    : in std_logic;
            o_v1    : in std_logic;
            o_k0    : in std_logic;
            o_k1    : in std_logic;
            o_k2    : in std_logic;
            o_k3    : in std_logic;
            o_sel   : in std_logic;
        );
    end component;

    component xtea_engines is
        port(
            i_clk   : in std_logic;
            i_sel   : in std_logic;
            i_v0    : in std_logic;
            i_v1    : in std_logic;
            i_k0    : in std_logic;
            i_k1    : in std_logic;
            i_k2    : in std_logic;
            i_k3    : in std_logic;
            o_out0    : out std_logic;
            o_out1    : out std_logic;
            o_done    : out std_logic;
            o_addr    : out std_logic;
        );
    end component;

    begin
        
    end;

end structural;