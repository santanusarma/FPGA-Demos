----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:42:25 11/26/2009 
-- Design Name: 
-- Module Name:    counter - Behavioral 
-- Project Name: 
-- Target Devices: lx110t
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
    Port ( CLOCK : in  STD_LOGIC;
           DIRECTION : in  STD_LOGIC;
           COUNT_OUT : out  STD_LOGIC_VECTOR (31 downto 0));
end counter;

architecture Behavioral of counter is
signal count_int : std_logic_vector(0 to 31) := (others =>'0');
begin
process (CLOCK) 
begin
   if CLOCK='1' and CLOCK'event then
      if DIRECTION='1' then   
         count_int <= count_int + 1;
      else
         count_int <= count_int - 1;
      end if;
   end if;
end process;
COUNT_OUT <= count_int;
end Behavioral;

