#include "rwmake.ch"
#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MTASF2   บAutor  ณMicrosiga Vitoria   บ Data ณ  01/01/01   บฑฑ
ฑฑบ          ณ          บAlter. ณRanisses A. Corona  บ Data ณ  08/08/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ *Calcula/Grava ICMS Frete Autonomo                         บฑฑ
ฑฑบ          ณ *Alterado Calculo do ICMS Autonomo, para realizar o calulo บฑฑ
ฑฑบ          ณ  varificando a variavel nTpFrete							  						บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Faturamento                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function MTASF2()

//Variaveis de Posicionamento
//--------------------------------
Private aArea	:= GetArea()

dbSelectArea("SD2")
Private cArqSD2	:= Alias()
Private cIndSD2	:= IndexOrd()
Private cRegSD2	:= Recno()

dbSelectArea("SC5")
Private cArqSC5	:= Alias()
Private cIndSC5	:= IndexOrd()
Private cRegSC5	:= Recno()
//--------------------------------

Private wBaseCalc	:= 0
Private wIcms		:= 0
Private cMun		:= ""
Private cEst		:= ""
Private wTpFrete  := IIf(cEmpAnt <> "07" .And. SF2->F2_CLIENTE == "010064" .And. !(SF2->F2_TIPO $ "D_B"), 2, nTpFrete)

SD2->(DbSetOrder(3))
If SD2->(DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
	While ! SD2->(Eof()) .And.;
		SF2->F2_DOC     == SD2->D2_DOC     .And. ;
		SF2->F2_SERIE   == SD2->D2_SERIE   .And. ;
		SF2->F2_CLIENTE == SD2->D2_CLIENTE .And. ;
		SF2->F2_LOJA 	 	== SD2->D2_LOJA

		//Posiciona no Pedido de Venda
		SC5->(DbSetOrder(1))
		SC5->(DbSeek(xFilial("SC5")+SD2->D2_PEDIDO))
		
		//Calcula Frete Autonomo
		If wTpFrete == 1 //Autonomo - Alterado para utilizar variavel do Tipo de Frete 08/09/09 Ranisses
			
			If Alltrim(SC5->C5_YFLAG) == "2"
				cEst		:= SC5->C5_YEST
				cMun		:= SC5->C5_YCODMUN	//SC5->C5_YMUN
			ElseIf Alltrim(SF2->F2_TIPO) $ "DB"
				SA2->(DbSetOrder(1))
				If SA2->(DbSeek(xFilial("SA2")+SF2->F2_CLIENTE+SF2->F2_LOJA))									
					cEst	:= SA2->A2_EST
					cMun	:= SA2->A2_COD_MUN //SA2->A2_MUN
				EndIf
			Else
				cEst	:= SA1->A1_EST
				cMun	:= SA1->A1_COD_MUN //SA1->A1_MUN
			EndIf
			
			//Calcula o ICMS Frete
			aVlr	:= U_fCalcFreteAut(cESt,cMun,SD2->D2_COD,SD2->D2_LOTECTL,SD2->D2_QUANT)
			
			//Acumula a Base e o Valor do Frete
			wBaseCalc	+= aVlr[1]
			wIcms		+= aVlr[2]
			
		EndIf

        //MaFisAlt("IT_AUTONOMO",Round(aVlr[1],2),Val(SD2->D2_ITEM)) //F2_FRETAUT X CDA_BASE 
		//MaFisAlt("IT_VALICA",Round(aVlr[2],2),Val(SD2->D2_ITEM)) //F2_ICMAUTO X CDA_VALOR  

		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Grava no Campo D2_CCUSTO/D2_CLVL/D2_ITEMCC o conteudo do C5_YCC/C5_YCLVL/C5_YITEMCT ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		dbSelectArea("SD2")
		RecLock("SD2",.F.)
		SD2->D2_CCUSTO := SC5->C5_YCC
		SD2->D2_CLVL   := SC5->C5_YCLVL
		SD2->D2_ITEMCC := SC5->C5_YITEMCT
		SD2->(MsUnLock())
		
		SD2->(DbSkip())
	EndDo
Else
	MSGBOX("NAO CADASTRADO NO SD2")
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Grava no Campo F2_YCCUSTO/F2_YCLVL/F2_YITEMCT o conteudo do C5_YCC/C5_YCLVL/C5_YITEMCT ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("SF2")
RecLock("SF2",.F.)
SF2->F2_FRETAUT := wBaseCalc
SF2->F2_ICMAUTO := wIcms
SF2->F2_YCCUSTO := SC5->C5_YCC
SF2->F2_YCLVL   := SC5->C5_YCLVL
SF2->F2_YITEMCT := SC5->C5_YITEMCT
MsUnlock()
dbCommit()

If cArqSD2 <> ""
	dbSelectArea(cArqSD2)
	dbSetOrder(cIndSD2)
	dbGoTo(cRegSD2)
EndIf

If cArqSC5 <> ""
	dbSelectArea(cArqSC5)
	dbSetOrder(cIndSC5)
	dbGoTo(cRegSC5)
EndIf

RestArea(aArea)

Return