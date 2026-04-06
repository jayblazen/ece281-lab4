library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_basys3 is
    port(
        clk     : in std_logic;
        sw      : in std_logic_vector(15 downto 0);
        btnU    : in std_logic;
        btnL    : in std_logic;
        btnR    : in std_logic;
        
        led : out std_logic_vector(15 downto 0);
        seg : out std_logic_vector(6 downto 0);
        an  : out std_logic_vector(3 downto 0)
    );
end top_basys3;

architecture top_basys3_arch of top_basys3 is

    -- signals
    signal w_fsm_reset : std_logic := '0';
    signal w_clk_reset : std_logic := '0';
    signal w_fsm_clk   : std_logic := '0';

    signal w_floor  : std_logic_vector(3 downto 0) := "0010";
    signal w_floor2 : std_logic_vector(3 downto 0) := "0010";

    signal seg0, seg2 : std_logic_vector(6 downto 0);

    -- components
    component sevenseg_decoder is
        port (
            i_Hex : in STD_LOGIC_VECTOR (3 downto 0);
            o_seg_n : out STD_LOGIC_VECTOR (6 downto 0)
        );
    end component;

    component elevator_controller_fsm is
        port (
            i_clk        : in  STD_LOGIC;
            i_reset      : in  STD_LOGIC;
            is_stopped   : in  STD_LOGIC;
            go_up_down   : in  STD_LOGIC;
            o_floor      : out STD_LOGIC_VECTOR (3 downto 0)
        );
    end component;

    component clock_divider is
        generic ( constant k_DIV : natural := 2 );
        port (
            i_clk    : in std_logic;
            i_reset  : in std_logic;
            o_clk    : out std_logic
        );
    end component;

begin

    ------------------------------------------------------------------
    -- CLOCK DIVIDER (0.5 sec movement)
    ------------------------------------------------------------------
    clkdiv_inst : clock_divider
        generic map ( k_DIV => 50000000 )
        port map (
            i_clk   => clk,
            i_reset => w_clk_reset,
            o_clk   => w_fsm_clk
        );


    elevator_inst : elevator_controller_fsm
        port map (
            i_clk      => w_fsm_clk,
            i_reset    => w_fsm_reset,
            is_stopped => sw(0),
            go_up_down => sw(1),
            o_floor    => w_floor
        );

    elevator_inst2 : elevator_controller_fsm
        port map (
            i_clk      => w_fsm_clk,
            i_reset    => w_fsm_reset,
            is_stopped => sw(14),
            go_up_down => sw(15),
            o_floor    => w_floor2
        );


    decoder0: sevenseg_decoder
        port map(
            i_Hex => w_floor,
            o_seg_n => seg0
        );

    decoder2: sevenseg_decoder
        port map(
            i_Hex => w_floor2,
            o_seg_n => seg2
        );

    process(clk)
        variable refresh_counter : unsigned(15 downto 0) := (others => '0');
    begin
        if rising_edge(clk) then
            refresh_counter := refresh_counter + 1;

            if refresh_counter(15) = '0' then
                -- Display 0 (rightmost)
                an  <= "1110";
                seg <= seg0;
            else
                -- Display 2
                an  <= "1011";
                seg <= seg2;
            end if;
        end if;
    end process;


    w_fsm_reset <= btnR or btnU;
    w_clk_reset <= btnL or btnU;


    led(15) <= w_fsm_clk;
    led(14 downto 0) <= (others => '0');

end top_basys3_arch;
	
