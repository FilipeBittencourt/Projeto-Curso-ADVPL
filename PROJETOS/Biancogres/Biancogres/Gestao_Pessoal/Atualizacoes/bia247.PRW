#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

User Function BIA247()

	/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	Autor     := Marcos Alberto Soprani
	Programa  := BIA247
	Empresa   := Biancogres Cerâmica S/A
	Data      := 22/10/12
	Uso       := Gestão de Pessoal
	Aplicação := Browser para manutenção do calculo do Plano de Saúde
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

	Private cCadastro := "Manutenção Cálculo de Benefícios"

	aRotina   := {  {"Pesquisar"    ,"AxPesqui"	                               ,0, 1},;
	{                "Visualizar"   ,'Execblock("BIA247A" ,.F.,.F.,"V")'       ,0, 2},;
	{                "Incluir"      ,'MsgINFO("Utilize outra Opção","Atenção")',0, 3},;
	{                "Alterar"      ,'Execblock("BIA247A" ,.F.,.F.,"A")'       ,0, 4},;
	{                "Leganda"      ,'GpLegend'                                ,0, 5} }

	dbSelectArea("SRA")
	dbSetOrder(1)
	dbGoTop()

	SRA->(mBrowse(06, 01, 22, 75, "SRA", NIL , NIL , NIL , NIL , NIL , fCriaCor() ))

	dbSelectArea("SRA")

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA247A  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 22.10.12 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Montagem de Tela Modelo2                                   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA247A()

	local _i, _ni, lk, _ni
	wopcao      := Paramixb
	lVisualizar := .F.
	lAlterar    := .F.

	Do Case
		Case wOpcao == "V" ; lVisualizar := .T. ; nOpcE := 2 ; nOpcG := 2 ; cOpcao := "VISUALIZAR"
		Case wOpcao == "A" ; lAlterar    := .T. ; nOpcE := 3 ; nOpcG := 3 ; cOpcao := "ALTERAR"
	EndCase

	xs_mat   := SRA->RA_MAT
	xs_nome  := SRA->RA_NOME
	xs_cCLVL := SRA->RA_CLVL

	nOpcx    := 0
	nUsado   := 0
	aHeader  := {}
	aCols    := {}

	zy_Cab  := {"RHR_FILIAL","RHR_MAT   "}
	zy_Grid := {}
	nUsado := 0
	dbSelectArea("SX3")
	dbSeek("RHR")
	aHeader := {}
	While !Eof() .and. SX3->X3_ARQUIVO == "RHR"
		If aScan(zy_Cab, SX3->X3_CAMPO)	== 0
			If x3Uso(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL
				nUsado := nUsado+1
				Aadd(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture, x3_tamanho, x3_decimal, "AllwaysTrue()", x3_usado, x3_tipo, , } )
				Aadd(zy_Grid, x3_campo)
			Endif
		EndIf
		dbSkip()
	End
	Aadd(aHeader,{ "Registro", "REGRHR", "99999999999999", 14, 0,"AllwaysTrue()", x3_usado, "N", x3_arquivo, x3_context } )

	aCols:={}
	dbSelectArea("RHR")
	dbSetOrder(1)
	dbGoTop()
	dbSeek(xFilial("RHR")+xs_mat)
	While !Eof() .and. RHR->RHR_FILIAL == xFilial("RHR") .and. RHR->RHR_MAT == xs_mat
		AADD(aCols,Array(nUsado+2))
		For _ni := 1 to nUsado
			aCols[Len(aCols),_ni] := FieldGet(FieldPos(aHeader[_ni,2]))
		Next
		aCols[Len(aCols),nUsado+1] := Recno()
		aCols[Len(aCols),nUsado+2] := .F.
		dbSkip()
	End

	If Len(Acols) == 0
		aCols := {Array(nUsado+2)}
		For _ni := 1 to nUsado
			aCols[1,_ni] := CriaVar(aHeader[_ni,2])
		Next
		aCols[1,nUsado+1] := 0
		aCols[1,nUsado+2] := .F.
	EndIf

	If len(aCols) == 0
		Return
	EndIf

	cTitulo  := "..: "+cCadastro+" :.."
	aC := {}
	aR := {}

	aCGD   := {170,05,250,455}
	aCordw := {95,03,600,820}

	If lVisualizar
		AADD(aC,{"xs_mat"    ,{020,010}  ,"Matricula: "       ,"@!", , , .F.})
		AADD(aC,{"xs_nome"   ,{020,130}  ,"Nome: "            ,"@!", , , .F.})
		AADD(aC,{"xs_cCLVL"  ,{020,500}  ,"Revisão:  "        ,"@!", , , .F.})
		aGetsD   := {}
		nOpcx    := 1
		mk_LinhaOk := "AllwaysTrue()"
		mk_TudoOk  := "AllwaysTrue()"
		lRet := Modelo2(cTitulo,aC,aR,aCGD,nOpcx,mk_LinhaOk, mk_TudoOk,aGetsD ,   ,   ,   ,aCordw, .F.     )

	ElseIf lAlterar
		AADD(aC,{"xs_mat"    ,{020,010}  ,"Matricula: "       ,"@!", , , .F.})
		AADD(aC,{"xs_nome"   ,{020,130}  ,"Nome: "            ,"@!", , , .F.})
		AADD(aC,{"xs_cCLVL"  ,{020,500}  ,"Classe de Valor: " ,"@!", , , .F.})
		aGetsD   := zy_Grid
		nOpcx    := 3
		mk_LinhaOk := "AllwaysTrue()"
		mk_TudoOk  := "AllwaysTrue()"
		lRet := Modelo2(cTitulo,aC,aR,aCGD,nOpcx,mk_LinhaOk, mk_TudoOk,aGetsD ,   ,   ,   ,aCordw, .T.     )

	EndIf

	If lRet

		If lAlterar

			For _i := 1 to len(aCols)
				If !aCols[_i,nUsado+2]
					dbSelectArea("RHR")
					If GdFieldGet("REGRHR",_i) == 0
						RecLock("RHR",.T.)
						RHR->RHR_FILIAL := xFilial("RHR")
						RHR->RHR_MAT    := xs_mat
					Else
						dbGoto(GdFieldGet("REGRHR",_i))
						RecLock("RHR",.F.)
					EndIf
					For lk := 1 to Len(aHeader)
						If Alltrim(aHeader[lk][2]) <> "REGRHR"
							&("RHR->"+TRIM(aHeader[lk][2])) := ACOLS[_i][lk]
						EndIf
					Next lk
					MsUnLock()
				Else
					dbSelectArea("RHR")
					dbGoto(GdFieldGet("REGRHR",_i))
					RecLock("RHR",.F.)
					DELETE
					MsUnLockAll()
				EndIf
			Next _i

		EndIf

	EndIf

	n := 1

Return
