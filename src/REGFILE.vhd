----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/09/2020 03:05:10 PM
-- Design Name: 
-- Module Name: REGFILE - Behavioral
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

entity REGFILE is
    Port ( clk : in STD_LOGIC;
           regWr : in STD_LOGIC;
           ra1 : in STD_LOGIC_VECTOR (3 downto 0);
           ra2 : in STD_LOGIC_VECTOR (3 downto 0);
           wa : in STD_LOGIC_VECTOR (3 downto 0);
           wd : in STD_LOGIC_VECTOR (15 downto 0);
           rd1 : out STD_LOGIC_VECTOR (15 downto 0);
           rd2 : out STD_LOGIC_VECTOR (15 downto 0));
end REGFILE;

architecture Behavioral of REGFILE is
type reg_type is array (0 to 15) of std_logic_vector(15 downto 0);
signal reg_file: reg_type :=(
"0000000111110000",
"0000000100110011",
"0000011100110100",
"0000000111111111",
"0000000100010000",
"0000001111110000",
others=>"0000000000000000");
begin
process(clk)
begin
    if (rising_edge(clk)) then
        if (regWr = '1') then
            reg_file(conv_integer(wa)) <= wd;
        end if;
    end if;
end process;
rd1 <= reg_file(conv_integer(ra1));
rd2 <= reg_file(conv_integer(ra2));
end Behavioral;
