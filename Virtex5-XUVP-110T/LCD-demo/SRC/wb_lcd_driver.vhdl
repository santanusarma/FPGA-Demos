-- ---------------------------------------------------------------------------
-- (2008) Benjamin Krill <ben@codiert.org>
--
-- "THE BEER-WARE LICENSE" (Revision 42):
-- ben@codiert.org wrote this file. As long as you retain this notice you can
-- do whatever you want with this stuff. If we meet some day, and you think
-- this stuff is worth it, you can buy me a beer in return Benjamin Krill
-- ---------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_Logic_unsigned.all;
use IEEE.numeric_std.all;

entity wb_lcd_driver is
	generic (
	CLK_DIV : std_logic_vector(7 downto 0) := x"32";
	ADDRESS : std_logic_vector(15 downto 0)
	);
	port (
	clk       : in    std_logic;
	rst_n     : in    std_logic;

	-- wishbone interface
	wb_adr_i  : in    std_logic_vector(15 downto 0);
	wb_dat_i  : in    std_logic_vector(7 downto 0);
	wb_sel_i  : in    std_logic;
	wb_stb_i  : in    std_logic;
	wb_ack_o  : out   std_logic;

	-- lcd interface
	data_io   : inout std_logic_vector(3 downto 0);
	rs_o      : out   std_logic;
	rw_o      : out   std_logic;
	e_o       : out   std_logic
	);
end;

architecture wb_lcd_driver of wb_lcd_driver is
	type   lcd_states is (IDLE, LCD_WD, LCD_BUSY_WAIT, WB_ACK);
	signal lcd_sm : lcd_states;
	signal cnt    : std_logic;

	signal clock_cnt             : std_logic_vector(7 downto 0);
	signal sclockr, sclockf      : std_logic;
	signal mclock, mclock_d      : std_logic;
	signal clk_slow              : std_logic;
begin

	-- internal clocking 270khz
	process(clk)
	begin
		if rising_edge(clk) then
			if clock_cnt = X"00" then
				clock_cnt <= CLK_DIV;
				mclock <= not mclock;
			else
				clock_cnt <= clock_cnt - 1;
				mclock <= mclock;
			end if;
			mclock_d <= mclock;
			sclockr <= mclock and not mclock_d;
			sclockf <= mclock_d and not mclock;

			clk_slow <= clk_slow;
			if sclockr = '1' then
				clk_slow <= '1';
			elsif sclockf = '1' then
				clk_slow <= '0';
			end if;
		end if;
	end process;

	data_io  <= wb_dat_i(7 downto 4) when lcd_sm = LCD_WD and cnt = '0' else
	            wb_dat_i(3 downto 0) when lcd_sm = LCD_WD and cnt = '1' else
	            (others => 'Z');
	rs_o     <= wb_sel_i when lcd_sm = LCD_WD else '0';
	rw_o     <= '0' when lcd_sm = LCD_WD else
	            '1' when lcd_sm = LCD_BUSY_WAIT else '0';
	e_o      <= clk_slow when lcd_sm = LCD_WD or lcd_sm = LCD_BUSY_WAIT else '0';
	wb_ack_o <= '1' when wb_stb_i = '1' and lcd_sm = WB_ACK else '0';

	sm: process (clk, rst_n)
	begin
	if rst_n = '0' then
		lcd_sm <= IDLE;
	elsif rising_edge(clk) then
		cnt <= cnt;
		if lcd_sm = IDLE then
			cnt <= '0';
		elsif (lcd_sm = LCD_WD or lcd_sm = LCD_BUSY_WAIT) and sclockr = '1' then
			cnt <= not cnt;
		end if;

		case lcd_sm is
		when IDLE =>
			if sclockr = '1' and wb_stb_i = '1' and wb_adr_i = ADDRESS then
				lcd_sm <= LCD_WD;
			end if;
		when LCD_WD =>
			if cnt = '1' and sclockr = '1' then
				lcd_sm <= LCD_BUSY_WAIT;
			end if;
		when LCD_BUSY_WAIT =>
			if sclockf='1' and cnt = '0' and data_io(3) = '0' then
				lcd_sm <= WB_ACK;
			elsif wb_stb_i = '0' then
				lcd_sm <= IDLE;
			end if;
		when WB_ACK =>
			if wb_stb_i = '0' then
				lcd_sm <= IDLE;
			end if;
		end case;
	end if;
	end process;

end wb_lcd_driver;
