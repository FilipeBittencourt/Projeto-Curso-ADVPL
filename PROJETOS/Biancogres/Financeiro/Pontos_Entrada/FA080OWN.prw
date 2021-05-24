#include "rwMake.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ FA080OWN ³ Autor ³ MADALENO              ³ Data ³ 26/03/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ FUNCAO VALIDAR A DATA DA BAIXA COM O PARAMETRO MV_DATAFIM  ³±±
±±³          ³ NO MOMENTO DO CANCELAMENTO DA BAIXA DO CONTAS A PAGAR      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAFIN                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function FA080OWN()

	local lFA080OWN as logical

		begin sequence
			lFA080OWN:=(!FIDC():isPGFIDC(.T.))
			if (!lFA080OWN)
				break
			endif
			lFA080OWN:=FA080OWN()
		end sequence

	return(lFA080OWN)

static function FA080OWN()

LOCAL LRET := .T.

If SE5->E5_DATA <= GETMV("MV_DATAFIN") .AND. SE5->E5_DATA <> DDATABASE
	MsgBox("Data da Baixa Invalida. Não é permitido realizar o Cancelamento da Baixa com data anterior a "+Dtoc(GetMv("MV_DATAFIN"))+" , e a Data Base deverá ser a mesma da Data da Baixa.","DATA INVALIDA","INFO")
	LRET := .F.
EndIf

If SE5->E5_DATA <> DDATABASE
	MsgBox("Data da Baixa Invalida. Não é permitido realizar o Cancelamento da Baixa com data anterior a "+Dtoc(GetMv("MV_DATAFIN"))+" , e a Data Base deverá ser a mesma da Data da Baixa.","DATA INVALIDA","INFO")
	LRET := .F.
EndIf

Return(LRET)
