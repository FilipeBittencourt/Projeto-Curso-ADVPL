#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} BFTE01MC
@description Calculo de Margem Operacional para tela de proposta de engenharia
@author Fernando Rocha
@since 18/10/2016
@type function
/*/

User Function BFTE01MC()

U_BIAMsgRun("Calculando Margem Operacional...",,{|| MargemProc()})

Return

Static Function MargemProc()
Local cSQL   	:= ""
Local nFator 	:= 0

Local nCPfix	:= 0
Local nCPvar 	:= 0
Local nDAO 		:= 0
Local nDCF 		:= 0
Local nDCVc 	:= 0
Local nDCVCLI 	:= 0
Local nDCVFAB 	:= 0
Local nIMP 		:= 0
Local nINSS 	:= 0
Local nMB 		:= 0
Local nMC 		:= 0
Local nMO 		:= 0
Local nPercMO 	:= 0
Local nRB		:= 0
Local nRL		:= 0
Local nVOL		:= 0
Local nVP		:= 0
Local oFont1 	:= TFont():New("Lucida Sans Typewriter",,018,,.F.,,,,,.F.,.F.)
Local oFont2 	:= TFont():New("Lucida Sans Typewriter",,018,,.T.,,,,,.F.,.F.)
Local oGroup2
Local oGroup3
Local oGroup4
Local oGroup5
Local oGroup6
Local oSay1
Local oSay2
Local oSay3
Local oSay4
Local oSay5
Local oSay6
Local oSay7
Local oSay8
Local oSay9
Local oSay10
Local oSay11
Local oSay12
Local oSay13
Local oSay14
Local oSay15
Local oSay16
Local oSay17
Local oSay18
Local _cTes

Local I
Local cAliasTmp

Static oDlg

cSQL := ""

/*cSQL += " SELECT Z68_CODCLI, Z68_COND, SUM(Z69_QTDVEN) QUANTIDADE, SUM(Z69_VALOR) VALOR                    "+CRLF
cSQL += " 	,SUM(COMISSAO) COMISSAO, SUM(ROUND((Z69_QTDVEN*CVU),2)) CV, SUM(ROUND((Z69_QTDVEN*CFU),2)) CF  "+CRLF
cSQL += " FROM 														                                       "+CRLF
cSQL += " (                                                                                                "+CRLF
cSQL += " SELECT 													                                       "+CRLF
cSQL += " CVU = (SELECT dbo.FN_CV('"+CEMPANT+"',Z69_CODPRO,Z68_EMISSA,Z68_EMISSA)),								   "+CRLF
cSQL += " CFU = (SELECT dbo.FN_CF('"+CEMPANT+"',Z69_CODPRO,Z68_EMISSA,Z68_EMISSA)),								   "+CRLF
cSQL += " Z69_QTDVEN, Z69_VALOR, 			                                                               "+CRLF
cSQL += " ROUND(((Z69_VALOR*5)/100),2) AS COMISSAO,                                                        "+CRLF
cSQL += " Z68_COND,                                                                                        "+CRLF
cSQL += " Z68_EMISSA,                                                                                      "+CRLF
cSQL += " Z68_CODCLI                                                                                       "+CRLF
cSQL += "                                                                                                  "+CRLF
cSQL += " FROM Z68010 Z68, Z69010 Z69                                                                      "+CRLF
cSQL += " WHERE	Z68_NUM			= Z69_NUM AND                                                              "+CRLF
cSQL += " 		Z68_REV			= Z69_REV AND                                                              "+CRLF
cSQL += " 		Z68_NUM			= '"+Z68->Z68_NUM+"' AND                                                   "+CRLF
cSQL += " 		Z68_REV			= '"+Z68->Z68_REV+"' AND                                                   "+CRLF
cSQL += " 		Z69.D_E_L_E_T_ 	= '' 			AND	                                                       "+CRLF
cSQL += " 		Z68.D_E_L_E_T_ 	= ''                                                                       "+CRLF
cSQL += " ) AS TMP		                                                                                   "+CRLF
cSQL += " GROUP BY Z68_CODCLI, Z68_COND                                                                    "+CRLF

If chkfile("_TMP")
	dbSelectArea("_TMP")
	dbCloseArea()
EndIf
TCQUERY cSQL ALIAS "_TMP" NEW*/

_nPosQtd := aScan(AHeader,{|x| AllTrim(x[2]) == "Z69_QTDVEN"})
_nPosVal := aScan(AHeader,{|x| AllTrim(x[2]) == "Z69_VALOR"})
_nPosPro := aScan(AHeader,{|x| AllTrim(x[2]) == "Z69_CODPRO"})

__SQUANTIDADE 	:= 0
__SVALOR 		:= 0
__SCOMIS 		:= 0
__SCV			:= 0
__SCF			:= 0	

For I := 1 To Len(ACols)

	If !ACols[I][Len(AHeader)+1]
	
		//Quantidade
		__SQUANTIDADE 	+= ACols[I][_nPosQtd]
		
		//Valor
		__SVALOR 		+= ACols[I][_nPosVal]
		
		
		//CVU
		cAliasTmp := GetNextAlias()
		BeginSql Alias cAliasTmp
		%NoParser%
		
		SELECT CVU = (SELECT dbo.FN_CV(%EXP:AllTrim(CEMPANT)%,%Exp:ACols[I][_nPosPro]%,%Exp:M->Z68_EMISSA%,%Exp:M->Z68_EMISSA%))
			
		EndSql
		
		__CVU := (cAliasTmp)->CVU
		
		(cAliasTmp)->(DbCloseArea())
		
		//CFU
		cAliasTmp := GetNextAlias()
		BeginSql Alias cAliasTmp
		%NoParser%
		
		SELECT CFU = (SELECT dbo.FN_CF(%EXP:AllTrim(CEMPANT)%,%Exp:ACols[I][_nPosPro]%,%Exp:M->Z68_EMISSA%,%Exp:M->Z68_EMISSA%))
			
		EndSql
		
		__CFU := (cAliasTmp)->CFU
		
		(cAliasTmp)->(DbCloseArea())
		
		//COMISSAO
		_cComis1 	:= POSICIONE("SA3",1,XFilial("SA3")+M->Z68_CODVEN,"A3_COMIS")   //comissao do cabecalho
		__COMIS		:= U_fCalComi(_cComis1,ACols[I][_nPosPro])
		
		__SCOMIS	+= ROUND(((ACols[I][_nPosVal] * __COMIS)/100),2) 
		
		//CV
		__SCV		+= ROUND((ACols[I][_nPosQtd] * __CVU),2)
		
		//CF
		__SCF		+= ROUND((ACols[I][_nPosQtd] * __CFU),2)
	
	
	EndIf

Next I


//Calcula MO somente nas vendas para o Cliente Final
If cEmpAnt <> "07" .And. Alltrim(M->Z68_CODCLI) == "010064"
	Msgbox("A Margem Operacional (MO) é calculada somente nas vendas para o Cliente final!","BFTE01MC","STOP")
	Return
EndIf

cSQL := ""
cSQL += "SELECT E4_YMEDIA as PZM FROM SE4010 WHERE E4_CODIGO = "+M->Z68_COND+" AND D_E_L_E_T_ = ''" + CRLF

If chkfile("_TMP2")
	dbSelectArea("_TMP2")
	dbCloseArea()
EndIf
TCQUERY cSQL ALIAS "_TMP2" NEW

//Empresa/Marca
_cMarca := AllTrim(CEMPANT)+AllTrim(CFILANT)

nFator	:= U_fBuscaTxBI(_cMarca,"TXF",DTOS(M->Z68_EMISSA))

IF nFator == 0
	MsgBox("Favor verificar o preenchimento da tabela Parametros BI (Z40), pois a Taxa Financeira (TXF) esta vencida para a Marca "+_cMarca+". Entre em contato com a Controladoria ou Direção Administrativa.","BFTE01MC","STOP")	
	Return
EndIf

cSQL := ""
cSQL += "SELECT ISNULL(Z40_PERC,0) PERC FROM "+RetSqlName("Z40")+" WHERE Z40_MARCA = '"+_cMarca+"' AND Z40_TIPO = 'DAO' AND Z40_DATDE <= '"+dtos(dDataBase)+"' AND Z40_DATATE >= '"+dtos(dDataBase)+"' AND D_E_L_E_T_ = '' "
If chkfile("_DAO")
	dbSelectArea("_DAO")
	dbCloseArea()
EndIf
TCQUERY cSQL ALIAS "_DAO" NEW

cSQL := ""
cSQL += "SELECT ISNULL(Z40_PERC,0) PERC FROM "+RetSqlName("Z40")+" WHERE Z40_MARCA = '"+_cMarca+"' AND Z40_TIPO = 'DCF' AND Z40_DATDE <= '"+dtos(dDataBase)+"' AND Z40_DATATE >= '"+dtos(dDataBase)+"' AND D_E_L_E_T_ = '' "
If chkfile("_DCF")
	dbSelectArea("_DCF")
	dbCloseArea()
EndIf
TCQUERY cSQL ALIAS "_DCF" NEW

cSQL := ""
cSQL += "SELECT ISNULL(Z40_PERC,0) PERC FROM "+RetSqlName("Z40")+" WHERE Z40_MARCA = '"+_cMarca+"' AND Z40_TIPO = 'DVi' AND Z40_DATDE <= '"+dtos(dDataBase)+"' AND Z40_DATATE >= '"+dtos(dDataBase)+"' AND D_E_L_E_T_ = '' "
If chkfile("_DCVI")
	dbSelectArea("_DCVI")
	dbCloseArea()
EndIf
TCQUERY cSQL ALIAS "_DCVI" NEW

cSQL := ""
cSQL += "SELECT ISNULL(Z40_PERC,0) PERC FROM "+RetSqlName("Z40")+" WHERE Z40_MARCA = '"+_cMarca+"' AND Z40_TIPO = 'DVp' AND Z40_DATDE <= '"+dtos(dDataBase)+"' AND Z40_DATATE >= '"+dtos(dDataBase)+"' AND D_E_L_E_T_ = '' "
If chkfile("_DCVP")
	dbSelectArea("_DCVP")
	dbCloseArea()
EndIf
TCQUERY cSQL ALIAS "_DCVP" NEW

cSQL := ""
cSQL += "SELECT ISNULL(Z40_PERC,0) PERC FROM "+RetSqlName("Z40")+" WHERE Z40_MARCA = '"+_cMarca+"' AND Z40_TIPO = 'INS' AND Z40_DATDE <= '"+dtos(dDataBase)+"' AND Z40_DATATE >= '"+dtos(dDataBase)+"' AND D_E_L_E_T_ = '' "
If chkfile("_INSS")
	dbSelectArea("_INSS")
	dbCloseArea()
EndIf
TCQUERY cSQL ALIAS "_INSS" NEW

//Informacoes do Pedido
nVOL		:= __SQUANTIDADE
nRB			:= __SVALOR

//Impostos
_nImposto := 0
_nDescZF := 0

//Comissao
_nComissao := 0

For I := 1 To Len(ACols)

	If !ACols[I][Len(AHeader)+1]
		
		//TES
		_cTes		:= MaTesInt(2,"N ",M->Z68_CODCLI,M->Z68_LOJCLI,"C",ACols[I][_nPosPro])
		
		_aImposto	:= U_fGetImp({"IT_ALIQICM","IT_ALIQPIS","IT_ALIQCOF","IT_DESCZF"}, M->Z68_CODCLI, M->Z68_LOJCLI, ACols[I][_nPosPro], _cTes, 0, 0, 0)
		
		//Pegando a aliquota de ICMS do cabecalho da proposta que ja contem as regras
		_aImposto[1] := M->Z68_ALIQ
		
		_nImposto	+= (ACols[I][_nPosVal] * _aImposto[1])/100 + (ACols[I][_nPosVal] * _aImposto[2])/100 + (ACols[I][_nPosVal] * _aImposto[3])/100
		
		_nDescZF 	+= _aImposto[4]
		
		
		//Calculo de comissao temporario
		_nAComis := POSICIONE("SA3",1,XFilial("SA3")+M->Z68_CODVEN,"A3_COMIS")   //comissao do cabecalho
		_nAComis := U_fCalComi(_nAComis,ACols[I][_nPosPro])
		
		_nComissao += (ACols[I][_nPosVal] * _nAComis)/100
		
	EndIf
	
Next I

//Calculo da RL
nVP			:= Round((nRB)/((1+nFator)^_TMP2->PZM),2)
nIMP		:= _nImposto
nINSS		:= Round(((_INSS->PERC*(nRB - _nDescZF))/100),2)
nRL			:= nVP - (nIMP + nINSS)

//Calculo da MC
nCPvar 		:= __SCV
nMC 		:= nRL - nCPvar

//Calculo da MB
nCPfix 		:= __SCF
nMB 		:= nMC - nCPfix

//Calculo da MO
nDAO 		:= Round((_DAO->PERC*nRB)/100,2)
nDCF 		:= Round((_DCF->PERC*nRB)/100,2)
nDCVc 		:= _nComissao
nDCVCLI 	:= Round((_DCVI->PERC*nRB)/100,2)
nDCVFAB		:= Round((_DCVP->PERC*nRB)/100,2)
nMO 		:= nMB - (nDAO+nDCF+nDCVc+nDCVCLI+nDCVFAB)
nPercMO		:= Round((nMO/nRL)*100,2)
rPercMO		:= nPercMO

nVOL		:= Transform(nVOL,		"@E 999,999,999.99")
nRB			:= Transform(nRB,		"@E 999,999,999.99")
nVP			:= Transform(nVP,		"@E 999,999,999.99")
nIMP		:= Transform(nIMP,		"@E 999,999,999.99")
nINSS 		:= Transform(nINSS, 	"@E 999,999,999.99")
nRL 		:= Transform(nRL, 		"@E 999,999,999.99")
nCPvar 		:= Transform(nCPvar,	"@E 999,999,999.99")
nMC 		:= Transform(nMC, 		"@E 999,999,999.99")
nCPfix 		:= Transform(nCPfix,	"@E 999,999,999.99")
nMB 		:= Transform(nMB, 		"@E 999,999,999.99")
nDAO 		:= Transform(nDAO, 		"@E 999,999,999.99")
nDCF 		:= Transform(nDCF, 		"@E 999,999,999.99")
nDCVc 		:= Transform(nDCVc, 	"@E 999,999,999.99")
nDCVCLI		:= Transform(nDCVCLI,	"@E 999,999,999.99")
nDCVFAB		:= Transform(nDCVFAB, 	"@E 999,999,999.99")
nMO			:= Transform(nMO, 		"@E 999,999,999.99")
nPercMO		:= Transform(nPercMO, 	"@E 999,999,999.99")
       
//Prazo Medio de Pagamento
nPrzMedio 	:= U_BF01PRZ()
nPrzMedio	:= Transform(nPrzMedio, "@E 99,999,999,999")

__nRight := 160
__nTop := -147

//Exibicao da Tela
DEFINE MSDIALOG oDlg TITLE "Cálculo Margem Operacional (MO)" FROM 000, 000  TO 330, 665 COLORS 0, 16777215 PIXEL

@ 008, 010 GROUP oGroup2 TO 042, 163 OF oDlg COLOR 0, 16777215 PIXEL
@ 048, 010 GROUP oGroup3 TO 110, 163 OF oDlg COLOR 0, 16777215 PIXEL
@ 115, 010 GROUP oGroup4 TO 149, 163 OF oDlg COLOR 0, 16777215 PIXEL

@ 156 + __nTop, 010 + __nRight GROUP oGroup5 TO 190 + __nTop, 163 + __nRight OF oDlg COLOR 0, 16777215 PIXEL
@ 196 + __nTop, 010 + __nRight GROUP oGroup6 TO 308 + __nTop, 163 + __nRight OF oDlg COLOR 0, 16777215 PIXEL

@ 017, 012 SAY oSay1 PROMPT "Volume(VOL)         " OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
@ 017, 101 SAY nVOL  OF oDlg COLORS 0, 16777215 FONT oFont1 PIXEL

@ 030, 012 SAY oSay2 PROMPT "Receita Bruta(RB)    " OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
@ 030, 101 SAY nRB   OF oDlg COLORS 0, 16777215 FONT oFont1 PIXEL

@ 057, 012 SAY oSay3 PROMPT "Valor Presente    (VP)+" OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
@ 057, 101 SAY nVP 	  OF oDlg COLORS 0, 16777215 FONT oFont1 PIXEL

@ 070, 012 SAY oSay4 PROMPT "PIS+COFINS+ICMS  (IMP)-" OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
@ 070, 101 SAY nIMP  OF oDlg COLORS 0, 16777215 FONT oFont1 PIXEL

@ 083, 012 SAY oSay5 PROMPT "%INSS Deson.     (IMP)-" OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
@ 083, 101 SAY nINSS OF oDlg COLORS 0, 16777215 FONT oFont1 PIXEL

@ 096, 012 SAY oSay6 PROMPT "Receita Líquida   (RL)=" OF oDlg FONT oFont2 COLORS 0, 16777215 PIXEL
@ 096, 101 SAY nRL OF oDlg COLORS 0, 16777215 FONT oFont2 PIXEL

@ 123, 012 SAY oSay7 PROMPT "Custo Variável (CPvar)-" OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
@ 123, 101 SAY nCPvar OF oDlg COLORS 0, 16777215 FONT oFont1 PIXEL

@ 136, 012 SAY oSay8 PROMPT "Margem Contrib.   (MC)=" OF oDlg FONT oFont2 COLORS 0, 16777215 PIXEL
@ 136, 101 SAY nMC OF oDlg COLORS 0, 16777215 FONT oFont2 PIXEL

@ 163 + __nTop, 012 + __nRight SAY oSay9 PROMPT "Custo Fixo     (CPfix)-" OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
@ 163 + __nTop, 101 + __nRight SAY nCPfix OF oDlg COLORS 0, 16777215 FONT oFont1 PIXEL

@ 176 + __nTop, 012 + __nRight SAY oSay10 PROMPT "Margem Bruta      (MB)=" OF oDlg FONT oFont2 COLORS 0, 16777215 PIXEL
@ 176 + __nTop, 101 + __nRight SAY nMB OF oDlg COLORS 0, 16777215 FONT oFont2 PIXEL

@ 204 + __nTop, 012 + __nRight SAY oSay11 PROMPT "Desp. Adm. Oper. (DAO)-" OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
@ 204 + __nTop, 101 + __nRight SAY nDAO OF oDlg COLORS 0, 16777215 FONT oFont1 PIXEL

@ 217 + __nTop, 012 + __nRight SAY oSay12 PROMPT "Desp. Com. Fixa  (DCF)-" OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
@ 217 + __nTop, 101 + __nRight SAY nDCF OF oDlg COLORS 0, 16777215 FONT oFont1 PIXEL

@ 230 + __nTop, 012 + __nRight SAY oSay13 PROMPT "Comissão        (DCVc)-" OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
@ 230 + __nTop, 101 + __nRight SAY nDCVc OF oDlg COLORS 0, 16777215 FONT oFont1 PIXEL

@ 243 + __nTop, 012 + __nRight SAY oSay14 PROMPT "Invest. Cli.  (DCVCLI)-" OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
@ 243 + __nTop, 101 + __nRight SAY nDCVCLI OF oDlg COLORS 0, 16777215 FONT oFont1 PIXEL

@ 256 + __nTop, 012 + __nRight SAY oSay15 PROMPT "Invest. Emp.  (DCVFAB)-" OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
@ 256 + __nTop, 101 + __nRight SAY nDCVFAB OF oDlg COLORS 0, 16777215 FONT oFont1 PIXEL

@ 269 + __nTop, 012 + __nRight SAY oSay16 PROMPT "Margem Oper.      (MO)=" OF oDlg FONT oFont2 COLORS 0, 16777215 PIXEL
@ 269 + __nTop, 101 + __nRight SAY nMO OF oDlg COLORS 0, 16777215 FONT oFont2 PIXEL

@ 282 + __nTop, 012 + __nRight SAY oSay17 PROMPT "% Margem Oper.   (MO%)=" OF oDlg FONT oFont2 COLORS 0, 16777215 PIXEL
@ 282 + __nTop, 101 + __nRight SAY nPercMO OF oDlg COLORS 0, 16777215 FONT oFont2 PIXEL

@ 295 + __nTop, 012 + __nRight SAY oSay18 PROMPT "Prazo Médio (dias)=" OF oDlg FONT oFont2 COLORS 0, 16777215 PIXEL
@ 295 + __nTop, 101 + __nRight SAY nPrzMedio OF oDlg COLORS 0, 16777215 FONT oFont2 PIXEL

ACTIVATE MSDIALOG oDlg CENTERED

Return
