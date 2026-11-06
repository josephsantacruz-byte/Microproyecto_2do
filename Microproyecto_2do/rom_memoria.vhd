library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Importamos el paquete global para usar las constantes y tipos
use work.pkg_system.all;

entity rom_memoria is
    generic (
        DATA_WIDTH : positive := 8;
        ADDR_WIDTH : positive := 4
    );
    port (
        reloj_in     : in  std_logic;                                    -- Reloj principal del sistema
        direccion_in : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);    -- Dirección de memoria para leer el evento
        dato_out     : out std_logic_vector(DATA_WIDTH - 1 downto 0)     -- Código de evento almacenado leído desde la ROM
    );
end entity rom_memoria;

architecture arqui_rom_memoria of rom_memoria is

    -- Definición de la matriz de la ROM con un rango acotado explícitamente (0 hasta 2**ADDR_WIDTH - 1)
    type tipo_rom_local is array (0 to 2**ADDR_WIDTH - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);

    -- Inicialización estática de la memoria ROM con códigos de eventos de presencia
    constant CONTENIDO_ROM : tipo_rom_local := (
        0  => x"01", -- Evento 1: Presencia detectada en Zona A
        1  => x"02", -- Evento 2: Presencia detectada en Zona B
        2  => x"03", -- Evento 3: Presencia detectada en Pasillo
        3  => x"04", -- Evento 4: Acceso autorizado principal
        4  => x"05", -- Evento 5: Alerta de movimiento prolongado
        5  => x"AA", -- Evento de prueba 1
        6  => x"55", -- Evento de prueba 2
        7  => x"F0", -- Evento de prueba 3
        others => (others => '0') -- Resto de posiciones inicializadas en cero
    );

    -- Registro interno de salida para asegurar la sincronía de lectura
    signal registro_salida : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');

    -- Directiva para obligar a Quartus a inferir bloques de memoria física M9K
    attribute romstyle : string;
    attribute romstyle of CONTENIDO_ROM : constant is "M9K";

begin

    -- Proceso síncrono para la lectura de la memoria ROM
    PROCESO_ROM : process(reloj_in)
    begin
        if rising_edge(reloj_in) then
            -- Lee de forma síncrona el contenido de la ROM según la dirección proporcionada
            registro_salida <= CONTENIDO_ROM(to_integer(unsigned(direccion_in)));
        end if;
    end process PROCESO_ROM;

    -- Asignación del registro interno al puerto de salida
    dato_out <= registro_salida;

end architecture arqui_rom_memoria;