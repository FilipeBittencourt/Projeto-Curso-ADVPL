#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} BIA271
@author Marcos Alberto Soprani
@since 11/07/19
@version 1.0
@description Atribui Conta Contábil ao cálculo da folha de RPA - Especificamente a verba 201 
@type function
/*/

User Function BIA271()

	Private oGet1
	Private cGet1 := Space(06)
	Private oGet2
	Private cGet2 := SRA->RA_MAT
	Private oGet3
	Private cGet3 := SRA->RA_NOME
	Private oGet4
	Private cGet4 := SRA->RA_CLVL
	Private oGet5
	Private cGet5 := Space(20)
	Private oGroup1
	Private oSay1
	Private oSay2
	Private oSay3
	Private oSay4
	Private oSay5
	Private oSButton1

	Private oDlgAtribCTA
	Private msFechaTela := .F.
	Private msAreaAtu := GetArea()

	If Alltrim(Upper(FunName())) == "GPEA580"
		cGet1 := cPeriodo
	EndIf 

	DEFINE MSDIALOG oDlgAtribCTA TITLE "AtribCTA" FROM 000, 000  TO 310, 650 COLORS 0, 16777215 PIXEL

	@ 014, 016 GROUP oGroup1 TO 125, 309 PROMPT " Atribuição de Conta Contábil para PRA " OF oDlgAtribCTA COLOR 0, 16777215 PIXEL
	@ 031, 025 SAY oSay1 PROMPT "Período Ref:" SIZE 050, 007 OF oDlgAtribCTA COLORS 0, 16777215 PIXEL
	@ 046, 025 SAY oSay2 PROMPT "Matricula:" SIZE 050, 007 OF oDlgAtribCTA COLORS 0, 16777215 PIXEL
	@ 061, 025 SAY oSay3 PROMPT "Nome:" SIZE 050, 007 OF oDlgAtribCTA COLORS 0, 16777215 PIXEL
	@ 076, 025 SAY oSay4 PROMPT "Classe de Valor: " SIZE 050, 007 OF oDlgAtribCTA COLORS 0, 16777215 PIXEL
	@ 091, 025 SAY oSay5 PROMPT "Conta Contábil:" SIZE 050, 007 OF oDlgAtribCTA COLORS 0, 16777215 PIXEL
	@ 031, 086 MSGET oGet1 VAR cGet1 SIZE 060, 010 OF oDlgAtribCTA COLORS 0, 16777215 PIXEL
	@ 046, 086 MSGET oGet2 VAR cGet2 SIZE 060, 010 OF oDlgAtribCTA COLORS 0, 16777215 READONLY PIXEL
	@ 061, 086 MSGET oGet3 VAR cGet3 SIZE 179, 010 OF oDlgAtribCTA COLORS 0, 16777215 READONLY PIXEL
	@ 076, 086 MSGET oGet4 VAR cGet4 SIZE 060, 010 OF oDlgAtribCTA COLORS 0, 16777215 READONLY PIXEL
	@ 091, 086 MSGET oGet5 VAR cGet5 SIZE 060, 010 OF oDlgAtribCTA COLORS 0, 16777215 F3 "CT1" PIXEL
	DEFINE SBUTTON oSButton1 FROM 132, 280 TYPE 01 OF oDlgAtribCTA ENABLE ACTION msGravaCTA()

	ACTIVATE MSDIALOG oDlgAtribCTA CENTERED VALID msFechaTela

	RestArea( msAreaAtu )

Return 

Static Function msGravaCTA()

	CT1->(dbSetOrder(1))
	If CT1->(dbSeek(xFilial("CT1") + cGet5))

		msChkAtrib := U_B478RTCC(cGet4)[2]
		msContaC   := Substr(cGet5 , 1, 1)

		If msChkAtrib = "C" .and. msContaC <> "6" 

			MsgSTOP("A Classe de valor informada exige um conta contábil de CUSTO!!!")

		ElseIf msChkAtrib = "D" .and. msContaC <> "3" 

			MsgSTOP("A Classe de valor informada exige um conta contábil de DESPESA!!!")

		Else

			msFechaTela := .T.
			oDlgAtribCTA:End()

		EndIf

	Else

		MsgSTOP("Conta Contábil não existe!!!")

	EndIf

	If msFechaTela

		ZCT->( dbSetOrder(1) )
		If !ZCT->( dbSeek(xFilial("ZCT") + cGet1 + cGet2 + cGet4 ))
			RecLock("ZCT",.T.)
			ZCT->ZCT_FILIAL := xFilial("ZCT")
			ZCT->ZCT_DATARQ := cGet1
			ZCT->ZCT_MAT    := cGet2
			ZCT->ZCT_CLVL   := cGet4
		Else
			RecLock("ZCT",.F.)
		EndIf
		ZCT->ZCT_CONTA   := cGet5
		MsUnlock()

	EndIf

Return
