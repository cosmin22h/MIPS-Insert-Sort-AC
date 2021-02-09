----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/24/2020 03:23:43 PM
-- Design Name: 
-- Module Name: MPG - Behavioral
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

entity MPG is
    Port ( btn : in STD_LOGIC;
           clk : in STD_LOGIC;
           enb : out STD_LOGIC);
end MPG;

architecture Behavioral of MPG is
signal count_int:std_logic_vector(31 downto 0):=x"00000000";
signal q1:std_logic;
signal q2:std_logic;
signal q3:std_logic;
begin

enb <= q2 and (not q3);

process(clk)
begin
    if(rising_edge(clk)) then
          count_int <= count_int + 1;
    end if;
end process;

process(clk)
begin
    if(rising_edge(clk))then
        if(count_int(15 downto 0) = "0000000000000000") then
            q1 <= btn;
        end if;
    end if;
end process;

process(clk)
begin
    if(rising_edge(clk))then
        q2 <= q1;
        q3 <= q2;
    end if;
end process;

end Behavioral;
