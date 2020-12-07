#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Luana Marin Ribeiro
Programa  := F4NFORI
Empresa   := Biancogres Cerâmica S/A
Data      := 12/07/2016
Uso       := Ponto-de-Entrada: F4NFORI - Atualização do arquivo temporário
Aplicação := O ponto de entrada F4NFORI será acionado na chamada da interface de visualizacao dos documentos de entrada/saida para devolução . Utilizado para que o 
			 usuário possa incluir um filtro que deverá ser executado na atualização do arquivo temporário com base nos itens do SD1 .
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

User Function F4NFORI()

Local cExp1 := PARAMIXB[1]
Local cExp2 := PARAMIXB[2]
Local cExp3 := PARAMIXB[3]
Local cExp4 := ""
Local _uMV01Bkp := MV_PAR01
Local _uMV02Bkp := MV_PAR02

//Validações do usuário
If PARAMIXB[1] == "SD2"
	cPerg := "F4NFORI"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValPergAco() 
		
	If !Pergunte(cPerg,.T.)
		Return
	EndIf
	
	cExp4 := " D2_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "
EndIf

MV_PAR01 := _uMV01Bkp
MV_PAR02 := _uMV02Bkp
                                                                                                                                                                                                                                    
Return cExp4

Static Function ValPergAco()
Local i,j,nX
Local aTRegs := {}
Local aHelpPor := {}
Local aHelpEng := {}
Local aHelpSpa := {}
Local Enter := chr(13) + Chr(10)
              
cPerg := PADR(cPerg,10)

//DECLARACAO DAS PERGUNTAS NA ORDEM QUE DESEJA CRIAR
aAdd(aTRegs,{"Data de digitação de:","D",8,0,0,"G","","","","","","","","Data de digitação da nota de"})//1
aAdd(aTRegs,{"Data de digitação até:","D",8,0,0,"G","","","","","","","","Data de digitação da nota ate"})//2

//Criar aRegs na ordem do vetor Temporario
aRegs := {}
For I := 1 To Len(aTRegs)
	aAdd(aRegs,{cPerg,StrZero(I,2),aTRegs[I][1],aTRegs[I][1],aTRegs[I][1]	,"mv_ch"+Alltrim(Str(I)),aTRegs[I][2],aTRegs[I][3],aTRegs[I][4],aTRegs[I][5],aTRegs[I][6],aTRegs[I][7],;
	"mv_par"+StrZero(I,2),aTRegs[I][8],"","","","",aTRegs[I][9],"","","","",aTRegs[I][10],"","","","",aTRegs[I][11],"","","","",aTRegs[I][12],"","","",aTRegs[I][13],""})
Next I

//Grava no SX1 se ja nao existir
dbSelectArea("SX1")
For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Else
		//ATUALIZA SX1
		RecLock("SX1",.F.)
		For j:=3 to FCount()
			If j <= Len(aRegs[i])
				If SubStr(FieldName(j),1,6) <> "X1_CNT"
					FieldPut(j,aRegs[i,j])
				EndIf
			Endif
		Next
		MsUnlock()
	EndIf
	
	//HELP DAS PERGUNTAS
	aHelpPor := {}
	__aRet := STRTOKARR(AllTrim(aTRegs[I][14]),"#")
	FOR nX := 1 To Len(__aRet)
		AADD(aHelpPor,AllTrim(__aRet[nX]))
	NEXT nX
	PutSX1Help("P."+AllTrim(cPerg)+aRegs[i,2]+".",aHelpPor,aHelpEng,aHelpSpa)
Next

//Renumerar perguntas
_ncont := 1
SX1->(dbSeek(cPerg))
While .Not. SX1->(Eof()) .And. X1_GRUPO == cPerg
	RecLock("SX1",.F.)
	SX1->X1_ORDEM := StrZero(_ncont,2)
	SX1->(MsUnlock())
	SX1->(DbSkip())
	_ncont++
EndDo

//Deletar Perguntas sobrando - apagadas do vetor
While SX1->(dbSeek(cPerg+StrZero(i,2)))
	RecLock("SX1",.F.)
	SX1->(DbDelete())
	SX1->(MsUnlock())
	i++
EndDo

Return