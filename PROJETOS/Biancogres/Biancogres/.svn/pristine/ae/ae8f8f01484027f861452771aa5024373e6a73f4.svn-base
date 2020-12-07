#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

User Function Bia078()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

	Local xxn

	SetPrvt("XXN,XCCAMPO,WSPROD,WSUM,")

	For xxn := 1 to Len(aHeader)
		xcCampo := Trim(aHeader[xxn][2])
		if xcCampo == "C7_PRODUTO"
			wsProd := aCols[n][xxn]
		endif
		if xcCampo == "C7_UM"
			wsUm := aCols[n][xxn]
		endif
	Next

	DbSelectArea("SB1")
	DbSetOrder(1)
	if DbSeek(xFilial("SB1")+wsProd,.F.)
		if SB1->B1_UM <> wsUm
			MsgAlert("Unidade Nao Pode Ser Alterada")
			wsUm := SB1->B1_UM
		endif
	else
		MsgAlert("PRODUTO nao cadastrado!")
		wsUm := ""
	endif

Return(wsUm)