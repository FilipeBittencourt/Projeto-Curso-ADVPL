#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪驴北
北矲uncao     �      MA020BUT �       Autor �        Luana Marin Ribeiro  		 � Data �           14/09/15 潮�
北媚哪哪哪哪呐哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北矰escri噮o � Ponto de entrada para cria玢o de bot鉶 na rotina cadastro de fornecedor no m骴ulo de compras. 潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
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

	AVISO("Usu醨io e data de altera玢o", "Usu醨io e data de altera玢o" + CRLF + CRLF + "Usu醨io: " + Replace(Replace(sUsuAltForn->USUARIO,"@",""),"#","") + CRLF + "Data: " + dtoc(stod(sUsuAltForn->DATAALT)), {"Ok"}, 1)
	
	sUsuAltForn->(dbCloseArea())        

Return()