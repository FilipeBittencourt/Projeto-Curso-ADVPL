#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH" 
#INCLUDE "TBICONN.CH"
#INCLUDE "FONT.CH"
#INCLUDE "MSOBJECT.CH" 
#include "TOTVS.CH"

//__________________________________________________________________________________________________
//                                                                      							|
// Prgrama   : TECFAT03                                               								|                        
//                                                                                                  | 
// Data      : 20/09/16                                                                     		| 
//__________________________________________________________________________________________________| 
//                                                                                                 	| 
// Descrição : Interface que permite determinar o Banco a ser utilizado na geração dos Boletos		| 
//__________________________________________________________________________________________________| 

User Function TECFAT03()  

	Local   oDlgBanco := Nil 
	Local   oGrpFil   := Nil 
	Local   oGrpAcao  := Nil
  	  
	Local   aFinan 	  := {}	
	Private oBanco    := Nil
	Private cBanco    := Space(TAMSX3("A6_COD")[1]) 
	
	Private oAgencia  := Nil
	Private cAgencia  := Space(TAMSX3("A6_AGENCIA")[1]) 
	
	Private oConta    := Nil
	Private cConta    := Space(TAMSX3("A6_NUMCON")[1])  
 
	
 	Private  oBTNOK    := Nil
  	Private  oBTNCAN   := Nil 
  	
	DEFINE MSDIALOG oDlgBanco TITLE "Dados Bancários" STYLE DS_MODALFRAME FROM 000,000 TO 300,195 PIXEL      

		oGrpFil  := TGroup():New( 001, 005, 100, 095, 'Filtro',  oDlgBanco,,, .T.) 
		oGrpAcao := TGroup():New( 105, 005, 134, 095, 'Acão'  ,  oDlgBanco,,, .T.) 
                                              
        @ 015, 010  SAY   "Banco"  SIZE 040,009  OF  oDlgBanco PIXEL 
        @ 024, 010  MSGET oBanco   VAR  cBanco   F3  "SA6"     Picture  "@!" When .T. SIZE  030,009  VALID VldBanco(cBanco) OF oDlgBanco PIXEL HASBUTTON    
        
        //_________________________________________________________________________________________________________ 
        //                                                                                                         | 
        // Atualiza os campos Agencia e Conta                                                                      |
        //_________________________________________________________________________________________________________|
                                          
        //oBanco:bLostFocus := bValid
        
	    @ 042, 010  SAY   "Agência"  SIZE 040,009   OF oDlgBanco PIXEL 
        @ 051, 010  MSGET oAgencia   VAR  cAgencia  Picture "@!" When .F. SIZE 030,009  OF oDlgBanco PIXEL HASBUTTON 
        
        @ 069, 010  SAY   "Conta"    SIZE 040,009   OF oDlgBanco PIXEL 
        @ 078, 010  MSGET oConta     VAR  cConta  Picture "@!"   When .F. SIZE 080,009  OF oDlgBanco PIXEL HASBUTTON 
     
	  	@ 114, 010 BUTTON oBTNOK PROMPT  "OK" SIZE 037,015  ACTION  (aAdd(aFinan,{cBanco,cAgencia,cConta}), oDlgBanco:End())  OF oDlgBanco PIXEL
	  		  
	  	@ 114, 052 BUTTON oBTNCAN PROMPT "FECHAR"   SIZE 037,015 ACTION (aFinan := {} ,oDlgBanco:End()) OF oDlgBanco PIXEL
	  	
	  	oBtnOK:Disable() 
	  	
    ACTIVATE MSDIALOG oDlgBanco CENTERED 

Return( aFinan)     


//__________________________________________________________________________________________________
//                                                                      							|
// Prgrama   : VldBanco                                               								|                        
//                                                                                                  | 
// Data      : 20/09/16                                                                     		| 
//__________________________________________________________________________________________________| 
//                                                                                                 	| 
// Descrição : Valida a inlcusão do Banco															| 
//__________________________________________________________________________________________________| 
Static Function VldBanco(cBanco) 

	Local lRet := .T.
                              
    If !Empty(cBanco)
    	 
    	 If ExistCpo("SA6", cBanco)
    		 
    		 cAgencia 		:= SA6->A6_AGENCIA 
			 cConta    		:= SA6->A6_NUMCON
			 oBtnOK:lActive := .T.
    	 Else
    		 cAgencia 		:= ""
			 cConta   		:= ""
    		 lRet	  		:= .F.      
    		 
    		 oBtnOK:lActive := .F.
    	 Endif 
    
    Else
    	 cAgencia 		:= ""
		 cConta   		:= ""
    	 lRet	  		:= .F.      
    		 
    	 oBtnOK:lActive := .F.
    Endif                         
    
	
	oAgencia:Refresh()
	oConta:Refresh()
	
Return  lRet