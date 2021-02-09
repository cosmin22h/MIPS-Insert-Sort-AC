----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/24/2020 02:45:09 PM
-- Design Name: 
-- Module Name: test_env - Behavioral
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

entity test_env is
    Port ( clk : in STD_LOGIC;
           btn: in STD_LOGIC_VECTOR(4 downto 0);
           sw: in STD_LOGIC_VECTOR (15 downto 0);
           led: out STD_LOGIC_VECTOR (15 downto 0);
           an: out STD_LOGIC_VECTOR (3 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end test_env;

architecture Behavioral of test_env is

-- COMPONENTE

-- MPG
component MPG is
    Port ( clk : in STD_LOGIC;
       btn : in STD_LOGIC;
       enb : out STD_LOGIC);
end component;

-- AFISOR
component SSD is
    Port ( clk : in STD_LOGIC;
           digit0 : in STD_LOGIC_VECTOR(3 downto 0); 
           digit1 : in STD_LOGIC_VECTOR(3 downto 0); 
           digit2 : in STD_LOGIC_VECTOR(3 downto 0); 
           digit3 : in STD_LOGIC_VECTOR(3 downto 0);
           cat : out STD_LOGIC_VECTOR(6 downto 0);
           an : out STD_LOGIC_VECTOR(3 downto 0));
end component;

-- Instruction Fetch
component IF_UNIT is
    Port ( clk: in std_logic;
           sigEnb: in std_logic;
           sigReset: in std_logic;
           adrBrc: in std_logic_vector(15 downto 0);
           adrJmp: in std_logic_vector(15 downto 0);
           pcSrc: in std_logic;
           jmp: in std_logic;
           inst : out STD_LOGIC_VECTOR (15 downto 0);
           nextAdrPC : out STD_LOGIC_VECTOR (15 downto 0));
end component;

-- Instruction Decode   
component ID_UNIT is
    Port ( clk : in STD_LOGIC;
           regWrite : in STD_LOGIC;
           sigenb: in STD_LOGIC;
           instr : in STD_LOGIC_VECTOR (15 downto 0);
           regDst : in STD_LOGIC;
           ExtOp : in STD_LOGIC;
           WD : in STD_LOGIC_VECTOR(15 downto 0);
           RD1 : out STD_LOGIC_VECTOR(15 downto 0);
           RD2 : out STD_LOGIC_VECTOR(15 downto 0);
           ExtImm : out STD_LOGIC_VECTOR (15 downto 0);
           func : out STD_LOGIC_VECTOR (2 downto 0);
           sa : out STD_LOGIC);
end component;

-- Execute 
component EX_UNIT is
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
end component;

-- Memory
component MEM is
    Port ( clk : in STD_LOGIC;
           sigEnb : in STD_LOGIC;
           memWrite : in STD_LOGIC;
           AluRes : in STD_LOGIC_VECTOR (15 downto 0);
           writeData : in STD_LOGIC_VECTOR (15 downto 0);
           MemData : out STD_LOGIC_VECTOR (15 downto 0);
           AluRes2 : out STD_LOGIC_VECTOR (15 downto 0));
end component;

-- SEMNALE

-- semnal buton MPG
signal sig_enb: std_logic;                          -- pentru controlul lui PC, REGFILE si MEM
signal sig_reset: std_logic;                        -- pentru resetarea lui PC
-- semnal pentru afisor
signal ssd_input: std_logic_vector(15 downto 0);
-- semnale pentru IF
signal inst: std_logic_vector(15 downto 0);         -- instructiunea din ROM
signal next_adrPC: std_logic_vector(15 downto 0);   -- PC + 1

-- main control
signal opcode: std_logic_vector(2 downto 0);        -- opcode-ul instructiunilor
signal regDst: std_logic;                           -- alegem adresa registrului in care scriem (pentru tip R: rd, pentru tip I: rt)
signal ExtOp: std_logic;                            -- semnal pentru extinderea cu semn/zero
signal AluSrc: std_logic;                           -- alegem intrarea a 2-a pentru ALU: RD2 sau ExtImm
signal BrEq: std_logic;                             -- semnal pentru branch (identic)
signal BrGeZ: std_logic;                            -- semnal pentru branch (mai mare sau egal cu 0)
signal jmp: std_logic;                              -- semanl pentru jump
signal MemW: std_logic;                             -- semnal pentru scrierea in memoria RAM
signal MemToReg: std_logic;                         -- alegem ce sa scriem in registru: ce se afla in memorie sau rezultatul lui ALU
signal regW: std_logic;                             -- semnal pentru scrierea in registru
signal AluOp: std_logic_vector(1 downto 0);         -- semnal pentru alegerea operatie care va fi executata de ALU
signal pcSrc: std_logic;                            -- alegem adresa PC + 1 sau adresa pentru branch  

-- semnale pentru ID
signal WD: std_logic_vector(15 downto 0);           -- ce scriem in registru
signal RD1: std_logic_vector(15 downto 0);          -- continutul primului regitru
signal RD2: std_logic_vector(15 downto 0);          -- continutul registrului 2
signal Ext_Imm: std_logic_vector(15 downto 0);      -- numarul extins
signal func: std_logic_vector(2 downto 0);          -- campul func pentru inst de tip R
signal sa: std_logic;                               -- shift amount

-- semnale Alu
signal zeroFlag: std_logic;                        -- zero flag
signal GreaterThanZeroFlag: std_logic;             -- GreaterThanZero flag 
signal AluRes: STD_LOGIC_VECTOR (15 downto 0);     -- adresa memoriei (rezultatul lui ALU)
signal BrAddress: STD_LOGIC_VECTOR (15 downto 0);  -- adresa pentru branch
signal JmpAddress: STD_LOGIC_VECTOR (15 downto 0); -- adresa pentru jump
signal MemData: STD_LOGIC_VECTOR (15 downto 0);    -- continutul memoriei
signal AluRes2: STD_LOGIC_VECTOR (15 downto 0);    -- rezultatul lui ALU

-- semnalele unui numarator pentru afisarea continutului din memoria RAM
signal count: std_logic_vector(15 downto 0):= x"0000";
signal enb_count: std_logic;
signal reset_count: std_logic;
signal addressMem: std_logic_vector(15 downto 0):=x"0000";

begin

-- IF
M1: MPG port map(clk, btn(0), sig_enb);
M2: MPG port map(clk, btn(1), sig_reset);
IFU: IF_UNIT port map (clk, sig_enb, sig_reset,BrAddress, JmpAddress, pcSrc, jmp, inst, next_adrPC);

-- ID
ID: ID_UNIT port map (clk, regW, sig_enb, inst, regDst, ExtOp, WD, RD1, RD2, Ext_Imm, func, sa);

-- UC
opcode <= inst(15 downto 13);
process(opcode)
begin
    regDst <= '0';
    regW  <= '0';
    ExtOp  <= '0';
    AluSrc  <= '0';
    AluOp <= "00";
    BrEq  <= '0';
    BrGeZ <= '0';
    MemW <= '0';
    MemToReg <= '0';
    jmp <= '0';
    case opcode is
        when "000" => regDst <= '1'; regW <= '1'; AluOp <= "10";                                   -- operatii tip R
        when "001" => ExtOp <= '1'; AluSrc <= '1'; regW <= '1'; AluOp <= "00";                     -- addi
        when "010" => ExtOp <= '1'; AluSrc <= '1'; MemToReg <= '1'; regW <= '1'; AluOp <= "00";    -- lw
        when "011" => ExtOp <= '1'; AluSrc <= '1'; MemW <= '1'; AluOp <= "00";                     -- sw
        when "100" => ExtOp <= '1'; BrEq <= '1'; AluOp <= "01";                                    -- beq
        when "101" => AluSrc <= '1'; regW <= '1'; AluOp <= "11";                                   -- ori
        when "110" => ExtOp <= '1'; BrGeZ <= '1'; AluOp <= "01";                                   -- bgez
        when "111" => jmp <= '1';                                                                  -- jmp
    end case;

end process;

-- EX
EX: EX_UNIT port map (next_adrPC, RD1, RD2, Ext_Imm, AluSrc, sa, func, AluOp, zeroFlag, GreaterThanZeroFlag, AluRes, BrAddress);

-- MEM
M: MEM port map (clk, sig_enb, MemW, addressMem, RD2, MemData, AluRes2);

-- MUX-ul catre RF (writeData)
process(MemToReg, MemData, AluRes2)
begin
    case MemToReg is
        when '0' => WD <= AluRes2;
        when '1' => WD <= MemData;
        when others =>WD <=x"0000";
    end case;
end process;

-- pentru branch
pcSrc <= (BrEq and zeroFlag) or (BrGeZ and (GreaterThanZeroFlag or zeroFlag));

-- jmp address
JmpAddress <= next_adrPC(15 downto 14) & '0' & inst(12 downto 0);

-- numarator pentru afisarea continutului memoriei RAM
M3: MPG port map(clk, btn(2), enb_count);
M4: MPG port map(clk, btn(3), reset_count);

process(clk,enb_count, reset_count)
begin
    if reset_count = '1' then count <=x"0000";
    elsif (rising_edge(clk) and enb_count = '1') 
       then count <= count + 1;
    end if; 
end process; 

process(sw(0), count, AluRes)
begin
    if sw(0) = '0' then addressMem <= AluRes; 
    else addressMem <= count;
    end if;
end process;

-- afisor
process(sw(7 downto 5) ,inst, next_adrPC)
begin
    case sw(7 downto 5) is
        when "000" => ssd_input <= inst;        -- instructiunea
        when "001" => ssd_input <= next_adrPC;  -- urmatoarea adresa
        when "010" => ssd_input <= RD1;         -- prima iesire din blocul de registrii
        when "011" => ssd_input <= RD2;         -- a 2-a iesire din blocul de registrii
        when "100" => ssd_input <= Ext_Imm;     -- numarul extins cu semn
        when "101" => ssd_input <= AluRes;      -- rezultatul lui alu 
        when "110" => ssd_input <= MemData;     -- ce se citeste din memorie
        when "111" => ssd_input <= WD;          -- ce se scrie in registru
        when others => ssd_input <= (others=>'0');
    end case;
end process; 

-- afisare 
S: SSD port map(clk, ssd_input(3 downto 0), ssd_input(7 downto 4), ssd_input(11 downto 8), ssd_input(15 downto 12), cat, an);

-- afisarea semnalelor din main control pe led-uri
led(15) <= regDst;
led(14) <= regW;
led(13) <= ExtOp;
led(12) <=  AluSrc;
led(1 downto 0) <=  AluOp;
led(11) <= BrEq;
led(10) <= BrGeZ;
led(9) <= MemW;
led(8) <=  MemToReg;
led(7) <= jmp;

end Behavioral;
