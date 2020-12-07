#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

User Function BIA221()

	/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	Autor     := Marcos Alberto Soprani
	Programa  := BIA221
	Empresa   := Biancogres Cerâmica S/A
	Data      := 17/01/13
	Uso       := Gestão de Pessoal
	Aplicação := Browser para Manutenção do Histórico de Setor
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

	Private cCadastro := "Histórico de Setor"

	aRotina   := {  {"Pesquisar"    ,"AxPesqui"	                               ,0, 1},;
	{                "Visualizar"   ,'Execblock("BIA221A" ,.F.,.F.,"V")'       ,0, 2},;
	{                "Manutenção"   ,'Execblock("BIA221A" ,.F.,.F.,"A")'       ,0, 4},;
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
¦¦¦Funçao    ¦ BIA221A  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 17.01.13 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Montagem de Tela Modelo2                                   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA221A()

	local _i, _ni, lk, _ni
	wopcao      := Paramixb
	lVisualizar := .F.
	lAlterar    := .F.

	Do Case
		Case wOpcao == "V" ; lVisualizar := .T. ; nOpcE := 2 ; nOpcG := 2 ; cOpcao := "VISUALIZAR"
		Case wOpcao == "A" ; lAlterar    := .T. ; nOpcE := 3 ; nOpcG := 3 ; cOpcao := "ALTERAR"
	EndCase

	xs_mat    := SRA->RA_MAT
	xs_nome   := SRA->RA_NOME
	xs_cclvl  := SRA->RA_CLVL
	xs_dAdmis := SRA->RA_ADMISSA

	nOpcx    := 0
	nUsado   := 0
	aHeader  := {}
	aCols    := {}

	zy_Cab  := {"ZV_FILIAL ","ZV_MAT    ","ZV_NOME   "}
	zy_Grid := {}
	nUsado := 0
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbGoTop()
	dbSeek("SZV")
	aHeader := {}
	While !Eof() .and. SX3->X3_ARQUIVO == "SZV"
		If aScan(zy_Cab, SX3->X3_CAMPO)	== 0
			If x3Uso(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL
				nUsado := nUsado+1
				Aadd(aHeader,{ TRIM(x3_titulo), x3_campo, x3_picture, x3_tamanho, x3_decimal, "AllwaysTrue()", x3_usado, x3_tipo, , } )
				Aadd(zy_Grid, x3_campo)
			Endif
		EndIf
		dbSkip()
	End
	Aadd(aHeader,{ "Registro", "REGSZV", "99999999999999", 14, 0,"AllwaysTrue()", x3_usado, "N", x3_arquivo, x3_context } )

	aCols:={}
	dbSelectArea("SZV")
	dbSetOrder(1)
	dbGoTop()
	dbSeek(xFilial("SZV")+xs_mat)
	While !Eof() .and. SZV->ZV_FILIAL == xFilial("SZV") .and. SZV->ZV_MAT == xs_mat
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
		AADD(aC,{"xs_cclvl"  ,{020,500}  ,"Classe de Valor: " ,"@!", , , .F.})
		AADD(aC,{"xs_dAdmis" ,{040,010}  ,"Data de Admissão:" ,"@!", , , .F.})
		aGetsD   := {}
		nOpcx    := 1
		mk_LinhaOk := "AllwaysTrue()"
		mk_TudoOk  := "AllwaysTrue()"
		lRet := Modelo2(cTitulo,aC,aR,aCGD,nOpcx,mk_LinhaOk, mk_TudoOk,aGetsD ,   ,   ,   ,aCordw, .F.     )

	ElseIf lAlterar
		AADD(aC,{"xs_mat"    ,{020,010}  ,"Matricula: "       ,"@!", , , .F.})
		AADD(aC,{"xs_nome"   ,{020,130}  ,"Nome: "            ,"@!", , , .F.})
		AADD(aC,{"xs_cclvl"  ,{020,500}  ,"Classe de Valor: " ,"@!", , , .F.})
		AADD(aC,{"xs_dAdmis" ,{040,010}  ,"Data de Admissão:" ,"@!", , , .F.})
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
					dbSelectArea("SZV")
					If GdFieldGet("REGSZV",_i) == 0
						RecLock("SZV",.T.)
						SZV->ZV_FILIAL := xFilial("SZV")
						SZV->ZV_MAT    := xs_mat
					Else
						dbGoto(GdFieldGet("REGSZV",_i))
						RecLock("SZV",.F.)
					EndIf
					For lk := 1 to Len(aHeader)
						If Alltrim(aHeader[lk][2]) <> "REGSZV"
							&("SZV->"+TRIM(aHeader[lk][2])) := ACOLS[_i][lk]
						EndIf
					Next lk
					MsUnLock()
				Else
					dbSelectArea("SZV")
					dbGoto(GdFieldGet("REGSZV",_i))
					RecLock("SZV",.F.)
					DELETE
					MsUnLockAll()
				EndIf
			Next _i

			YU004 := " UPDATE " + RetSqlName("SRA")
			YU004 += "    SET RA_YDEPART = (SELECT ZV_CODATU
			YU004 += "                        FROM " + RetSqlName("SZV")
			YU004 += "                       WHERE ZV_FILIAL = '"+xFilial("SZV")+"'
			YU004 += "                         AND ZV_MAT = '"+xs_mat+"'
			YU004 += "                         AND ZV_DATA IN(SELECT MAX(ZV_DATA)
			YU004 += "                                          FROM " + RetSqlName("SZV")
			YU004 += "                                         WHERE ZV_FILIAL = '"+xFilial("SZV")+"'
			YU004 += "                                           AND ZV_MAT = '"+xs_mat+"'
			YU004 += "                                           AND D_E_L_E_T_ = ' ')
			YU004 += "                         AND D_E_L_E_T_ = ' ')
			YU004 += "  WHERE RA_FILIAL = '"+xFilial("SRA")+"'
			YU004 += "    AND RA_MAT = '"+xs_mat+"'
			YU004 += "    AND D_E_L_E_T_ = ' '
			TCSQLExec(YU004)

			MsUnLockAll()

			SX3->(dbSetOrder(2))
			SX3->(dbSeek("RA_APELIDO"))
			nTamApl := SX3->X3_TAMANHO

			YU005 := " UPDATE " + RetSqlName("SRA")
			YU005 += "    SET RA_APELIDO = ISNULL((SELECT SUBSTRING(QB_YPCMSO,1,"+Alltrim(Str(nTamApl))+")
			YU005 += "                               FROM " + RetSqlName("SQB")
			YU005 += "                              WHERE QB_FILIAL = '"+xFilial("SQB")+"'
			YU005 += "                                AND QB_DEPTO = RA_YDEPART
			YU005 += "                                AND D_E_L_E_T_ = ' '), ' ')
			YU005 += "  WHERE RA_FILIAL = '"+xFilial("SRA")+"'
			YU005 += "    AND RA_MAT = '"+xs_mat+"'
			YU005 += "    AND D_E_L_E_T_ = ' '
			TCSQLExec(YU005)

			MsUnLockAll()

		EndIf

	EndIf

	n := 1

Return
