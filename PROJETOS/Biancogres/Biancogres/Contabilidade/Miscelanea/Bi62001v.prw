#include "rwmake.ch"
#include "TOPCONN.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ BI61004V ³ Autor ³ Gustav koblinger Jr   ³      ³ 28/06/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Execblock para permitir a contabilizacao do ICMS Autonomo  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico: BIANCOGRES S/A                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
// Lancamento Padronizado ( Valor do ICMS do Autonomo )
User Function BI62001V()

SetPrvt("CALIAS,CTES,NVALOR,XGRUPO,")
Private cAlias	:= Alias()
Private wBaseCalc:= 0
Private wIcms		:= 0
Private cArqSD2	:= ""
Private cIndSD2	:= 0
Private cRegSD2	:= 0

DbSelectArea("SD2")
cArqSD2 := Alias()
cIndSD2 := IndexOrd()
cRegSD2 := Recno()
DbSetOrder(3)
If DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA,.T.)
	While ! Eof() .And.;
		SF2->F2_DOC     == SD2->D2_DOC     .And. ;
		SF2->F2_SERIE   == SD2->D2_SERIE   .And. ;
		SF2->F2_CLIENTE == SD2->D2_CLIENTE .And. ;
		SF2->F2_LOJA 	 	== SD2->D2_LOJA
		
		If nTpFrete == 1 //Autonomo - Alterado para utilizar variavel do Tipo de Frete 08/09/09 Ranisses

			DbSelectArea("SC5")
			dbSetOrder(1)
			dbSeek(xFilial("SC5")+SD2->D2_PEDIDO,.F.)
			If Alltrim(SC5->C5_YFLAG) == "2" //Busca UF e MUN do Local de Entrega
				cEST	:= SC5->C5_YEST
				cMun	:= SC5->C5_YCODMUN //SC5->C5_YMUN
			Else
				IF !(SF2->F2_TIPO $ "DB")
					DbSelectArea("SA1")
					DbSetOrder(1)
					If DbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,.T.)
						cEST	:= SA1->A1_EST
						cMun	:= SA1->A1_COD_MUN //SA1->A1_MUN
					EndIf
				ELSE
					DbSelectArea("SA2")
					DbSetOrder(1)
					If DbSeek(xFilial("SA2")+SF2->F2_CLIENTE+SF2->F2_LOJA,.T.)
						cEST	:= SA2->A2_EST
						cMun	:= SA2->A2_COD_MUN //SA2->A2_MUN
					EndIf
				ENDIF
			EndIf		
		
			//Calcula o ICMS Frete
			wIcms	+= U_fCalcFreteAut(cEst,cMun,SD2->D2_COD,SD2->D2_LOTECTL,SD2->D2_QUANT)[2] //Posicao 2 retorna o Valor do Icms Frete

		EndIf
		
		DbSelectArea("SD2")
		DbSetOrder(3)
		dbSkip()
	EndDo
Else
	MSGBOX("NAO CADASTRADO NO SD2")
EndIf

If cArqSD2 <> ""
	dbSelectArea(cArqSD2)
	dbSetOrder(cIndSD2)
	dbGoTo(cRegSD2)
	RetIndex("SD2")
EndIf

Return(wIcms)