#include "rwmake.ch"
#include "tbiconn.ch"
#include "topconn.ch"

/*/{Protheus.doc} BIA902
@author Ranisses A. Corona
@since 26.01.04
@version 1.0
@description Cadastro de Pre Requisicao 
@type function
/*/

User Function BIA902()

	Local _cHrBloq		:= GetNewPar("FA_RQCHRB","12:00")  //Horario de bloqueio de baixas no ultimo dia do mes
	Local i 

	SetPrvt("DTFECH,WOPCAO,LVISUALIZAR,LINCLUIR,LIMPRIMIR,LALTERAR,LBAIXAR,LEXCLUIR,NOPCE")
	SetPrvt("NOPCG,COPCAO,NUSADO,AHEADER,ACOLS,I")
	SetPrvt("CTITULO,CALIASENCHOICE,CALIASGETD,CLINOK,CTUDOK,CFIELDOK")
	SetPrvt("ACPOENCHOICE,LRET,WP_COD,WP_DESCRI,WP_UM,WP_QUANT,WP_VLRTOT,WP_APLIC,WP_CLVL,WP_TAG,_ACAMPOS")
	SetPrvt("_CTRAB,LSZJ,LSZI,")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Determina funcao selecionada                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	wOpcao      := paramixb
	lVisualizar := .F.
	lIncluir    := .F.
	lImprimir   := .F.
	lBaixar     := .F.
	lExcluir    := .F.

	Do Case
		Case wOpcao == "V" ; lVisualizar := .T. ; nOpcE := 2 ; nOpcG := 2 ; cOpcao := "VISUALIZAR"
		Case wOpcao == "I" ; lIncluir    := .T. ; nOpcE := 3 ; nOpcG := 3 ; cOpcao := "INCLUIR"
		Case wOpcao == "L" ; lImprimir   := .T. ; nOpcE := 2 ; nOpcG := 2 ; cOpcao := "IMPRIMIR"
		Case wOpcao == "B" ; lBaixar     := .T. ; nOpcE := 2 ; nOpcG := 2 ; cOpcao := "BAIXAR"
		Case wOpcao == "E" ; lExcluir    := .T. ; nOpcE := 2 ; nOpcG := 2 ; cOpcao := "EXCLUIR"
	EndCase

	If lIncluir
		If dtos(dDataBase) > "20190916" .or. ( dtos(dDataBase) == "20190916" .and. Substr(Time(), 1, 4) >= "12:00" )
			MsgSTOP("A partir de 16/09/19 a opçao de < Incluir > Pré-requisição pelo Protheus foi descontinuada. Favor utilizar a rotina do BIZAGI!!!")
			Return
		EndIf
	EndIf

	//VALIDAR NAO PERMITIR BAIXAR APOS AS 12:00 HORAS DO ULTIMO DIA DO MES
	If lBaixar .And. dDataBase == UltimoDU(dDataBase) .And. SubStr(Time(),1,5) > AllTrim(_cHrBloq)

		//  Identificado em 01/09/15 durante fechamento do mês de agosto de 2015 que esta regra somente poderia ser executada
		// para transferências. As requisições e devoluções normais deveriam continuar permitindo baixar. Por Marcos Alberto
		// solicitado por Beirão, Jean e Jecimar.
		RT007 := " SELECT COUNT(*) CONTAD "
		RT007 += "   FROM " + RetSqlName("SZJ") + ""
		RT007 += "  WHERE ZJ_FILIAL = '"+xFilial("SZJ")+"' "
		RT007 += "    AND ZJ_DOC = '"+SZI->ZI_DOC+"' "
		RT007 += "    AND ZJ_EMPRESA <> ZJ_EMPDEST "
		RT007 += "    AND D_E_L_E_T_ = ' ' "
		RTIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,RT007),'RT07',.T.,.T.)
		dbSelectArea("RT07")
		dbGoTop()
		xxContaBx := RT07->CONTAD
		RT07->(dbCloseArea())
		Ferase(RTIndex+GetDBExtension())     //arquivo de trabalho
		Ferase(RTIndex+OrdBagExt())          //indice gerado

		If xxContaBx > 0
			msgBox("Não é possível baixar pre-requisição no ultimo dia do mês após as "+AllTrim(_cHrBloq)+"hs. Bloqueio solicitado pela controladoria em virtude do fechamento das notas intragrupo.","Pre Requisicao","ALERT")
			Return
		EndIf

	EndIf

	RegToMemory("SZI",(cOpcao=="INCLUIR"))

	dbSelectArea("SX3")
	dbSetOrder(2)
	nUsado  := 0
	aHeader := {}
	dbSeek("ZJ_COD    ") ; nUsado:=nUsado+1 ; aadd(aHeader,{trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"AllwaysTrue()",SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT,SX3->X3_NIVEL})
	dbSeek("ZJ_LOCAL  ") ; nUsado:=nUsado+1 ; aadd(aHeader,{trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"AllwaysTrue()",SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT,SX3->X3_NIVEL})
	dbSeek("ZJ_DESCRI ") ; nUsado:=nUsado+1 ; aadd(aHeader,{trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"AllwaysTrue()",SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT,SX3->X3_NIVEL})
	dbSeek("ZJ_UM     ") ; nUsado:=nUsado+1 ; aadd(aHeader,{trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"AllwaysTrue()",SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT,SX3->X3_NIVEL})
	dbSeek("ZJ_QUANT  ") ; nUsado:=nUsado+1 ; aadd(aHeader,{trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"U_B902VQTD()",SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT,SX3->X3_NIVEL})
	dbSeek("ZJ_QTAPROV") ; nUsado:=nUsado+1 ; aadd(aHeader,{trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"AllwaysTrue()",SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT,SX3->X3_NIVEL})
	dbSeek("ZJ_VLRTOT ") ; nUsado:=nUsado+1 ; aadd(aHeader,{trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"AllwaysTrue()",SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT,SX3->X3_NIVEL})
	dbSeek("ZJ_APLIC  ") ; nUsado:=nUsado+1 ; aadd(aHeader,{trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"AllwaysTrue()",SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT,SX3->X3_NIVEL})
	dbSeek("ZJ_TAG    ") ; nUsado:=nUsado+1 ; aadd(aHeader,{trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"U_B902VTAG()",SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT,SX3->X3_NIVEL})
	dbSeek("ZJ_DOCTRAN") ; nUsado:=nUsado+1 ; aadd(aHeader,{trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"AllwaysTrue()",SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT,SX3->X3_NIVEL})
	dbSeek("ZJ_BAIXA  ") ; nUsado:=nUsado+1 ; aadd(aHeader,{trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"AllwaysTrue()",SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT,SX3->X3_NIVEL})

	//Fernando/Facile em 17/12/2015 - criado o campo classe de valor no item da requesicao
	If ( SZJ->(FieldPos("ZJ_CLVL")) > 0 )
		dbSeek("ZJ_CLVL   ") ; nUsado:=nUsado+1 ; aadd(aHeader,{trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"U_B902VCLV()",SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT,SX3->X3_NIVEL})
		dbSeek("ZJ_YDRIVER   ") ; nUsado:=nUsado+1 ; aadd(aHeader,{trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"U_B902VCLV()",SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT,SX3->X3_NIVEL})
		dbSeek("ZJ_YSUBITE   ") ; nUsado:=nUsado+1 ; aadd(aHeader,{trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"U_B902VCLV()",SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT,SX3->X3_NIVEL})
	EndIf

	dbSeek("ZJ_YMELHOR") ; nUsado:=nUsado+1 ; aadd(aHeader,{trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"AllwaysTrue()",SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT,SX3->X3_NIVEL})
	dbSeek("ZJ_EMPDEST") ; nUsado:=nUsado+1 ; aadd(aHeader,{trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"AllwaysTrue()",SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT,SX3->X3_NIVEL})
	dbSeek("ZJ_YLOCALI") ; nUsado:=nUsado+1 ; aadd(aHeader,{trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"AllwaysTrue()",SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT,SX3->X3_NIVEL})
	dbSeek("ZJ_YPARADA") ; nUsado:=nUsado+1 ; aadd(aHeader,{trim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"AllwaysTrue()",SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT,SX3->X3_NIVEL})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta aCols                                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  lIncluir
		aCols             := {array(nUsado+1)}
		aCols[1,nUsado+1]	:= .F.
		For i := 1 to nUsado
			aCols[1,i] := CriaVar(aHeader[i,2])
		Next
	Else
		aCols:={}
		dbSelectArea("SZJ")
		dbSetOrder(1)
		dbSeek(xFilial("SZJ")+M->ZI_DOC+M->ZI_EMPRESA,.T.) //RAC
		While !eof()	.and. SZJ->ZJ_FILIAL						== xFilial("SZJ") ;
		.and. ALLTRIM(SZJ->ZJ_DOC)			== ALLTRIM(M->ZI_DOC) ;
		.and. ALLTRIM(SZJ->ZJ_EMPRESA)	== ALLTRIM(M->ZI_EMPRESA)
			aadd(aCols,array(nUsado+1))
			For i := 1 to nUsado
				aCols[len(aCols),i]    := FieldGet(FieldPos(aHeader[i,2]))
			Next
			aCols[len(aCols),nUsado+1] := .F.
			dbSkip()
		End
	End

	cTitulo        := "Cadastro de Pre Requisicao"
	cAliasEnchoice := "SZI"
	cAliasGetD     := "SZJ"
	cLinOk         := 'EXECBLOCK("VALIDA_LINHA")'
	cTudOk         := 'EXECBLOCK("VALIDA_TUDO")'
	cFieldOk       := "AllwaysTrue()"
	aCpoEnchoice   := {"ZI_DOC+ZI_EMPRESA"} //RAC

	dbSelectArea("SZJ")
	dbSetOrder(1)
	dbSelectArea("SZI")
	dbSetOrder(1)

	If lIncluir
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Acha o proximo numero de requisicao a ser gravada no SZI/SD3   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//M->ZI_DOC			:= GETSX8NUM("SZI","ZI_DOC","SZI")
		M->ZI_DOC			:= GetSxENum("SZI","ZI_DOC")
		//Grava empresa corrente
		M->ZI_EMPRESA	:= cEmpAnt
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a Data do Ultimo Fechamento      					           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DtFech := GetMv("MV_ULMES")

	//If SZI->ZI_EMISSAO <= DtFech .and. lBaixar
	If dDataBase <= DtFech .and. lBaixar
		//msgBox("Pre Requisicao com data anterior ao do ultimo fechamento, portanto nao sera possivel baixa-la","Pre Requisicao","ALERT")
		msgBox("Não é permitido efetuar baixa com data de Pre Requisicao com data anterior ao do ultimo fechamento, portanto nao sera possivel baixa-la", "Pre Requisicao", "ALERT")
		RollBackSx8()
		Return
	End

	If (AllTrim(M->ZI_BAIXA) == 'X' .And. (lBaixar .Or. lExcluir .Or. lImprimir))
		msgBox("Pre Requisicao cancelada.","Pre Requisicao","ALERT")
		RollBackSx8()
		Return
	EndIf

	If (lExcluir)
		msgBox("Atencao. Ação 'EXCLUIR' não pode mais ser feita até segunda ordem, por favor utilizar a opção 'CANCELAR'.","Pre Requisicao","ALERT")
		RollBackSx8()
		Return
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a Pre Requisicao ja foi baixada                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If M->ZI_BAIXA = "S" .and. lBaixar
		msgBox("Atencao. Pre Requisicao ja baixada, portanto nao sera possivel baixa-la novamente.","Pre Requisicao","ALERT")
		RollBackSx8()
		Return
	End

	If M->ZI_TIPO = "TR" .and. lBaixar
		msgBox("Atencao. Não será possível baixar Pre Transferencias. Utilizar rotina especifica ","Pre Transferencia","ALERT")
		RollBackSx8()
		Return
	End

	If M->ZI_BAIXA = "S" .and. lExcluir
		msgBox("Atencao. Pre Requisicao ja baixada, portanto nao podera ser excluida.","Pre Requisicao","ALERT")
		RollBackSx8()
		Return
	End

	If M->ZI_TIPO = "TR" .and. lExcluir
		msgBox("Atencao. Pre Transferencia nao podera ser excluida.","Pre Transferencia","ALERT")
		RollBackSx8()
		Return
	End

	If dDataBase < M->ZI_EMISSAO
		msgBox("Atencao. Não será permitida a baixa de uma pré-requisição com data inferior a emissão da mesma ", "Pre Requisicao", "ALERT")
		RollBackSx8()
		Return
	End

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa funcao modelo 3                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lRet := Modelo3(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk,nOpcE,nOpcG,cFieldOk,,300,,,,{0,0,MSADVSIZE()[6],MSADVSIZE()[5]},400)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa processamento                                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet
		fProcessa()
	Else
		RollBackSx8()
	End

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VALIDA_LINHA                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida todas as linha para nao incluir produtos repetidos  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

USER FUNCTION VALIDA_LINHA()

	LOCAL sRett 		:= .T.
	Local ni				:= 0
	Local nDuplique	:= 0
	//Local nDuplEmp	:= 0
	Local sCodigo 	:= Gdfieldget("ZJ_COD",n) 			//aCols[n,AScan(aHeader, { |x| Alltrim(x[2]) == 'ZJ_COD'})]
	Local sAlmox	:= Gdfieldget("ZJ_LOCAL",n)			//aCols[n,AScan(aHeader, { |x| Alltrim(x[2]) == 'ZJ_LOCAL'})]
	//Local sEmpDest	:= Gdfieldget("ZJ_EMPDEST",n)		//aCols[n,AScan(aHeader, { |x| Alltrim(x[2]) == 'ZJ_EMPDEST'})]

	//Projeto requisicao comum em 05/12 - fernando/facile
	//Local lCLVLInd  := (SubStr(M->ZI_CLVL,1,1) == "3")
	Local lComum	:= .F.
	Local cAlmoxBlq := AllTrim(GetNewPar("MV_YALBLQR","99"))
	//Local cReqDev	:= M->ZI_TIPO

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a Matricula                              					   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("ZZY")
	DbSetOrder(3)
	DbSeek(xFilial("ZZY")+M->ZI_MATRIC)
	If Alltrim(ZZY->ZZY_SITFUN) <> "N" //Este campo tem que estar vazio
		msgBox("Matricula informada inválida","Pre Requisicao","ALERT")
		Return
	End

	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1")+sCodigo)

	//Nao permite uso de Produtos PA
	If ALLTRIM(SB1->B1_GRUPO) == 'PA'
		Msgbox("Não é permite o uso de Produtos PA na rotina de Pre-Requisição!","Aviso","INFO")
		sRett := .F.
		RETURN(sRett)
	EndIf

	If Empty(GdFieldGet("ZJ_APLIC",n))
		Msgbox("O campo aplicação é obrigatório","Aviso","INFO")
		sRett := .F.
		RETURN(sRett)
	EndIf

	//Projeto requisicao comum em 05/12 - fernando/facile
	SBZ->(DbSetOrder(1))
	If SBZ->(DbSeek(xFilial("SBZ")+sCodigo)) .And. SBZ->BZ_YCOMUM == "S"
		lComum := .T.
	EndIf

	//Fernando/Facile em 16/03/2015 - Bloquear requisicao no Almoxarifado 99
	If sAlmox $ cAlmoxBlq
		Msgbox("Almoxarifado "+cAlmoxBlq+" não permitido para Requisição!","Aviso","INFO")
		sRett := .F.
		Return(sRett)
	EndIf

	//Valida produto duplicado
	If  !aCols[n,nUsado+1]
		If len(aCols)  <> 1
			For  ni := 1 to len(aCols)
				If  sCodigo  == aCols[ni,AScan(aHeader, { |x| Alltrim(x[2]) == 'ZJ_COD'})] .And.;
				sAlmox   == aCols[ni,AScan(aHeader, { |x| Alltrim(x[2]) == 'ZJ_LOCAL'})]
					nDuplique ++
					If nDuplique = 2
						Msgbox("Produto+Almoxarifado está duplicado","Aviso","INFO")
						sRett := .F.
						Return(sRett)
					EndIf
				Endif
			Next
		End If
	EndIf

	//Valida Empresa Destino (não pode ser diferente)
	If !aCols[n,nUsado+1]

		If Len(aCols) <> 1

			For ni := 1 to Len(aCols)

				Do Case
					Case cEmpAnt == '01' .AND. sAlmox == "01" .And. !Gdfieldget("ZJ_LOCAL",ni) $ "01/6B"
					Msgbox("Não é permitido requisitar produtos neste Almoxarifado junto com 01 e 6B!","Aviso","INFO")
					sRett := .F.
					Return(sRett)
					Case cEmpAnt == '01' .AND. sAlmox == "6B" .And. !Gdfieldget("ZJ_LOCAL",ni) $ "01/6B"
					Msgbox("Não é permitido requisitar produtos neste Almoxarifado junto com 01 e 6B!","Aviso","INFO")
					sRett := .F.
					Return(sRett)
					Case cEmpAnt == '01' .AND. sAlmox == "6I" .And. Gdfieldget("ZJ_LOCAL",ni) $ "01/6B"
					Msgbox("Não é permitido requisitar produtos neste Almoxarifado junto com 01 e 6B!","Aviso","INFO")
					sRett := .F.
					Return(sRett)
					Case cEmpAnt == '01' .AND. sAlmox == "6V" .And. Gdfieldget("ZJ_LOCAL",ni) $ "01/6B"
					Msgbox("Não é permitido requisitar produtos neste Almoxarifado junto com 01 e 6B!","Aviso","INFO")
					sRett := .F.
					Return(sRett)

					Case cEmpAnt == '05' .AND. sAlmox == "01" .And. !Gdfieldget("ZJ_LOCAL",ni) $ "01/6I"
					Msgbox("Não é permitido requisitar produtos neste Almoxarifado junto com 01 e 6I!","Aviso","INFO")
					sRett := .F.
					Return(sRett)
					Case cEmpAnt == '05' .AND. sAlmox == "6I" .And. !Gdfieldget("ZJ_LOCAL",ni) $ "01/6I"
					Msgbox("Não é permitido requisitar produtos neste Almoxarifado junto com 01 e 6I!","Aviso","INFO")
					sRett := .F.
					Return(sRett)
					Case cEmpAnt == '05' .AND. sAlmox == "6B" .And. Gdfieldget("ZJ_LOCAL",ni) $ "01/6I"
					Msgbox("Não é permitido requisitar produtos neste Almoxarifado junto com 01 e 6I!","Aviso","INFO")
					sRett := .F.
					Return(sRett)
					Case cEmpAnt == '05' .AND. sAlmox == "6V" .And. Gdfieldget("ZJ_LOCAL",ni) $ "01/6I"
					Msgbox("Não é permitido requisitar produtos neste Almoxarifado junto com 01 e 6I!","Aviso","INFO")
					sRett := .F.
					Return(sRett)

					Case cEmpAnt == '14' .AND. sAlmox == "01" .And. !Gdfieldget("ZJ_LOCAL",ni) $ "01/6V"
					Msgbox("Não é permitido requisitar produtos neste Almoxarifado junto com 01 e 6V!","Aviso","INFO")
					sRett := .F.
					Return(sRett)
					Case cEmpAnt == '14' .AND. sAlmox == "6I" .And. !Gdfieldget("ZJ_LOCAL",ni) $ "01/6V"
					Msgbox("Não é permitido requisitar produtos neste Almoxarifado junto com 01 e 6V!","Aviso","INFO")
					sRett := .F.
					Return(sRett)
					Case cEmpAnt == '14' .AND. sAlmox == "6B" .And. Gdfieldget("ZJ_LOCAL",ni) $ "01/6V"
					Msgbox("Não é permitido requisitar produtos neste Almoxarifado junto com 01 e 6V!","Aviso","INFO")
					sRett := .F.
					Return(sRett)
					Case cEmpAnt == '14' .AND. sAlmox == "6V" .And. Gdfieldget("ZJ_LOCAL",ni) $ "01/6V"
					Msgbox("Não é permitido requisitar produtos neste Almoxarifado junto com 01 e 6V!","Aviso","INFO")
					sRett := .F.
					Return(sRett)

					Case !cEmpAnt $ "01/05/14"
					Msgbox("Não é permitido requisitar produtos nesta Empresa!","Aviso","INFO")
					sRett := .F.
					Return(sRett)
					Otherwise
				EndCase

			Next

		EndIf

	EndIf

	//Obriga digitacao Codigo Melhoria
	If !aCols[n,nUsado+1]
		For  ni := 1 to len(aCols)
			If  aCols[ni,AScan(aHeader, { |x| Alltrim(x[2]) == 'ZJ_APLIC'})] == '3' .AND. EMPTY(aCols[ni,AScan(aHeader, { |x| Alltrim(x[2]) == 'ZJ_YMELHOR'})])
				Msgbox("Código da Melhoria não informado.","Aviso","INFO")
				sRett := .F.
				RETURN(sRett)
			Endif
		Next
	End if

	If !aCols[n,nUsado+1]
		For  ni := 1 to Len(aCols)
			DbSelectArea("SB1")
			DbSetOrder(1)
			DbSeek(xFilial("SB1")+aCols[ni,AScan(aHeader, { |x| Alltrim(x[2]) == 'ZJ_COD'})],.F.)
			If (aCols[ni,AScan(aHeader, { |x| Alltrim(x[2]) == 'ZJ_APLIC'})] == '4' .And. ALLTRIM(Substr(SB1->B1_GRUPO,1,3)) <> '212' .And. EMPTY(aCols[ni,AScan(aHeader, { |x| Alltrim(x[2]) == 'ZJ_YMELHOR'})]) ) .Or.;
			(aCols[ni,AScan(aHeader, { |x| Alltrim(x[2]) == 'ZJ_APLIC'})] == '4' .And. (ALLTRIM(Substr(SB1->B1_GRUPO,1,3)) < '201' .Or. ALLTRIM(Substr(SB1->B1_GRUPO,1,3)) > '220') .And. !EMPTY(aCols[ni,AScan(aHeader, { |x| Alltrim(x[2]) == 'ZJ_YMELHOR'})]) ) .Or.;
			(aCols[ni,AScan(aHeader, { |x| Alltrim(x[2]) == 'ZJ_APLIC'})] <> '4' .And. ALLTRIM(Substr(SB1->B1_GRUPO,1,3)) == '212')
				Msgbox("Para produtos do grupo 212, o código da aplicação deverá ser igual a 4 (Segurança) quando a melhoria não for informada.","Aviso","INFO")
				sRett := .F.
				Return(sRett)
			Endif
		Next
	EndIf

	//Valida o preenchimento do campo Empresa Destino
	If !aCols[n,nUsado+1]
		For  ni := 1 to Len(aCols)
			If Empty(Alltrim(aCols[ni,AScan(aHeader, { |x| Alltrim(x[2]) == 'ZJ_EMPDEST'})]))
				Msgbox("Campo Empresa Destino em Branco. Favor verificar!","Aviso","INFO")
				sRett := .F.
				Return(sRett)
			Endif
		Next
	EndIf

	//Valida a database com a data do computador
	If Date() <> ddatabase .And. INCLUI
		Msgbox("VIRADA DE TURNO!!! O SISTEMA SERA ENCERRADO AUTOMATICAMENTE!!!","AVISO","ALERT")
		Final("VIRADA DE TURNO!!! O SISTEMA SERA ENCERRADO AUTOMATICAMENTE!!!")
	EndIf

	// Por Marcos Alberto Soprani em 24/05/13. A pre-requisição RBBPXL apresentada pela Ariely nesta data foi que determinou o ajuste nao bloqueio. OS effettivo 0879-13
	If M->ZI_TIPO == "RE"

		If !aCols[n,nUsado+1]

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula Saldo do Produto, para nao deixar negativo             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cEmpAnt == GdfieldGet("ZJ_EMPDEST", n)
				//Funcao para calcular o saldo do produto
				aSaldos := CalcEst(GdfieldGet("ZJ_COD", n), GdfieldGet("ZJ_LOCAL", n), ddatabase+1) //Somado +1 na database, para dar o saldo do dia corrente
			Else
				//Armazena a Empresa Original
				cEmpOri := cEmpAnt
				//Altera a "Empresa Original" para "Empresa Destino" - CUIDADO
				cEmpAnt := GdfieldGet("ZJ_EMPDEST", n)
				//Funcao para calcular o saldo do produto
				aSaldos := CalcEst(GdfieldGet("ZJ_COD", n), GdfieldGet("ZJ_LOCAL", n), ddatabase+1) //Somado +1 na database, para dar o saldo do dia corrente
				//Volta a "Empresa Original" - CUIDADO
				cEmpAnt := cEmpOri
			EndIf

			wSALDO := aSaldos[1] - GdfieldGet("ZJ_QUANT", n)

			DbSelectArea("ZCN")
			ZCN->(DbSetOrder(1))

			DbSelectArea("SBZ")
			SBZ->(DbSetOrder(1))

			SBZ->(DbSeek(xFilial("SBZ")+GdfieldGet("ZJ_COD", n)))

			If wSALDO < 0 .And. (!ZCN->(DbSeek(xFilial("ZCN")+GdfieldGet("ZJ_COD", n)+"2"+GdfieldGet("ZJ_LOCAL", n))) .Or. AllTrim(SBZ->BZ_YPOLIT) == "4") 
				Msgbox("Este produto " + Alltrim(GdfieldGet("ZJ_COD", n)) + " não possui saldo suficiente para atender está Pré-Requisição. Favor verificar!", "Aviso  [BIA902(1)]", "INFO")
				sRett := .F.
			EndIf

		EndIf

	EndIf

Return(sRett)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VALIDA_TUDO                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida todas as linha para nao incluir produtos repetidos  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
USER FUNCTION VALIDA_TUDO()

	LOCAL sRett	 := .T.
	Local lConta := .F.

	//Projeto requisicao comum em 05/12 - fernando/facile
	//Local lCLVLInd  := (SubStr(M->ZI_CLVL,1,1) == "3")
	Local lComum	:= .F.
	Local _cClasse  := ""
	Local _lDifClvl := .F.
	LOcal ni

	For  ni := 1 to Len(aCols)

		If !aCols[ni][Len(aHeader)+1]

			DbSelectArea("SB1")
			DbSetOrder(1)
			DbSeek(xFilial("SB1")+Gdfieldget("ZJ_COD",ni),.F.)

			//Fernando/Facile em 30/12 - validar se todas as classes de valor estão iguais
			// Por Marcos Alberto Soprani em 24/02/16 para atender a necessidade de algumas áreas que não necessitam controlar Classe de Valor por TAG.
			SZC->(dbSetOrder(1))
			SZC->(dbSeek(xFilial("SZC") + Gdfieldget("ZJ_TAG",ni)))
			If !SZC->ZC_VLDTAG $ " /N"
				If !Empty(_cClasse) .And. ( Gdfieldget("ZJ_CLVL",ni) <> _cClasse )
					_lDifClvl := .T.
				EndIf
			EndIf

			CTH->(dbSetOrder(1))
			CTH->(dbSeek(xFilial("CTH") + Gdfieldget("ZJ_CLVL",ni)))

			//Alteração para Validar aplicação

			If !Empty(Gdfieldget("ZJ_CLVL",ni)) .And. CTH->CTH_YATRIB == 'C' .And. SUBSTR(B1_YCTRIND,1,1) == '6' .And. GdFieldGet("ZJ_APLIC",ni) $ " _0"

				Msgbox("Existem produtos com classe de valor que não permite que a aplicação seja em branco ou zero!.","Aviso","INFO")
				sRett := .F.
				RETURN(sRett)

			EndIf

			_cClasse := Gdfieldget("ZJ_CLVL",ni)

			//Projeto requisicao comum em 05/12 - fernando/facile
			SBZ->(DbSetOrder(1))
			If SBZ->(DbSeek(xFilial("SBZ")+SB1->B1_COD)) .And. SBZ->BZ_YCOMUM == "S"
				lComum := .T.
			EndIf

			//Verifica se o produto possui conta de Investimento (31401)
			If (Substr(SB1->B1_CONTA,1,5) == "31401" .Or. ;
			Substr(SB1->B1_CONTA,1,5) == "31406" .Or. ;
			Substr(SB1->B1_YCTARES,1,5) == "31401" .Or. ;
			Substr(SB1->B1_YCTARES,1,5) == "31406" .Or. ;
			Substr(SB1->B1_YCTRIND,1,5) == "31401" .Or. ;
			Substr(SB1->B1_YCTRIND,1,5) == "31406" .Or. ;
			Substr(SB1->B1_YCTRADM,1,5) == "31401" .Or. ;
			Substr(SB1->B1_YCTRADM,1,5) == "31406") .And. !lConta
				IF ALLTRIM(SB1->B1_CONTA) <> '31401017' .AND. ALLTRIM(SB1->B1_YCTARES) <> '31401017' .AND. ALLTRIM(SB1->B1_YCTRIND) <> '31401017' .AND. ALLTRIM(SB1->B1_YCTRADM) <> '31401017'
					lConta := .T.
				ENDIF
			EndIf

		EndIf

	Next

	// Por Marcos Alberto Soprani em 19/12/16
	CTH->(dbSetOrder(1))
	CTH->(dbSeek(xFilial("CTH") + M->ZI_CLVL))

	If CTH->CTH_YCTRTG == "S"

		//Fernando/Facile em 30/12 - validar se todas as classes de valor estão iguais
		If ( _lDifClvl )

			Msgbox("Não é permitido requisitar Produtos de CLASSES DE VALOR diferentes na mesma requisição. Verifique os itens.","Aviso","INFO")
			sRett := .F.
			RETURN(sRett)

		Else

			// Em 19/12/16... Por Marcos Alberto Soprani... retirei daquí

		EndIf

	EndIf

	// Em 19/12/16... Por Marcos Alberto Soprani... e inseri aqui
	// Por Marcos Alberto Soprani em 24/02/16 para atender a necessidade de algumas áreas que não necessitam controlar Classe de Valor por TAG.
	If Empty(M->ZI_CLVL)

		M->ZI_CLVL	:= _cClasse
		M->ZI_CC 	:= U_B902BCC(_cClasse)

	EndIf

	//Funcao para Validar o Item Contabil
	sRett := U_fValItemCta("XX",lConta,M->ZI_CLVL,M->ZI_ITEMCTA)

	If sRett .And. ( SZJ->(FieldPos("ZJ_CLVL")) > 0 )

		sRett := U_B902VCOK()

	EndIf

Return(sRett)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fProcessa                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Processa confirmacao da tela                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fProcessa()

	Local _cAliasTrn	:=	GetNextAlias()
	Local i

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Determina posicao dos campos no aCols                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	wP_COD     := aScan(aHeader,{|x| x[2]=="ZJ_COD    "})
	wP_LOCAL   := aScan(aHeader,{|x| x[2]=="ZJ_LOCAL  "})
	wP_DESCRI  := aScan(aHeader,{|x| x[2]=="ZJ_DESCRI "})
	wP_UM      := aScan(aHeader,{|x| x[2]=="ZJ_UM     "})
	wP_QUANT   := aScan(aHeader,{|x| x[2]=="ZJ_QUANT  "})
	wP_VLRTOT  := aScan(aHeader,{|x| x[2]=="ZJ_VLRTOT "})
	wP_APLIC   := aScan(aHeader,{|x| x[2]=="ZJ_APLIC  "})
	WP_CLVL	   := aScan(aHeader,{|x| x[2]=="ZJ_CLVL   "})
	wP_TAG     := aScan(aHeader,{|x| x[2]=="ZJ_TAG    "})
	wP_MELHOR  := aScan(aHeader,{|x| x[2]=="ZJ_YMELHOR"})
	wP_EMPDEST := aScan(aHeader,{|x| x[2]=="ZJ_EMPDEST"})
	wP_LOCALIZ := aScan(aHeader,{|x| x[2]=="ZJ_YLOCALI"})
	wP_YPARADA := aScan(aHeader,{|x| x[2]=="ZJ_YPARADA"})
	wP_QTAPROV := aScan(aHeader,{|x| x[2]=="ZJ_QTAPROV"})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Definicao do arquivo de trabalho                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_aCampos := {	{"COD    ","C", 15,0},;
	{"ALMOX  ","C",  2,0},;
	{"DESCRI ","C", 30,0},;
	{"UM     ","C",  2,0},;
	{"QUANT  ","N", 18,8},;
	{"QAPROV ","N", 18,8},;
	{"VLRTOT ","N", 18,8},;
	{"APLIC  ","C",  1,0},;
	{"CLVL   ","C",  9,0},;
	{"TAG    ","C",  8,0},;
	{"MELHOR ","C",  6,0},;
	{"EMPDEST","C",  2,0},;
	{"LOCALIZ","C", 15,0},;
	{"YPARADA","C",  1,0}}
	If chkfile("_cTrab")
		dbSelectArea("_cTrab")
		dbCloseArea()
	EndIf
	_cTrab := CriaTrab(_aCampos)
	dbUseArea(.T.,,_cTrab,"_cTrab")
	dbCreateInd(_cTrab,"COD+ALMOX+DESCRI",{||COD+ALMOX+DESCRI})
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta arquivo de trabalho                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("_cTrab")
	For i := 1 to len(aCols)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o item foi deletado                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If  !aCols[i,nUsado+1]
			RecLock("_cTrab",.T.)
			_cTrab->COD		:= aCols[i,wP_COD    ]
			_cTrab->ALMOX	:= aCols[i,wP_LOCAL  ]
			_cTrab->DESCRI	:= aCols[i,wP_DESCRI ]
			_cTrab->UM		:= aCols[i,wP_UM     ]
			_cTrab->QUANT	:= aCols[i,wP_QUANT  ]
			_cTrab->QAPROV	:= aCols[i,wP_QTAPROV]
			_cTrab->VLRTOT	:= aCols[i,wP_VLRTOT ]
			_cTrab->APLIC	:= aCols[i,wP_APLIC  ]
			_cTrab->CLVL	:= aCols[i,wP_CLVL   ]
			_cTrab->TAG		:= aCols[i,wP_TAG    ]
			_cTrab->MELHOR	:= aCols[i,wP_MELHOR ]
			_cTrab->EMPDEST	:= aCols[i,wP_EMPDEST]
			_cTrab->LOCALIZ	:= aCols[i,wP_LOCALIZ]
			_cTrab->YPARADA	:= aCols[i,wP_YPARADA]
			MsUnLock()
		End
	Next

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica funcao utilizada                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Do Case
		Case lIncluir
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Processa arquivo de trabalho                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Begin Transaction

			dbSelectArea("_cTrab")
			dbGoTop()
			lSZJ  := .F.
			While !EOF()
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava SZJ -                                                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SZJ")
				RecLock("SZJ",.T.)
				SZJ->ZJ_FILIAL  := xFilial("SZJ")
				SZJ->ZJ_DOC     := M->ZI_DOC
				SZJ->ZJ_EMPRESA := cEmpAnt				//RAC
				SZJ->ZJ_COD     := _cTrab->COD
				SZJ->ZJ_LOCAL   := _cTrab->ALMOX //RAC
				SZJ->ZJ_DESCRI  := _cTrab->DESCRI
				SZJ->ZJ_UM      := _cTrab->UM
				SZJ->ZJ_QUANT   := _cTrab->QUANT
				SZJ->ZJ_VLRTOT  := _cTrab->VLRTOT
				SZJ->ZJ_APLIC   := _cTrab->APLIC
				SZJ->ZJ_CLVL    := _cTrab->CLVL
				SZJ->ZJ_TAG     := _cTrab->TAG
				SZJ->ZJ_YMELHOR := _cTrab->MELHOR
				SZJ->ZJ_EMPDEST := _cTrab->EMPDEST
				SZJ->ZJ_YLOCALI := _cTrab->LOCALIZ
				SZJ->ZJ_YPARADA := _cTrab->YPARADA
				SZJ->ZJ_QTAPROV := _cTrab->QAPROV
				MsUnLock()
				lSZI := .T.

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava o Empenho                                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Alltrim(M->ZI_TIPO) == "RE"
					If _cTrab->EMPDEST == "01"
						cSql := "UPDATE SB2010 SET B2_RESERVA = B2_RESERVA + "+Alltrim(Str(_cTrab->QAPROV))+" WHERE B2_COD = '"+_cTrab->COD+"' AND B2_LOCAL = '"+_cTrab->ALMOX+"' AND D_E_L_E_T_ = '' "
						TcSQLExec(cSQL)
					ElseIf _cTrab->EMPDEST == "05"
						cSql := "UPDATE SB2050 SET B2_RESERVA = B2_RESERVA + "+Alltrim(Str(_cTrab->QAPROV))+" WHERE B2_COD = '"+_cTrab->COD+"' AND B2_LOCAL = '"+_cTrab->ALMOX+"' AND D_E_L_E_T_ = '' "
						TcSQLExec(cSQL)
					ElseIf _cTrab->EMPDEST == "14"
						cSql := "UPDATE SB2140 SET B2_RESERVA = B2_RESERVA + "+Alltrim(Str(_cTrab->QAPROV))+" WHERE B2_COD = '"+_cTrab->COD+"' AND B2_LOCAL = '"+_cTrab->ALMOX+"' AND D_E_L_E_T_ = '' "
						TcSQLExec(cSQL)
					EndIf

				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Acessa proximo registro                                       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("_cTrab")
				dbSkip()
			End
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava SZI                                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			//Fernando/Facile em 30/12/15 para forcar gravar a classe de valor do primeiro item no cabecalho (todos tem que ser iguais)
			dbSelectArea("_cTrab")
			dbGoTop()

			If  lSZI
				dbSelectArea("SZI")
				RecLock("SZI",.T.)
				SZI->ZI_FILIAL  := xFilial("SZI")
				SZI->ZI_DOC     := M->ZI_DOC
				SZI->ZI_EMPRESA := cEmpAnt //RAC
				SZI->ZI_EMISSAO := M->ZI_EMISSAO
				SZI->ZI_CC      := M->ZI_CC
				SZI->ZI_CLVL    := M->ZI_CLVL

				// Retirado por Marcos Alberto Soprani em 24/02/16 para atender ao controle de TAG
				//M->ZI_CLVL		:= _cTrab->CLVL
				//SZI->ZI_CLVL	:= _cTrab->CLVL
				//SZI->ZI_CC		:= U_B902BCC(_cTrab->CLVL)
				//M->ZI_CC		:= SZI->ZI_CC

				SZI->ZI_ITEMCTA := M->ZI_ITEMCTA
				SZI->ZI_MATRIC  := M->ZI_MATRIC
				SZI->ZI_NOME    := M->ZI_NOME
				SZI->ZI_TIPO    := M->ZI_TIPO
				SZI->ZI_YLOCAL	:= M->ZI_YLOCAL
				SZI->ZI_BAIXA   := "N"
				MsUnLock()
			End

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Confima utilizacao do numero sequencial                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ConfirmSX8()

		End Transaction

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Impressao da Requisicao										   									 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Private x:="2;0;1;PRE REQUISICAO"
		CALLCRYS("REQUI_2",M->ZI_DOC+";"+M->ZI_EMPRESA,x)

		DbSelectArea("SZJ")
		MsUnLock()
		DbSelectArea("SZI")
		MsUnLock()

		Case lImprimir
		//Private x:="2;0;1;PRE REQUISICAO"
		CALLCRYS("REQUI_2",M->ZI_DOC+";"+M->ZI_EMPRESA,x)

		Case lBaixar

		//Verificar se a requisicao tem produdos Comuns, so funciona baixar na Biancogres
		cAliasTmp2 := GetNextAlias()
		BeginSql Alias cAliasTmp2
			SELECT *
			FROM  %Table:SZJ% (NOLOCK)
			WHERE ZJ_DOC = %Exp:M->ZI_DOC% AND ZJ_EMPRESA = %Exp:M->ZI_EMPRESA% AND %NOTDEL%
			ORDER BY ZJ_EMPRESA, ZJ_EMPDEST
		EndSql

		_lTransfEmp := .F. 

		//Fernando/Facile em 10/05/2016 - OS 4630-15 - Comentado o bloco abaixo para nao considerar mais produtos de uso comum
		//Variavel _lTransfEmp = .F. todo o processo de baixa sera sempre padrao na empresa corrente
		/*
		(cAliasTmp2)->(DbGoTop())
		While  !(cAliasTmp2)->(EOF())

		//Se a classe de valor de consumo nao pertence a empresa do estoque faz transferencia para temporario
		CTH->(DbSetOrder(1))
		If (CTH->(DbSeek(XFilial("CTH")+M->ZI_CLVL)) .And. !Empty(CTH->CTH_YEMPFL) .And. !Empty((cAliasTmp2)->ZJ_EMPDEST) .And. SubStr(CTH->CTH_YEMPFL,1,2) <> (cAliasTmp2)->ZJ_EMPDEST)
		_lTransfEmp := .T.
		EndIf

		(cAliasTmp2)->(DbSkip())
		EndDo
		(cAliasTmp2)->(DbCloseArea())
		*/

		If _lTransfEmp .And. AllTrim(CEMPANT) <> "01"
			Msgbox("Esta requisicao possui produtos de uso COMUM. Favor fazer a baixa pela empresa BIANCOGRES.","Aviso","INFO")
			Return
		EndIf

		BeginSql Alias _cAliasTrn

			SELECT COUNT(*) QTD
			FROM %TABLE:SZI% SZI
			JOIN %TABLE:SZJ% SZJ ON SZJ.ZJ_FILIAL =SZI.ZI_FILIAL
			AND SZJ.ZJ_DOC = SZI.ZI_DOC
			WHERE ZI_FILIAL = %XFILIAL:SZI%
			AND ZI_YDOCORI = %Exp:SZI->ZI_DOC%
			AND ZI_YDOCORI <> ''
			AND ZJ_BAIXA IN ('','R')
			AND SZJ.%NotDel%
			AND SZI.%NotDel%

		EndSql

		If (_cAliasTrn)->QTD > 0

			Msgbox("Esta requisicao possui pré-transferências rejeitadas ou não atendidas. Favor realizar o ajuste.","Aviso","INFO")
			(_cAliasTrn)->(DbCloseArea())
			Return

		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se a Pre Requisicao j517648a foi baixada			         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If M->ZI_BAIXA = "N"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o Tipo e Requisicao         					             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			_aCab1 			:=	{}
			_aItem 			:= 	{}
			_atotitem		:=	{}

			// Tiago Rossini Coradini - 23/05/16 - OS: 1130-16 - Carlos Junqueira - Objeto para tratamento de geração automatica de entrega de EPI			
			oEntEPI := TEntregaEPI():New()

			If Alltrim(M->ZI_TIPO) = "RE"
				nTM := "502"
			Else
				If Alltrim(M->ZI_TIPO) == "DN"
					nTM := "005"
				Else
					nTM := "006"
				EndIf
			EndIf

			//Preenche Cabecalho
			_aCab1 :=	{	{"D3_DOC"     ,M->ZI_DOC		, NIL},;
			{"D3_TM"      ,nTM			, NIL},;
			{"D3_CC"      ,M->ZI_CC			, NIL},;
			{"D3_CLVL"    ,M->ZI_CLVL 		, NIL},;
			{"D3_EMISSAO" ,dDatabase	, NIL}}
			//{"D3_EMISSAO" ,M->ZI_EMISSAO	, NIL}}

			//Agrupa os itens por Empresa Destino
			cAliasTmp := GetNextAlias()
			BeginSql Alias cAliasTmp
				SELECT ZJ_EMPDEST
				FROM  %Table:SZJ% (NOLOCK)
				WHERE ZJ_DOC = %Exp:M->ZI_DOC% AND ZJ_EMPRESA = %Exp:M->ZI_EMPRESA% AND %NOTDEL%
				GROUP BY ZJ_EMPDEST
			EndSql

			//Monta Array com os produtos por Empresa Destino
			While  !(cAliasTmp)->(EOF())

				cAliasTmp2 := GetNextAlias()
				BeginSql Alias cAliasTmp2
					SELECT *
					FROM  %Table:SZJ% (NOLOCK)
					WHERE ZJ_DOC = %Exp:M->ZI_DOC% AND ZJ_EMPRESA = %Exp:M->ZI_EMPRESA% AND ZJ_EMPDEST = %Exp:(cAliasTmp)->ZJ_EMPDEST% AND %NOTDEL%
					ORDER BY ZJ_EMPRESA, ZJ_EMPDEST
				EndSql

				_atotitem		:=	{}
				While  !(cAliasTmp2)->(EOF())

					//Se a classe de valor de consumo nao pertence a empresa do estoque faz transferencia para temporario
					_lTransfEmp := .F.
					//CTH->(DbSetOrder(1))
					//If (CTH->(DbSeek(XFilial("CTH")+M->ZI_CLVL)) .And. !Empty(CTH->CTH_YEMPFL) .And. !Empty((cAliasTmp)->ZJ_EMPDEST) .And. Substr(CTH->CTH_YEMPFL,1,2) <> (cAliasTmp)->ZJ_EMPDEST)
					//	_lTransfEmp := .T.
					//EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Calcula Saldo do Produto, para nao deixar negativo             ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Alltrim(M->ZI_TIPO) == "RE"
						_cLocSal := (cAliasTmp2)->ZJ_LOCAL
					ElseIf _lTransfEmp
						_cLocSal := "6T"
					Else
						_cLocSal := ""
					EndIf

					If !Empty(_cLocSal)
						If cEmpAnt == (cAliasTmp)->ZJ_EMPDEST
							//Funcao para calcular o saldo do produto
							aSaldos := CalcEst((cAliasTmp2)->ZJ_COD,_cLocSal,ddatabase+1) //Somado +1 na database, para dar o saldo do dia corrente
						Else
							//Armazena a Empresa Original
							cEmpOri := cEmpAnt
							//Altera a "Empresa Original" para "Empresa Destino" - CUIDADO
							cEmpAnt := (cAliasTmp)->ZJ_EMPDEST
							//Funcao para calcular o saldo do produto
							aSaldos := CalcEst((cAliasTmp2)->ZJ_COD,_cLocSal,ddatabase+1) //Somado +1 na database, para dar o saldo do dia corrente
							//Volta a "Empresa Original" - CUIDADO
							cEmpAnt := cEmpOri
						EndIf

						wSALDO := aSaldos[1] - (cAliasTmp2)->ZJ_QUANT

						If wSALDO < 0
							Msgbox("Este produto "+(cAliasTmp2)->ZJ_COD+" não possui saldo suficiente no Armazem: "+_cLocSal+" para atender está Pré-Requisição. Favor verificar!", "Aviso [BIA902(1)]", "INFO")
							Return
						EndIf

					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Localiza produto no SB1                 					             ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DbSelectArea("SB1")
					DbSetOrder(1)
					DbSeek(xFilial("SB1")+(cAliasTmp2)->ZJ_COD,.F.)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Define a Conta Contabil                 					             ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nConta	:= "" 
					If U_B478RTCC(M->ZI_CLVL)[2] == "D"
						nConta	:= SB1->B1_YCTRADM
					ElseIf U_B478RTCC(M->ZI_CLVL)[2] == "C"
						nConta  := SB1->B1_YCTRIND
					EndIf

					// Em 22/02/17, retirado de USO por Marcos Alberto Soprani, para adequar o sistema a nova regra aplicação de custo e despesa.
					//                                                          bem como por identificar erro na fórmula da segunda condição... 
					//If Subs(M->ZI_CLVL,1,1) $ "1,2,4,5,8"
					//	nConta	:= SB1->B1_YCTRADM
					//ElseIf Subs(M->ZI_CLVL,1,1) == "3,6"
					//	nConta  := SB1->B1_YCTRIND
					//EndIf

					//Valida Unidade de Medida
					If !ExistCpo("SAH",SB1->B1_UM) .Or. !ExistCpo("SAH",SB1->B1_SEGUM)
						Msgbox("Favor corrigir a Unidade de Medida do Produto "+Alltrim(SB1->B1_COD)+" pois está incorreta!","Aviso","INFO")
						Return
					EndIf

					//Verifica se a Conta Contabil no Cadastro de Produto esta correta
					DbSelectArea("CT1")
					DbSetOrder(1)
					If !DbSeek(xFilial("CT1")+nConta,.T.)
						Msgbox("A Conta Contabil "+nConta+" não está correta. Favor verificar o cadastro do produto "+(cAliasTmp2)->ZJ_COD+".","Aviso","INFO")
						Return
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Define a Custo                 					               ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Alltrim(M->ZI_TIPO) == "DU"
						nCusto := 0.01
					EndIF

					IF (cAliasTmp2)->ZJ_APLIC == '4' .AND. !EMPTY((cAliasTmp2)->ZJ_YMELHOR) .AND. Subs(M->ZI_CLVL,1,1) == "3"
						nConta := '61301010'
					ENDIF
					/*
					// Em 22/02/17... Por Marcos Alberto Soprani... implementado tratamento para atender a OS effettivo 3351-16 e OS 1546-17
					If Alltrim((cAliasTmp2)->ZJ_COD) $ "1070007/1070385/1070008" .and. Alltrim(SZI->ZI_CLVL) == "3117" 
					nConta := '61110006'
					EndIf
					*/
					// Em 06/04/17... Por Marcos Alberto Soprani... implementado tratamento para atender a OS effettivo 1245-17 
					If Substr((cAliasTmp2)->ZJ_COD,1,3) == "107" .and. cEmpAnt == "05" .and. Substr(nConta,1,5) == "6110" 
						nConta := '61108003'
					EndIf

					If SB1->B1_GRUPO == '107A' .Or. SB1->B1_GRUPO == '107E' 
						If Alltrim(SZI->ZI_CLVL) == "3117" .Or. Alltrim(SZI->ZI_CLVL) == "3135" .Or. Alltrim(SZI->ZI_CLVL) == "3217"
							nConta :=	"61110006" 
						ElseIf Alltrim(SZI->ZI_CLVL) == "3136" 
							nConta	:=	"61110001"
						EndIf
					EndIf

					//Novo metodo de baixa por transferencia - Fernando/Facile em 24/10/2014 - projeto req. de produto comum

					//Se a classe de valor de consumo nao pertence a empresa do estoque faz transferencia para temporario
					IF !_lTransfEmp

						//Preenche os Itens
						_aItem := {}
						aAdd(_aItem,{"D3_COD"	  	,(cAliasTmp2)->ZJ_COD		,NIL})
						aAdd(_aItem,{"D3_UM"	  	,SB1->B1_UM		     		,NIL})
						aAdd(_aItem,{"D3_QUANT"  	,(cAliasTmp2)->ZJ_QUANT    	,NIL})
						aAdd(_aItem,{"D3_LOCAL"  	,(cAliasTmp2)->ZJ_LOCAL		,NIL})

						If Alltrim(M->ZI_TIPO) == "DU"
							aAdd(_aItem,{"D3_CUSTO1" 	,nCusto					,NIL})
						EndIf

						aAdd(_aItem,{"D3_CONTA" 	,nConta						,NIL})
						aAdd(_aItem,{"D3_USUARIO"	,cUserName					,NIL})
						aAdd(_aItem,{"D3_CC"		,M->ZI_CC  				    ,NIL})
						aAdd(_aItem,{"D3_CLVL"		,M->ZI_CLVL					,NIL})
						aAdd(_aItem,{"D3_YMATRIC"	,M->ZI_MATRIC				,NIL})
						aAdd(_aItem,{"D3_ITEMCTA"	,M->ZI_ITEMCTA		    	,NIL})
						aAdd(_aItem,{"D3_SEGUM"  	,SB1->B1_SEGUM		    	,NIL})
						aAdd(_aItem,{"D3_YTAG"  	,(cAliasTmp2)->ZJ_TAG		,NIL})
						aAdd(_aItem,{"D3_YMELHOR"	,(cAliasTmp2)->ZJ_YMELHOR	,NIL})
						aAdd(_aItem,{"D3_YAPLIC" 	,iif(Empty((cAliasTmp2)->ZJ_APLIC),'0',(cAliasTmp2)->ZJ_APLIC)		,NIL})
						aAdd(_aItem,{"D3_YDRIVER" 	,(cAliasTmp2)->ZJ_YDRIVER	,NIL})
						aAdd(_aItem,{"D3_YSUBITE" 	,(cAliasTmp2)->ZJ_YSUBITE	,NIL})
						aAdd(_aItem,{"D3_YROM"  	,"N"						,NIL})
						aAdd(_aItem,{"D3_YCHAVE"	,""							,NIL})
						aAdd(_aItem,{"D3_YPARADA"	,(cAliasTmp2)->ZJ_YPARADA 	,NIL})

						aAdd(_atotitem,_aitem)

						// Se for requisição e o produto for do grupo de EPI, adiciona ao objeto para tratamento de entrega automatica
						If Alltrim(M->ZI_TIPO) == "RE" .And. (cAliasTmp2)->ZJ_APLIC == "4"

							oEntEPI:Add(M->ZI_MATRIC, (cAliasTmp2)->ZJ_COD, (cAliasTmp2)->ZJ_QUANT, (cAliasTmp2)->ZJ_LOCAL)

						EndIf


						//Retira a Reserva
						If Alltrim(M->ZI_TIPO) == "RE"

							If (cAliasTmp)->ZJ_EMPDEST == "01"
								cSql := "UPDATE SB2010 SET B2_RESERVA = B2_RESERVA - "+Alltrim(Str((cAliasTmp2)->ZJ_QTAPROV))+" WHERE B2_COD = '"+(cAliasTmp2)->ZJ_COD+"' AND B2_LOCAL = '"+(cAliasTmp2)->ZJ_LOCAL+"' AND D_E_L_E_T_ = '' "
								TcSQLExec(cSQL)
							ElseIf (cAliasTmp)->ZJ_EMPDEST == "14"
								cSql := "UPDATE SB2140 SET B2_RESERVA = B2_RESERVA - "+Alltrim(Str((cAliasTmp2)->ZJ_QTAPROV))+" WHERE B2_COD = '"+(cAliasTmp2)->ZJ_COD+"' AND B2_LOCAL = '"+(cAliasTmp2)->ZJ_LOCAL+"' AND D_E_L_E_T_ = '' "
								TcSQLExec(cSQL)
							Else
								cSql := "UPDATE SB2050 SET B2_RESERVA = B2_RESERVA - "+Alltrim(Str((cAliasTmp2)->ZJ_QTAPROV))+" WHERE B2_COD = '"+(cAliasTmp2)->ZJ_COD+"' AND B2_LOCAL = '"+(cAliasTmp2)->ZJ_LOCAL+"' AND D_E_L_E_T_ = '' "
								TcSQLExec(cSQL)
							EndIf

						EndIf

					ELSE 

						//Metodo de transferencia para armazem temporario - Fernando/Facile
						_aCustSD3 := {}
						aAdd(_aCustSD3,{"D3_CONTA"		,nConta})
						aAdd(_aCustSD3,{"D3_CC"			,M->ZI_CC})
						aAdd(_aCustSD3,{"D3_CLVL"		,M->ZI_CLVL})
						aAdd(_aCustSD3,{"D3_ITEMCTA"	,M->ZI_ITEMCTA})

						aAdd(_aCustSD3,{"D3_YMATRIC"	,M->ZI_MATRIC})
						aAdd(_aCustSD3,{"D3_YTAG"		,(cAliasTmp2)->ZJ_TAG})
						aAdd(_aCustSD3,{"D3_YMELHOR"	,(cAliasTmp2)->ZJ_YMELHOR})
						aAdd(_aCustSD3,{"D3_YAPLIC"		,(cAliasTmp2)->ZJ_APLIC})
						aAdd(_aCustSD3,{"D3_YDRIVER"	,(cAliasTmp2)->ZJ_YDRIVER})
						aAdd(_aCustSD3,{"D3_YSUBITE"	,(cAliasTmp2)->ZJ_YSUBITE})
						aAdd(_aCustSD3,{"D3_YROM"		,"N"})
						aAdd(_aCustSD3,{"D3_YCHAVE"		,""})
						aAdd(_aCustSD3,{"D3_YPARADA"	,(cAliasTmp2)->ZJ_YPARADA})
						aAdd(_aCustSD3,{"D3_USUARIO"	,cUserName})

						//Retira a Reserva
						If Alltrim(M->ZI_TIPO) == "RE"

							If (cAliasTmp)->ZJ_EMPDEST == "01"
								cSql := "UPDATE SB2010 SET B2_RESERVA = B2_RESERVA - "+Alltrim(Str((cAliasTmp2)->ZJ_QTAPROV))+" WHERE B2_COD = '"+(cAliasTmp2)->ZJ_COD+"' AND B2_LOCAL = '"+(cAliasTmp2)->ZJ_LOCAL+"' AND D_E_L_E_T_ = '' "
								TcSQLExec(cSQL)
							ElseIf (cAliasTmp)->ZJ_EMPDEST == "14"
								cSql := "UPDATE SB2140 SET B2_RESERVA = B2_RESERVA - "+Alltrim(Str((cAliasTmp2)->ZJ_QTAPROV))+" WHERE B2_COD = '"+(cAliasTmp2)->ZJ_COD+"' AND B2_LOCAL = '"+(cAliasTmp2)->ZJ_LOCAL+"' AND D_E_L_E_T_ = '' "
								TcSQLExec(cSQL)
							Else
								cSql := "UPDATE SB2050 SET B2_RESERVA = B2_RESERVA - "+Alltrim(Str((cAliasTmp2)->ZJ_QTAPROV))+" WHERE B2_COD = '"+(cAliasTmp2)->ZJ_COD+"' AND B2_LOCAL = '"+(cAliasTmp2)->ZJ_LOCAL+"' AND D_E_L_E_T_ = '' "
								TcSQLExec(cSQL)
							EndIf

						EndIf

						//Baixa Requisicao conforme empresa
						nEmp := (cAliasTmp)->ZJ_EMPDEST
						_lRetTr := .F.

						If Alltrim(M->ZI_TIPO) == "RE"

							If AllTrim(CEMPANT) == nEmp
								U_BIAMsgRun("Aguarde... Baixando Requisição Comum - Produto: "+AllTrim((cAliasTmp2)->ZJ_COD)+"",,;
								{|| _lRetTr := U_FRQCRT01(M->ZI_EMPRESA, M->ZI_DOC,(cAliasTmp2)->ZJ_COD,(cAliasTmp2)->ZJ_QUANT,(cAliasTmp2)->ZJ_LOCAL,"6T",_aCustSD3,Alltrim(M->ZI_TIPO) == "RE") })
							Else
								U_BIAMsgRun("Aguarde... Baixando Requisição Comum - Produto: "+AllTrim((cAliasTmp2)->ZJ_COD)+"",,;
								{||	_lRetTr := U_FROPCPRO(nEmp,"01","U_FRQCRT01",M->ZI_EMPRESA, M->ZI_DOC,(cAliasTmp2)->ZJ_COD,(cAliasTmp2)->ZJ_QUANT,(cAliasTmp2)->ZJ_LOCAL,"6T",_aCustSD3,Alltrim(M->ZI_TIPO) == "RE")  })
							EndIf

						Else

							If AllTrim(CEMPANT) == nEmp
								U_BIAMsgRun("Aguarde... Baixando Devolucao Comum - Produto: "+AllTrim((cAliasTmp2)->ZJ_COD)+"",,;
								{|| _lRetTr := U_FRQCRT01(M->ZI_EMPRESA, M->ZI_DOC,(cAliasTmp2)->ZJ_COD,(cAliasTmp2)->ZJ_QUANT,"6T",(cAliasTmp2)->ZJ_LOCAL,_aCustSD3,Alltrim(M->ZI_TIPO) == "RE") })
							Else
								U_BIAMsgRun("Aguarde... Baixando Devolucao Comum - Produto: "+AllTrim((cAliasTmp2)->ZJ_COD)+"",,;
								{||	_lRetTr := U_FROPCPRO(nEmp,"01","U_FRQCRT01",M->ZI_EMPRESA, M->ZI_DOC,(cAliasTmp2)->ZJ_COD,(cAliasTmp2)->ZJ_QUANT,"6T",(cAliasTmp2)->ZJ_LOCAL,_aCustSD3,Alltrim(M->ZI_TIPO) == "RE")  })
							EndIf

						EndIf

						//Atualizando cabecalho da Requisicao
						If _lRetTr
							SZI->(DbSetOrder(1))
							If SZI->(DbSeek(XFilial("SZI")+M->ZI_DOC+M->ZI_EMPRESA))
								RecLock("SZI",.F.)
								SZI->ZI_BAIXA   := "S"
								SZI->ZI_DTBAIXA := Date()
								SZI->ZI_HRBAIXA := Substr(Time(), 1, 5)
								SZI->(MsUnlock())
							EndIf
						EndIf

					ENDIF

					(cAliasTmp2)->(DBSKIP())
				End

				//Baixa de consumo interno na mesma empresa
				If Len(_atotitem) > 0

					// Validação para produtos EPI
					If !oEntEPI:Validate()

						MsgInfo("Atenção - BIA902[1]", "Baixa não efetuada, as informações do EPI não foram lançadas corretamente.")
						fRetRes(M->ZI_DOC)
						Return()

					EndIf						

					//Baixa Requisicao conforme empresa
					nEmp := (cAliasTmp)->ZJ_EMPDEST
					U_BIAMsgRun("Aguarde... Baixando Requisição Própria.",,{|| GravaSD3(nEmp, '01', _aCab1, _atotitem) })

				EndIf

				(cAliasTmp)->(dbSkip())
			End

			//Posiciona novamente no Cabecalho da PreRequisicao
			cAliasTmp3 := GetNextAlias()
			BeginSql Alias cAliasTmp3
				SELECT * FROM  %Table:SZI% (NOLOCK)	WHERE ZI_DOC = %Exp:M->ZI_DOC% AND ZI_EMPRESA = %Exp:M->ZI_EMPRESA%  AND %NOTDEL%
			EndSql

			If (cAliasTmp3)->ZI_BAIXA == "S"

				// Salva informacoes da EPI
				oEntEPI:Save(M->ZI_DOC)

				MsgBox("Pre Requisicao baixada com sucesso.","Pre Requisicao","ALERT")

			Else
				msgBox("Ocorreu um problema na baixa da Pre Requisicao. Favor verificar clicar em visualizar e em seguida localizar o campo Log de Erro. Lá você terá informações do que está impedindo a baixa da pré-requisição.", "Pre Requisicao", "ALERT")
				fRetRes(M->ZI_DOC)
			EndIf

			(cAliasTmp)->(dbCloseArea())
			(cAliasTmp2)->(dbCloseArea())
			(cAliasTmp3)->(dbCloseArea())

		EndIf
		Case lExcluir
		If M->ZI_BAIXA = "N"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Deleta SZJ                                                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SZJ")
			DbSetOrder(1)
			DbSeek(xFilial("SZJ")+SZI->ZI_DOC+SZI->ZI_EMPRESA,.T.) //RAC
			lSZI := .F.
			While !eof() 	.and. SZJ->ZJ_FILIAL						== xFilial("SZJ")					;
			.and. ALLTRIM(SZJ->ZJ_DOC)     	== ALLTRIM(SZI->ZI_DOC)		;
			.and. ALLTRIM(SZJ->ZJ_EMPRESA)	== ALLTRIM(SZI->ZI_EMPRESA) //RAC

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Deleta o Empenho                                              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Alltrim(M->ZI_TIPO) == "RE"

					//Apaga o empenho de acordo com a Empresa
					If SZJ->ZJ_EMPDEST == "01"
						cSql := "UPDATE SB2010 SET B2_RESERVA = B2_RESERVA - "+Alltrim(Str(SZJ->ZJ_QTAPROV))+" WHERE B2_COD = '"+SZJ->ZJ_COD+"' AND B2_LOCAL = '"+SZJ->ZJ_LOCAL+"' AND D_E_L_E_T_ = '' "
						TcSQLExec(cSQL)
					ElseIf SZJ->ZJ_EMPDEST == "14"
						cSql := "UPDATE SB2140 SET B2_RESERVA = B2_RESERVA - "+Alltrim(Str(SZJ->ZJ_QTAPROV))+" WHERE B2_COD = '"+SZJ->ZJ_COD+"' AND B2_LOCAL = '"+SZJ->ZJ_LOCAL+"' AND D_E_L_E_T_ = '' "
						TcSQLExec(cSQL)
					Else
						cSql := "UPDATE SB2050 SET B2_RESERVA = B2_RESERVA - "+Alltrim(Str(SZJ->ZJ_QTAPROV))+" WHERE B2_COD = '"+SZJ->ZJ_COD+"' AND B2_LOCAL = '"+SZJ->ZJ_LOCAL+"' AND D_E_L_E_T_ = '' "
						TcSQLExec(cSQL)
					EndIf

				EndIf

				DbSelectArea("SZJ")
				While ! RecLock("SZJ",.F.) ; End
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Deleta os itens                                                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbDelete()
				lSZI := .T.
				MsUnLock()

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Acessa o proximo registro                                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SZJ")
				DbSkip()
			End

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ DELETA SZI                                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If  lSZI
				DbSelectArea("SZI")
				While ! RecLock("SZI",.F.) ; End
				DbDelete()
				MsUnLock()
			End
		End
	EndCase

	DbSelectArea("SZI")
	MsUnLock("SZI")
	DbSelectArea("SZJ")
	MsUnLock("SZJ")
	dbCommitAll()

	dbSelectArea("_cTrab")
	USE
	If  File(_cTrab+".DBF")
		Ferase(_cTrab+".DBF")
		Ferase(_cTrab+".NTX")
		Ferase(_cTrab+".CDX")
	End

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ GravaSD3  ¦ Autor ¦                      ¦ Data ¦   .  .   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Funcao para gravar o Movimento Internos Mod. II            ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function GravaSD3(cEmp, cFil, aCab, aItem)

	Local uRet := U_FROPCPRO(cEmp, cFil, "U_GravaSD3", aCab, aItem)

Return uRet

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ GravaSD3  ¦ Autor ¦                      ¦ Data ¦   .  .   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦                                                            ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function GravaSD3(aCab, aItem)

	Local _aAutoErro

	Private lMsHelpAuto	:= .T.
	Private lMsErroAuto	:= .F.
	Private _cLogTxt 		:= ""
	Private _ExecAutoII	:= .T. //Variavel para desativar Execblock velhos
	Private lAutoErrNoFile := .T.

	MSExecAuto({|x,y,z| MATA241(x,y,z)},aCab,aItem)

	If lMsErroAuto

		_aAutoErro 	:= GETAUTOGRLOG()
		_cLogTxt 	:= U_XCONVELOG(_aAutoErro)

		ConOut(_cLogTxt)

		cSql := "UPDATE SZI010 SET ZI_BAIXA = 'N', ZI_ERROLOG = '"+_cLogTxt+"' WHERE ZI_DOC = '"+aCab[1][2]+"' AND D_E_L_E_T_ = '' "
		TcSQLExec(cSQL)

		//DisarmTransaction()
		Return(.F.)

	Else

		cSql := "UPDATE SZI010 SET ZI_BAIXA = 'S', ZI_STTSREQ = 'P', ZI_ERROLOG = '" + _cLogTxt + "', ZI_DTBAIXA = " + ValtoSql(Date()) + ", ZI_HRBAIXA = " + ValtoSql(SUBSTR(Time(),1,5)) + " WHERE ZI_DOC = '" + aCab[1][2] + "' AND D_E_L_E_T_ = '' "
		TcSQLExec(cSQL)

	EndIf

Return(.T.)

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ UltimoDU  ¦ Autor ¦ Fernando             ¦ Data ¦ 09.03.15 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Calcular ultimo dia util do mes - para bloqueio de baixas  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function UltimoDU(_dData)

	//Local nDu := 0
	Local dDt

	dDt := LastDate(_dData)
	If DOW(dDt) <> 1 .and. DOW(dDt) <> 7
		Return(dDt)
	Else
		While DOW(dDt) == 1 .or. DOW(dDt) == 7
			dDt := dDt - 1
		EndDo
	EndIf

Return(dDt)

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B902VCLC  ¦ Autor ¦ Fernando             ¦ Data ¦ 17.02.16 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ validar o campo classe de valor                            ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B902VCLV()

	Local _nPosTag     := aScan(aHeader,{|x| Alltrim(x[2])=="ZJ_TAG"})

	// Por Marcos Alberto Soprani em 24/02/16 para atender a necessidade de algumas áreas que não necessitam controlar Classe de Valor por TAG.
	SZC->(dbSetOrder(1))
	SZC->(dbSeek(xFilial("SZC") + Gdfieldget("ZJ_TAG",n)))
	If !SZC->ZC_VLDTAG $ " /N"

		If ( SubStr(M->ZJ_CLVL,1,2) == "31" .And. EMPTY(aCols[N][_nPosTag]) )

			MsgAlert("Para usar esta classe de valor, é obrigatório a seleção da TAG.","BIA902")
			Return(.F.)

		EndIf

		If !Empty(M->ZI_CLVL) .And. ( M->ZI_CLVL <> M->ZJ_CLVL )

			MsgAlert("Todos os itens da Requisição devem ter a mesma CLASSE DE VALOR.","BIA902")
			Return(.F.)

		EndIf

		//Manter por ultimo - preencher o cabecalho automaticamente com o primeiro item
		If Empty(M->ZI_CLVL)

			M->ZI_CLVL	:= M->ZJ_CLVL
			M->ZI_CC 	:= U_B902BCC(M->ZJ_CLVL)

		EndIf

	EndIf

Return(.T.)

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B902VCLC  ¦ Autor ¦ Fernando             ¦ Data ¦ 17.02.16 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Validar o campo TAG                                        ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B902VTAG()

	SZC->(DbSetOrder(1))
	If !SZC->(DbSeek(XFilial("SZC")+M->ZJ_TAG))

		MsgAlert("TAG inválida ou não existente.","BIA902")
		Return(.F.)

	Else

		// Por Marcos Alberto Soprani em 19/12/16

		CTH->(dbSetOrder(1))
		CTH->(dbSeek(xFilial("CTH") + M->ZI_CLVL))
		If CTH->CTH_YCTRTG == "S"

			// Por Marcos Alberto Soprani em 24/02/16 para atender a necessidade de algumas áreas que não necessitam controlar Classe de Valor por TAG.
			If !SZC->ZC_VLDTAG $ " /N"

				If !Empty(M->ZI_CLVL) .And. ( M->ZI_CLVL <> SZC->ZC_CLVL )

					MsgAlert("Todos os itens da Requisição devem ter a mesma CLASSE DE VALOR."+Chr(13)+Chr(10)+"Informe no cabeçalho a Classe de valor: "+AllTrim(SZC->ZC_CLVL)+".","BIA902")
					Return(.F.)

				EndIf

				//Manter por ultimo - preencher o cabecalho automaticamente com o primeiro item
				If Empty(M->ZI_CLVL)

					M->ZI_CLVL	:= SZC->ZC_CLVL
					M->ZI_CC 	:= U_B902BCC(SZC->ZC_CLVL)

				EndIf

			EndIf

		EndIf

	EndIf

Return(.T.)

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B902VCLC  ¦ Autor ¦ Fernando             ¦ Data ¦ 24.02.16 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦                                                            ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B902VCLC()

	Local I
	Local _nPosTag	:= aScan(aHeader,{|x| Alltrim(x[2])=="ZJ_TAG"})
	Local _nPosCLVL	:= aScan(aHeader,{|x| Alltrim(x[2])=="ZJ_CLVL"})

	For I := 1 to Len(aCols)

		If EMPTY(aCols[I][_nPosTag])

			aCols[I][_nPosCLVL] := M->ZI_CLVL

		EndIf

	Next I

	GetdRefresh()

Return(.T.)

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B902VCOK  ¦ Autor ¦ Fernando             ¦ Data ¦ 24.02.16 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦                                                            ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B902VCOK()

	Local I
	Local _nPosCLVL	:= aScan(aHeader,{|x| Alltrim(x[2])=="ZJ_CLVL"})
	Local _nPosTag	:= aScan(aHeader,{|x| Alltrim(x[2])=="ZJ_TAG"})

	If !Empty(M->ZI_CLVL)

		// Por Marcos Alberto Soprani em 19/12/16
		CTH->(dbSetOrder(1))
		CTH->(dbSeek(xFilial("CTH") + M->ZI_CLVL))
		If CTH->CTH_YCTRTG == "S"

			For I := 1 to Len(aCols)

				If !EMPTY(aCols[I][_nPosCLVL]) .And. ( aCols[I][_nPosCLVL] <> M->ZI_CLVL )

					// Por Marcos Alberto Soprani em 24/02/16 para atender a necessidade de algumas áreas que não necessitam controlar Classe de Valor por TAG.
					SZC->(dbSetOrder(1))
					SZC->(dbSeek(xFilial("SZC") + aCols[I][_nPosTag]))
					If !SZC->ZC_VLDTAG $ " /N"

						MsgAlert("Item com classe de valor diferente do cabeçalho.","BIA902 - B902VCOK")
						Return(.F.)

					EndIf

				EndIf

			Next I

		EndIf

	EndIf

Return(.T.)

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B902BCC  ¦ Autor ¦ Fernando              ¦ Data ¦ 30.12.15 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦  Buscando o centro de custo pela classe de valor - baseado ¦¦¦
¦¦¦          ¦ no BIA478 - para casos onde preenche a classe/tag no item  ¦¦¦
¦¦¦          ¦ primeiro                                                   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B902BCC(cCLVL)

	Local cCC := ""

	cCC := U_B478RTCC(cCLVL)[1]

RETURN(cCC)

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA902GTH  ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 24.02.16 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Tag SEM bloqueio de CLVL, usar CLVL do CABEÇALHO, do con-  ¦¦¦
¦¦¦          ¦ trário usar a CLVL da TAG                                  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA902GTH()

	Local hsClvlRt := M->ZI_CLVL
	Local hsAreaAn := GetArea()

	SZC->(dbSetOrder(1))
	SZC->(dbSeek(xFilial("SZC") + Gdfieldget("ZJ_TAG",n)))
	If SZC->ZC_VLDTAG $ "S"
		hsClvlRt := SZC->ZC_CLVL
	EndIf

	RestArea(hsAreaAn)

Return ( hsClvlRt )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B902VQTD  ¦ Autor ¦ Fernando             ¦ Data ¦ 30.03.16 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Validar o campo Quantidade                                 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B902VQTD()

	Local _aAreaB1 := SB1->(GetArea())
	Local _aAreaBZ := SBZ->(GetArea())
	Local _cProd := Gdfieldget("ZJ_COD",n)
	Local _nQtde := M->ZJ_QUANT
	Local _nMod
	Local lOk := .T.

	SBZ->(DbSetOrder(1))
	If SBZ->(FieldPos("BZ_YINTEGR")) > 0 .And. SBZ->(DbSeek(XFilial("SBZ")+_cProd)) .And. SBZ->BZ_YINTEGR == "S"

		SB1->(DbSetOrder(1))
		If SB1->(DbSeek(XFilial("SB1")+_cProd))

			_nMod := _nQtde % SB1->B1_CONV

			If ( _nQtde < SB1->B1_CONV ) .Or. ( _nMod <> 0 )

				MsgAlert("Fator da Embalagem do Produto: Quantidade requisitada precisa ser múltipla de "+AllTrim(Str(SB1->B1_CONV))+"." ,"BIA902")
				lOk := .F.

			EndIf

		EndIf

	EndIf

	RestArea(_aAreaBZ)
	RestArea(_aAreaB1)

Return(lOk)

Static Function fRetRes(_cDoc)

	Local _cQry	:=	""

	_cQry	+=	"	UPDATE SB2												"
	_cQry	+=	"	SET SB2.B2_RESERVA = SB2.B2_RESERVA + SZJ.ZJ_QTAPROV     "
	_cQry	+=	"	FROM "+RetSqlName("SZI")+" SZI                                         "
	_cQry	+=	"	JOIN "+RetSqlName("SZJ")+" SZJ ON SZI.ZI_FILIAL = SZJ.ZJ_FILIAL        "
	_cQry	+=	"		AND SZI.ZI_DOC = SZJ.ZJ_DOC                         "
	_cQry	+=	"		AND SZI.D_E_L_E_T_ = ''                             "
	_cQry	+=	"		AND SZJ.D_E_L_E_T_ = ''                             "
	_cQry	+=	"	JOIN "+RetSqlName("SB2")+" SB2 ON SB2.B2_FILIAL = SZJ.ZJ_FILIAL        "
	_cQry	+=	"		AND SB2.B2_COD = SZJ.ZJ_COD                         "
	_cQry	+=	"		AND SB2.B2_LOCAL = SZJ.ZJ_LOCAL                     "
	_cQry	+=	"		AND SB2.D_E_L_E_T_ = ''                             "
	_cQry	+=	"	WHERE SZI.ZI_FILIAL = "+ValtoSql(xFilial("SZI"))+"                              "
	_cQry	+=	"		AND SZI.ZI_DOC = "+ValtoSql(_cDoc)+"                        "
	_cQry	+=	"		AND SZI.ZI_BAIXA = 'N'                              "

	TcSqlExec(_cQry)

Return