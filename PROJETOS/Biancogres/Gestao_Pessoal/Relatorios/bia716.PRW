#Include "Protheus.ch"
#include "topconn.ch"

User Function BIA716()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := BIA716
Empresa   := Biancogres Cerêmicas S/A
Data      := 26/03/13
Uso       := Gestão de Pessoal
Aplicação := Levantamento de Funcionários por CBO
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

#IFDEF WINDOWS
	Processa({|| RptDetail()})
	Return
	Static Function RptDetail()
#ENDIF

Local hhi

cHInicio := Time()
fPerg := "BIA716"
fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
ValidPerg()
If !Pergunte(fPerg,.T.)
	Return
EndIf

aDados2 := {}

RV003 := " SELECT '"+Alltrim(SM0->M0_NOME)+"' EMPRESA,
RV003 += "        RA_MAT MATRICULA,
RV003 += "        RA_NOME NOME,
RV003 += "        RA_CODFUNC CODIGO,
RV003 += "        RJ_DESC DESC_FUNC,
RV003 += "        RJ_CODCBO CBO,
RV003 += "        RA_ADMISSA ADMISSAO,
RV003 += "        RJ_YMNRAPZ COTAMENOR
RV003 += "   FROM "+RetSqlName("SRA")+" SRA
RV003 += "   LEFT JOIN "+RetSqlName("SRJ")+" SRJ ON RJ_FILIAL = '"+xFilial("SRJ")+"'
RV003 += "                       AND RJ_FUNCAO = RA_CODFUNC
RV003 += "                       AND SRJ.D_E_L_E_T_ = ' '
RV003 += "  WHERE RA_FILIAL = '"+xFilial("SRA")+"'
RV003 += "    AND RA_MAT BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'
RV003 += "    AND RA_ADMISSA <= '"+dtos(MV_PAR03)+"'
RV003 += "    AND (RA_DEMISSA = '        ' OR RA_DEMISSA > '"+dtos(MV_PAR03)+"')
RV003 += "    AND SRA.D_E_L_E_T_ = ' '
TcQuery RV003 New Alias "RV03"
dbSelectArea("RV03")
dbGoTop()
ProcRegua(RecCount())
While !Eof()
	
	IncProc(RV03->NOME)
	
	aAdd(aDados2, { RV03->EMPRESA    ,;
	RV03->MATRICULA                  ,;
	RV03->NOME                       ,;
	RV03->CODIGO                     ,;
	RV03->DESC_FUNC                  ,;
	RV03->CBO                        ,;
	dtoc(stod(RV03->ADMISSAO))       ,;
	RV03->COTAMENOR                  })
	
	dbSelectArea("RV03")
	dbSkip()
End
aStru1 := ("RV03")->(dbStruct())

RV03->(dbCloseArea())

U_BIAxExcel(aDados2, aStru1, "BIA716"+strzero(seconds()%3500,5) )

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
aAdd(aRegs,{cPerg,"01","Da Matricula        ?","","","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SRA"})
aAdd(aRegs,{cPerg,"02","Ate Matricula       ?","","","mv_ch2","C",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SRA"})
aAdd(aRegs,{cPerg,"03","Data de Referência  ?","","","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})

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
