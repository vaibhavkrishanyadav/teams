/// Define App ID and Token
const APP_ID = '01eab1e053944f3bb50a39eaf4c43013';
const Token = '00601eab1e053944f3bb50a39eaf4c43013IADgPHEsyKRA9g3HkPzScB5X4qBpLL1Hofaw62+g0xD2S1u/UFYAAAAAEAAm+nFWZ1TUYAEAAQBmVNRg';

class Utils {

  static String getInitials(String name) {
    List<String> nameSplit = name.split(" ");
    String firstNameInitial = nameSplit[0][0];
    String lastNameInitial = nameSplit[1][0];
    return firstNameInitial + lastNameInitial;
  }

}