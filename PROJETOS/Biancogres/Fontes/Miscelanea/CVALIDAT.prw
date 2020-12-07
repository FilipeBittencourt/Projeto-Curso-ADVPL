#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 16/05/02
#Include "topconn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ CVALIDAT ³ Autor ³ MICROSIGA Vitoria     ³ Data ³ 01.01.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Validacao do cadastro de preco                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RDMAKE                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

USER Function CVALIDAT()
LOCAL cRes := .T.
Local cSQL := ""
local sCont := 0

//If lAlterar
//	RETURN(cRes)
//End if
cSQL := "SELECT *  "
cSQL += "FROM " + RETSQLNAME("SZ2") 
cSQL += " WHERE 	Z2_FILIAL	= '"  + xFilial("SZ2")     + "' AND "   
cSQL += "		Z2_REFER 	= '"  + M->Z2_REFER            + "' AND  "

cSQL += "  ('" + dtos(M->Z2_DTINIPR)   + "' >= Z2_DTINIPR and  '" + dtos(M->Z2_DTINIPR)   + "' <= Z2_DTFIMPR  "
cSQL += "				 									or													"
cSQL += "	'" + dtos(M->Z2_DTINIPR)   + "'	 <= Z2_DTINIPR and  '" + dtos(M->Z2_DTFIMPR)   + "' >= Z2_DTINIPR  "
cSQL += "				   									or													"
cSQL += "	'" + dtos(M->Z2_DTFIMPR)   + "'	 >= Z2_DTINIPR and  '" + dtos(M->Z2_DTFIMPR)   + "' <= Z2_DTFIMPR)  "

cSQL += " And		D_E_L_E_T_ 	= '' "		

If chkfile("_Traba")
	dbSelectArea("_Traba")
	dbCloseArea()
End If
TCQUERY cSQL ALIAS "_Traba" NEW	


If lAlterar
	
	do while ! _Traba->(eof())
		sCont ++
		_Traba->(dbskip())
	end do
	If sCont = 1
		cRes := .T.  ; RETURN(cRes)	
	else
		cRes := .F.  
		msgbox("Registro já cadastrado","Aviso","INFO")	
		RETURN(cRes)
	end if
else
	IF !_Traba->(eof())
		cRes := .F.	
		msgbox("Registro já cadastrado","Aviso","INFO")
	END IF
end if


RETURN(cRes)