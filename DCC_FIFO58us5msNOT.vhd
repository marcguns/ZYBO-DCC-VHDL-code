-- IP voor genereren van DCC signalen o.b.v. bits die uit FIFO gehaald worden; 1 bit per 58 microsec
-- wachttijd van 5 msec gevuld met DCC "1"-en ts. 2 DCC-packets (packet = ca. 7 msec) => 12 msec/packet = ca. 83 packets/sec
-- Inverse DCC-output toegevoegd voor geinverteerd unipolair signaal
-- v.1.0 d.d. 1/08/2016

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
library UNISIM;
use UNISIM.Vcomponents.ALL;

entity DCC_Gen is
   port (
		Clk		: in std_logic;
		aResetn	: in std_logic;
		PWM8620 : in std_logic;						-- 8,62KHz (duty cycle 50%) signaal van andere IP (= DCC "1")
		VALID	: in std_logic;						-- Valid data from FIFO
		FIFOdat	: in std_logic_vector(31 downto 0);	-- data van FIFO > bit 0 = DCC-bit, bit 30='1':1e woord, bit31='1':laatste woord
		READY	: out std_logic;					-- signaal aan FIFO: IP is klaar om een woord te ontvangen
		DCC		: out std_logic;					-- uitgang naar het power board
		DCCn	: out std_logic;					-- NOT_DCC uitgang naar het power board
		Interrpt: out std_logic);                   -- interrupt voor PS: Reset Transmit FIFO Data
end DCC_Gen;

architecture Behavior of DCC_Gen is
	-- signals:
	signal ConstD1	: std_logic_vector(12 downto 0) := b"1" & x"6A7"; -- x16A7 = dec5799 => CEO puls om de 58usec;
	signal BIT0		: std_logic := '0';
	signal aReset	: std_logic;
	signal Laad		: std_logic;
	signal SelMux	: std_logic;
	signal BIT30a	: std_logic;
	signal BIT31a	: std_logic;
	signal Start	: std_logic;
	signal StartF	: std_logic;	-- flag van Start
	signal StartFF	: std_logic;	-- flipflop van Start
	signal DCC1		: std_logic;

	-- declaration of components

	component FIFO_STREAM is -- regelaar van uitlezing FIFO via AXI-stream handshake
	PORT (CLK,BIT30,BIT31,RESET,us58,VALID: IN std_logic;
		  S_MUX,READY : OUT std_logic);
	end component;

	component Cnt13Ld is -- 13 bit counter met CEO om de D/100 usec als C=100MHz
	port (
        CEO : out std_logic;
        C   : in std_logic; -- 100MHz !
        D   : in std_logic_vector(12 downto 0);
        L   : in std_logic);
	end component;

	component Cnt5ms is -- Counter tot 5 millisec als Clock=100MHz
	port (
		Clock		: in STD_LOGIC;
		StartCnt	: in STD_LOGIC;
		EindCnt		: out STD_LOGIC);
	end component;

	begin
	aReset <= not aResetn;	-- aResetn is active low!
	BIT0 <= FIFOdat(0);
	BIT30a <= FIFOdat(30);
	BIT31a <= FIFOdat(31);
	DCC <= DCC1;
	DCCn <= not DCC1;

	-- Instantiations:

	Streamer : FIFO_STREAM
	port map (
		CLK => Clk,
		BIT30 => BIT30a,
		BIT31 => BIT31a,
		RESET => aReset,
		us58 => Laad,
		VALID => VALID,
		S_MUX => SelMux,
		READY => READY);

    P58us : Cnt13Ld
    port map (
		CEO => Laad,
		C => Clk,
		D => ConstD1(12 downto 0),
		L => Laad);

    P5ms : Cnt5ms
    port map (
		Clock => Clk,
		StartCnt => Start,
		EindCnt => Interrpt);

	-- processes (logic):

	process(SelMux, Clk) is	-- na DCC signaal moet Cnt5ms gestart worden; signaal Start is 1 klokcyclus lang (10ns)
	begin
        if (SelMux = '0') then DCC1 <= PWM8620; else DCC1 <= BIT0; end if;
        if (falling_edge(SelMux)) then StartF <= '1'; end if;	-- StartFlag wordt '1' op falling edge van SelMux
		if (rising_edge(Clk)) then	-- bij elke klokcyclus!
			StartFF <= StartF;	-- StartFlipFlop krijgt de waarde van StartFlag één klokcyclus na StartFlag
			Start <= '0';	-- defautl value; counterstartsignaal af
			if (StartF = '1' AND StartFF = '0') then	-- detecteert StartFlag rising from '0'  to '1'
				Start <= '1';	-- ; counterstartsignaal aan (gedurende 1 klokpuls)
			end if;
		end if;
		if (Start = '1') then StartF <= '0'; end if;	-- flag voor start op nul (blijft zo tot volgende falling edge van SelMux)
	end process;

end Behavior;
