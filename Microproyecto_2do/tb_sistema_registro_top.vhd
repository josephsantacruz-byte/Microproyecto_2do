library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_sistema_registro_top is
    -- Los testbench no llevan puertos de entrada/salida
end entity tb_sistema_registro_top;

architecture simulacion of tb_sistema_registro_top is

    -- Declaración del componente que vamos a simular (Top-Level)
    component sistema_registro_top is
        port (
            reloj_in            : in  std_logic;
            reset_in            : in  std_logic;
            sensor_pir_in       : in  std_logic;
            btn_reset_cuenta_in : in  std_logic;
            seg_uni_out         : out std_logic_vector(6 downto 0);
            seg_dec_out         : out std_logic_vector(6 downto 0);
            seg_cen_out         : out std_logic_vector(6 downto 0);
            seg_mil_out         : out std_logic_vector(6 downto 0);
            alarma_out          : out std_logic
        );
    end component;

    -- Señales de estímulo para conectar al UUT (Unit Under Test)
    signal reloj_tb            : std_logic := '0';
    signal reset_tb            : std_logic := '0';
    signal sensor_pir_tb       : std_logic := '0';
    signal btn_reset_cuenta_tb : std_logic := '1';

    -- Señales de observación (Salidas del sistema)
    signal seg_uni_tb          : std_logic_vector(6 downto 0);
    signal seg_dec_tb          : std_logic_vector(6 downto 0);
    signal seg_cen_tb          : std_logic_vector(6 downto 0);
    signal seg_mil_tb          : std_logic_vector(6 downto 0);
    signal alarma_tb           : std_logic;

    -- Constante para el periodo del reloj de 50 MHz (T = 20 ns)
    constant CLK_PERIOD : time := 20 ns;

begin

    -- Instanciación de la entidad principal (Top-Level)
    uut: sistema_registro_top
        port map (
            reloj_in            => reloj_tb,
            reset_in            => reset_tb,
            sensor_pir_in       => sensor_pir_tb,
            btn_reset_cuenta_in => btn_reset_cuenta_tb,
            seg_uni_out         => seg_uni_tb,
            seg_dec_out         => seg_dec_tb,
            seg_cen_out         => seg_cen_tb,
            seg_mil_out         => seg_mil_tb,
            alarma_out          => alarma_tb
        );

    -- Generador de Reloj principal de 50 MHz
    p_reloj : process
    begin
        reloj_tb <= '0';
        wait for CLK_PERIOD / 2;
        reloj_tb <= '1';
        wait for CLK_PERIOD / 2;
    end process p_reloj;

    -- Proceso de Estímulos y Pruebas
    p_estimulos : process
    begin
        -- 1. Inicialización y Reset general del sistema
        reset_tb <= '1';
        btn_reset_cuenta_tb <= '1';
        sensor_pir_tb <= '0';
        wait for 100 ns;
        
        reset_tb <= '0'; -- Liberamos el reset general
        wait for 200 ns;

        -- 2. Primera detección de movimiento (Pulso de 15 ms para superar el filtro de 10 ms)
        sensor_pir_tb <= '1';
        wait for 15 ms; 
        sensor_pir_tb <= '0';
        wait for 5 ms; -- Espera entre detecciones

        -- 3. Segunda detección de movimiento
        sensor_pir_tb <= '1';
        wait for 15 ms;
        sensor_pir_tb <= '0';
        wait for 5 ms;

        -- 4. Tercera detección de movimiento
        sensor_pir_tb <= '1';
        wait for 15 ms;
        sensor_pir_tb <= '0';
        wait for 5 ms;

        -- 5. Prueba del botón físico de reinicio de cuenta (activo en bajo '0')
        btn_reset_cuenta_tb <= '0';
        wait for 100 ns;
        btn_reset_cuenta_tb <= '1';
        wait for 5 ms;

        -- 6. Cuarta detección después del reinicio (debe iniciar de nuevo en la posición 0)
        sensor_pir_tb <= '1';
        wait for 15 ms;
        sensor_pir_tb <= '0';
        
        -- Fin de la simulación
        wait;
    end process p_estimulos;

end architecture simulacion;