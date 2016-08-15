-- 13 bit Load-counter; klok is in principe 100MHz (aclk van ARM uP ZYBO)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Cnt13Ld is -- Counter met CEO om de D/100 usec (geen uitgang Q=COUNT)
port (
        CEO : out STD_LOGIC;
        C   : in STD_LOGIC; -- 100MHz !
        D   : in STD_LOGIC_VECTOR(12 downto 0);
        L   : in STD_LOGIC);
end Cnt13Ld;

architecture Gedrag of Cnt13Ld is
  signal COUNT : STD_LOGIC_VECTOR(12 downto 0) := (others => '0');
  constant TERMINAL_COUNT_DOWN : STD_LOGIC_VECTOR(12 downto 0) := (others => '0');
begin
	process(C)
	begin
		if (rising_edge(C)) then
			if (L = '1') then
				COUNT <= D;
			else COUNT <= COUNT-1;
			end if;
		end if;
	end process;

CEO <= '1' when (COUNT = TERMINAL_COUNT_DOWN) else '0';

end Gedrag;
