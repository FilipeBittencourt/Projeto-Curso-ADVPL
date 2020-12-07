#include "protheus.ch"
#include "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³C5PENGF3  ³ Autor ³ Fernando Rocha        ³ Data ³ 05.09.16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³Proposta Comercial de Engenharia - Pesquisa proposta do Cli.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³BIANCOGRES                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function C5PENGF3()

	Local aArea   		:= GetArea()
    Local cTitulo		:= "Propostas do Cliente"
	Local cQuery		:= "" 								//obrigatorio
	Local cAlias		:= "Z68"							//obrigatorio
	Local cCpoChave		:= "Z68_NUM"	 					//obrigatorio
	Local cTitCampo		:= "Numero/Revisão"					//obrigatorio
	Local cMascara		:= "@!"								//obrigatorio
	Local nTamCpo		:= 8		
	Local cRetCpo		:= "uCRet1"							//obrigatorio
	Local nColuna		:= 1
	Local cCodigo		:= &(ReadVar())						//pego o conteudo e levo para minha consulta padrão			
 	Local I
 	Local cPedIn		:= ""
 	Local cTabPr		:= ""
 	
 	Private bRet 		:= .F. 	
 	Public uCRet1		:= ""
 	
 	If (M->C5_YLINHA == "1")
 		cTabPr := "Z68010"
 	Else
 		cTabPr := "Z68050"
 	EndIf 	
 	
 	//Propostas Aprovadas do Cliente selecionado no Pedido
   	cQuery := " SELECT Z68_NUM = Z68_NUM+Z68_REV , Z68_EMISSA "
	cQuery += " FROM "+cTabPr+" AS Z68 WITH (NOLOCK) "
	cQuery += " WHERE Z68_FILIAL  = '" + xFilial("Z68") + "' "
	cQuery += " AND Z68_CLICAD = 'S' "
	cQuery += " AND Z68_STATUS = '2' "
	cQuery += " AND Z68_CODCLI = '"+M->C5_CLIENTE+"' "
	cQuery += " AND Z68_LOJCLI = '"+M->C5_LOJACLI+"' "
	cQuery += " AND Z68_DTVALI >= '"+DTOS(dDataBase)+"' "
	cQuery += " AND Z68.D_E_L_E_T_= ' ' "
	cQuery += " ORDER BY Z68_NUM "
	
 	bRet := U_FiltroF3(cTitulo,cQuery,nTamCpo,cAlias,cCodigo,cCpoChave,cTitCampo,cMascara,cRetCpo,nColuna)
 	
RestArea( aArea )
Return .T.