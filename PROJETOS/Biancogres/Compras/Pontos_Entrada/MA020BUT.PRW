#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂ¿±±
±±³Funcao     ³      MA020BUT ³       Autor ³        Luana Marin Ribeiro  		 ³ Data ³           14/09/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ponto de entrada para criação de botão na rotina cadastro de fornecedor no módulo de compras. ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function MA020BUT()

	Local aButtons := {}
    
    //If __cUserID="000996"            
		AAdd(aButtons,{"USUARIO", {|| fUsuarioAltFornecedor()  }, "Consulta Usuario Alt.","Usuario"})
	//EndIf

Return aButtons

Static Function fUsuarioAltFornecedor()
	sUsuAltForn := "SELECT dbo.USERLG(SA2.A2_USERLGA) USUARIO, "
	sUsuAltForn += "	dbo.DATALG(SA2.A2_USERLGA) DATAALT "
	sUsuAltForn += "FROM SA2010 SA2 "
	sUsuAltForn += "WHERE SA2.A2_COD='" + SA2->A2_COD + "' "
	sUsuAltForn += "ORDER BY DATAALT DESC "
	
	If chkfile("sUsuAltForn")
		DbSelectArea("sUsuAltForn")
		DbCloseArea()
	EndIf
	TcQuery sUsuAltForn New Alias "sUsuAltForn"
	
	DbSelectArea("sUsuAltForn")
	DbGoTop()

	AVISO("Usuário e data de alteração", "Usuário e data de alteração" + CRLF + CRLF + "Usuário: " + Replace(Replace(sUsuAltForn->USUARIO,"@",""),"#","") + CRLF + "Data: " + dtoc(stod(sUsuAltForn->DATAALT)), {"Ok"}, 1)
	
	sUsuAltForn->(dbCloseArea())        

Return()