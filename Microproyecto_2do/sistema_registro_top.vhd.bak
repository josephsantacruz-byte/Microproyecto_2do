library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Importación de los paquetes del sistema y de componentes
use work.pkg_system.all;
use work.pkg_componentes.all;

entity sistema_registro_top is
    port (
        reloj_in      : in  std_logic;                                    -- Reloj principal del sistema (ej. 50 MHz)
        reset_in      : in  std_logic;                                    -- Señal de reinicio general del sistema
        sensor_pir_in : in  std_logic;                                    -- Señal física cruda proveniente del sensor PIR
        
        -- Puertos opcionales de monitoreo externo o depuración en pines de la FPGA
        alarma_out    : out std_logic                                     -- Indicador visual opcional de actividad de escritura
    );
end entity sistema_registro_top;

architecture arqui_sistema_top of sistema_registro_top is

    -- Señales internas para interconectar los módulos en el nivel superior
    signal pulso_pir_s  : std_logic;                                    -- Pulso limpio filtrado por el controlador PIR
    signal dir_rom_s    : std_logic_vector(ADDR_WIDTH - 1 downto 0);    -- Bus de dirección hacia la memoria ROM
    signal dir_ram_s    : std_logic_vector(ADDR_WIDTH - 1 downto 0);    -- Bus de dirección hacia la memoria RAM
    signal dato_rom_s   : std_logic_vector(DATA_WIDTH - 1 downto 0);    -- Dato de evento leído desde la ROM
    signal dato_ram_s   : std_logic_vector(DATA_WIDTH - 1 downto 0);    -- Dato transferido hacia la RAM
    signal wr_en_ram_s  : std_logic;                                    -- Señal de habilitación de escritura en la RAM

begin

    -- 1. Instanciación del Controlador PIR (Filtro y detector de flanco)
    INSTANCIA_CONTROLADOR_PIR : controlador_pir
        generic map (
            ANCHO_CONTEO => 20
        )
        port map (
            reloj_in      => reloj_in,
            reset_in      => reset_in,
            sensor_pir_in => sensor_pir_in,
            pulso_out     => pulso_pir_s
        );

    -- 2. Instanciación de la Unidad de Control (FSM coordinadora del sistema)
    INSTANCIA_UNIDAD_CONTROL : unidad_control
        generic map (
            ADDR_WIDTH => ADDR_WIDTH,
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            reloj_in           => reloj_in,
            reset_in           => reset_in,
            pulso_deteccion_in => pulso_pir_s,
            dato_rom_in        => dato_rom_s,
            dir_rom_out        => dir_rom_s,
            dir_ram_out        => dir_ram_s,
            wr_en_ram_out      => wr_en_ram_s,
            dato_ram_out       => dato_ram_s
        );

    -- 3. Instanciación de la Memoria ROM (Almacén estático de códigos de eventos)
    INSTANCIA_ROM_MEMORIA : rom_memoria
        generic map (
            DATA_WIDTH => DATA_WIDTH,
            ADDR_WIDTH => ADDR_WIDTH
        )
        port map (
            reloj_in     => reloj_in,
            direccion_in => dir_rom_s,
            dato_out     => dato_rom_s
        );

    -- 4. Instancia de la Memoria RAM (Registro dinámico de eventos de presencia)
    INSTANCIA_RAM_MEMORIA : ram_memoria
        generic map (
            DATA_WIDTH => DATA_WIDTH,
            ADDR_WIDTH => ADDR_WIDTH
        )
        port map (
            reloj_in     => reloj_in,
            wr_en_in     => wr_en_ram_s,
            direccion_in => dir_ram_s,
            dato_in      => dato_ram_s,
            dato_out     => open -- La salida de lectura puede dejarse abierta si operará de forma interna
        );

    -- Asignación de señales de salida adicionales (ej. indicador de escritura activa)
    alarma_out <= wr_en_ram_s;

end architecture arqui_sistema_top;