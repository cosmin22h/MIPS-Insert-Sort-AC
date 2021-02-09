----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/05/2020 07:48:58 PM
-- Design Name: 
-- Module Name: MEM - Behavioral
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

-- Memory
entity MEM is
    Port ( clk : in STD_LOGIC;
           sigEnb : in STD_LOGIC;
           memWrite : in STD_LOGIC;
           AluRes : in STD_LOGIC_VECTOR (15 downto 0);
           writeData : in STD_LOGIC_VECTOR (15 downto 0);
           MemData : out STD_LOGIC_VECTOR (15 downto 0);
           AluRes2 : out STD_LOGIC_VECTOR (15 downto 0));
end MEM;

architecture Behavioral of MEM is
-- memoria RAM
type mem_ram is array(0 to 127) of std_logic_vector(15 downto 0);
-- MEMORIE PROIECT
-- SIR: A[]={30, 48, 7, 77, 14, 23, 52, 21, 1, 3}; n =10
signal RAM: mem_ram:=(
0=>x"000A", -- 10 (numarul de elemente din sir)
1=>x"001E", -- 30 (A[0]) 
2=>x"0030", -- 48 (A[1])
3=>x"0007", -- 7  (A[2])
4=>x"004D", -- 77 (A[3])
5=>x"000E", -- 14 (A[4])
6=>x"0017", -- 23 (A[5])
7=>x"0034", -- 52 (A[6])
8=>x"0015", -- 21 (A[7]) 
9=>x"0001", -- 1  (A[8])  
10=>x"0003",-- 3  (A[9]) 
others => x"0000" );
    
begin

-- RAM
process(clk)
begin
    if (rising_edge(clk)) then
        if (memWrite = '1') and (sigEnb = '1') then
            RAM(conv_integer(AluRes(6 downto 0))) <= writeData;
        end if;
    end if;
    MemData <= RAM(conv_integer(AluRes(6 downto 0)));
end process;

AluRes2 <= AluRes;

end Behavioral;
