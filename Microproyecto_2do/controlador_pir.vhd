library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controlador_pir is
    generic (
        ANCHO_CONTEO : integer := 10  -- Límite de ciclos para el filtro antirrebote
    );
    port (
        reloj_in      : in  std_logic;                                    -- Reloj principal del sistema
        reset_in      : in  std_logic;                                    -- Señal de reinicio general
        sensor_pir_in : in  std_logic;                                    -- Señal física cruda del sensor PIR
        pulso_out     : out std_logic                                     -- Pulso limpio y filtrado de detección
    );
end entity controlador_pir;

architecture arqui_controlador_pir of controlador_pir is

    -- Señales internas para el filtrado y detección de flancos
    signal contador_filtro : integer range 0 to ANCHO_CONTEO := 0;
    signal sensor_sinc_1   : std_logic := '0';
    signal sensor_sinc_2   : std_logic := '0';
    signal sensor_filtrado : std_logic := '0';
    signal sensor_anterior : std_logic := '0';

begin

    -- Proceso síncrono para sincronización, filtrado antirrebote y detección de flanco
    PROCESO_FILTRO_PIR : process(reloj_in)
    begin
        if rising_edge(reloj_in) then
            if reset_in = '1' then
                contador_filtro <= 0;
                sensor_sinc_1   <= '0';
                sensor_sinc_2   <= '0';
                sensor_filtrado <= '0';
                sensor_anterior <= '0';
                pulso_out       <= '0';
            else
                -- 1. Sincronización de la señal asíncrona del sensor PIR para evitar metaestabilidad
                sensor_sinc_1   <= sensor_pir_in;
                sensor_sinc_2   <= sensor_sinc_1;

                -- 2. Filtro antirrebote basado en temporización usando el genérico
                if sensor_sinc_2 /= sensor_filtrado then
                    if contador_filtro < ANCHO_CONTEO - 1 then
                        contador_filtro <= contador_filtro + 1;
                    else
                        contador_filtro <= 0;
                        sensor_filtrado <= sensor_sinc_2;
                    end if;
                else
                    contador_filtro <= 0;
                end if;

                -- 3. Detección de flanco de subida para generar un pulso único de un ciclo
                sensor_anterior <= sensor_filtrado;
                if sensor_filtrado = '1' and sensor_anterior = '0' then
                    pulso_out <= '1';
                else
                    pulso_out <= '0';
                end if;

            end if;
        end if;
    end process PROCESO_FILTRO_PIR;

end architecture arqui_controlador_pir;