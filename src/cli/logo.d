/++
 [cli.logo] is a helper for outputing logo on terminal

 + Authors: ACoderOrHacker
 + License: Apache-2.0 License
 + Copyright: Copyright (C) 2025, ACoderOrHacker
 +/

module cli.logo;
@safe:
export:

import termcolor.gradient;

/++
 + The logo that outputs on the terminal
 +/
enum logoString = r"              
                    ,---,               ___     
                  ,--.' |      ,--,   ,--.'|_   
                  |  |  :    ,--.'|   |  | :,'  
         .--.--.  :  :  :    |  |,    :  : ' :  
        /  /    ' :  |  |,--.`--'_  .;__,'  /   
       |  :  /`./ |  :  '   |,' ,'| |  |   |    
       |  :  ;_   |  |   /' :'  | | :__,'| :    
        \  \    `.'  :  | | ||  | :   '  : |__  
         `----.   \  |  ' | :'  : |__ |  | '.'| 
        /  /`--'  /  :  :_:,'|  | '.'|;  :    ; 
       '--'.     /|  | ,'    ;  :    ;|  ,   /  
         `--'---' `--''      |  ,   /  ---`-'   
                              ---`-'            


";

/++
 + Output the logo by gradient mode
 +/
void outputLogo()
{
    lolcat(logoString);
}