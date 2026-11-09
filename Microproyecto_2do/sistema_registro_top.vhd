library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Importación de los paquetes del sistema y de componentes
use work.pkg_system.all;
use work.pkg_componentes.all;

entity sistema_registro_top is
    port (
        reloj_in            : in  std_logic;                    -- Reloj principal del sistema (50 MHz)
        reset_in            : in  std_logic := '0';             -- Señal de reinicio general (activo en '1', conectar a Switch)
        sensor_pir_in       : in  std_logic;                    -- Señal física cruda del sensor PIR HC-SR501
        btn_reset_cuenta_in : in  std_logic := '1';             -- Botón físico para reiniciar la cuenta (activo en bajo '0')
        
        -- 4 Salidas físicas hacia los displays de 7 segmentos de la FPGA
        seg_uni_out         : out std_logic_vector(6 downto 0); -- Display 1 (HEX0): Dígito bajo del código en RAM
        seg_dec_out         : out std_logic_vector(6 downto 0); -- Display 2 (HEX1): Dígito alto del código en RAM
        seg_cen_out         : out std_logic_vector(6 downto 0); -- Display 3 (HEX2): Unidades del contador de eventos
        seg_mil_out         : out std_logic_vector(6 downto 0); -- Display 4 (HEX3): Decenas del contador de eventos
        
        -- Indicador visual LED
        alarma_out          : out std_logic                     -- LED indicador de detección activa / escritura en RAM
    );
end entity sistema_registro_top;

architecture arqui_sistema_top of sistema_registro_top is

    -- Señales internas de interconexión entre los módulos
    signal pulso_pir_s      : std_logic;
    signal reset_combinado  : std_logic;
    signal dir_rom_s        : std_logic_vector(ADDR_WIDTH - 1 downto 0);
    signal dir_ram_s        : std_logic_vector(ADDR_WIDTH - 1 downto 0);
    signal dato_rom_s       : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal dato_ram_s       : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal dato_leido_ram_s : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal wr_en_ram_s      : std_logic;
    
    -- Señales para separar unidades y decenas del conteo de movimientos (Displays 3 y 4)
    signal unidades_sig     : unsigned(3 downto 0);
    signal decenas_sig      : unsigned(3 downto 0);

begin

    -- Combina ambos reinicios para limpiar también el controlador PIR al pulsar el botón
    reset_combinado <= '1' when (reset_in = '1' or btn_reset_cuenta_in = '0') else '0';

    -- 1. Instanciación del Controlador PIR (500,000 ciclos = 10 ms a 50 MHz)
    INSTANCIA_CONTROLADOR_PIR : controlador_pir
        generic map (
            ANCHO_CONTEO => 500000
        )
        port map (
            reloj_in      => reloj_in,
            reset_in      => reset_combinado,
            sensor_pir_in => sensor_pir_in,
            pulso_out     => pulso_pir_s
        );

    -- 2. Instanciación de la Unidad de Control (FSM coordinadora con botón de reinicio)
    INSTANCIA_UNIDAD_CONTROL : unidad_control
        generic map (
            ADDR_WIDTH => ADDR_WIDTH,
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            reloj_in            => reloj_in,
            reset_in            => reset_in,
            pulso_deteccion_in  => pulso_pir_s,
            dato_rom_in         => dato_rom_s,
            btn_reset_cuenta_in => btn_reset_cuenta_in,
            dir_rom_out         => dir_rom_s,
            dir_ram_out         => dir_ram_s,
            wr_en_ram_out       => wr_en_ram_s,
            dato_ram_out        => dato_ram_s
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

    -- 4. Instanciación de la Memoria RAM (Registro dinámico conectado a los displays)
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
            dato_out     => dato_leido_ram_s
        );

    -- 5. Separación matemática del número de eventos en Unidades y Decenas para los Displays 3 y 4
    unidades_sig <= unsigned(dir_rom_s) mod 10;
    decenas_sig  <= (unsigned(dir_rom_s) / 10) mod 10;

    -- 6. Display 1 (seg_uni_out): Muestra los 4 bits bajos del dato almacenado en la RAM
    INSTANCIA_DECO_UNIDADES : hex_decoder
        port map (
            bin_in  => dato_leido_ram_s(3 downto 0),
            seg_out => seg_uni_out
        );

    -- 7. Display 2 (seg_dec_out): Muestra los 4 bits altos del dato almacenado en la RAM
    INSTANCIA_DECO_DECENAS : hex_decoder
        port map (
            bin_in  => dato_leido_ram_s(7 downto 4),
            seg_out => seg_dec_out
        );

    -- 8. Display 3 (seg_cen_out): Muestra las unidades del conteo de detecciones (0 a 9)
    INSTANCIA_DECO_CENTENAS : hex_decoder
        port map (
            bin_in  => std_logic_vector(unidades_sig),
            seg_out => seg_cen_out
        );

    -- 9. Display 4 (seg_mil_out): Muestra las decenas del conteo de detecciones (0 a 1)
    INSTANCIA_DECO_MILES : hex_decoder
        port map (
            bin_in  => std_logic_vector(decenas_sig),
            seg_out => seg_mil_out
        );

    -- Asignación de salida LED: se enciende mientras el sensor detecta movimiento o escribe en RAM
    alarma_out <= wr_en_ram_s or sensor_pir_in;

end architecture arqui_sistema_top;