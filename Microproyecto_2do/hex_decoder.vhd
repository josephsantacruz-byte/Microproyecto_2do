library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hex_decoder is
    port (
        bin_in  : in  std_logic_vector(3 downto 0); -- Entrada en binario de 4 bits (unidades o decenas)
        seg_out : out std_logic_vector(6 downto 0)  -- Salida de 7 segmentos (orden: g-f-e-d-c-b-a)
    );
end entity hex_decoder;

architecture arqui_hex_decoder of hex_decoder is
begin

    -- Proceso combinacional para decodificar el número binario a 7 segmentos
    -- Nota: Asume lógica activa en bajo ('0' enciende el segmento, típico de ánodo común).
    -- Mapeo de bits de salida (seg_out): 
    -- 6: g | 5: f | 4: e | 3: d | 2: c | 1: b | 0: a
    process(bin_in)
    begin
        case bin_in is
            when "0000" => seg_out <= "1000000"; -- Dígito 0 (ciertos segmentos encendidos, g apagado)
            when "0001" => seg_out <= "1111001"; -- Dígito 1
            when "0010" => seg_out <= "0100100"; -- Dígito 2
            when "0011" => seg_out <= "0110000"; -- Dígito 3
            when "0100" => seg_out <= "0011001"; -- Dígito 4
            when "0101" => seg_out <= "0010010"; -- Dígito 5
            when "0110" => seg_out <= "0000010"; -- Dígito 6
            when "0111" => seg_out <= "1111000"; -- Dígito 7
            when "1000" => seg_out <= "0000000"; -- Dígito 8
            when "1001" => seg_out <= "0010000"; -- Dígito 9
            when others => seg_out <= "1111111"; -- Apagado por seguridad en caso de valores no válidos
        end case;
    end process;

end architecture arqui_hex_decoder;