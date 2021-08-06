#Include "Protheus.ch"
#include "topconn.ch"

User Function BIA738()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := BIA738
Empresa   := Biancogres Cerêmicas S/A
Data      := 26/09/13
Uso       := PCP / Estoque / Ecosis
Aplicação := Conferência de Etiquetas em aberto no sistema Ecosis
.            - Por Endereço
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

#IFDEF WINDOWS
	Processa({|| RptDetail()})
	Return
	Static Function RptDetail()
#ENDIF

Local hhi

cHInicio := Time()
fPerg := "BIA738"
fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
ValidPerg()
If !Pergunte(fPerg,.T.)
	Return
EndIf

If cEmpAnt == "01"
	kt_BsDad := "DADOSEOS"
ElseIf cEmpAnt == "05"
	kt_BsDad := "DADOS_05_EOS"
ElseIf cEmpAnt == "13"
	kt_BsDad := "DADOS_13_EOS"
ElseIf cEmpAnt == "14"
	kt_BsDad := "DADOS_14_EOS"	
Else
	MsgINFO("Empresa não configurada para apontamento automático de Cerâmica!!!")
	Return
EndIf

aDados2 := {}
TX007 := " SELECT COD_ENDERECO,
TX007 += "        A.CE_NUMERO_DOCTO ETIQUET,
TX007 += "        A.ID_MOV_PROD IDECO,
TX007 += "        A.COD_TRANSACAO TRANSAC,
TX007 += "        A.COD_PRODUTO PRODUT,
TX007 += "        SUBSTRING(B1_DESC,1,50) DESCR,
TX007 += "        A.CE_LOTE LOTEPR,
TX007 += "        A.CE_QTDADE QUANT,
TX007 += "        CONVERT(CHAR(10),CONVERT(DATETIME, SUBSTRING(CONVERT(VARCHAR(10), B.ETIQ_DATA, 112), 1, 10)),103) DTREF,
TX007 += "        SUBSTRING(CONVERT(VARCHAR(16), B.ETIQ_DATA, 120), 12, 5) HRREF,
TX007 += "        CASE
TX007 += "          WHEN B.etiq_pallet_fechado = 0 THEN 'ABERTO'
TX007 += "          WHEN B.etiq_pallet_fechado = 1 THEN 'FECHADO'
TX007 += "          ELSE 'VERIFICAR'
TX007 += "        END PALLET
TX007 += "   FROM "+kt_BsDad+"..CEP_MOVIMENTO_PRODUTO A
TX007 += "   JOIN "+kt_BsDad+"..CEP_ETIQUETA_PALLET B ON B.ID_CIA = A.ID_CIA
TX007 += "                                       AND B.COD_ETIQUETA = A.CE_NUMERO_DOCTO
TX007 += "   INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_COD = A.COD_PRODUTO COLLATE LATIN1_GENERAL_BIN
TX007 += "  WHERE A.ID_CIA = 1
TX007 += "    AND A.CE_LOTE <> ' '
TX007 += "    AND ETIQ_CANCELADA = 0
TX007 += "    AND SUBSTRING(CONVERT(VARCHAR(10), B.ETIQ_DATA, 112),1,10) BETWEEN '"+dtos(MV_PAR02)+"' AND '"+dtos(MV_PAR03)+"'
TX007 += "    AND (NF_NUMERO = '' OR NF_NUMERO IS NULL)
If !Empty(MV_PAR01)
	TX007 += "    AND COD_ENDERECO LIKE '%"+Alltrim(MV_PAR01)+"%'
EndIf
TX007 += "  ORDER BY A.CE_NUMERO_DOCTO
TXcIndex := CriaTrab(Nil,.f.)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,TX007),'TX07',.T.,.T.)
dbSelectArea("TX07")
dbGoTop()
ProcRegua(RecCount())
While !Eof()
	
	IncProc()
	
	aAdd(aDados2, { TX07->COD_ENDERECO,;
	TX07->ETIQUET,;
	TX07->IDECO,;
	TX07->TRANSAC,;
	TX07->PRODUT,;
	TX07->DESCR,;
	TX07->LOTEPR,;
	Transform(TX07->QUANT   ,"@E 999,999,999.9999"),;
	TX07->DTREF,;
	TX07->HRREF,;
	TX07->PALLET} )
	
	dbSelectArea("TX07")
	dbSkip()
	
End

aStru1 := ("TX07")->(dbStruct())

TX07->(dbCloseArea())
Ferase(TXcIndex+GetDBExtension())     //arquivo de trabalho
Ferase(TXcIndex+OrdBagExt())          //indice gerado

U_BIAxExcel(aDados2, aStru1, "BIA738"+strzero(seconds()%3500,5) )

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
aAdd(aRegs,{cPerg,"01","Informe a Rua       ?","","","mv_ch1","C",10,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","De Data             ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Ate Data            ?","","","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})

For i := 1 to Len(aRegs)
	if !dbSeek(cPerg + aRegs[i,2])
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
