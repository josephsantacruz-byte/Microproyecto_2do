library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- El testbench no tiene puertos de entrada/salida físicos
entity tb_sistema_registro_top is
end entity tb_sistema_registro_top;

architecture arqui_tb of tb_sistema_registro_top is

    -- Declaración del componente Top que vamos a simular
    component sistema_registro_top is
        port (
            reloj_in            : in  std_logic;
            reset_in            : in  std_logic;
            sensor_pir_in       : in  std_logic;
            btn_reset_cuenta_in : in  std_logic;
            seg_uni_out         : out std_logic_vector(6 downto 0);
            seg_dec_out         : out std_logic_vector(6 downto 0);
            alarma_out          : out std_logic
        );
    end component;

    -- Señales de estímulo y monitoreo
    signal reloj_tb            : std_logic := '0';
    signal reset_tb            : std_logic := '1';
    signal sensor_pir_tb       : std_logic := '0';
    signal btn_reset_cuenta_tb : std_logic := '1'; -- Activo en bajo ('1' en reposo)
    
    signal seg_uni_tb          : std_logic_vector(6 downto 0);
    signal seg_dec_tb          : std_logic_vector(6 downto 0);
    signal alarma_tb           : std_logic;

    -- Definición del periodo de reloj (50 MHz -> periodo de 20 ns)
    constant CLK_PERIOD : time := 20 ns;

begin

    -- Instanciación del módulo principal (UUT - Unit Under Test)
    UUT : sistema_registro_top
        port map (
            reloj_in            => reloj_tb,
            reset_in            => reset_tb,
            sensor_pir_in       => sensor_pir_tb,
            btn_reset_cuenta_in => btn_reset_cuenta_tb,
            seg_uni_out         => seg_uni_tb,  -- CORREGIDO: se usa =>
            seg_dec_out         => seg_dec_tb,
            alarma_out          => alarma_tb
        );

    -- Generador de Reloj Principal
    PROCESO_RELOJ : process
    begin
        reloj_tb <= '0';
        wait for CLK_PERIOD / 2;
        reloj_tb <= '1';
        wait for CLK_PERIOD / 2;
    end process PROCESO_RELOJ;

    -- Proceso de Estímulos (Secuencia de prueba)
    PROCESO_ESTIMULOS : process
    begin
        -- 1. Estado inicial: Aplicar reset general por 100 ns
        reset_tb <= '1';
        sensor_pir_tb <= '0';
        btn_reset_cuenta_tb <= '1';
        wait for 100 ns;
        
        -- Liberar el reset general
        reset_tb <= '0';
        wait for 50 ns;

        -- 2. Simular primer evento de movimiento (Pulso en el sensor PIR)
        sensor_pir_tb <= '1';
        wait for 500 ns;
        sensor_pir_tb <= '0';
        wait for 1 us;

        -- 3. Simular segundo evento de movimiento
        sensor_pir_tb <= '1';
        wait for 500 ns;
        sensor_pir_tb <= '0';
        wait for 1 us;

        -- 4. Simular tercer evento de movimiento
        sensor_pir_tb <= '1';
        wait for 500 ns;
        sensor_pir_tb <= '0';
        wait for 1 us;

        -- 5. Probar el botón de reinicio de cuenta (Activo en bajo '0')
        btn_reset_cuenta_tb <= '0';
        wait for 200 ns;
        btn_reset_cuenta_tb <= '1';
        wait for 500 ns;

        -- 6. Simular un nuevo evento post-reinicio
        sensor_pir_tb <= '1';
        wait for 500 ns;
        sensor_pir_tb <= '0';
        wait for 1 us;

        -- Fin de la simulación
        wait;
    end process PROCESO_ESTIMULOS;

end architecture arqui_tb;