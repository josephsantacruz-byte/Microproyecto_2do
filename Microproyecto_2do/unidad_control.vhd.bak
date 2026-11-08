library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity unidad_control is
    generic (
        ADDR_WIDTH : positive := 4;
        DATA_WIDTH : positive := 8
    );
    port (
        reloj_in           : in  std_logic;                                    -- Reloj principal del sistema
        reset_in           : in  std_logic;                                    -- Señal de reinicio general
        pulso_deteccion_in : in  std_logic;                                    -- Pulso limpio proveniente del controlador PIR
        dato_rom_in        : in  std_logic_vector(DATA_WIDTH - 1 downto 0);    -- Dato del evento leído desde la ROM
        
        dir_rom_out        : out std_logic_vector(ADDR_WIDTH - 1 downto 0);    -- Dirección enviada a la ROM
        dir_ram_out        : out std_logic_vector(ADDR_WIDTH - 1 downto 0);    -- Dirección de escritura/lectura enviada a la RAM
        wr_en_ram_out      : out std_logic;                                    -- Habilitador de escritura para la RAM ('1' para guardar)
        dato_ram_out       : out std_logic_vector(DATA_WIDTH - 1 downto 0)     -- Dato que se escribirá en la RAM
    );
end entity unidad_control;

architecture arqui_unidad_control of unidad_control is

    -- Definición de los estados de la Máquina de Estados Finitos (FSM)
    type t_estado is (REPOSO, LEER_ROM, ESCRIBIR_RAM, ACTUALIZAR_PUNTEROS);
    signal estado_actual : t_estado := REPOSO;

    -- Punteros internos para direccionar las memorias ROM y RAM
    signal puntero_rom : unsigned(ADDR_WIDTH - 1 downto 0) := (others => '0');
    signal puntero_ram : unsigned(ADDR_WIDTH - 1 downto 0) := (others => '0');

begin

    -- Proceso secuencial síncrono para coordinar la FSM de control
    PROCESO_FSM : process(reloj_in)
    begin
        if rising_edge(reloj_in) then
            if reset_in = '1' then
                estado_actual <= REPOSO;
                puntero_rom   <= (others => '0');
                puntero_ram   <= (others => '0');
                wr_en_ram_out <= '0';
                dato_ram_out  <= (others => '0');
            else
                case estado_actual is
                    
                    -- Estado 1: Espera pasiva de una detección de movimiento válida
                    when REPOSO =>
                        wr_en_ram_out <= '0';
                        if pulso_deteccion_in = '1' then
                            estado_actual <= LEER_ROM;
                        end if;

                    -- Estado 2: Espera un ciclo de reloj para sincronizar la lectura de la ROM
                    when LEER_ROM =>
                        estado_actual <= ESCRIBIR_RAM;

                    -- Estado 3: Toma el código de la ROM y activa la escritura en la RAM
                    when ESCRIBIR_RAM =>
                        wr_en_ram_out <= '1';
                        dato_ram_out  <= dato_rom_in;
                        estado_actual <= ACTUALIZAR_PUNTEROS;

                    -- Estado 4: Desactiva la escritura, incrementa los punteros y regresa al reposo
                    when ACTUALIZAR_PUNTEROS =>
                        wr_en_ram_out <= '0';
                        puntero_rom   <= puntero_rom + 1;
                        puntero_ram   <= puntero_ram + 1;
                        estado_actual <= REPOSO;

                    when others =>
                        estado_actual <= REPOSO;
                end case;
            end if;
        end if;
    end process PROCESO_FSM;

    -- Asignación de los punteros internos hacia los puertos de salida
    dir_rom_out <= std_logic_vector(puntero_rom);
    dir_ram_out <= std_logic_vector(puntero_ram);

end architecture arqui_unidad_control;