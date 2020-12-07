#include "rwmake.ch"
#Include "Protheus.ch"
#include "topconn.ch"
#INCLUDE "SHELL.CH"
#include "Fileio.ch"
#include "tbiconn.ch"
#INCLUDE "DIRECTRY.CH"

User Function BIA718()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := BIA718
Empresa   := Biancogres Ceramica S.A.
Data      := 13/05/13
Uso       := Contábil / Estoque/Custos
Aplicação := Envio automático de e-mail para informar à Diretoria todas as
.            movimentações excepcionais de estoque de produto acabado
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

#IFDEF WINDOWS
	Processa({|| RptDetail()})
	Return
	Static Function RptDetail()
#ENDIF

Local xtArea := GetArea()
Local x

If Select("SX6") == 0                                 // Via Schedule
	*****************************************************************
	
	xv_Emps    := U_BAGtEmpr("01_05")
	For x := 1 to Len(xv_Emps)
		
		//Inicializa o ambiente
		RPCSetType(3)
		WfPrepEnv(xv_Emps[x,1], xv_Emps[x,2])
		
		cHInicio := Time()
		fPerg := "BIA718
		fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
		// Subtrair 25 dias apenas para posicionar no Mes anterior
		MV_PAR01 := stod(Substr(dtos(dDataBase-25),1,6)+"01")
		MV_PAR02 := UltimoDia(dDataBase-25)
		
		ConOut("HORA: "+TIME()+" - Iniciando Processo BIA718 " + xv_Emps[x,1])
		
		U_WF_BIA718()
		
		ConOut("HORA: "+TIME()+" - Finalizando Processo BIA718 " + xv_Emps[x,1])
		
		//Finaliza o ambiente criado
		RpcClearEnv()
		
	Next
	
Else                                         // Via Integração Manual
	*****************************************************************
	cHInicio := Time()
	fPerg := "BIA718
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf
	
	U_WF_BIA718()
	
EndIf

RestArea(xtArea)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ WF_BIA718 ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 19/08/13 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Responsável pela execução dos Jobs                         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function WF_BIA718()

Local hhi

WF074 := ' <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
WF074 += ' <html xmlns="http://www.w3.org/1999/xhtml">
WF074 += ' <head>
WF074 += ' <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
WF074 += ' <title>Untitled Document</title>
WF074 += ' <style type="text/css">
WF074 += ' <!--
WF074 += ' .style1 {
WF074 += ' 	color: #FFFFFF;
WF074 += ' 	font-weight: bold;
WF074 += ' }
WF074 += ' -->
WF074 += ' </style>
WF074 += ' </head>
WF074 += ' <body>
WF074 += ' <p>Prezados Senhores,</p>
WF074 += ' <p>&nbsp;</p>
WF074 += ' <p>Na empresa '+UPPER(Alltrim(SM0->M0_NOMECOM))+' foram identificados no período de '+dtoc(MV_PAR01)+' a '+dtoc(MV_PAR02)+' as seguintes movimentações excepcionais de estoque:</p>
WF074 += ' <p>&nbsp;</p>
WF074 += ' <table width="604" border="1" cellspacing="0" bordercolor="#666666">
WF074 += '   <tr>
WF074 += '     <td width="76" bgcolor="#0000FF" scope="col"><div align="left" class="style1">Origem </div></td>
WF074 += '     <td width="150" bgcolor="#0000FF" scope="col"><div align="left" class="style1">Código</div></td>
WF074 += '     <td width="245" bgcolor="#0000FF" scope="col"><div align="left" class="style1">Descrição</div></td>
WF074 += '     <td width="115" bgcolor="#0000FF" scope="col"><div align="right" class="style1">Quantidade (m2)</div></td>
WF074 += '   </tr>

aDados2 := {}
xpEMail := .F.

TP003 := " SELECT D3_TM,
TP003 += "        F5_TEXTO DESCR,
TP003 += "        SUM(D3_QUANT) QUANT
TP003 += "   FROM "+RetSqlName("SD3")+" SD3
TP003 += "  INNER JOIN "+RetSqlName("SF5")+" SF5 ON F5_FILIAL = '"+xFilial("SF5")+"'
TP003 += "                       AND F5_CODIGO = D3_TM
TP003 += "                       AND SF5.D_E_L_E_T_ = ' '
TP003 += "  WHERE D3_FILIAL = '"+xFilial("SD3")+"'
TP003 += "    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
TP003 += "    AND D3_TIPO = 'PA'
TP003 += "    AND D3_ESTORNO = ' '
TP003 += "    AND D3_YORIMOV = '   '
TP003 += "    AND D3_CF NOT IN('RE4','DE4')
TP003 += "    AND D3_QUANT <> 0
TP003 += "    AND SD3.D_E_L_E_T_ = ' '
TP003 += "  GROUP BY D3_TM, F5_TEXTO
TP003 += "  ORDER BY D3_TM, F5_TEXTO
TP003 := ChangeQuery(TP003)
TPIndex := CriaTrab(Nil,.f.)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,TP003),'TP03',.T.,.T.)
dbSelectArea("TP03")
dbGoTop()
ProcRegua(RecCount())
While !Eof()
	
	IncProc()
	
	xpEMail := .T.
	
	WF074 += '   <tr>
	WF074 += '     <td><div align="left">'+IIF(TP03->D3_TM < "500", "Entrada", "Saída")+'</div></td>
	WF074 += '     <td><div align="left">'+TP03->D3_TM+'</div></td>
	WF074 += '     <td><div align="left">'+Alltrim(TP03->DESCR)+'</div></td>
	WF074 += '     <td><div align="right">'+Transform(TP03->QUANT, "@E 999,999,999.99")+'</div></td>
	WF074 += '   </tr>
	
	dbSelectArea("TP03")
	dbSkip()
	
End
TP03->(dbCloseArea())
Ferase(TPIndex+GetDBExtension())     //arquivo de trabalho
Ferase(TPIndex+OrdBagExt())          //indice gerado

WF074 += ' </table>
WF074 += ' <p>&nbsp;</p>
WF074 += ' <p>Caso tenham interesse em avaliar o detalhamento destas movimentações, elas se encontram anexas ao e-mail que acabam de receber. </p>
WF074 += ' <p>&nbsp;</p>
WF074 += ' <p>Atenciosamente,</p>
WF074 += ' <p>&nbsp;</p>
WF074 += ' <p>&quot;E-mail enviado automaticamente pelo sistema Protheus ao final do processo de fechamento mesal de estoque de produto acabado (by BIA718)&quot;.</p>
WF074 += ' </body>
WF074 += ' </html>

YR004 := " SELECT ' ' ORIGEM,
YR004 += "        D3_EMISSAO EMISSAO,
YR004 += "        D3_TM TPMOV,
YR004 += "        F5_TEXTO DESCRMOV,
YR004 += "        D3_DOC DOCUMENTO,
YR004 += "        D3_NUMSEQ NUMSEQ,
YR004 += "        D3_USUARIO USUARIO,
YR004 += "        D3_COD PRODUTO,
YR004 += "        SUBSTRING(B1_DESC,1,50) DESCR,
YR004 += "        D3_QUANT QUANT,
YR004 += "        D3_YOBS OBSERVACAO
YR004 += "   FROM "+RetSqlName("SD3")+" SD3
YR004 += "  INNER JOIN "+RetSqlName("SF5")+" SF5 ON F5_FILIAL = '"+xFilial("SF5")+"'
YR004 += "                       AND F5_CODIGO = D3_TM
YR004 += "                       AND SF5.D_E_L_E_T_ = ' '
YR004 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"'
YR004 += "                       AND B1_COD = D3_COD
YR004 += "                       AND SB1.D_E_L_E_T_ = ' '
YR004 += "  WHERE D3_FILIAL = '"+xFilial("SD3")+"'
YR004 += "    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
YR004 += "    AND D3_TIPO = 'PA'
YR004 += "    AND D3_ESTORNO = ' '
YR004 += "    AND D3_YORIMOV = '   '
YR004 += "    AND D3_CF NOT IN('RE4','DE4')
YR004 += "    AND D3_QUANT <> 0
YR004 += "    AND SD3.D_E_L_E_T_ = ' '
YR004 += "  ORDER BY D3_TM, F5_TEXTO
YR004 := ChangeQuery(YR004)
YRIndex := CriaTrab(Nil,.f.)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,YR004),'YR04',.T.,.T.)
dbSelectArea("YR04")
dbGoTop()
ProcRegua(RecCount())
While !Eof()
	
	IncProc()
	
	xpEMail := .T.
	
	aAdd(aDados2, { IIF(YR04->TPMOV < "500", "Entrada", "Saída"),;
	dtoc(stod(YR04->EMISSAO)),;
	YR04->TPMOV,;
	YR04->DESCRMOV,;
	YR04->DOCUMENTO,;
	YR04->NUMSEQ,;
	YR04->USUARIO,;
	YR04->PRODUTO,;
	YR04->DESCR,;
	Transform(YR04->QUANT, "@E 999,999,999.99"),;
	YR04->OBSERVACAO} )
	
	dbSelectArea("YR04")
	dbSkip()
	
End
aStru1 := ("YR04")->(dbStruct())
YR04->(dbCloseArea())
Ferase(YRIndex+GetDBExtension())     //arquivo de trabalho
Ferase(YRIndex+OrdBagExt())          //indice gerado

yrArqv  := "BIA718"+strzero(seconds()%3500,5)
xAbreEx := .F.
U_BIAxExcel(aDados2, aStru1, yrArqv, xAbreEx )

If xpEMail

	df_Dest := "marcelo.guizzardi@biancogres.com.br;wanisay.william@biancogres.com.br"
	df_Assu := "Relação das movimentações excepcionais de estoque de produto acabado"
	df_Erro := "Relação das movimentações excepcionais de estoque de produto acabado não enviado. Favor verificar!!!"
	yrAnexo := "\dirdoc\co"+cEmpAnt+"\shared\"+yrArqv+".csv"
	
	U_BIAEnvMail(, df_Dest, df_Assu, WF074, df_Erro, yrAnexo)
EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ ValidPerg¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 05/07/11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function ValidPerg()

local i,j
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(fPerg,fTamX1)
aRegs:={}

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
aAdd(aRegs,{cPerg,"01","De Emissao          ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Ate Emissao         ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})

For i := 1 to Len(aRegs)
	If !dbSeek(cPerg + aRegs[i,2])
		RecLock("SX1",.t.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

dbSelectArea(_sAlias)

Return
