#Include "Protheus.ch"
#include "topconn.ch"
#include "rwmake.ch"
#include "tbiconn.ch"
#Include "font.ch"
#INCLUDE "SHELL.CH"
#include "Fileio.ch"
#include "vkey.ch"

/*/{Protheus.doc} BIA693
@author Marcos Alberto Soprani
@since 02/06/16
@version 1.0
@description Cadastro do Número Serial do Crachá dos Funcionários para con-
.            trole de Acesso.
@type function
/*/

User Function BIA693()

	Private dfwEnterX  := CHR(13)+CHR(10)
	Private dfwFecha   := .F.
	Private oDlgCtrlAcess
	Private oButtonAt
	Private oButtonCn
	Private oComboEmpr
	Private nComboEmpr := 1
	Private oFontCtrl  := TFont():New("Arial Narrow",,020,,.T.,,,,,.F.,.F.)
	Private oGetNewNum
	Private cGetNewNum := Space(20)
	Private oGetMatr
	Private cGetMatr   := Space(06)
	Private oGetNome
	Private cGetNome   := Space(50)
	Private oGetNumSer
	Private cGetNumSer := Space(20)
	Private oGpNumSer
	Private oSayMatr
	Private oSayNewNum
	Private oSayNumSer

	DEFINE MSDIALOG oDlgCtrlAcess TITLE "Controle de Acesso" FROM 000, 000  TO 250, 600 COLORS 0, 16777215 PIXEL

	@ 005, 006 GROUP oGpNumSer TO 103, 291 PROMPT "Número Serial do Crachá para controle de Acesso" OF oDlgCtrlAcess COLOR 0, 16777215 PIXEL

	@ 020, 012 SAY oSayEmpr PROMPT "Empresa:" SIZE 032, 011 OF oDlgCtrlAcess FONT oFontCtrl COLORS 0, 16777215 PIXEL
	@ 020, 046 MSCOMBOBOX oComboEmpr VAR nComboEmpr ITEMS {"Biancogres", "Incesa", "JK", "LM", "Mundi", "Vitcer", "ST"} SIZE 094, 014 OF oDlgCtrlAcess VALID BIA693C() COLORS 0, 16777215 FONT oFontCtrl PIXEL

	@ 040, 049 MSGET oGetMatr   VAR    cGetMatr               SIZE 051, 014 OF oDlgCtrlAcess PICTURE "999999" VALID BIA693A() COLORS 0, 16777215 FONT oFontCtrl PIXEL
	@ 080, 082 MSGET oGetNewNum VAR    cGetNewNum             SIZE 095, 014 OF oDlgCtrlAcess COLORS 0, 16777215 FONT oFontCtrl PIXEL
	@ 107, 253 BUTTON oButtonAt PROMPT "Atualizar"            SIZE 037, 012 OF oDlgCtrlAcess ACTION bkGravaReg() PIXEL
	@ 107, 213 BUTTON oButtonCn PROMPT "Cancelar"             SIZE 037, 012 OF oDlgCtrlAcess ACTION (bkCanceReg(), dfwFecha := .T.) PIXEL

	@ 042, 011 SAY   oSayMatr   PROMPT "Matricula:"           SIZE 038, 011 OF oDlgCtrlAcess FONT oFontCtrl COLORS 0, 16777215 PIXEL
	@ 040, 102 MSGET oGetNome   VAR    cGetNome               SIZE 181, 014 OF oDlgCtrlAcess COLORS 0, 16777215 FONT oFontCtrl READONLY PIXEL
	@ 062, 011 SAY   oSayNumSer PROMPT "Número Serial Atual:" SIZE 069, 011 OF oDlgCtrlAcess FONT oFontCtrl COLORS 0, 16777215 PIXEL
	@ 060, 081 MSGET oGetNumSer VAR    cGetNumSer             SIZE 096, 014 OF oDlgCtrlAcess COLORS 0, 16777215 FONT oFontCtrl READONLY PIXEL
	@ 082, 011 SAY   oSayNewNum PROMPT "Novo Número Serial:"  SIZE 069, 011 OF oDlgCtrlAcess FONT oFontCtrl COLORS 0, 16777215 PIXEL

	ACTIVATE MSDIALOG oDlgCtrlAcess

	If !dfwFecha

		U_BIA693()

	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BIA693C  ¦ Autor ¦ Marcos Alberto S.     ¦ Data ¦ 10.06.16 ¦¦¦
¦¦¦----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Valida a digitação do campo empresa                        ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function BIA693C()

	Local hgVerif := .F.

	If Alltrim(Str(oComboEmpr:NAT)) $ ("1,2,3")

		hgVerif := .T.

	Else

		MsgINfO("Favor selecionar uma empresa antes de prosseguir!!!")

	EndIf

Return ( hgVerif )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BIA693A  ¦ Autor ¦ Marcos Alberto S.     ¦ Data ¦ 02.06.16 ¦¦¦
¦¦¦----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Verifica a Existência da Matricula expressa no cracha e    ¦¦¦
¦¦¦          ¦lista o númer o serial caso existe na base de dados         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function BIA693A()

	Local dfwRetOk := .F.
	Local dfwEmpr  := ""
	Local dfwItem  := oComboEmpr:NAT

	If !Empty(cGetMatr)
		cGetMatr := StrZero(Val(cGetMatr), 6)
		oDlgCtrlAcess:Refresh()
	EndIf

	// 1           , 2       , 3   , 4   , 5      , 6       , 7
	// "Biancogres", "Incesa", "JK", "LM", "Mundi", "Vitcer", "ST"

	If dfwItem == 1
		dfwEmpr := "01"

	ElseIf dfwItem == 2
		dfwEmpr := "05"

	ElseIf dfwItem == 3
		dfwEmpr := "06"

	ElseIf dfwItem == 4
		dfwEmpr := "07"

	ElseIf dfwItem == 5
		dfwEmpr := "13"

	ElseIf dfwItem == 6
		dfwEmpr := "14"

	ElseIf dfwItem == 7
		dfwEmpr := "12"

	Else

		MsgSTOP("Primeiro é necessário selecionar a Empresa...")

	EndIf

	If !Empty(dfwEmpr)

		If !Empty(cGetMatr)

			cGetMatr := StrZero(Val(cGetMatr), 6)

			TY005 := " SELECT RA_MAT, RA_NOME, RA_YSERIAL  "
			TY005 += "   FROM SRA"+dfwEmpr+"0 "
			TY005 += "  WHERE RA_MAT = '"+cGetMatr+"' "
			TY005 += "    AND RA_DEMISSA = '        ' "
			TY005 += "    AND D_E_L_E_T_ = ' ' "
			TYcIndex := CriaTrab(Nil,.f.)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,TY005),'TY05',.F.,.T.)
			dbSelectArea("TY05")
			dbGoTop()
			If !TY05->(Eof())

				cGetNome   := Alltrim(TY05->RA_NOME)
				cGetNumSer := TY05->RA_YSERIAL
				dfwRetOk   := .T.

			Else

				MsgINFO("Necessário verificar com o RH a matricula digitada, pois ela não existe ou o funcionário está demitido!!!")
				cGetMatr   := Space(06)
				cGetNewNum := Space(20)
				cGetNome   := Space(50)
				cGetNumSer := Space(20)
				dfwRetOk   := .T.
				oSayEmpr:SetFocus()

			EndIf

			TY05->(dbCloseArea())
			Ferase(TYcIndex+GetDBExtension())     //arquivo de trabalho
			Ferase(TYcIndex+OrdBagExt())          //indice gerado

		Else

			dfwRetOk := .T.

		EndIf

	Else

		cGetMatr   := Space(06)
		cGetNewNum := Space(20)
		cGetNome   := Space(50)
		cGetNumSer := Space(20)

		dfwRetOk := .T.
		oSayEmpr:SetFocus()

	EndIf

	oDlgCtrlAcess:Refresh()

Return ( dfwRetOk )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ bkGravaReg ¦ Autor ¦ Marcos Alberto S.   ¦ Data ¦ 02.06.16 ¦¦¦
¦¦¦----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Grava o novo número serial do crachá                       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function bkGravaReg()

	Local dfwRetOk := .F.
	Local dfwEmpr  := ""
	Local dfwItem  := oComboEmpr:NAT

	// 1           , 2       , 3   , 4   , 5      , 6       , 7
	// "Biancogres", "Incesa", "JK", "LM", "Mundi", "Vitcer", "ST"

	If dfwItem == 1
		dfwEmpr := "01"

	ElseIf dfwItem == 2
		dfwEmpr := "05"

	ElseIf dfwItem == 3
		dfwEmpr := "06"

	ElseIf dfwItem == 4
		dfwEmpr := "07"

	ElseIf dfwItem == 5
		dfwEmpr := "13"

	ElseIf dfwItem == 6
		dfwEmpr := "14"

	ElseIf dfwItem == 7
		dfwEmpr := "12"

	Else

		MsgSTOP("Primeiro é necessário selecionar a Empresa...")

	EndIf


	If !Empty(dfwEmpr)

		If !Empty(cGetMatr)

			If !Empty(cGetNewNum)

				If AT( ";", cGetNewNum ) > 0
					cGetNewNum := Substr( cGetNewNum, 1, AT( ";", cGetNewNum ) - 1 )
				Else
					cGetNewNum := Alltrim(cGetNewNum)
				EndIf

				TY005 := " UPDATE SRA"+dfwEmpr+"0 SET RA_YSERIAL = '"+cGetNewNum+"' "
				TY005 += "   FROM SRA"+dfwEmpr+"0 "
				TY005 += "  WHERE RA_MAT = '"+cGetMatr+"' "
				TY005 += "    AND RA_DEMISSA = '        ' "
				TY005 += "    AND D_E_L_E_T_ = ' ' "
				TCSQLExec(TY005)

				TY005 := " SELECT RA_MAT, RA_NOME, RA_YSERIAL  "
				TY005 += "   FROM SRA"+dfwEmpr+"0 "
				TY005 += "  WHERE RA_MAT = '"+cGetMatr+"' "
				TY005 += "    AND RA_DEMISSA = '        ' "
				TY005 += "    AND D_E_L_E_T_ = ' ' "
				TYcIndex := CriaTrab(Nil,.f.)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,TY005),'TY05',.F.,.T.)
				dbSelectArea("TY05")
				dbGoTop()
				If !TY05->(Eof())

					oDlgCtrlAcess:End()
					Aviso('Serial de Cartão', 'Atualizado com sucesso o Serial do cartão de Acesso' + dfwEnterX + dfwEnterX + 'Funcionário: ' + Alltrim(TY05->RA_NOME) + dfwEnterX + dfwEnterX + 'Novo Serial: ' + Alltrim(TY05->RA_YSERIAL) , {'Ok'}, 3 )

				Else

					oDlgCtrlAcess:End()
					MsgALERT("Favor refazer o passo de gravação novamente, porque apresentou problema de gravação...")

				EndIf

				TY05->(dbCloseArea())
				Ferase(TYcIndex+GetDBExtension())     //arquivo de trabalho
				Ferase(TYcIndex+OrdBagExt())          //indice gerado

			Else

				oDlgCtrlAcess:End()
				MsgALERT("Favor refazer o passo de gravação novamente, porque apresentou problema de gravação...")

			EndIf

		Else

			oDlgCtrlAcess:End()
			Aviso('Serial de Cartão', 'Nenhuma atualização realizada por dados incompletos: número do serial em branco. Favor verificar!!!' , {'Ok'}, 3 )

		EndIf

	Else

		oDlgCtrlAcess:End()
		Aviso('Serial de Cartão', 'Nenhuma atualização realizada por dados incompletos. Favor verificar!!!' , {'Ok'}, 3 )

	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ bkCanceReg ¦ Autor ¦ Marcos Alberto S.   ¦ Data ¦ 02.06.16 ¦¦¦
¦¦¦----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Fecha tela de gravação                                     ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function bkCanceReg()

	Local dfwRetOk := .F.
	Local dfwEmpr  := ""
	Local dfwItem  := oComboEmpr:NAT

	If dfwItem == 1
		dfwEmpr := "01"
	ElseIf dfwItem == 2
		dfwEmpr := "05"
	ElseIf dfwItem == 3
		dfwEmpr := "14"
	Else
		MsgSTOP("Primeiro é necessário selecionar a Empresa...")
	EndIf

	oDlgCtrlAcess:End()

	TY005 := " SELECT RA_MAT, RA_NOME, RA_YSERIAL  "
	TY005 += "   FROM SRA"+dfwEmpr+"0 "
	TY005 += "  WHERE RA_MAT = '"+cGetMatr+"' "
	TY005 += "    AND RA_DEMISSA = '        ' "
	TY005 += "    AND D_E_L_E_T_ = ' ' "
	TYcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,TY005),'TY05',.F.,.T.)
	dbSelectArea("TY05")
	dbGoTop()
	If !TY05->(Eof())

		Aviso('Serial de Cartão', 'Ação cancelada' + dfwEnterX + dfwEnterX + 'Nenhuma atualização foi realizada no campo serial deste Funcionário: ' + Alltrim(TY05->RA_NOME), {'Ok'}, 3 )

	EndIf

	TY05->(dbCloseArea())
	Ferase(TYcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(TYcIndex+OrdBagExt())          //indice gerado

Return
