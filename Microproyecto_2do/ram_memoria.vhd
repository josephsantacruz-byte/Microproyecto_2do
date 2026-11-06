library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pkg_system.all;

entity ram_memoria is
    generic (
        DATA_WIDTH : positive := DATA_WIDTH;
        ADDR_WIDTH : positive := ADDR_WIDTH
    );
    port (
        reloj_in     : in  std_logic;                                    -- Reloj principal del sistema
        wr_en_in     : in  std_logic;                                    -- Habilitador de escritura ('1' para guardar el dato)
        direccion_in : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);    -- Dirección de memoria para leer o escribir
        dato_in      : in  std_logic_vector(DATA_WIDTH - 1 downto 0);    -- Dato entrante que se va a registrar
        dato_out     : out std_logic_vector(DATA_WIDTH - 1 downto 0)     -- Dato almacenado leído desde la RAM
    );
end entity ram_memoria;

architecture arqui_ram_memoria of ram_memoria is

    -- Definición del tipo de matriz para la memoria RAM
    type tipo_memoria_ram is array (0 to 2**ADDR_WIDTH - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);
    
    -- Instanciación de la memoria interna inicializada en ceros
    signal memoria_ram : tipo_memoria_ram := (others => (others => '0'));

    -- Señales internas de control y direccionamiento
    signal indice_direccion : integer range 0 to 2**ADDR_WIDTH - 1;
    signal registro_salida  : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');

    -- Directiva para obligar a Quartus a inferir bloques de memoria física M9K
    attribute ramstyle : string;
    attribute ramstyle of memoria_ram : signal is "M9K";

begin

    -- Convierte la dirección binaria a un número entero para operar en la matriz
    indice_direccion <= to_integer(unsigned(direccion_in));

    -- Proceso síncrono para las operaciones de escritura y lectura en la RAM
    PROCESO_RAM : process(reloj_in)
    begin
        if rising_edge(reloj_in) then
            -- Si la señal de escritura está activa, guarda el dato en la dirección actual
            if wr_en_in = '1' then
                memoria_ram(indice_direccion) <= dato_in;
            end if;
            
            -- Lectura síncrona permanente de la posición direccionada
            registro_salida <= memoria_ram(indice_direccion);
        end if;
    end process PROCESO_RAM;

    -- Asigna el registro interno al puerto de salida de datos
    dato_out <= registro_salida;

end architecture arqui_ram_memoria;