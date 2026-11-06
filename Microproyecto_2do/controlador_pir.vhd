library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pkg_system.all;

entity controlador_pir is
    port (
        reloj_in            : in  std_logic; -- Reloj principal del sistema
        reset_in            : in  std_logic; -- Señal de reinicio
        sensor_pir_in       : in  std_logic; -- Entrada física desde el pin del sensor
        sensor_activo_out   : out std_logic; -- Indica presencia continua detectada
        pulso_deteccion_out : out std_logic  -- Pulso de un ciclo al detectar movimiento inicial
    );
end entity controlador_pir;

architecture arqui_controlador_pir of controlador_pir is

    -- Sincronizadores de doble etapa para evitar metaestabilidad
    signal sincronizador_etapa_1   : std_logic := '0';
    signal sincronizador_etapa_2   : std_logic := '0';

    -- Señales internas de filtrado y detección
    signal senal_filtrada_actual   : std_logic := '0';
    signal senal_filtrada_anterior : std_logic := '0';
    signal contador_estabilidad    : natural range 0 to LIMITE_FILTRO_SENSOR := 0;

begin

    -- Proceso síncrono para sincronizar y filtrar el ruido del sensor
    PROCESO_ACONDICIONAMIENTO : process(reloj_in)
    begin
        if rising_edge(reloj_in) then
            if reset_in = '1' then
                sincronizador_etapa_1   <= '0';
                sincronizador_etapa_2   <= '0';
                senal_filtrada_actual   <= '0';
                senal_filtrada_anterior <= '0';
                contador_estabilidad    <= 0;
            else
                -- Doble etapa para evitar problemas de metaestabilidad con la señal externa
                sincronizador_etapa_1 <= sensor_pir_in;
                sincronizador_etapa_2 <= sincronizador_etapa_1;

                -- Filtro digital robusto de estabilidad
                if sincronizador_etapa_2 /= senal_filtrada_actual then
                    if contador_estabilidad = LIMITE_FILTRO_SENSOR then
                        senal_filtrada_actual <= sincronizador_etapa_2;
                        contador_estabilidad  <= 0;
                    else
                        contador_estabilidad  <= contador_estabilidad + 1;
                    end if;
                else
                    -- Si la señal es estable y coincide, mantenemos el contador en cero
                    contador_estabilidad <= 0;
                end if;

                -- Almacena el estado para poder comparar el ciclo anterior
                senal_filtrada_anterior <= senal_filtrada_actual;
            end if;
        end if;
    end process PROCESO_ACONDICIONAMIENTO;

    -- Asigna el nivel estable para mostrar presencia continua
    sensor_activo_out <= senal_filtrada_actual;

    -- Genera un pulso limpio de un solo ciclo al detectar el flanco de subida
    pulso_deteccion_out <= '1' when (senal_filtrada_actual = '1' and senal_filtrada_anterior = '0') else '0';

end architecture arqui_controlador_pir;