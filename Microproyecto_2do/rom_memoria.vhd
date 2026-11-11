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
        direccion_in : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);    -- Dirección de memoria para leer el evento
        dato_out     : out std_logic_vector(DATA_WIDTH - 1 downto 0)     -- Código de evento almacenado leído desde la ROM
    );
end entity rom_memoria;

architecture arqui_rom_memoria of rom_memoria is

    -- Inicialización estática de la memoria ROM usando el tipo centralizado en pkg_system
    constant CONTENIDO_ROM : tipo_memoria_rom := (
	 --para la simulacion simulamos distintos timpos de deteccion con su respectivo codigo
        0  => x"01", -- Evento 1: Presencia detectada en Zona A
        1  => x"02", -- Evento 2: Presencia detectada en Zona B
        2  => x"03", -- Evento 3: Presencia detectada en Pasillo
        3  => x"04", -- Evento 4: Acceso autorizado principal
        4  => x"05", -- Evento 5: Alerta de movimiento prolongado
        5  => x"AA", -- Evento 6: Código de prueba 1
        6  => x"55", -- Evento 7: Código de prueba 2
        7  => x"F0", -- Evento 8: Código de prueba 3
        8  => x"08", -- Evento 9: Sector C
        9  => x"09", -- Evento 10: Sector D
        10 => x"1A", -- Evento 11: Puerta Norte
        11 => x"2B", -- Evento 12: Puerta Sur
        12 => x"3C", -- Evento 13: Laboratorio 1
        13 => x"4D", -- Evento 14: Laboratorio 2
        14 => x"5E", -- Evento 15: Sala de Equipos
        15 => x"6F"  -- Evento 16: Alerta General
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
            registro_salida <= CONTENIDO_ROM(to_integer(unsigned(direccion_in)));
        end if;
    end process PROCESO_ROM;

    -- Asignación del registro interno al puerto de salida
    dato_out <= registro_salida;

end architecture arqui_rom_memoria;