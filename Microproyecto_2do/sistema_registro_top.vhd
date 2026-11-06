library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Importación de los paquetes del sistema y de componentes
use work.pkg_system.all;
use work.pkg_componentes.all;

entity sistema_registro_top is
    port (
        reloj_in      : in  std_logic;                                    -- Reloj principal del sistema (ej. 50 MHz)
        reset_in      : in  std_logic;                                    -- Señal de reinicio general
        sensor_pir_in : in  std_logic;                                    -- Señal física cruda del sensor PIR
        
        -- Salidas físicas hacia los displays de 7 segmentos de la FPGA
        seg_uni_out   : out std_logic_vector(6 downto 0);                 -- Display de unidades
        seg_dec_out   : out std_logic_vector(6 downto 0);                 -- Display de decenas
        
        -- Indicador visual opcional
        alarma_out    : out std_logic                                     -- Indicador de escritura activa en RAM
    );
end entity sistema_registro_top;

architecture arqui_sistema_top of sistema_registro_top is

    -- Señales internas de interconexión entre los módulos
    signal pulso_pir_s    : std_logic;
    signal dir_rom_s      : std_logic_vector(ADDR_WIDTH - 1 downto 0);
    signal dir_ram_s      : std_logic_vector(ADDR_WIDTH - 1 downto 0);
    signal dato_rom_s     : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal dato_ram_s     : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal wr_en_ram_s    : std_logic;
    
    -- Señal adaptada a 7 bits para alimentar el decodificador de displays
    signal dato_visual_s  : std_logic_vector(6 downto 0);

begin

    -- 1. Instanciación del Controlador PIR (Filtro antirrebote y flancos)
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

    -- 2. Instanciación de la Unidad de Control (FSM coordinadora)
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

    -- 3. Instanciación de la Memoria ROM (Almacén de eventos)
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

    -- 4. Instanciación de la Memoria RAM (Registro dinámico de presencia)
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
            dato_out     => open 
        );

    -- 5. Adaptación del bus para mostrar la dirección actual de la RAM en los displays
    dato_visual_s <= "000" & dir_ram_s;

    -- 6. Instanciación del Decodificador de 7 Segmentos
    INSTANCIA_DECO_HEX : hex_decoder
        port map (
            bin_in  => dato_visual_s,
            seg_dec => seg_dec_out,
            seg_uni => seg_uni_out
        );

    -- Asignación de salida para monitoreo de escritura
    alarma_out <= wr_en_ram_s;

end architecture arqui_sistema_top;