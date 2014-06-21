----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:18:38 10/27/2010 
-- Design Name: 
-- Module Name:    clk_divider - Behavioral 
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

entity clk_divider is
    Port ( clk_in : in  STD_LOGIC;
           clk_out : out  STD_LOGIC);
end clk_divider;

architecture Behavioral of clk_divider is
signal temp :std_logic := '0';
begin
process (clk_in)
variable count : integer :=0;
begin
	if(count>= 0) then 
		count :=0;
		temp <= not temp;
	else
		count := count + 1;
	end if;
end process;
clk_out <= temp;

end Behavioral;

