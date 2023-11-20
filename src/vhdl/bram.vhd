library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity bram is
generic (
    DATA    : integer := 32;
    ADDR    : integer := 12);
port (
    -- Port A
    clkA  : in std_logic;
    wr_enA    : in std_logic;
    addrA  : in std_logic_vector(ADDR-1 downto 0);
    wr_dataA   : in std_logic_vector(DATA-1 downto 0);
    rd_dataA  : out std_logic_vector(DATA-1 downto 0)

    -- -- Port B
    -- clkB  : in std_logic;
    -- wr_enB   : in std_logic;
    -- addrB  : in std_logic_vector(ADDR-1 downto 0);
    -- wr_dataB   : in std_logic_vector(DATA-1 downto 0);
    -- rd_dataB  : out std_logic_vector(DATA-1 downto 0)
);
end bram;

architecture behavioral of bram is
    -- Shared memory
    type mem_type is array ( 0 to (2**ADDR)-1 ) of std_logic_vector(DATA-1 downto 0);
    signal mem : mem_type;
begin

-- Port A
process(clkA)
begin
    if(clkA'event and clkA='1') then
        if(wr_enA='1') then
            mem(to_integer(unsigned(addrA))) <= wr_dataA;
        end if;
        rd_dataA <= mem(to_integer(unsigned(addrA)));
    end if;
end process;

-- Port B
-- process(clkB)
-- begin
--     if(clkB'event and clkB='1') then
--         if(wr_enB='1') then
--             mem(to_integer(unsigned(addrB))) <= wr_dataB;
--         end if;
--         rd_dataB <= mem(to_integer(unsigned(addrB)));
--     end if;
-- end process;

end behavioral;