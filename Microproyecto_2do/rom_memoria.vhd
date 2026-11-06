library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pkg_system.all;

entity rom_memoria is
    generic (
        DATA_WIDTH : positive := DATA_WIDTH;
        ADDR_WIDTH : positive := ADDR_WIDTH
    );
    port (
        reloj_in     : in  std_logic;                                    -- Reloj principal del sistema
        direccion_in : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);    -- Dirección de lectura solicitada
        dato_out     : out std_logic_vector(DATA_WIDTH - 1 downto 0)     -- Dato fijo almacenado en la ROM
    );
end entity rom_memoria;

architecture arqui_rom_memoria of rom_memoria is

    -- Tabla estática precargada con los códigos de eventos fijos de fábrica
    constant tabla_rom : tipo_memoria_rom := (
        0  => x"01", 1  => x"02", 2  => x"03", 3  => x"04",
        4  => x"05", 5  => x"06", 6  => x"07", 7  => x"08",
        8  => x"09", 9  => x"0A", 10 => x"0B", 11 => x"0C",
        12 => x"0D", 13 => x"0E", 14 => x"0F", 15 => x"00",
        others => (others => '0')
    );

    -- Señales internas de control y direccionamiento
    signal registro_salida  : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal indice_direccion : integer range 0 to 2**ADDR_WIDTH - 1;

    -- Directiva para obligar a Quartus a usar bloques de memoria física M9K
    attribute romstyle : string;
    attribute romstyle of tabla_rom : constant is "M9K";

begin

    -- Convierte la dirección binaria a un número entero para buscar en la tabla
    indice_direccion <= to_integer(unsigned(direccion_in));

    -- Proceso síncrono para la lectura de la memoria ROM al ritmo del reloj
    PROCESO_ROM_SINCRONA : process(reloj_in)
    begin
        if rising_edge(reloj_in) then
            registro_salida <= tabla_rom(indice_direccion);
        end if;
    end process PROCESO_ROM_SINCRONA;

    -- Asigna el registro interno a la salida de datos del componente
    dato_out <= registro_salida;

end architecture arqui_rom_memoria;