library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fifo is
    generic(
        addr        : integer := 12
    );
    port(
        -- i_clk       : in std_logic;
        i_done      : in std_logic;
        in_addr     : in std_logic_vector(addr-1 downto 0);
        out_addr    : out std_logic_vector(addr-1 downto 0)
    );
end fifo;

architecture fifo_arc of fifo is
    type address is array (3 downto 0) of std_logic_vector(addr-1 downto 0);
    signal addr_list    : address;
    signal index        : integer := 0;
    signal index_a      : std_logic := '0';
    signal index_b      : std_logic := '0';
    begin
    process
    begin
        wait on in_addr;
            addr_list(index) <= in_addr;
            index_a <= not(index_a);
    end process;

    process(i_done)
    begin
        if rising_edge(i_done) then
            out_addr <= addr_list(index-1);
            index_b <= not(index_b);
        end if;
    end process;

    process(index_a, index_b)
    begin
        if (index_a'EVENT) then
            index <= index + 1;
        elsif (index_b'EVENT) then
            index <= index - 1;
        end if;
    end process;
end architecture;