--  C:\_FSM\STREAM_FIFO3\FIFO_STREAM3.vhd
--  VHDL code created by Xilinx's StateCAD 9.1i
--  Fri Jul 29 17:33:49 2016

--  This VHDL code (for use with Xilinx XST) was generated using: 
--  enumerated state assignment with structured code format.
--  Minimization is enabled,  implied else is enabled, 
--  and outputs are speed optimized.

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY FIFO_STREAM IS
	PORT (CLK,BIT30,BIT31,RESET,us58,VALID: IN std_logic;
		  READY,S_MUX : OUT std_logic);
END;

ARCHITECTURE BEHAVIOR OF FIFO_STREAM IS
	TYPE type_sreg IS (ST1,ST2,ST3,ST4,ST5,ST6);
	SIGNAL sreg, next_sreg : type_sreg;
	SIGNAL next_READY,next_S_MUX : std_logic;
BEGIN
	PROCESS (CLK)
	BEGIN
		IF CLK='1' AND CLK'event THEN
			IF ( RESET='1' ) THEN
				sreg <= ST1;
			ELSE
				sreg <= next_sreg;
			END IF;
		END IF;
	END PROCESS;

	PROCESS (CLK)
	BEGIN
		IF CLK='1' AND CLK'event THEN
			IF ( RESET='1' ) THEN
				READY <= '0';
			ELSE
				READY <= next_READY;
			END IF;
		END IF;
	END PROCESS;

	PROCESS (CLK)
	BEGIN
		IF CLK='1' AND CLK'event THEN
			IF ( RESET='1' ) THEN
				S_MUX <= '0';
			ELSE
				S_MUX <= next_S_MUX;
			END IF;
		END IF;
	END PROCESS;

	PROCESS (sreg,BIT30,BIT31,RESET,us58,VALID)
	BEGIN
		next_READY <= '0'; next_S_MUX <= '0'; 

		next_sreg<=ST1;

		IF ( RESET='1' ) THEN
			next_sreg<=ST1;
			next_S_MUX<='0';
			next_READY<='0';
		ELSE
			CASE sreg IS
				WHEN ST1 =>
					IF ( BIT30='1' AND VALID='1' AND us58='1' ) THEN
						next_sreg<=ST2;
						next_READY<='0';
						next_S_MUX<='1';
					 ELSE
						next_sreg<=ST1;
						next_READY<='0';
						next_S_MUX<='0';
					END IF;
				WHEN ST2 =>
					IF ( us58='1' ) THEN
						next_sreg<=ST3;
						next_READY<='1';
						next_S_MUX<='1';
					 ELSE
						next_sreg<=ST2;
						next_READY<='0';
						next_S_MUX<='1';
					END IF;
				WHEN ST3 =>
					IF ( VALID='0' ) THEN
						next_sreg<=ST1;
						next_READY<='0';
						next_S_MUX<='0';
					END IF;
					IF ( VALID='1' ) THEN
						next_sreg<=ST4;
						next_READY<='0';
						next_S_MUX<='1';
					END IF;
				WHEN ST4 =>
					IF ( BIT31='1' ) THEN
						next_sreg<=ST5;
						next_READY<='0';
						next_S_MUX<='1';
					END IF;
					IF ( BIT31='0' ) THEN
						next_sreg<=ST2;
						next_READY<='0';
						next_S_MUX<='1';
					END IF;
				WHEN ST5 =>
					IF ( us58='1' ) THEN
						next_sreg<=ST6;
						next_READY<='1';
						next_S_MUX<='0';
					 ELSE
						next_sreg<=ST5;
						next_READY<='0';
						next_S_MUX<='1';
					END IF;
				WHEN ST6 =>
					IF ( VALID='0' ) THEN
						next_sreg<=ST1;
						next_READY<='0';
						next_S_MUX<='0';
					 ELSE
						next_sreg<=ST6;
						next_READY<='1';
						next_S_MUX<='0';
					END IF;
				WHEN OTHERS =>
			END CASE;
		END IF;
	END PROCESS;
END BEHAVIOR;
