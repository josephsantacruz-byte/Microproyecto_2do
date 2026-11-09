library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package pkg_system is

    -- Constantes globales de configuración para el ancho de bus de datos y direcciones
    constant DATA_WIDTH : positive := 8;
    constant ADDR_WIDTH : positive := 4;

    -- Definición del tipo de matriz estática para la memoria ROM del sistema
    type tipo_memoria_rom is array (natural range <>) of std_logic_vector(DATA_WIDTH - 1 downto 0);

    -- Definición del tipo de matriz para la memoria RAM del sistema
    type tipo_memoria_ram is array (0 to 2**ADDR_WIDTH - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);

end package pkg_system;

package body pkg_system is
    -- El cuerpo del paquete se mantiene vacío ya que solo contiene definiciones de tipos y constantes
end package body pkg_system;