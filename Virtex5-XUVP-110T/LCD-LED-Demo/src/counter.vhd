----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:26:23 08/08/2008 
-- Design Name: 
-- Module Name:    cc123 - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity counter is
    Port ( clk : in  STD_LOGIC;
           rst_n : in  STD_LOGIC;
           q : out  STD_LOGIC_VECTOR (31 downto 0));
end counter;

architecture Behavioral of counter is
signal s1:std_logic_vector(31 downto 0);
begin
process(clk,rst_n)
begin
if rst_n='0' then 
	s1<= (OTHERS =>'0');
elsif  clk'event and clk='1' then
	s1<=s1+1;
end if;
end process;
q<=s1;

end Behavioral;

