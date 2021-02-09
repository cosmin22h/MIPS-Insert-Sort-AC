----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/23/2020 02:34:43 PM
-- Design Name: 
-- Module Name: IF_UNIT - Behavioral
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

-- Instruction Fetch
entity IF_UNIT is
    Port ( clk: in std_logic;
           sigEnb: in std_logic;
           sigReset: in std_logic;
           adrBrc: in std_logic_vector(15 downto 0);
           adrJmp: in std_logic_vector(15 downto 0);
           pcSrc: in std_logic;
           jmp: in std_logic;
           inst : out STD_LOGIC_VECTOR (15 downto 0);
           nextAdrPC : out STD_LOGIC_VECTOR (15 downto 0));
end IF_UNIT;

architecture Behavioral of IF_UNIT is
-- pentru PC
signal next_inst_adr: std_logic_vector(15 downto 0):=x"0000";   -- adresa urmatoarei instructiuni (intrare PC)
signal inst_adr: std_logic_vector(15 downto 0):=x"0000";        -- adresa instructiunii (iesire PC)
-- pentru adresa urmatoare
signal alu_next_adr: std_logic_vector(15 downto 0):=x"0000";    -- adresa urmatoarei instructiuni (CONSECUTIVA)
-- pentru branch si jump
signal after_brc: std_logic_vector(15 downto 0):=x"0000";       -- adresa urmatoarei instructiuni (MUX: CONSECUTIVA SAU BRANCH)
signal after_jmp: std_logic_vector(15 downto 0):=x"0000";       -- adresa urmatoarei instructiuni (MUX: (CONSEVUTIVA SAU BRANCH) SAU JUMP)
-- memoria rom 
type mem_type is array (0 to 255) of std_logic_vector(15 downto 0);
-- program test (adunarea a doua siruri-element cu element) 
signal ROM_test: mem_type :=(
0=>B"000_000_000_001_0_000", -- add $1,$0,$0  
1=>B"001_000_010_0000111",   -- addi $2,$0,7 
2=>B"000_000_000_011_0_000", -- add $3,$0,$0  
3=>B"000_000_000_100_0_000", -- add $4,$0,$0  
4=>B"000_000_000_101_0_000", -- add $5,$0,$0 
5=>B"100_010_001_0001001",   -- bq $1,$2,9    
6=>B"010_011_110_0000000",   -- lw $6, 0($3)
7=>B"010_100_111_0001000",   -- lw $7, 8($4) 
8=>B"000_110_111_110_0_000", -- add $6,$6,$7  
9=>B"011_101_110_1000000",   -- sw $6,64($5)  
10=>B"001_011_011_0000001",  -- addi $3,$3,1  
11=>B"001_100_100_0000001",  -- addi $4,$4,1  
12=>B"001_101_101_0000001",  -- addi $5,$5,1
13=>B"001_001_001_0000001",	 -- addi $1,$1,1
14=>B"111_0000000000101",    -- j 5           
others=>"0000000000000000"
);		  			   
-- PROIECT: ALGORIMT DE SORTARE A UNUI SIR CU N ELEMENTE (INSERT SORT) 
-- Obs: numarul de elemente este stocat la adresa 0 din memoria RAM, iar elementele sirului incep de la adresa 1 
signal ROM: mem_type := (
0=>B"001_000_001_0000001",  -- 0x2081: addi $1,$0,1 	(i<-1)
1=>B"010_000_010_0000000",  -- 0x4100: lw $2,0($0) 		(numarul de elemente: n)
2=>B"001_000_011_1111111",  -- 0x21FF: addi $3,$0,-1 	(valoarea -1)
3=>B"100_010_001_0001110",  -- 0x888E: beq $1,$2,14		(daca i=n => programul se termina)
4=>B"010_001_100_0000001",  -- 0x4601: lw $4,1($1)   	(x<-A[i])
5=>B"001_001_101_1111111",  -- 0x26FF: addi $5,$1,-1 	(j<-i-1)
6=>B"100_011_101_0000111",  -- 0x8E87: beq $5,$3,7   	(daca j=-1 => bucla while se termina)
7=>B"010_101_110_0000001",  -- 0x5701: lw $6,1($5)		(valoarea A[j])
8=>B"000_100_110_111_0_001",-- 0x1371: sub $7,$4,$6 	(valoarea x-A[j])
9=>B"110_111_000_0000100",	-- 0xDC04: begz $7,4		(daca x-A[j]>=0, exchivalentul a x>=A[j] => => bucla while se termina) 
10=>B"001_101_111_0000001",	-- 0x3781: addi $7,$5,1 	(j+1)
11=>B"011_111_110_0000001",	-- 0x7F01: sw $6,1($7)		(A[j++]<-A[j])
12=>B"001_101_101_1111111",	-- 0x36FF: addi $5,$5,-1 	(j<-j-1)
13=>B"111_0000000000110",	-- 0xE006: j 6				(bucla while)
14=>B"001_101_101_0000001",	-- 0x3681: addi $5,$5,1		(j+1)
15=>B"011_101_100_0000001",	-- 0x7601: sw $4,1($5)		(A[j+1]<-x)
16=>B"001_001_001_0000001", -- 0x2481: addi $1,$1,1		(i<-i+1)
17=>B"111_0000000000011", 	-- 0xE003: j 3				(bucla for)
others=>x"0000"
);
begin

-- PC
process(clk, sigReset, sigEnb)
begin
    if (sigReset = '1') then
        inst_adr <= x"0000";
    elsif (rising_edge(clk)) then
        if (sigEnb = '1') then
            inst_adr <= next_inst_adr;
         end if;
    end if;
end process;

-- Instruction Memory (ROM)
process(inst_adr)
begin
    inst <= ROM(conv_integer(inst_adr));
end process;

-- ALU pentru adresa urmatoare; PC <= PC + 1
alu_next_adr <= inst_adr + 1;

-- iesire PC + 1
nextAdrPC <= alu_next_adr;

-- branch
process(pcSrc, adrBrc, alu_next_adr)
begin
	case pcSrc is
		when '0' => after_brc <= alu_next_adr;
		when '1' => after_brc <= adrBrc;
    	when others=> after_brc <= x"0000";     
    end case;
end process;

-- jump
process(jmp, adrJmp, after_brc)
begin 
	case jmp is
		when '0' => after_jmp <= after_brc;
		when '1' => after_jmp <= adrJmp;
    	when others=> after_jmp <= x"0000";     
    end case;
end process;

next_inst_adr <= after_jmp;

end Behavioral;
