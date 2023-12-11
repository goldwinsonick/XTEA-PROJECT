library ieee;
use ieee.std_logic_1164.all;
 
entity demux_4in is
    generic(
        n: integer := 32
    );
    port(
        i_data  : in std_logic_vector(n-1 downto 0);
        sel     : in std_logic_vector(1 downto 0);

        o_data0     : out std_logic_vector(n-1 downto 0);
        o_data1     : out std_logic_vector(n-1 downto 0);
        o_data2     : out std_logic_vector(n-1 downto 0);
        o_data3     : out std_logic_vector(n-1 downto 0)
    );
end entity;

architecture behavioral of demux_4in is
begin
process(i_data, sel) is
begin
    o_data0 <= (others => '0');
    o_data1 <= (others => '0');
    o_data2 <= (others => '0');
    o_data3 <= (others => '0');

    if(sel = "00") then
        o_data0 <= i_data;
    elsif(sel = "01") then
        o_data1 <= i_data;
    elsif(sel = "10") then
        o_data2 <= i_data;
    elsif(sel = "11") then
        o_data3 <= i_data;
    end if;
end process;
end architecture behavioral;