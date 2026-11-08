library ieee;
use ieee.std_logic_1164.all;

package pkg_componentes is

    -- 1. Componente del Controlador PIR (Filtro antirrebote y flancos)
    component controlador_pir is
        generic (
            ANCHO_CONTEO : integer := 20
        );
        port (
            reloj_in      : in  std_logic;
            reset_in      : in  std_logic;
            sensor_pir_in : in  std_logic;
            pulso_out     : out std_logic
        );
    end component;

    -- 2. Componente de la Memoria ROM (Almacén de eventos)
    component rom_memoria is
        generic (
            DATA_WIDTH : positive := 8;
            ADDR_WIDTH : positive := 4
        );
        port (
            reloj_in     : in  std_logic;
            direccion_in : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
            dato_out     : out std_logic_vector(DATA_WIDTH - 1 downto 0)
        );
    end component;

    -- 3. Componente de la Memoria RAM (Registro dinámico de presencia)
    component ram_memoria is
        generic (
            DATA_WIDTH : positive := 8;
            ADDR_WIDTH : positive := 4
        );
        port (
            reloj_in     : in  std_logic;
            wr_en_in     : in  std_logic;
            direccion_in : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
            dato_in      : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
            dato_out     : out std_logic_vector(DATA_WIDTH - 1 downto 0)
        );
    end component;

    -- 4. Componente de la Unidad de Control (FSM coordinadora con botón de reinicio)
    component unidad_control is
        generic (
            ADDR_WIDTH : positive := 4;
            DATA_WIDTH : positive := 8
        );
        port (
            reloj_in            : in  std_logic;
            reset_in            : in  std_logic;
            pulso_deteccion_in  : in  std_logic;
            dato_rom_in         : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
            btn_reset_cuenta_in : in  std_logic;
            dir_rom_out         : out std_logic_vector(ADDR_WIDTH - 1 downto 0);
            dir_ram_out         : out std_logic_vector(ADDR_WIDTH - 1 downto 0);
            wr_en_ram_out       : out std_logic;
            dato_ram_out        : out std_logic_vector(DATA_WIDTH - 1 downto 0)
        );
    end component;

    -- 5. Componente del Decodificador de 7 Segmentos (1 dígito: 4 bits a 7 segmentos)
    component hex_decoder is
        port (
            bin_in  : in  std_logic_vector(3 downto 0);
            seg_out : out std_logic_vector(6 downto 0)
        );
    end component;

end package pkg_componentes;

package body pkg_componentes is
    -- El cuerpo del paquete se mantiene vacío ya que solo contiene declaraciones de componentes
end package body pkg_componentes;