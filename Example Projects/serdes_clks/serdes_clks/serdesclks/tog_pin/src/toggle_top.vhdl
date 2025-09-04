library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity toggle_top is
  port
  (
    cpu_resetn     : in std_logic; -- 3.3 - v LVCMOS
    clk_ddr3_100_p : in std_logic; -- 2.5v pins N14/N15 CLK2p/CLK2n
    clk_50_max10   : in std_logic; -- 2.5v pin  M9 CLK7p
    clk_25_max10   : in std_logic; -- 2.5v pin  M8 CLK7n
    clk_lvds_125_p : in std_logic; -- 2.5v pins P11/R11
    clk_10_adc     : in std_logic; -- 2.5v pin  N5 CLK0p
    user_led       : out std_logic_vector(4 downto 0); -- 1.5v pins T20, U22, U21, AA21, AA22
    user_pb        : in std_logic_vector(3 downto 0); -- 1.5v pins L22, M21, M22, N21
    user_dipsw     : in std_logic_vector(4 downto 0); -- 2.5v pins H21, H22, J21, J22, G19
    usb_resetn     : in std_logic; -- 3.3 - v LVCMOS
    usb_wrn        : in std_logic; -- 3.3 - v LVCMOS
    usb_rdn        : in std_logic; -- 3.3 - v LVCMOS
    usb_oen        : in std_logic; -- 3.3 - v LVCMOS
    usb_addr       : inout std_logic_vector(1 downto 0); -- 3.3 - v LVCMOS
    usb_data       : inout std_logic_vector(7 downto 0); -- 3.3 - v LVCMOS
    usb_full       : out std_logic; -- 3.3 - v LVCMOS
    usb_empty      : out std_logic; -- 3.3 - v LVCMOS
    usb_scl        : in std_logic; -- 3.3 - v LVCMOS
    usb_sda        : in std_logic; -- 3.3 - v LVCMOS
    usb_clk        : in std_logic; -- 3.3 - v LVCMOS
    uart_tx        : out std_logic; -- 2.5v pin W18
    uart_rx        : in std_logic; -- 2.5v pin Y19
    pmoda_io       : inout std_logic_vector(7 downto 0); -- 3.3 - v LVCMOS pins C7 C8 A6 B7 D8 A4 A5 E9
    pmodb_io       : inout std_logic_vector(7 downto 0); -- 3.3 - v LVCMOS pins E8 D5 B5 C4 A2 A3 B4 B3
    dac_sync       : out std_logic; -- 3.3 - v LVCMOS pin B10
    dac_sclk       : out std_logic; -- 3.3 - v LVCMOS pin A7
    dac_din        : out std_logic; -- 3.3 - v LVCMOS pin A8
    adc1in         : in std_logic_vector(8 downto 1); -- 2.5v pins
    adc2in         : in std_logic_vector(8 downto 1); -- 2.5v
    hsmc_clk_in_p  : in std_logic_vector(2 downto 1); -- 2.5v
    hsmc_clk_in0   : in std_logic; -- 2.5v
    hsmc_clk_out_p : out std_logic_vector(2 downto 1); -- 2.5v
    hsmc_clk_out0  : out std_logic; -- 2.5v
    hsmc_rx_d_p    : in std_logic_vector(16 downto 0); -- 2.5v
    hsmc_tx_d_p    : out std_logic_vector(16 downto 0); -- 2.5v
    hsmc_d         : inout std_logic_vector(3 downto 0); -- 2.5v
    hsmc_sda       : inout std_logic; -- 2.5v
    hsmc_scl       : out std_logic; -- 2.5v
    hsmc_prsntn    : in std_logic -- 2.5v
  );
end toggle_top;
architecture rtl of toggle_top is

  ------------------------------------------------------------------------------
  alias clk_50_out is pmoda_io(0);
  alias clk_25_out is pmoda_io(1);
  alias clk_25_out2 is pmoda_io(2);
  alias clk_10_out is pmoda_io(4);
  alias clk_1_out  is pmoda_io(6);
  alias clk_10k_out  is pmoda_io(7);

  alias led_alive_pin is user_led(3);


  ------------------------------------------------------------------------------
  signal pll_clk_10mhz : std_logic;
  signal pll_clk_1mhz  : std_logic;
  signal pll_clk_10khz : std_logic;

  ------------------------------------------------------------------------------
  signal pll1_locked : std_logic;
  signal led_sig : std_logic := '0';

  ------------------------------------------------------------------------------
  component pll1
    port
    (
      inclk0 : in std_logic := '0';
      c0     : out std_logic;
      c1     : out std_logic;
      c2     : out std_logic;
      locked : out std_logic
    );
  end component;

  ------------------------------------------------------------------------------
  -- processes
  ------------------------------------------------------------------------------

begin

  ------------------------------------------------------------------------------
  -- non clocked outputs
  ------------------------------------------------------------------------------
  clk_50_out <= clk_50_max10;
--  clk_50_out <= clk_50_max10;
  clk_25_out <= clk_25_max10;
  clk_25_out2 <= clk_25_max10;
  clk_10_out <= pll_clk_10mhz;
  clk_1_out  <= pll_clk_1mhz;
  clk_10k_out <= pll_clk_10khz;

  ------------------------------------------------------------------------------
  -- PLL instance with 10MHz, 1MHz and 10kHz outputs
  ------------------------------------------------------------------------------
  pll_1 : pll1
  port map
  (
    inclk0 => clk_50_max10,
    c0     => pll_clk_10mhz,
    c1     => pll_clk_1mhz,
    c2     => pll_clk_10khz,
    locked => pll1_locked
  );

  ------------------------------------------------------------------------------
  -- LED "alive" output
  ------------------------------------------------------------------------------
  LEDTOG : process (pll_clk_10khz)
    variable count : natural range 0 to 10000 := 0;
  begin

    if rising_edge(pll_clk_10khz) then
      count := count + 1;
      if (count >= 500) then
        count := 0;
        led_sig       <= not led_sig;
        led_alive_pin <= led_sig;
      end if;
    end if;

  end process LEDTOG;

end architecture;