library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Importación del paquete del sistema
use work.pkg_system.all;

entity tb_sistema_registro_top is
end entity tb_sistema_registro_top;

architecture arqui_tb_sistema_registro_top of tb_sistema_registro_top is

    -- Señales de estímulo y monitoreo para la entidad Top
    signal reloj_tb      : std_logic := '0';
    signal reset_tb      : std_logic := '1';
    signal sensor_pir_tb : std_logic := '0';
    signal seg_uni_tb    : std_logic_vector(6 downto 0);
    signal seg_dec_tb    : std_logic_vector(6 downto 0);
    signal alarma_out_tb : std_logic;

    -- Periodo del reloj principal (50 MHz -> 20 ns)
    constant PERIODO_RELOJ : time := 20 ns;

begin

    -- Instanciación del Sistema Top (Unit Under Test)
    UUT : entity work.sistema_registro_top
        port map (
            reloj_in      => reloj_tb,
            reset_in      => reset_tb,
            sensor_pir_in => sensor_pir_tb,
            seg_uni_out   => seg_uni_tb,
            seg_dec_out   => seg_dec_tb,
            alarma_out    => alarma_out_tb
        );

    -- Generador de reloj continuo de 50 MHz
    PROCESO_RELOJ : process
    begin
        reloj_tb <= '0';
        wait for PERIODO_RELOJ / 2;
        reloj_tb <= '1';
        wait for PERIODO_RELOJ / 2;
    end process PROCESO_RELOJ;

    -- Proceso de estímulos: Ruido, rebotes y detecciones válidas
    PROCESO_ESTIMULOS : process
    begin
        -- Inicialización y aplicación de Reset general
        reset_tb      <= '1';
        sensor_pir_tb <= '0';
        wait for 60 ns;

        -- Liberar el reset
        reset_tb <= '0';
        wait for 80 ns;

        -- Simulación de ruido y rebotes rápidos (el filtro PIR debe ignorarlos)
        sensor_pir_tb <= '1'; wait for 30 ns;
        sensor_pir_tb <= '0'; wait for 40 ns;
        sensor_pir_tb <= '1'; wait for 20 ns;
        sensor_pir_tb <= '0'; wait for 60 ns;
        sensor_pir_tb <= '1'; wait for 15 ns;
        sensor_pir_tb <= '0';
        wait for 300 ns;

        -- Primera detección válida de presencia
        sensor_pir_tb <= '1';
        wait for 1.5 us;
        sensor_pir_tb <= '0';
        wait for 400 ns;

        -- Segunda detección válida: Incrementa la dirección RAM y actualiza los displays
        sensor_pir_tb <= '1';
        wait for 1.5 us;
        sensor_pir_tb <= '0';
        wait for 400 ns;

        -- Tercera detección válida de presencia
        sensor_pir_tb <= '1';
        wait for 1.5 us;
        sensor_pir_tb <= '0';
        wait for 400 ns;

        -- Fin de la simulación
        wait;
    end process PROCESO_ESTIMULOS;

end architecture arqui_tb_sistema_registro_top;