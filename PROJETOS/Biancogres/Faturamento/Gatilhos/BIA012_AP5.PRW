#include "rwmake.ch"
#include "TOPCONN.ch"
User Function Bia012()

	Local xxn 

	SetPrvt("WALIAS,WPRTAB,WPRSC6,WTES,WPRECO,LFUNCAO")
	SetPrvt("WUSUARIO,XXN,XCCAMPO,")

	/*/
	北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
	北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
	北矲un噮o    � BIA012     � Autor � MICROSIGA VITORIA     � Data � 12/05/99 潮�
	北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
	北矰escri噭o � Determina se o usuario podera alterar o Preco de Venda SC6   潮�
	北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
	北� Uso      � Interpretador x Base                                         潮�
	北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
	北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
	哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
	/*/
	CSQL := "SELECT B1_GRUPO FROM "+RETSQLNAME("SB1")+" WHERE B1_COD = '"+aCols[n, AScan(aHeader, { |x| Alltrim(x[2]) == 'C6_PRODUTO'}) ]+"' AND D_E_L_E_T_ = '' "
	If chkfile("_cTrab")
		dbSelectArea("_cTrab")
		dbCloseArea()
	EndIf
	TCQUERY CSQL ALIAS "_cTrab" NEW

	IF _cTrab->(EOF())
		RETURN(0)
	ELSEIF ALLTRIM(_cTrab->B1_GRUPO) <> "PA"
		RETURN( ROUND(aCols[n, AScan(aHeader, { |x| Alltrim(x[2]) == 'C6_QTDVEN'}) ]  *  aCols[n, AScan(aHeader, { |x| Alltrim(x[2]) == 'C6_PRCVEN'}) ] ,2)     )   
	END IF

	wAlias   := Alias()
	wPrtab   := execblock("BIA005",.F.,.F.)

	wPrSC6   := aCols[n, AScan(aHeader, { |x| Alltrim(x[2]) == 'C6_PRCVEN'})   ]

	wTes     := " "
	wPreco   := 0
	lFuncao  := " "
	wUsuario := alltrim(upper(cUserName))

	For xxn := 1 to Len(aHeader)
		xcCampo := Trim(aHeader[xxn][2])
		If xcCampo == "C6_TES"
			wTes     := aCols[n][xxn]
		Endif
	Next

	Do Case
		Case wUsuario == "ADMINISTRADOR"
		lFuncao := "D"
		Case wUsuario == "CAMERINO"
		lFuncao := "D"
		Case wUsuario == "FERNANDA"
		lFuncao := "D"
		Case wUsuario == "ANA"
		lFuncao := "D"
		Case wUsuario == "LUISMAR"
		lFuncao := "D"       
		Case wUsuario == "ANDREA"
		lFuncao := "D"       
		Case wUsuario == "MATEUS"
		lFuncao := "D"       
		Case wUsuario == "GERALDO"
		lFuncao := "D"   		
		Case wUsuario == "MARIO"
		lFuncao := "D"   		
		Case wUsuario == "CLAUDEIR FADINI"
		lFuncao := "D"   		
		Otherwise
		lFuncao := "O"
	EndCase

	If lFuncao == "G"
		If wPrSC6 < wPrTab
			msgBox("Atencao. Usuario nao autorizado a alterar preco de Venda","Usuario nao autorizado","ALERT")
			wPreco := wPrTab
		Else
			wPreco := wPrSC6
		EndIf
	EndIf

	If lFuncao == "D"
		wPreco := wPrSC6
	EndIf

	If lFuncao == "F"
		If wPrSC6 <  wPrTab
			msgBox("Atencao. Usuario nao autorizado a alterar preco de Venda","Usuario nao autorizado","ALERT")
			wPreco := wPrTab
		Else
			wPreco := wPrSC6
		Endif
	EndIf

	If lFuncao == "O"
		wPreco := 0
		msgBox("Atencao. Usuario nao autorizado a alterar preco de Venda","Usuario nao autorizado","ALERT")
	EndIf

	aCols[n, AScan(aHeader, { |x| Alltrim(x[2]) == 'C6_PRCVEN'}) ]  = wPreco

RETURN( ROUND(aCols[n, AScan(aHeader, { |x| Alltrim(x[2]) == 'C6_QTDVEN'}) ]  *  aCols[n, AScan(aHeader, { |x| Alltrim(x[2]) == 'C6_PRCVEN'}) ] ,2)     )   

//RETURN(wPreco)   