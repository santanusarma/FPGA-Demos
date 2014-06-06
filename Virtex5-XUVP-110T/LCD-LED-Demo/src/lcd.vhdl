
library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_Logic_unsigned.all;
use IEEE.numeric_std.all;

entity lcd2x16 is
	port(
	CLK_27MHZ_FPGA       : in    std_logic;
	CLK_33MHZ_FPGA       : in    std_logic;
	USER_CLK      			: in    std_logic; --100MHz
	
	rst_n                : in    std_logic;

	-- lcd interface
	LCD_FPGA_DB          : inout std_logic_vector(3 downto 0);
	LCD_FPGA_E           : out   std_logic;
	LCD_FPGA_RS          : out   std_logic;
	LCD_FPGA_RW          : out   std_logic;
	-- button
	GPIO_SW_C            : in    std_logic;
	-- led
	GPIO_LED             : out   std_logic_vector(7 downto 0);
	--counter out
	COUNT						: out   std_logic_vector(31 downto 0)
	);
end;

architecture lcd2x16 of lcd2x16 is
	component wb_lcd_driver
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
	wb_stb_i  : in    std_logic;
	wb_sel_i  : in    std_logic;
	wb_ack_o  : out   std_logic;

	-- lcd interface
	data_io   : inout std_logic_vector(3 downto 0);
	rs_o      : out   std_logic;
	rw_o      : out   std_logic;
	e_o       : out   std_logic
	);
	end component;
	
	component clk_divider 
    Port ( clk_in : in  STD_LOGIC;
           clk_out : out  STD_LOGIC);
	end component;


	component clk_div 
	PORT
	(
		clock_50Mhz				: IN	STD_LOGIC;
		clock_1MHz				: OUT	STD_LOGIC;
		clock_100KHz			: OUT	STD_LOGIC;
		clock_10KHz				: OUT	STD_LOGIC;
		clock_1KHz				: OUT	STD_LOGIC;
		clock_100Hz				: OUT	STD_LOGIC;
		clock_10Hz				: OUT	STD_LOGIC;
		clock_1Hz				: OUT	STD_LOGIC);	
	END component;


	component counter 
    Port ( clk : in  STD_LOGIC;
           rst_n : in  STD_LOGIC;
           q : out  STD_LOGIC_VECTOR (31 downto 0));
	end component;
	
	
	-- wishbone interface
	signal wb_dat_i  : std_logic_vector(7 downto 0);
	signal wb_adr_i  : std_logic_vector(15 downto 0);
	signal wb_sel_i  : std_logic;
	signal wb_stb_i  : std_logic;
	signal wb_ack_o  : std_logic;

	type lcd_rec is record
		rs   : std_logic;
		data : std_logic_vector(7 downto 0);
	end record;

	type lcd_mem is ARRAY(0 to 32) of lcd_rec;
	signal data : lcd_mem;

	type   lcd_states is (IDLE, GO, WAIT_LOOP, STOP);
	signal lcd_sm     : lcd_states;
	signal ptr        : std_logic_vector(7 downto 0);
	signal GPIO_LED_i : std_logic_vector(7 downto 0);
	signal rst        : std_logic;
	signal clk        : std_logic;
	signal first      : std_logic;
	signal GPIO_SW_C_q: std_logic;
	
	signal clock_1MHz,clock_100KHz,clock_10KHz,clock_1KHz,clock_100Hz,clock_10Hz,clock_1Hz: STD_LOGIC;
	signal clk_divr : std_logic_vector(31 downto 0);

begin
	clk <= CLK_27MHZ_FPGA;
	
	--counter instance
	cntr: counter port map (CLK_27MHZ_FPGA, rst_n, clk_divr);
	COUNT<=clk_divr;
	
	--clock divider
	clk_dvider: clk_div port map( 
		clock_50Mhz	=> clk_divr(1),
		clock_1MHz=>clock_1MHz,
		clock_100KHz=>clock_100KHz,
		clock_10KHz=>clock_10KHz,
		clock_1KHz=>clock_1KHz,
		clock_100Hz=>clock_100Hz,
		clock_10Hz=>clock_10Hz,
		clock_1Hz=>clock_1Hz);

	--clk <= clk_divr(14);
	
	
	
	
	-- INIT LCD
	wb_adr_i <= x"0000";
	wb_dat_i <= data(to_integer(unsigned(ptr))).data;
	wb_sel_i <= data(to_integer(unsigned(ptr))).rs;
	--wb_stb_i <= '1' when lcd_sm = GO and wb_ack_o = '0' else '0';
	wb_stb_i <= '1' when lcd_sm = GO else '0';
	GPIO_LED <= GPIO_LED_i;

	sm: process (clk, rst_n, wb_ack_o)
	begin
	if rst_n = '0' then
		lcd_sm <= IDLE;
		first      <= '0';
		ptr        <= (others => '0');
		GPIO_LED_i <= (others => '0');
		data   <= (('0', x"03"), ('0', x"03"), ('0', x"03"), ('0', x"02"),
		           ('0', x"28"), ('0', x"0c"), ('0', x"04"), ('0', x"01"),
					  ('0', x"02"),  -- 9 init done
			   --      W             E             L            L
			   ('1', x"57"), ('1', x"45"), ('1', x"4C"), ('1', x"4C"),
			   --      C             O             M             E
			   ('1', x"43"), ('1', x"4F"), ('1', x"4D"), ('1', x"45"),
			   --     SPACE			T					O				SPACE
			   ('1', x"20"), ('1', x"54"), ('1', x"4F"), ('1', x"20"),
			   --    F             P         G             A
			   ('1', x"46"), ('1', x"50"), ('1', x"47"), ('1', x"41"), 
			   -- 2-line    		--			D					E             M			
			   ('0', x"C0"),('1', x"20"), ('1', x"44"), ('1', x"45"), ('1', x"4D"), 
				--  O            S				Space
				('1', x"4F"), ('1', x"53"), ('1', x"20")  
			   );

  	elsif (clk'event and clk = '0') then
		ptr <= ptr;
		if lcd_sm = IDLE and first = '0' then
			ptr <= (others => '0');
		elsif lcd_sm = IDLE and first = '1' then
			ptr <= x"07";
		elsif lcd_sm = WAIT_LOOP then
			ptr <= ptr + 1;
		end if;

		GPIO_SW_C_q <= GPIO_SW_C;
		
		
		case lcd_sm is
		when IDLE =>
			GPIO_LED_i(0) <= '0';
			lcd_sm <= GO;
		when GO =>
			if wb_ack_o = '1' then
				if ptr = x"1d" then
					lcd_sm <= STOP;
				else
					lcd_sm <= WAIT_LOOP;
				end if;
			end if;
		when WAIT_LOOP =>
				lcd_sm <= GO;
		when STOP =>
			GPIO_LED_i(0) <= '1';
			first <= '1';
			if GPIO_SW_C = '1' and GPIO_SW_C_q = '0' then
				lcd_sm <= IDLE;
			end if;
		end case;
	end if;
	end process;

	wb_lcd_driver_0: wb_lcd_driver
	generic map (
	--CLK_DIV => x"32",
	CLK_DIV => x"0a",
	ADDRESS => x"0000")
	port map (
	clk       => clk,
	rst_n     => rst_n,

	-- wishbone interface
	wb_adr_i  => wb_adr_i,
	wb_dat_i  => wb_dat_i,
	wb_stb_i  => wb_stb_i,
	wb_sel_i  => wb_sel_i,
	wb_ack_o  => wb_ack_o,

	-- lcd interface
	data_io   => LCD_FPGA_DB,
	rs_o      => LCD_FPGA_RS,
	rw_o      => LCD_FPGA_RW,
	e_o       => LCD_FPGA_E
	);

end lcd2x16;
