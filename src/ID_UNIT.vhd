----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/29/2020 08:15:29 PM
-- Design Name: 
-- Module Name: ID_UNIT - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-- Instruction Decode
entity ID_UNIT is
    Port ( clk : in STD_LOGIC;
           regWrite : in STD_LOGIC;
           sigEnb: in STD_LOGIC;
           instr : in STD_LOGIC_VECTOR (15 downto 0);
           regDst : in STD_LOGIC;
           ExtOp : in STD_LOGIC;
           WD : in STD_LOGIC_VECTOR(15 downto 0);
           RD1 : out STD_LOGIC_VECTOR(15 downto 0);
           RD2 : out STD_LOGIC_VECTOR(15 downto 0);
           ExtImm : out STD_LOGIC_VECTOR (15 downto 0);
           func : out STD_LOGIC_VECTOR (2 downto 0);
           sa : out STD_LOGIC);
end ID_UNIT;

architecture Behavioral of ID_UNIT is
signal writeAdress: std_logic_vector (2 downto 0):= "000";          -- adresa registrului in care se scrie
type reg_type is array (0 to 15) of std_logic_vector(15 downto 0);
-- continutul registrelor
signal reg_file: reg_type :=(
others=>x"0000");
-- pentru extinderea cu semn
signal extensie: std_logic_vector(8 downto 0):="000000000";   -- extensia imm-ului
begin

-- blocul de registrii RF (!scriere sincrona)
process(clk)
begin
    if (rising_edge(clk)) then
        if (regWrite = '1') and (sigEnb = '1') then
            reg_file(conv_integer(writeAdress)) <= WD;
        end if;
    end if;
end process;
RD1 <= reg_file(conv_integer(instr(12 downto 10))); -- rs
RD2 <= reg_file(conv_integer(instr(9 downto 7)));   -- rt

-- mux-ul pentru writeAdress
process(regDst, instr(9 downto 7), instr(6 downto 4))
begin
    case regDst is
        when '0' => writeAdress <= instr(9 downto 7); -- rt
        when '1' => writeAdress <= instr(6 downto 4); -- rd
        when others => writeAdress <= "000";
    end case;
end process;

-- extindere cu zero/semn
extensie <= "000000000" when instr(6)='0' else "111111111";
ExtImm <= "000000000" & instr(6 downto 0) when ExtOp='0' else extensie & instr(6 downto 0);

-- campul func si shift amount (pentru instructiunile de tip R)
func <= instr(2 downto 0);
sa <= instr(3);

end Behavioral;
