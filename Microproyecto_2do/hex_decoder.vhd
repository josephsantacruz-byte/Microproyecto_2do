library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hex_decoder is
    port (
        bin_in  : in  std_logic_vector(6 downto 0); -- Entrada binaria (hasta 7 bits)
        seg_dec : out std_logic_vector(6 downto 0); -- Salida para el display de decenas (MSB)
        seg_uni : out std_logic_vector(6 downto 0)  -- Salida para el display de unidades (LSB)
    );
end entity hex_decoder;

architecture arqui_hex_decoder of hex_decoder is

    -- Función de conversión de un valor numérico (0 a 15) a código de 7 segmentos (Ánodo Común / Active-Low)
    function conv_7seg (val : integer range 0 to 15) return std_logic_vector is
    begin
        case val is
            when 0  => return "1000000"; -- '0'
            when 1  => return "1111001"; -- '1'
            when 2  => return "0100100"; -- '2'
            when 3  => return "0110000"; -- '3'
            when 4  => return "0011001"; -- '4'
            when 5  => return "0010010"; -- '5'
            when 6  => return "0000010"; -- '6'
            when 7  => return "1111000"; -- '7'
            when 8  => return "0000000"; -- '8'
            when 9  => return "0010000"; -- '9'
            when 10 => return "0001000"; -- 'A'
            when 11 => return "0000011"; -- 'b'
            when 12 => return "1000110"; -- 'C'
            when 13 => return "0100001"; -- 'd'
            when 14 => return "0000110"; -- 'E'
            when others => return "0001110"; -- 'F'
        end case;
    end function;

    signal valor_entero : integer range 0 to 127;
    signal digito_dec   : integer range 0 to 9;
    signal digito_uni   : integer range 0 to 9;

begin

    -- Conversión de vector lógico a entero
    valor_entero <= to_integer(unsigned(bin_in));
    
    -- Extracción matemática de decenas y unidades (Operador de asignación corregido :=)
    digito_dec   <= (valor_entero / 10) mod 10;
    digito_uni   <= valor_entero mod 10;

    -- Asignación de los patrones decodificados a los displays físicos
    seg_dec      <= conv_7seg(digito_dec);
    seg_uni      <= conv_7seg(digito_uni);

end architecture arqui_hex_decoder;