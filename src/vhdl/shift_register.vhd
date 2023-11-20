library IEEE;
use IEEE.std_logic_1165.all;
use IEEE.numeric.std.all;

entity shift_register is
    generic(
        size : integer := 8;
    );
    port(
        clk : in std_logic;
        rst : in std_logic;
        shift_in  : in std_logic_vector(size-1 downto 0);
        shift_r   : in std_logic;
        shift_l   : in std_logic;
        shift_out : out std_logic_vector(size-1 downto 0);
    );
end entity;

architecture behavioral of shift_register is
    signal data : std_logic_vector(size-1 downto 0) := (others => '0');
begin
    process(clk, rst)
    begin
        if rst = '1' then
            data <= (others => '0');
        elsif rising_edge(clk) then -- shift
            if(shift_right = '1') then -- shift right
                data <= shift_in & data(data'high downto 1);
            elsif(shift_left = '1') then -- shift left
                data <= data(data'high-1 downto 0) & shift_out;
        end if;
    end process;
    shift_out <= data(0);
end behavioral;