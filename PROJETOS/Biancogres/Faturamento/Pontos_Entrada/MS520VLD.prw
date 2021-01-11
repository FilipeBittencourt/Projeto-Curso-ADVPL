#include "rwmake.ch"
#include "topconn.ch"
#Include "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ MS520VLD ³ Autor ³ MADALENO              ³ Data ³ 03/10/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Ponto de Entrada na Exclusao da Nota Fiscal SAIDA     .    ³±±
±±³          ³ utilizado para excluir o SUBSTITUICAO TRIBUTARIA           ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Faturamento                              .                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
USER FUNCTION MS520VLD()

LOCAL CRET  := .T. // PODE DELETAR
LOCAL cRET1 := .T. // PODE DELETAR
LOCAL cRET2 := .T. // PODE DELETAR

//OS 3494-16 - Tania c/ aprovação do Fabio
If cEmpAnt == "02"
	Return(.T.)
EndIf

//Ranisses em 11/10/10 para tratar os dois RPO's utilizados pelo Comercial (Producao e FatBianco)
/*
cEnvironment := Upper(AllTrim(getenvserver()))
If !Alltrim(cEnvironment) $ "CARLOS-PROD_PRODUCAO_REMOTO_SIGASLA_SIGASLA3_TESTE2_TESTE3_TESTE4_TESTE5_TESTE6_RANISSES_RANISSES2_RANISSES3_RANISSES4_RANISSES5_FECHAMENTO_RANISSES-PROD_MARCOS-PROD"
	MsgBox("Favor utilizar apenas o ambiente de PRODUCAO para realizar Exclusao de Notas Fiscais!","MS520VLD","ALERT")
	Return(.F.)
EndIf
*/

//************************************************************************************
//         VALIDA PROCESSO DE ST MANUAL
//************************************************************************************

//************************************************************************************
//         VERIFICANDO SE JA FOI GERADO O BORDERO PARA OS TITULOS A RECEBER
//************************************************************************************
CSQL := "SELECT ISNULL(COUNT(E1_NUM),0) AS AUXIL FROM "+RETSQLNAME("SE1")+" "
CSQL += "WHERE	E1_PREFIXO	= '"+SF2->F2_SERIE+"'	AND "
CSQL += "		E1_NUM		= '"+SF2->F2_DOC+"'	AND "
CSQL += "		E1_TIPO		= 'ST'	AND "
CSQL += "		E1_NUMBOR	<>	''		AND "
CSQL += "		E1_FILIAL	=	'"+xFilial('SE1')+"' AND "
CSQL += "		D_E_L_E_T_  = '' "
If chkfile("c_TRAB")
	dbSelectArea("c_TRAB")
	dbCloseArea()
EndIf
TCQUERY CSQL ALIAS "c_TRAB" NEW
IF c_TRAB->AUXIL > 0
	cRET1 := .F.  // NAO PODE DELETAR
END IF

//************************************************************************************
//         VERIFICANDO SE JA FOI GERADO O BORDERO PARA OS TITULOS A PAGAR
//************************************************************************************
CSQL := "SELECT ISNULL(COUNT(E2_NUM),0) AS AUXIL FROM "+RETSQLNAME("SE2")+" "
CSQL += "WHERE	E2_PREFIXO	=	'"+SF2->F2_SERIE+"'	AND "
CSQL += "		E2_NUM		=	'"+SF2->F2_DOC+"'	AND "
CSQL += "		E2_NUMBOR	<>	''		AND "
CSQL += "		E2_TIPO		=	'ST'	AND "
CSQL += "		E2_FILIAL	=	'"+xFilial('SE2')+"' AND "
CSQL += "		D_E_L_E_T_	=	'' "

If chkfile("c_TRAB")
	dbSelectArea("c_TRAB")
	dbCloseArea()
EndIf
TCQUERY CSQL ALIAS "c_TRAB" NEW
IF c_TRAB->AUXIL > 0
	cRET2 := .F.  // NAO PODE DELETAR
END IF

//************************************************************************************
//                            VERIFICANDO SE PODE DELETAR..
//************************************************************************************

If (!cRET1 .Or. !cRET2)

	MSGBOX("A NOTA FISCAL NÃO PODERÁ SER EXCLUÍDA, POIS EXISTE TITULO DE SUBSTITUICAO TRIBUTARIA JÁ BAIXADO!","MS520VLD","STOP")
	CRET := .F.	

EndIf

/*IF cRET1 .AND. cRET2 // PODE DELETAR
	CRET := .T.
	
	CSQL := "UPDATE "+RETSQLNAME("SE1")+" SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "
	CSQL += "WHERE	E1_PREFIXO = '"+SF2->F2_SERIE+"' AND "
	CSQL += "		E1_NUM = '"+SF2->F2_DOC+"' AND "
	CSQL += "		E1_TIPO = 'ST' AND "
	CSQL += "		D_E_L_E_T_  = '' "
	TCSqlExec(CSQL)
	
	CSQL := "UPDATE "+RETSQLNAME("SE2")+" SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "
	CSQL += "WHERE	E2_PREFIXO = '"+SF2->F2_SERIE+"' AND "
	CSQL += "		E2_NUM = '"+SF2->F2_DOC+"' AND "
	CSQL += "		E2_TIPO = 'ST' AND "
	CSQL += "		D_E_L_E_T_  = '' "
	TCSqlExec(CSQL)
ELSE
	MSGBOX("A NOTA FISCAL NÃO PODERÁ SER EXCLUÍDA, POIS EXISTE TITULO DE SUBSTITUICAO TRIBUTARIA JÁ BAIXADO!","MS520VLD","STOP")
	CRET := .F.
END IF*/

//************************************************************************************
//         VALIDA PROCESSO DE ST AUTOMATICA
//************************************************************************************

//Verifica o status da Guia de ST antes excluir a NF
DbSelectArea('SF6')
DbSetOrder(3)
If DbSeek(xFilial('SF6')+'2'+'N'+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA,.T.)
	
	//Verifica se a Guia foi Processada
	If SF6->F6_PROCESS == "1"
		CRET := MsgBox("FOI GERADO O ARQUIVO XML PARA PAGAMENTO DA SUBSTITUICAO TRIBUTÁRIA. DESEJA PROSSEGUIR COM A EXCLUSÃO DA NF?","MS520VLD","YesNo")
	EndIf
	
	//Verifica se o Titulo no Contas a Pagar foi pago
	CSQL := "SELECT COUNT(*) AS QUANT FROM "+RetSqlName("SE2")+" "
	CSQL += "WHERE E2_FILIAL = "+xFilial('SE2')+" AND E2_PREFIXO+E2_NUM IN (SELECT F6_NUMERO FROM "+RetSqlName("SF6")+" WHERE F6_FILIAL = "+xFilial('SF6')+" AND F6_SERIE = '"+SF2->F2_SERIE+"' AND F6_DOC = '"+SF2->F2_DOC+"' AND D_E_L_E_T_ = '' ) AND E2_NUMBOR <> '' AND D_E_L_E_T_ = '' "
	If chkfile("TRB")
		dbSelectArea("TRB")
		dbCloseArea()
	EndIf
	TCQUERY CSQL ALIAS "TRB" NEW
	IF TRB->QUANT > 0
		MSGBOX("A NOTA FISCAL NÃO PODERÁ SER EXCLUÍDA, POIS EXISTE TITULO DE SUBSTITUICAO TRIBUTARIA JÁ BAIXADO!","MS520VLD","STOP")
		CRET := .F.
	END IF
	
EndIf

CRET := ValidSE2()
If (CRET)
	CRET := ValidSF6()
EndIf



// Tratamento incluído por Marcos Alberto Soprani em 28/08/14 conforme OS effettivo 1605-14
If !SF2->F2_TIPO $ "D/B"
	
	kwCodEmp := ""
	kwCgc    := ""
	If SF2->F2_CLIENTE == "000481"         // Biancogres
		kwCodEmp := "01"
		kwCgc    := "02077546000176"
	ElseIf SF2->F2_CLIENTE == "004536"     // Incesa
		kwCodEmp := "05"
		kwCgc    := "04917232000160"
	ElseIf SF2->F2_CLIENTE == "010064"     // LM
		kwCodEmp := "07"
		kwCgc    := "10524837000193"
	ElseIf SF2->F2_CLIENTE == "014395"     // Mundi
		kwCodEmp := "13"
		kwCgc    := "14086214000137"
	ElseIf SF2->F2_CLIENTE == "008615"     // Vitcer
		kwCodEmp := "14"
		kwCgc    := "08930868000100"
	EndIf
	
	QY003 := " SELECT A2_COD CLIFOR, A2_LOJA LOJA, A2_CGC CGC
	QY003 += "   FROM " + RetSqlName("SA2")
	QY003 += "  WHERE A2_FILIAL = '"+xFilial("SA2")+"'
	QY003 += "    AND A2_CGC = '"+SM0->M0_CGC+"'
	QY003 += "    AND D_E_L_E_T_ = ' '
	QYIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,QY003),'QY03',.T.,.T.)
	kwCliFor := QY03->CLIFOR
	kwLoja   := QY03->LOJA
	kwCnpj   := QY03->CGC
	QY03->(dbCloseArea())
	Ferase(QYIndex+GetDBExtension())
	Ferase(QYIndex+OrdBagExt())
	
	If !Empty(kwCodEmp)
		RT005 := " SELECT COUNT(*) CONTAD
		RT005 += "   FROM SF1"+kwCodEmp+"0
		RT005 += "  WHERE F1_DOC = '"+SF2->F2_DOC+"'
		RT005 += "    AND F1_SERIE = '"+SF2->F2_SERIE+"'
		RT005 += "    AND F1_EMISSAO = '"+dtos(SF2->F2_EMISSAO)+"'
		RT005 += "    AND F1_FORNECE = '"+kwCliFor+"'
		RT005 += "    AND F1_LOJA = '"+kwLoja+"'
		RT005 += "    AND D_E_L_E_T_ = ' '
		RTIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,RT005),'RT05',.T.,.T.)
		If RT05->CONTAD > 0
			MsgSTOP("Nota fiscal emitada INTRAGRUPO foi localizada na empresa DESTINO! Será necessário estornar o lançamento da nota fiscal na empresa DESTINO, antes de excluir a nota na empresa ORIGEM.","MS520VLD")
			cRet := .F.
		EndIf
		RT05->(dbCloseArea())
		Ferase(RTIndex+GetDBExtension())
		Ferase(RTIndex+OrdBagExt())
	EndIf
	
EndIf

//  Implementado em 20/02/13 por Marcos Alberto Soprani para auxilio do fechamento de estoque vs movimentações retroativas que poderiam
// acontecer pelo fato de o parâmtro MV_ULMES necessitar permanecer em aberto até que o fechamento de estoque esteja concluído
If SF2->F2_EMISSAO <= GetMv("MV_YULMES")
	MsgSTOP("Impossível prosseguir, pois este movimento interfere no fechamento de custo!!! Favor verificar com a contabilidade!!!","MS520VLD")
	cRet := .F.
EndIf

//Fecha arquivo temporario
If chkfile("TRB")
	dbSelectArea("TRB")
	dbCloseArea()
EndIf

If chkfile("c_TRAB")
	dbSelectArea("c_TRAB")
	dbCloseArea()
EndIf

//Rubens Junior (FACILE)
//Validar se existe nota de entrada na LM refente a nota que esta sendo excluida
If CRET
	CRET := ValidNf()
	If !CRET
		MsgInfo("Ainda Existe Nota Fiscal de Entrada do Documento "+SF2->F2_DOC+" na Empresa LM. Favor Verificar antes de Excluir!")
	EndIf
EndIf

//RUBENS JUNIOR (FACILE SISTEMAS) OS:1726-13 21-02-14
If CRET
	MotivoCanc()
EndIf

RETURN(CRET)


/*
##############################################################################################################
# PROGRAMA...: MotivoCac
# AUTOR......: Rubens Junior (FACILE SISTEMAS)
# DATA.......: 21/02/2014
# DESCRICAO..: Preenchimento do motivo de cancelamento da NF
##############################################################################################################
*/
Static Function MotivoCanc()

Private nTela := .T.
Private nMot := space(3)

While nTela
	DEFINE MSDIALOG oDlg TITLE "Motivo Cancelamento Nota" FROM 000, 000  TO 060, 270 COLORS 0, 16777215 PIXEL
	
	@ 006, 005 SAY oSay1 PROMPT "Informe o código do motivo do Cancelamento da NF: " +SF2->F2_DOC SIZE 090, 015 OF oDlg COLORS 0, 16777215 PIXEL
	@ 004, 103 MSGET oGet1 VAR nMot SIZE 027, 010 OF oDlg PICTURE "@R999" COLORS 0, 16777215 F3 "ZY" Valid ckMotivo(nMot)  PIXEL
	DEFINE SBUTTON oSButton1 FROM 015, 103 TYPE 01 OF oDlg ENABLE ACTION fGrava()
	
	ACTIVATE MSDIALOG oDlg CENTERED
End

return

//--------------------------------------------------------------------
Static Function fGrava()

If Alltrim(nMot) <> ""
	DbSelectArea("SF3")
	DbSetOrder(4)
	If DbSeek(xFilial("SF3")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE)		
		RecLock("SF3",.F.)
		SF3->F3_YMOTIVO	:= nMot
		MsUnlock()
		nRet  := 1
		nTela := .F.
		Close(oDlg)
	Else	
		nRet  := 1
		nTela := .F.
		Close(oDlg)		
	EndIf
	DbCloseArea("SF3")
Else
	nRet  := 0
	MsgAlert("Favor informar um código valido!")
EndIf

Return

//--------------------------------------------------------------------
Static Function ckMotivo(nMot)

Local cAreaAnt := GetArea()
Local lRetor := .F.
cMotivo := nMot

SX005 := ""
SX005 += "SELECT X5_DESCRI           "
SX005 += "FROM "+RetSqlName("SX5") + " SX5 "
SX005 += "WHERE SX5.X5_FILIAL = '"+xFilial("SX5")+"' "
SX005 += "AND SX5.X5_TABELA = 'ZY'   "
SX005 += "AND SX5.X5_CHAVE = '"+cMotivo+"' "
SX005 += "AND SX5.D_E_L_E_T_ = ''	"
dbUseArea(.T.,"TOPCONN",TcGenQry(,,SX005),'_SX05',.T.,.T.)
DBSelectArea('_SX05')
dbGoTop()

lRetor := (!Eof())

if(!lRetor)
	MsgAlert("Favor informar um código valido!")
EndiF

dbCloseArea('_SX05')
RestArea(cAreaAnt)
Return lRetor
//--------------------------------------------------------------------

/*
##############################################################################################################
# PROGRAMA...: ValidNf
# AUTOR......: Rubens Junior (FACILE)
# DATA.......: 10/09/2013
# DESCRICAO..: Antes de Excluir a NF valida se ja foi excluida a entrada na empresa LM
##############################################################################################################
# ALTERACAO..: 21/04/2019
# AUTOR......: BARBARA COELHO
# MOTIVO.....: CORREÇÃO DE VALIDAÇÃO DE NF DE ENTRADA NA LM REFERENTE A SAIDA DA BIANCOGRES
##############################################################################################################
*/
Static Function ValidNf()
Local lRet := .T.
Local CSQL := ''
Local cFornec := ''

If cEmpAnt <> "07" .And. SF2->F2_CLIENTE == "010064"
	If cEmpAnt == '01'
    	cFornec := '000534'
    elseif cEmpAnt == '05'
    	cFornec := '002912'
    elseif cEmpAnt == '14'
    	cFornec := '002912'
    elseif cEmpAnt == '13'
    	cFornec := '004695'
    endif
    
	CSQL += " SELECT * "
	CSQL += " FROM SF3070 SF3 " 
	CSQL += " WHERE SF3.F3_FILIAL	= '"+xFilial("SF3")+"' 	AND " 
	CSQL += " 		SF3.F3_NFISCAL	= '"+SF2->F2_DOC+"'  	AND " 
	CSQL += " 		SF3.F3_SERIE	= '"+SF2->F2_SERIE+"' 	AND "
	CSQL += " 		SUBSTRING(SF3.F3_CFO,1,1) IN ('1','2','3')	AND "//CFOPS DE ENTRADA
	
	CSQL += "		SF3.F3_CLIEFOR 	= '"+ cFornec +"'	AND "
	CSQL += "		SF3.F3_DTCANC 	= '' AND " 
	CSQL += "		SF3.D_E_L_E_T_	= '' "	
	
	TCQUERY CSQL ALIAS "QRY" NEW	
	
	IF !QRY->(EOF())  		//ENCONTROU A NOTA NA EMPRESA LM?
		lRet := .F.
	Else
		lRet := .T.        //SE NAO ENCONTRAR NADA NA EMPRESA 07, PODE EXCLUIR A NF
	EndIf	
	QRY->(DbCloseArea())

EndIf

Return lRet


Static Function ValidSE2()

	Local cQuery 		:= ""
	Local cAliasTmp		:= Nil
	Local lRet			:= .T.
	Local aArea			:= GetArea()
	Local cFilSE2		:= xFilial('SF2')
	
	
	If (cEmpAnt == '07' .And. cFilAnt == '01')
		If (SF2->F2_CLIENTE  == '029954') //LM SP
			
			cFilSE2 := '05'
			
			cQuery := "SELECT TOTAL=ISNULL(COUNT(E2_NUM),0)  FROM "+RETSQLNAME("SE2")+"		 		"
			cQuery += "WHERE	E2_PREFIXO	=	'"+SF2->F2_SERIE+"'			AND 					"
			cQuery += "			E2_NUM		=	'"+SF2->F2_DOC+"'			AND 					"
			cQuery += "			E2_NUMBOR	<>	''							AND 					"
			cQuery += "			E2_TIPO		=	'ST'						AND 					"
			cQuery += "			E2_FILIAL	=	'"+cFilSE2+"' 				AND 					"
			cQuery += "			D_E_L_E_T_	=	'' 													"
			
			cAliasTmp := GetNextAlias()
			TcQuery cQuery New Alias (cAliasTmp)
			
			If (!(cAliasTmp)->(Eof()))	
				If ((cAliasTmp)->TOTAL > 0)
					MsgBox("A NOTA FISCAL NÃO PODERÁ SER EXCLUÍDA, POIS EXISTE TITULO DE SUBSTITUICAO TRIBUTARIA JÁ BAIXADO! FILIAL: 05","MS520VLD","STOP")
					lRet := .F.
				EndIf
			EndIf
			
		EndIf
	EndIf
	
	RestArea(aArea)
		
Return lRet


Static Function ValidSF6()
	
	Local cQuery 		:= ""
	Local lRet			:= .T.
	Local aArea			:= GetArea()
	Local lRet			:= .T.
	Local cFilSF6		:= xFilial('SF6')
	Local cFilSE2		:= xFilial('SF2')
	
	
	If (cEmpAnt == '07' .And. cFilAnt == '01')
		If (SF2->F2_CLIENTE  == '029954') //LM SP
			
			cFilSF6 := '05'
			cFilSE2 := '05'
			
			DbSelectArea('SF6')
			SF6->(DbSetOrder(3))
			
			If SF6->(DbSeek(cFilSF6+'2'+'N'+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA,.T.))
				
				//Verifica se a Guia foi Processada
				If SF6->F6_PROCESS == "1"
					lRet := MsgBox("FOI GERADO O ARQUIVO XML PARA PAGAMENTO DA SUBSTITUICAO TRIBUTÁRIA, FILIAL: 05. DESEJA PROSSEGUIR COM A EXCLUSÃO DA NF?","MS520VLD","YesNo")
				EndIf
					
				//Verifica se o Titulo no Contas a Pagar foi pago
				cQuery := "SELECT TOTAL=COUNT(*)  FROM "+RetSqlName("SE2")+" "
				cQuery += "WHERE E2_FILIAL = "+cFilSE2+" AND E2_PREFIXO+E2_NUM IN (SELECT F6_NUMERO FROM "+RetSqlName("SF6")+" WHERE F6_FILIAL = "+cFilSF6+" AND F6_SERIE = '"+SF2->F2_SERIE+"' AND F6_DOC = '"+SF2->F2_DOC+"' AND D_E_L_E_T_ = '' ) AND E2_NUMBOR <> '' AND D_E_L_E_T_ = '' "
				
				cAliasTmp := GetNextAlias()
				TcQuery cQuery New Alias (cAliasTmp)
				
				If (!(cAliasTmp)->(Eof()))	
					If ((cAliasTmp)->TOTAL > 0)
						MsgBox("A NOTA FISCAL NÃO PODERÁ SER EXCLUÍDA, POIS EXISTE TITULO DE SUBSTITUICAO TRIBUTARIA JÁ BAIXADO!, FILIAL: 05","MS520VLD","STOP")
						lRet := .F.
					EndIf
				EndIf
				
			EndIf
			
		EndIf
	EndIf	
	
	RestArea(aArea)

Return lRet
