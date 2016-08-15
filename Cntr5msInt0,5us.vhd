-- Counter tot 5 millisec; Clock is 100MHz (aclk van PS ZYBO)
-- Interruptsignaal van 500 nsec
-- Opgemaakt 31/07/2016, om wachttijd van 5 milliseconden te genereren tussen twee DCC packets via Interrupt signaal van 0,5 microsec breed

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Cnt5ms is -- Counter met Start en Einde na 5 millisec en breedte 1 microsec (50 klokpulsen) = lengte van interruptsignaal
port (
	Clock		: in STD_LOGIC; -- 100MHz
	StartCnt	: in STD_LOGIC;
	EindCnt		: out STD_LOGIC);
end Cnt5ms;

architecture Gedrag of Cnt5ms is
  signal COUNT	: STD_LOGIC_VECTOR(18 downto 0) := (others => '0');
  signal CE		: STD_LOGIC := '0';
  constant Nul : STD_LOGIC_VECTOR(18 downto 0) := (others => '0');
  constant Een : STD_LOGIC_VECTOR(18 downto 0) := b"000" & x"0001";
  constant Vijftig: STD_LOGIC_VECTOR(18 downto 0) := b"000" & x"0032";
  constant Hoogst :  STD_LOGIC_VECTOR(18 downto 0) := b"111" & x"A152"; -- x"7A152"=dec500.050 => EindCnt na 5 msec + 50 klokpulsen=lengte INT
begin
	process(Clock, StartCnt)
	begin
	if (rising_edge(Clock)) then
		if (StartCnt='1') then COUNT <= Hoogst; EindCnt <= '0';
		elsif (CE = '1') then COUNT <= COUNT-1;
		end if;
	end if;
	if (COUNT = Vijftig) then EindCnt <= '1';
	elsif (COUNT = Een) then EindCnt <= '0';
	end if;
	end process;
CE <= '0' when (COUNT = Nul) else '1';

end Gedrag;
