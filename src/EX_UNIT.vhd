----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/05/2020 06:54:13 PM
-- Design Name: 
-- Module Name: EX_UNIT - Behavioral
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

entity EX_UNIT is
    Port ( PcNext : in STD_LOGIC_VECTOR (15 downto 0);
           RD1 : in STD_LOGIC_VECTOR (15 downto 0);
           RD2 : in STD_LOGIC_VECTOR (15 downto 0);
           ExtImm : in STD_LOGIC_VECTOR (15 downto 0);
           AluSrc : in STD_LOGIC;
           sa : in STD_LOGIC;
           func : in STD_LOGIC_VECTOR (2 downto 0);
           AluOp : in STD_LOGIC_VECTOR (1 downto 0);
           Zero : out STD_LOGIC;
           GreaterThanZero: out STD_LOGIC;
           AluRes : out STD_LOGIC_VECTOR (15 downto 0);
           BrAddress : out STD_LOGIC_VECTOR (15 downto 0));
end EX_UNIT;

architecture Behavioral of EX_UNIT is
signal in_alu2: std_logic_vector(15 downto 0):=x"0000";     -- intrarea a 2-a pentru ALU
signal aluCtr: std_logic_vector(2 downto 0):="000";         -- semnalul ce stabileste ce operatie efectueaza ALU
signal alu_out: std_logic_vector(15 downto 0):=x"0000";     -- iesirea lui ALU
signal zeroFlag: std_logic:='0';                            -- flag-ul pentru 0 (iesirea lui ALU e 0)
signal GreaterThanZeroFlag: std_logic:='0';                 -- flag-ul pentru mai mare ca 0
begin

-- branch address
BrAddress <= PcNext + ExtImm;

-- ALU Control
process(AluOp, func)
begin
    case AluOp is
        when "10" => 
                case func is
                    when "000" => aluCtr <= "000"; -- add
                    when "001" => aluCtr <= "001"; -- sub
                    when "010" => aluCtr <= "010"; -- sll
                    when "011" => aluCtr <= "011"; -- srl
                    when "100" => aluCtr <= "100"; -- and
                    when "101" => aluCtr <= "101"; -- or
                    when "110" => aluCtr <= "110"; -- xor;
                    when "111" => aluCtr <= "111"; -- sra
                    when others => aluCtr <= "000"; -- others;
               end case;
       when "00" => aluCtr <= "000"; -- addi, lw, sw
       when "01" => aluCtr <= "001"; -- beq, bgez
       when "11" => aluCtr <= "101"; -- ori
       when others => aluCtr <= "000";
       end case;
end process;

-- mux pentru intrarea 2 a lui ALU
process(AluSrc, RD2, ExtImm, alu_out)
begin
    case AluSrc is
        when '0' => in_alu2 <= RD2;
        when '1' => in_alu2 <= ExtImm;
        when others => in_alu2 <= x"0000";
    end case;
end process;

-- ALU
process(RD1, in_alu2, sa, aluCtr, alu_out)
begin
    case aluCtr is
        when "000" => alu_out <= RD1 + in_alu2;                 -- add, addi, lw, sw
        when "001" => alu_out <= RD1 - in_alu2;                 -- sub, beq, bgez
        when "010" =>
            case sa is                                          -- sll
                when '1' => alu_out <= RD1(14 downto 0) & '0';
                when others => alu_out <= RD1(15 downto 0);
             end case;                                     
        when "011" =>
            case sa is                                          -- srl
                when '1' => alu_out <= '0' & RD1(15 downto 1);
                when others => alu_out <= RD1;
            end case;
        when "100" => alu_out <= RD1 and in_alu2;               -- and
        when "101" => alu_out <= RD1 or in_alu2;                -- or, ori
        when "110" => alu_out <= RD1 xor in_alu2;               -- xor;
        when "111" =>
            case sa is                                          --sra
                when '1' => alu_out <= RD1(15) & RD1(15 downto 1);
                when others => alu_out <= RD1;
            end case;
        when others => alu_out <= x"0000";                      -- others
        end case; 
        
        -- zero flag 
        case alu_out is
            when x"0000" => zeroFlag <= '1';
            when others => zeroFlag <= '0';
        end case;
        -- GreaterThanZero Flag
		GreaterThanZeroFlag <= not(alu_out(15));
end process;

AluRes <= alu_out;
Zero <= zeroFlag;
GreaterThanZero <= GreaterThanZeroFlag;

end Behavioral;
