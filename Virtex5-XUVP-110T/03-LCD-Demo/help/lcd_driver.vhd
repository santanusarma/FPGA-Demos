------------------------------------------------------------------------------------------------------------
-- File name   : lcd_driver.vhd
--
-- Project     : EE367 - Logic Design (Spring 2007)
--               LCD Driver
--
-- Description : VHDL model LCD Controller Using State Machines
--
-- Author(s)   : Clint Gauer
--               Montana State University
--
-- Date        : February 10, 2008
--
-- Note(s)     : This file contains the Entity and Architecture
--               
--
------------------------------------------------------------------------------------------------------------
library IEEE;                    -- this library adds additional capability for VHDL
use IEEE.std_logic_1164.all;     -- this package has "STD_LOGIC" data types
use IEEE.STD_LOGIC_ARITH.ALL;    --  
use IEEE.STD_LOGIC_UNSIGNED.ALL; --


entity lcd_driver is
    port   (Clock            : in   STD_LOGIC;
            Reset            : in   STD_LOGIC;
            EN               : out  STD_LOGIC;
            RS               : out  STD_LOGIC;
            RW               : out  STD_LOGIC;
            DB7              : out  STD_LOGIC;
            DB6              : out  STD_LOGIC;
            DB5              : out  STD_LOGIC;
            DB4              : out  STD_LOGIC;
            char1_1          : in   STD_LOGIC_VECTOR (7 downto 0);
            char1_2          : in   STD_LOGIC_VECTOR (7 downto 0);
				char1_3          : in   STD_LOGIC_VECTOR (7 downto 0);
            char1_4          : in   STD_LOGIC_VECTOR (7 downto 0);
				char1_5          : in   STD_LOGIC_VECTOR (7 downto 0);
            char1_6          : in   STD_LOGIC_VECTOR (7 downto 0);
				char1_7          : in   STD_LOGIC_VECTOR (7 downto 0);
            char1_8          : in   STD_LOGIC_VECTOR (7 downto 0);
				char1_9          : in   STD_LOGIC_VECTOR (7 downto 0);
            char1_10         : in   STD_LOGIC_VECTOR (7 downto 0);
				char1_11         : in   STD_LOGIC_VECTOR (7 downto 0);
            char1_12         : in   STD_LOGIC_VECTOR (7 downto 0);
				char1_13         : in   STD_LOGIC_VECTOR (7 downto 0);
            char1_14         : in   STD_LOGIC_VECTOR (7 downto 0);
				char1_15         : in   STD_LOGIC_VECTOR (7 downto 0);
            char1_16         : in   STD_LOGIC_VECTOR (7 downto 0);
				char2_1          : in   STD_LOGIC_VECTOR (7 downto 0);
            char2_2          : in   STD_LOGIC_VECTOR (7 downto 0);
				char2_3          : in   STD_LOGIC_VECTOR (7 downto 0);
            char2_4          : in   STD_LOGIC_VECTOR (7 downto 0);
				char2_5          : in   STD_LOGIC_VECTOR (7 downto 0);
            char2_6          : in   STD_LOGIC_VECTOR (7 downto 0);
				char2_7          : in   STD_LOGIC_VECTOR (7 downto 0);
            char2_8          : in   STD_LOGIC_VECTOR (7 downto 0);
				char2_9          : in   STD_LOGIC_VECTOR (7 downto 0);
            char2_10         : in   STD_LOGIC_VECTOR (7 downto 0);
				char2_11         : in   STD_LOGIC_VECTOR (7 downto 0);
            char2_12         : in   STD_LOGIC_VECTOR (7 downto 0);
				char2_13         : in   STD_LOGIC_VECTOR (7 downto 0);
            char2_14         : in   STD_LOGIC_VECTOR (7 downto 0);
				char2_15         : in   STD_LOGIC_VECTOR (7 downto 0);
            char2_16         : in   STD_LOGIC_VECTOR (7 downto 0));
end lcd_driver;

architecture lcd_driver_arch of lcd_driver is

    constant   wait_40ms: STD_LOGIC_VECTOR(11 downto 0) := x"3d0";
    constant   wait_2ms: STD_LOGIC_VECTOR(11 downto 0) := x"030";
    type State_Type is (S1,POWER_ON,F_SET_1,F_SET_2,F_SET_3,
                         WAIT_1,D_CONTROL_1,D_CONTROL_2,WAIT_2,
                         WAIT_3,D_CLEAR_1,D_CLEAR_2,
                         E_MODE_1,E_MODE_2,WAIT_4,
								 PRINT_CHAR1_1_1,PRINT_CHAR1_1_2,PRINT_CHAR1_2_1,PRINT_CHAR1_2_2,
								 PRINT_CHAR1_3_1,PRINT_CHAR1_3_2,PRINT_CHAR1_4_1,PRINT_CHAR1_4_2,
								 PRINT_CHAR1_5_1,PRINT_CHAR1_5_2,PRINT_CHAR1_6_1,PRINT_CHAR1_6_2,
								 PRINT_CHAR1_7_1,PRINT_CHAR1_7_2,PRINT_CHAR1_8_1,PRINT_CHAR1_8_2,
								 PRINT_CHAR1_9_1,PRINT_CHAR1_9_2,PRINT_CHAR1_10_1,PRINT_CHAR1_10_2,
								 PRINT_CHAR1_11_1,PRINT_CHAR1_11_2,PRINT_CHAR1_12_1,PRINT_CHAR1_12_2,
								 PRINT_CHAR1_13_1,PRINT_CHAR1_13_2,PRINT_CHAR1_14_1,PRINT_CHAR1_14_2,
								 PRINT_CHAR1_15_1,PRINT_CHAR1_15_2,PRINT_CHAR1_16_1,PRINT_CHAR1_16_2,
                         MOVE_CURSOR_1,MOVE_CURSOR_2,MOVE_CURSOR2_1,MOVE_CURSOR2_2,
								 PRINT_CHAR2_1_1,PRINT_CHAR2_1_2,PRINT_CHAR2_2_1,PRINT_CHAR2_2_2,
								 PRINT_CHAR2_3_1,PRINT_CHAR2_3_2,PRINT_CHAR2_4_1,PRINT_CHAR2_4_2,
								 PRINT_CHAR2_5_1,PRINT_CHAR2_5_2,PRINT_CHAR2_6_1,PRINT_CHAR2_6_2,
								 PRINT_CHAR2_7_1,PRINT_CHAR2_7_2,PRINT_CHAR2_8_1,PRINT_CHAR2_8_2,
								 PRINT_CHAR2_9_1,PRINT_CHAR2_9_2,PRINT_CHAR2_10_1,PRINT_CHAR2_10_2,
								 PRINT_CHAR2_11_1,PRINT_CHAR2_11_2,PRINT_CHAR2_12_1,PRINT_CHAR2_12_2,
								 PRINT_CHAR2_13_1,PRINT_CHAR2_13_2,PRINT_CHAR2_14_1,PRINT_CHAR2_14_2,
								 PRINT_CHAR2_15_1,PRINT_CHAR2_15_2,PRINT_CHAR2_16_1,PRINT_CHAR2_16_2
                         );
    signal Current_State   :State_Type;
    signal Next_State      :State_Type;
    signal Count           :STD_LOGIC_VECTOR(11 downto 0);
	 signal Count_Reset	   :STD_LOGIC;
	 signal Clock_Out			:STD_LOGIC;
	 signal EN_Clock        :STD_LOGIC;
	 signal EN_enable       :STD_LOGIC;
	 signal DB              :STD_LOGIC_VECTOR(3 downto 0);
   
   component lcd_counter
       Port ( Clock     : in  STD_LOGIC;
              Reset     : in  STD_LOGIC;
              Count_Out : out STD_LOGIC_VECTOR (11 downto 0));
   end component;
	
	component lcd_clock_div	
		port   (	Clock_In     : in   STD_LOGIC;
					Reset        : in   STD_LOGIC;
					Clock_Out    : out  STD_LOGIC;
					Clock_Out2   : out  STD_LOGIC);
	end component;
				
   
begin
    U1: lcd_counter   port map(Clock_Out,Count_Reset,Count);
	 U2: lcd_clock_div port map(Clock,Reset,Clock_Out,EN_Clock);
	 
	STATE_MEMORY: process(Clock_Out,Reset)
	begin
		if(Reset = '0')then
			Current_State <= S1;
		elsif(Clock_Out'event and Clock_Out = '1')then
			Current_State <= Next_State; end if;
	end process;
		
	NEXT_STATE_LOGIC: process(Current_State,Count)
	begin    
		case(Current_State)is
			when S1		=>			  Next_State <= POWER_ON;
			when POWER_ON =>       if(Count = wait_40ms)then Next_State <= F_SET_1;
								        else   Next_State <= POWER_ON;end if;
			when F_SET_1 =>        Next_State <= F_SET_2;			                       
			when F_SET_2 =>        Next_State <= F_SET_3;			                       
			when F_SET_3 =>        Next_State <= WAIT_1;			                       
			when WAIT_1  =>        if(Count = wait_2ms) then
			                          Next_State <= D_CONTROL_1;
										  else Next_State <= WAIT_1;end if;			    
			when D_CONTROL_1  => 		Next_State <= D_CONTROL_2;
			when D_CONTROL_2  =>   Next_State <= WAIT_2;
			when WAIT_2       =>   if(Count = wait_2ms) then
			                          Next_State <= D_CLEAR_1;
									     else Next_State <= WAIT_2;end if;
			when D_CLEAR_1    =>   Next_State <= D_CLEAR_2;
			when D_CLEAR_2    =>   Next_State <= WAIT_3;
			when WAIT_3       =>   if(Count = wait_2ms) then
			                           Next_State <= E_MODE_1;
										  else Next_State <= WAIT_3;end if;
			when E_MODE_1     =>   Next_State <= E_MODE_2;
			when E_MODE_2     =>   Next_State <= WAIT_4;
			when WAIT_4  =>        if(Count = wait_2ms) then
			                           Next_State <= PRINT_CHAR1_1_1; 
										  else Next_State <= WAIT_4;end if;
			
			when PRINT_CHAR1_1_1	 =>   Next_State <= PRINT_CHAR1_1_2;
			when PRINT_CHAR1_1_2	 =>   Next_State <= PRINT_CHAR1_2_1;
			when PRINT_CHAR1_2_1	 =>   Next_State <= PRINT_CHAR1_2_2;
			when PRINT_CHAR1_2_2	 =>   Next_State <= PRINT_CHAR1_3_1;
			when PRINT_CHAR1_3_1	 =>   Next_State <= PRINT_CHAR1_3_2;
			when PRINT_CHAR1_3_2	 =>   Next_State <= PRINT_CHAR1_4_1;
			when PRINT_CHAR1_4_1	 =>   Next_State <= PRINT_CHAR1_4_2;
			when PRINT_CHAR1_4_2	 =>   Next_State <= PRINT_CHAR1_5_1;
			when PRINT_CHAR1_5_1	 =>   Next_State <= PRINT_CHAR1_5_2;
			when PRINT_CHAR1_5_2	 =>   Next_State <= PRINT_CHAR1_6_1;
			when PRINT_CHAR1_6_1	 =>   Next_State <= PRINT_CHAR1_6_2;
			when PRINT_CHAR1_6_2	 =>   Next_State <= PRINT_CHAR1_7_1;
			when PRINT_CHAR1_7_1	 =>   Next_State <= PRINT_CHAR1_7_2;
			when PRINT_CHAR1_7_2	 =>   Next_State <= PRINT_CHAR1_8_1;
			when PRINT_CHAR1_8_1	 =>   Next_State <= PRINT_CHAR1_8_2;
			when PRINT_CHAR1_8_2	 =>   Next_State <= PRINT_CHAR1_9_1;
			when PRINT_CHAR1_9_1	 =>   Next_State <= PRINT_CHAR1_9_2;
			when PRINT_CHAR1_9_2	 =>   Next_State <= PRINT_CHAR1_10_1;
			when PRINT_CHAR1_10_1 =>   Next_State <= PRINT_CHAR1_10_2;
			when PRINT_CHAR1_10_2 =>   Next_State <= PRINT_CHAR1_11_1;
			when PRINT_CHAR1_11_1 =>   Next_State <= PRINT_CHAR1_11_2;
			when PRINT_CHAR1_11_2 =>   Next_State <= PRINT_CHAR1_12_1;
			when PRINT_CHAR1_12_1 =>   Next_State <= PRINT_CHAR1_12_2;
			when PRINT_CHAR1_12_2 =>   Next_State <= PRINT_CHAR1_13_1;
			when PRINT_CHAR1_13_1 =>   Next_State <= PRINT_CHAR1_13_2;
			when PRINT_CHAR1_13_2 =>   Next_State <= PRINT_CHAR1_14_1;
			when PRINT_CHAR1_14_1 =>   Next_State <= PRINT_CHAR1_14_2;
			when PRINT_CHAR1_14_2 =>   Next_State <= PRINT_CHAR1_15_1;
			when PRINT_CHAR1_15_1 =>   Next_State <= PRINT_CHAR1_15_2;
			when PRINT_CHAR1_15_2 =>   Next_State <= PRINT_CHAR1_16_1;
			when PRINT_CHAR1_16_1 =>   Next_State <= PRINT_CHAR1_16_2;
			when PRINT_CHAR1_16_2 =>   Next_State <= MOVE_CURSOR_1;
			when MOVE_CURSOR_1    =>   Next_State <= MOVE_CURSOR_2;
			when MOVE_CURSOR_2    =>   Next_State <= PRINT_CHAR2_1_1;
			when PRINT_CHAR2_1_1	 =>   Next_State <= PRINT_CHAR2_1_2;
			when PRINT_CHAR2_1_2	 =>   Next_State <= PRINT_CHAR2_2_1;
			when PRINT_CHAR2_2_1	 =>   Next_State <= PRINT_CHAR2_2_2;
			when PRINT_CHAR2_2_2	 =>   Next_State <= PRINT_CHAR2_3_1;
			when PRINT_CHAR2_3_1	 =>   Next_State <= PRINT_CHAR2_3_2;
			when PRINT_CHAR2_3_2	 =>   Next_State <= PRINT_CHAR2_4_1;
			when PRINT_CHAR2_4_1	 =>   Next_State <= PRINT_CHAR2_4_2;
			when PRINT_CHAR2_4_2	 =>   Next_State <= PRINT_CHAR2_5_1;
			when PRINT_CHAR2_5_1	 =>   Next_State <= PRINT_CHAR2_5_2;
			when PRINT_CHAR2_5_2	 =>   Next_State <= PRINT_CHAR2_6_1;
			when PRINT_CHAR2_6_1	 =>   Next_State <= PRINT_CHAR2_6_2;
			when PRINT_CHAR2_6_2	 =>   Next_State <= PRINT_CHAR2_7_1;
			when PRINT_CHAR2_7_1	 =>   Next_State <= PRINT_CHAR2_7_2;
			when PRINT_CHAR2_7_2	 =>   Next_State <= PRINT_CHAR2_8_1;
			when PRINT_CHAR2_8_1	 =>   Next_State <= PRINT_CHAR2_8_2;
			when PRINT_CHAR2_8_2	 =>   Next_State <= PRINT_CHAR2_9_1;
			when PRINT_CHAR2_9_1	 =>   Next_State <= PRINT_CHAR2_9_2;
			when PRINT_CHAR2_9_2	 =>   Next_State <= PRINT_CHAR2_10_1;
			when PRINT_CHAR2_10_1 =>   Next_State <= PRINT_CHAR2_10_2;
			when PRINT_CHAR2_10_2 =>   Next_State <= PRINT_CHAR2_11_1;
			when PRINT_CHAR2_11_1 =>   Next_State <= PRINT_CHAR2_11_2;
			when PRINT_CHAR2_11_2 =>   Next_State <= PRINT_CHAR2_12_1;
			when PRINT_CHAR2_12_1 =>   Next_State <= PRINT_CHAR2_12_2;
			when PRINT_CHAR2_12_2 =>   Next_State <= PRINT_CHAR2_13_1;
			when PRINT_CHAR2_13_1 =>   Next_State <= PRINT_CHAR2_13_2;
			when PRINT_CHAR2_13_2 =>   Next_State <= PRINT_CHAR2_14_1;
			when PRINT_CHAR2_14_1 =>   Next_State <= PRINT_CHAR2_14_2;
			when PRINT_CHAR2_14_2 =>   Next_State <= PRINT_CHAR2_15_1;
			when PRINT_CHAR2_15_1 =>   Next_State <= PRINT_CHAR2_15_2;
			when PRINT_CHAR2_15_2 =>   Next_State <= PRINT_CHAR2_16_1;
			when PRINT_CHAR2_16_1 =>   Next_State <= PRINT_CHAR2_16_2;
			when PRINT_CHAR2_16_2 =>   Next_State <= MOVE_CURSOR2_1;
			when MOVE_CURSOR2_1   =>   Next_State <= MOVE_CURSOR2_2;
			when MOVE_CURSOR2_2 	 =>   Next_State <= PRINT_CHAR1_1_1;
								                            		
		end case;
   end process;
	
	OUTPUT_LOGIC: process(Current_State,EN_Clock)
	begin
	   case(Current_State)is
			when S1       =>     RS  <= '0';
                              RW  <= '0';
                              DB  <= "0000";
                              EN_enable  <= '0';
                              Count_Reset <= '0';
			--wait for more than 20ms after power on							
	      when POWER_ON =>     RS  <= '0';
                              RW  <= '0';
                              DB  <= "0000";
                              EN_enable  <= '0';
                              Count_Reset <= '1';
	      --set 4 bit mode    
			when F_SET_1 =>      RS  <= '0';
                              RW  <= '0';
                              DB  <= "0010";
										EN_enable  <= '1';
										Count_Reset <= '0';
                              
			--set 4 bit mode again    
			when F_SET_2 =>      RS  <= '0';
                              RW  <= '0';
                              DB  <= "0010";
										EN_enable  <= '1';
										Count_Reset <= '0';                              
			--set 2 line mode    
			when F_SET_3 =>      RS  <= '0';
                              RW  <= '0';
                              DB  <= "1100";
										EN_enable  <= '1';
										Count_Reset <= '0';
			--wait for more than 39us    
			when WAIT_1  =>      RS  <= '0';
                              RW  <= '0';
                              DB  <= "0000";
										EN_enable  <= '0';
										Count_Reset <= '1';
         --display control first nibble                     
         when D_CONTROL_1 =>  RS  <= '0';
                              RW  <= '0';
                              DB  <= "0000";
										EN_enable  <= '1';
										Count_Reset <= '0';
         --display controll - display on, cursor on, blink on                     
         when D_CONTROL_2 =>  RS  <= '0';
                              RW  <= '0';
                              DB  <= "1100";
										EN_enable  <= '1';
										Count_Reset <= '0';
         --wait for more than 39 us           
         when WAIT_2  =>      RS  <= '0';
                              RW  <= '0';
                              DB  <= "0000";
										EN_enable  <= '0';
										Count_Reset <= '1';
         --clear display                     
         when D_CLEAR_1 =>    RS  <= '0';
                              RW  <= '0';
                              DB  <= "0000";
										EN_enable  <= '1';
										Count_Reset <= '0';
                              
         when D_CLEAR_2 =>    RS  <= '0';
                              RW  <= '0';
                              DB  <= "0001";
										EN_enable  <= '1';
										Count_Reset <= '0';
         --wait for more than 1.53 ms                     
         when WAIT_3  =>      RS  <= '0';
                              RW  <= '0';
                              DB  <= "0000";
										EN_enable  <= '0';
										Count_Reset <= '1';
         --entry mode first nibble                     
         when E_MODE_1  =>    RS  <= '0';
                              RW  <= '0';
                              DB  <= "0000";
										EN_enable  <= '1';
										Count_Reset <= '0';
         --increment on, display shift off                     
         when E_MODE_2  =>    RS  <= '0';
                              RW  <= '0';
                              DB  <= "0110";
										EN_enable  <= '1';
										Count_Reset <= '0';
         --wait for more than 39 us                     
         when WAIT_4  =>      RS  <= '0';
                              RW  <= '0';
                              DB  <= "0000";
										EN_enable  <= '0';
										Count_Reset <= '1';
											
         when PRINT_CHAR1_1_1=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char1_1(7 downto 4);
										  EN_enable  <= '1';
										  Count_Reset <= '0';
										
         when PRINT_CHAR1_1_2=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char1_1(3 downto 0);
										  EN_enable  <= '1';
										  Count_Reset <= '0';										
										
			when PRINT_CHAR1_2_1=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char1_2(7 downto 4);
										  EN_enable  <= '1';
										  Count_Reset <= '0';
										
         when PRINT_CHAR1_2_2=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char1_2(3 downto 0);
										  EN_enable  <= '1';
										  Count_Reset <= '0';
											
         when PRINT_CHAR1_3_1=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char1_3(7 downto 4);
										  EN_enable  <= '1';
										  Count_Reset <= '0';
										
         when PRINT_CHAR1_3_2=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char1_3(3 downto 0);
										  EN_enable  <= '1';
										  Count_Reset <= '0';										
										
			when PRINT_CHAR1_4_1=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char1_4(7 downto 4);
										  EN_enable  <= '1';
										  Count_Reset <= '0';
										
         when PRINT_CHAR1_4_2=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char1_4(3 downto 0);
										  EN_enable  <= '1';
										  Count_Reset <= '0';
											
         when PRINT_CHAR1_5_1=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char1_5(7 downto 4);
										  EN_enable  <= '1';
										  Count_Reset <= '0';
										
         when PRINT_CHAR1_5_2=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char1_5(3 downto 0);
										  EN_enable  <= '1';
										  Count_Reset <= '0';										
										
			when PRINT_CHAR1_6_1=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char1_6(7 downto 4);
										  EN_enable  <= '1';
										  Count_Reset <= '0';
										
         when PRINT_CHAR1_6_2=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char1_6(3 downto 0);
										  EN_enable  <= '1';
										  Count_Reset <= '0';
											
         when PRINT_CHAR1_7_1=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char1_7(7 downto 4);
										  EN_enable  <= '1';
										  Count_Reset <= '0';
										
         when PRINT_CHAR1_7_2=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char1_7(3 downto 0);
										  EN_enable  <= '1';
										  Count_Reset <= '0';										
										
			when PRINT_CHAR1_8_1=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char1_8(7 downto 4);
										  EN_enable  <= '1';
										  Count_Reset <= '0';
										
         when PRINT_CHAR1_8_2=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char1_8(3 downto 0);
										  EN_enable  <= '1';
										  Count_Reset <= '0';
											
         when PRINT_CHAR1_9_1=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char1_9(7 downto 4);
										  EN_enable  <= '1';
										  Count_Reset <= '0';
										
         when PRINT_CHAR1_9_2=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char1_9(3 downto 0);
										  EN_enable  <= '1';
										  Count_Reset <= '0';										
										
			when PRINT_CHAR1_10_1=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char1_10(7 downto 4);
										  EN_enable  <= '1';
										  Count_Reset <= '0';
										
         when PRINT_CHAR1_10_2=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char1_10(3 downto 0);
										  EN_enable  <= '1';
										  Count_Reset <= '0';
											
         when PRINT_CHAR1_11_1=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char1_11(7 downto 4);
										  EN_enable  <= '1';
										  Count_Reset <= '0';
										
         when PRINT_CHAR1_11_2=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char1_11(3 downto 0);
										  EN_enable  <= '1';
										  Count_Reset <= '0';										
										
			when PRINT_CHAR1_12_1=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char1_12(7 downto 4);
										  EN_enable  <= '1';
										  Count_Reset <= '0';
										
         when PRINT_CHAR1_12_2=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char1_12(3 downto 0);
										  EN_enable  <= '1';
										  Count_Reset <= '0';
											
         when PRINT_CHAR1_13_1=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char1_13(7 downto 4);
										  EN_enable  <= '1';
										  Count_Reset <= '0';
										
         when PRINT_CHAR1_13_2=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char1_13(3 downto 0);
										  EN_enable  <= '1';
										  Count_Reset <= '0';										
										
			when PRINT_CHAR1_14_1=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char1_14(7 downto 4);
										  EN_enable  <= '1';
										  Count_Reset <= '0';
										
         when PRINT_CHAR1_14_2=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char1_14(3 downto 0);
										  EN_enable  <= '1';
										  Count_Reset <= '0';
											
         when PRINT_CHAR1_15_1=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char1_15(7 downto 4);
										  EN_enable  <= '1';
										  Count_Reset <= '0';
										
         when PRINT_CHAR1_15_2=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char1_15(3 downto 0);
										  EN_enable  <= '1';
										  Count_Reset <= '0';										
										
			when PRINT_CHAR1_16_1=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char1_16(7 downto 4);
										  EN_enable  <= '1';
										  Count_Reset <= '0';
										
         when PRINT_CHAR1_16_2=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char1_16(3 downto 0);
										  EN_enable  <= '1';
										  Count_Reset <= '0';
										
			when PRINT_CHAR2_1_1=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char2_1(7 downto 4);
										  EN_enable  <= '1';
										  Count_Reset <= '0';
										
         when PRINT_CHAR2_1_2=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char2_1(3 downto 0);
										  EN_enable  <= '1';
										  Count_Reset <= '0';
										
		   when PRINT_CHAR2_2_1=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char2_2(7 downto 4);
										  EN_enable  <= '1';
										  Count_Reset <= '0';
										
         when PRINT_CHAR2_2_2=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char2_2(3 downto 0);
										  EN_enable  <= '1';
										  Count_Reset <= '0';
										  
			when PRINT_CHAR2_3_1=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char2_3(7 downto 4);
										  EN_enable  <= '1';
										  Count_Reset <= '0';
										
         when PRINT_CHAR2_3_2=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char2_3(3 downto 0);
										  EN_enable  <= '1';
										  Count_Reset <= '0';										
										
			when PRINT_CHAR2_4_1=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char2_4(7 downto 4);
										  EN_enable  <= '1';
										  Count_Reset <= '0';
										
         when PRINT_CHAR2_4_2=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char2_4(3 downto 0);
										  EN_enable  <= '1';
										  Count_Reset <= '0';
											
         when PRINT_CHAR2_5_1=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char2_5(7 downto 4);
										  EN_enable  <= '1';
										  Count_Reset <= '0';
										
         when PRINT_CHAR2_5_2=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char2_5(3 downto 0);
										  EN_enable  <= '1';
										  Count_Reset <= '0';										
										
			when PRINT_CHAR2_6_1=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char2_6(7 downto 4);
										  EN_enable  <= '1';
										  Count_Reset <= '0';
										
         when PRINT_CHAR2_6_2=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char2_6(3 downto 0);
										  EN_enable  <= '1';
										  Count_Reset <= '0';
											
         when PRINT_CHAR2_7_1=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char2_7(7 downto 4);
										  EN_enable  <= '1';
										  Count_Reset <= '0';
										
         when PRINT_CHAR2_7_2=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char2_7(3 downto 0);
										  EN_enable  <= '1';
										  Count_Reset <= '0';										
										
			when PRINT_CHAR2_8_1=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char2_8(7 downto 4);
										  EN_enable  <= '1';
										  Count_Reset <= '0';
										
         when PRINT_CHAR2_8_2=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char2_8(3 downto 0);
										  EN_enable  <= '1';
										  Count_Reset <= '0';
											
         when PRINT_CHAR2_9_1=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char2_9(7 downto 4);
										  EN_enable  <= '1';
										  Count_Reset <= '0';
										
         when PRINT_CHAR2_9_2=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char2_9(3 downto 0);
										  EN_enable  <= '1';
										  Count_Reset <= '0';										
										
			when PRINT_CHAR2_10_1=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char2_10(7 downto 4);
										  EN_enable  <= '1';
										  Count_Reset <= '0';
										
         when PRINT_CHAR2_10_2=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char2_10(3 downto 0);
										  EN_enable  <= '1';
										  Count_Reset <= '0';
											
         when PRINT_CHAR2_11_1=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char2_11(7 downto 4);
										  EN_enable  <= '1';
										  Count_Reset <= '0';
										
         when PRINT_CHAR2_11_2=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char2_11(3 downto 0);
										  EN_enable  <= '1';
										  Count_Reset <= '0';										
										
			when PRINT_CHAR2_12_1=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char2_12(7 downto 4);
										  EN_enable  <= '1';
										  Count_Reset <= '0';
										
         when PRINT_CHAR2_12_2=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char2_12(3 downto 0);
										  EN_enable  <= '1';
										  Count_Reset <= '0';
											
         when PRINT_CHAR2_13_1=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char2_13(7 downto 4);
										  EN_enable  <= '1';
										  Count_Reset <= '0';
										
         when PRINT_CHAR2_13_2=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char2_13(3 downto 0);
										  EN_enable  <= '1';
										  Count_Reset <= '0';										
										
			when PRINT_CHAR2_14_1=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char2_14(7 downto 4);
										  EN_enable  <= '1';
										  Count_Reset <= '0';
										
         when PRINT_CHAR2_14_2=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char2_14(3 downto 0);
										  EN_enable  <= '1';
										  Count_Reset <= '0';
											
         when PRINT_CHAR2_15_1=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char2_15(7 downto 4);
										  EN_enable  <= '1';
										  Count_Reset <= '0';
										
         when PRINT_CHAR2_15_2=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char2_15(3 downto 0);
										  EN_enable  <= '1';
										  Count_Reset <= '0';										
										
			when PRINT_CHAR2_16_1=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char2_16(7 downto 4);
										  EN_enable  <= '1';
										  Count_Reset <= '0';
										
         when PRINT_CHAR2_16_2=> RS  <= '1';
                                RW  <= '0';
                                DB  <= char2_16(3 downto 0);
										  EN_enable  <= '1';
										  Count_Reset <= '0';
										                     
        	when MOVE_CURSOR_1=>   RS  <= '0';
                                RW  <= '0';
                                DB  <= "1100";
										  EN_enable  <= '1';
										  Count_Reset <= '0';
										
         when MOVE_CURSOR_2=>   RS  <= '0';
                                RW  <= '0';
                                DB  <= "0000";
										  EN_enable  <= '1';
										  Count_Reset <= '0';						
										
			when MOVE_CURSOR2_1=>  RS  <= '0';
                                RW  <= '0';
                                DB  <= "1000";
										  EN_enable  <= '1';
										  Count_Reset <= '0';
										
         when MOVE_CURSOR2_2=>  RS  <= '0';
                                RW  <= '0';
                                DB  <= "0000";
										  EN_enable  <= '1';
										  Count_Reset <= '0';
                              										
	   end case;
	   EN <= EN_Clock and EN_enable;
		DB7 <= DB(3);
		DB6 <= DB(2);
		DB5 <= DB(1);
		DB4 <= DB(0);
	end process; 	
end lcd_driver_arch;