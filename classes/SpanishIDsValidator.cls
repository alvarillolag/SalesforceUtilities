/**
*	Description: Class to validate spanish IDs, including NIFs (DNI and CIF) and NIE. Adapted to Apex from a JS version by @carlos-mg89
*	Author: alvarillolag
*	Original code (in Javascript): https://gist.github.com/carlos-mg89/4aaafa310c9e4b91f5fb890540f38cae
*/
public with sharing class SpanishIDsValidator {
    public static final String CORRESPONDENCIA = 'TRWAGMYFPDXBNJZSQVHLCKE';

    public static final String DNI_REGEX = '^(\\d{8})([A-Z])$';
    public static final String CIF_REGEX = '^([ABCDEFGHJKLMNPQRSUVW])(\\d{7})([0-9A-J])$';
    public static final String NIE_REGEX = '^[XYZ]\\d{7,8}[A-Z]$';

    public static String validateSpanishID(String id) {
        String result = '';
        id = id.toUpperCase().deleteWhitespace();

        Pattern p = Pattern.compile('\\d{8}');
        Matcher m = p.matcher(id);

        Boolean valid = false;
        String type = spainIdType(id);

        switch on type {

            when 'dni'{
                valid = validDNI(id);
            }

            when 'nie'{
                valid = validNIE(id);
            }

            when 'cif'{
                valid = validCIF(id);
            }
        }

        result = '{'+
            'type:'+ type + ','+
            'valid:'+ valid +
        '}';


        return result;
    }

    public static String spainIdType(String id) {
        String result;

        Pattern dniPattern = Pattern.compile(DNI_REGEX);
        Pattern niePattern = Pattern.compile(NIE_REGEX);
        Pattern cifPattern = Pattern.compile(CIF_REGEX);

        Matcher dniMatcher = dniPattern.matcher(id);
        Matcher nieMatcher = niePattern.matcher(id);
        Matcher cifMatcher = cifPattern.matcher(id);

        if (dniMatcher.matches()) {
            result = 'dni';
        }else if (nieMatcher.matches()) {
            result = 'nie';
        }else if (cifMatcher.matches()) {
            result = 'cif';
        }

        return result;
    }
    
    public static Boolean validDNI(String id) {
        String dni_letters = 'TRWAGMYFPDXBNJZSQVHLCKE';
        String idWithoutLetter = id.substring(0, 8);
        Integer dniNumbers = Integer.valueOf(idWithoutLetter);
        String letter = dni_letters.substring(Math.mod(dniNumbers, 23), Math.mod(dniNumbers, 23)+1);
    
        return letter == id.substring(8);
    }

    public static Boolean validNIE(String id) {
        // Change the initial letter for the corresponding number and validate as DNI
        String nie_prefix = id.substring(0,1);

        switch on nie_prefix {
            when 'X'{ 
                nie_prefix = '0';
            }

            when 'Y'{
                nie_prefix = '1';
            }

            when 'Z'{
                nie_prefix = '2';
            }
        }

        return validDNI(nie_prefix+id.substring(1));
    }

    public static Boolean validCIF(String id) {
        Boolean isValid = false;
        Pattern cifPattern = Pattern.compile(CIF_REGEX);
        Pattern abehPattern = Pattern.compile('[ABEH]');
        Pattern kpqsPattern = Pattern.compile('[KPQS]');

        Matcher cifMatcher = cifPattern.matcher(id);

        Boolean match = cifMatcher.matches();
        Boolean test = Pattern.matches(CIF_REGEX, id);

        if(match){
            String letter  = id.substring(0,1);
            String numero  = id.substring(1,8);
            String control = id.substring(8,9);

            Integer even_sum = 0;
            Integer odd_sum = 0;
            Integer n;

            for (Integer i = 0; i < numero.length(); i++) {
                n = Integer.valueOf(numero.substring(i, i+1));

                // Odd positions (Even index equals to odd position. i=0 equals first position)
                if (Math.mod(i, 2) == 0 ) {
                    // Odd positions are multiplied first.
                    n *= 2;

                    // If the multiplication is bigger than 10 we need to adjust
                    odd_sum += n < 10 ? n : n - 9;

                    // Even positions
                    // Just sum them
                } else {
                    even_sum += n;
                }

            }
            Integer sum = even_sum + odd_sum;
            String sumParsed = String.valueOf(sum);
            //Cogemos último caracter
            sumParsed = sumParsed.right(1);
            //var control_digit = (10 - (even_sum + odd_sum).toString().substr(-1)).toString().substr(-1) ;
            Integer resta = 10 - Integer.valueOf(sumParsed);
            String control_digit = String.valueOf(resta).right(1);
            //Integer control_digit = Math.mod((10 - Integer.valueOf(sumParsed)), 10);
            String control_letter = 'JABCDEFGHI'.substring(Integer.valueOf(control_digit), Integer.valueOf(control_digit)+1 );

            // Control must be a digit
            Matcher abehMatcher = abehPattern.matcher(letter);
            Matcher kpqsMatcher = kpqsPattern.matcher(letter);
            if(abehMatcher.matches()) {
                isValid = control == String.valueOf(control_digit);

            // Control must be a letter
            } else if (kpqsMatcher.matches()) {
                isValid = control == control_letter;

            // Can be either
            } else {
                isValid = control == String.valueOf(control_digit) || control == control_letter;
            }
        }
        
        return isValid;
    }
}