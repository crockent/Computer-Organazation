----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    02:28:48 04/12/2024 
-- Design Name: 
-- Module Name:    Datapath - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Datapath is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           pcSel : in  STD_LOGIC;
           pcLdEn : in  STD_LOGIC;
           RFWe : in std_logic;
           RFWrData : in std_logic;
			  RF_B_sel : in std_logic;
           WeMem : in std_logic;
			  ALU_Bin_sel : in std_logic;
			  ALU_Func : in std_logic_vector(3 downto 0);
           Zero : out std_logic;
           Ovf : out std_logic;
           Cout : out std_logic;
			  ImmedControl: in STD_LOGIC_VECTOR(1 downto 0);
			  instr : out  STD_LOGIC_VECTOR (31 downto 0);
			  selMem : in std_logic);
end Datapath;

architecture Behavioral of Datapath is
COMPONENT IFSTAGE
    PORT(
         PC_Immed : IN  std_logic_vector(31 downto 0);
         PC_sel : IN  std_logic;
         PC_LdEn : IN  std_logic;
         rst : IN  std_logic;
         clk : IN  std_logic;
         Instr : OUT  std_logic_vector(31 downto 0));
    END COMPONENT;
COMPONENT DECSTAGE
    Port ( instr : in  STD_LOGIC_VECTOR (31 downto 0);
			  rst : in std_logic;
           RF_we : in  STD_LOGIC;
           ALUOut : in  STD_LOGIC_VECTOR (31 downto 0);
           MEMOut : in  STD_LOGIC_VECTOR (31 downto 0);
           RF_wData_sel : in  STD_LOGIC;
           RF_B_sel : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           immed : out  STD_LOGIC_VECTOR (31 downto 0);
			  ImmedControl: in STD_LOGIC_VECTOR(1 downto 0);
           RF_A : out  STD_LOGIC_VECTOR (31 downto 0);
           RF_B : out  STD_LOGIC_VECTOR (31 downto 0);
			  selMem : in std_logic);
    END COMPONENT;
COMPONENT ALU_ex
    PORT(
         RF_A : IN  std_logic_vector(31 downto 0);
         RF_B : IN  std_logic_vector(31 downto 0);
         Immed : IN  std_logic_vector(31 downto 0);
         ALU_Bin_sel : IN  std_logic;
         ALU_Func : IN  std_logic_vector(3 downto 0);
         ALU_out : OUT  std_logic_vector(31 downto 0);
			Zero : out  STD_LOGIC;
         Cout : out  STD_LOGIC;
         Ovf : out  STD_LOGIC);
    END COMPONENT;
component MEM 
    Port ( clk : in  STD_LOGIC;
           Mem_WrEn : in  STD_LOGIC;
           ALU_MEM_addr : in  STD_LOGIC_VECTOR (31 downto 0);
           MEM_DataIn : in  STD_LOGIC_VECTOR (31 downto 0);
           MEM_DataOut : out  STD_LOGIC_VECTOR (31 downto 0));
	END COMPONENT;
signal instrS,AluOutS,MemOutS,immedS,RFA,RFB : STD_LOGIC_VECTOR(31 downto 0);
begin
InsFetch: IFSTAGE port map(PC_Immed => immedS, PC_sel => pcSel, PC_LdEn => pcLdEn, rst => RST, clk => clk, Instr => instrS);
Decoder: DECSTAGE port map(
	instr => instrS, rst => rst, clk => clk, RF_we => RFWe, ALUOut => AluOutS, MEMOut => MemOutS, RF_B_sel => RF_B_sel,
	RF_wData_sel => RFWrData, immed => immedS, RF_A => RFA, RF_B => RFB, ImmedControl => ImmedControl, selMem=> selMem);
AlU: ALU_ex port map(RF_A => RFA, RF_B => RFB, immed => immedS, ALU_Bin_sel => ALU_Bin_sel,
	ALU_Func => ALU_Func , ALU_out => AluOutS, Zero=> Zero, Ovf => Ovf, Cout => Cout);
MEMO : MEM port map(clk => clk, Mem_WrEn => WeMem , ALU_MEM_addr => AluOutS, MEM_DataOut => MemOutS, MEM_DataIn =>RFB);

instr<= instrS;
end Behavioral;
