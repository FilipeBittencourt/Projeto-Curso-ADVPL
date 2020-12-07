#include "rwmake.ch"
#include "topconn.ch"

/*/{Protheus.doc} F200DB1
@author Ranisses A. Corona
@since 18/06/13
@version 1.0
@description O ponto de entrada F200DB1 utilizado no CNAB a receber, será executado após gravar as despesas bancarias no SE5.
@history 27/10/2017, Fernando Rocha, Manutenção no fonte devido a erros FINA200 após migração para a versão P12
@history 21/11/2018, Ranisses A. Corona, Ajustes no posicionamento das tabelas abertas / While para verificação dos registros para acerto dos titulos.
@type function
/*/

User Function F200DB1()
Local aAreaSE1	:= SE1->(GetArea())
Local aAreaSE5	:= SE5->(GetArea())
Local cArq		:= ""
Local cInd		:= 0
Local cReg		:= 0

//Armazena area de Trabalho
cArq := Alias()
cInd := IndexOrd()
cReg := Recno()

IF SE5->(Eof())
	//MsgBox("F200DB1 - ERRO SE5 em EOF -> Título: "+IIF (!SE1->(Eof()) ,SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO), "SE1 em EOF" )+". FAVOR COMUNICAR A TI!","F200DB1","ALERT")
	Return
ENDIF	

//Posiciona no Título
dbSelectArea("SE1")
SE1->(dbOrderNickName("YNOSSONUM"))
SE1->(dbSeek(xFilial("SE1")+cNsNum))

While SE5->E5_BANCO+SE5->E5_AGENCIA+SE5->E5_CONTA+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA == SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA

	If SE5->E5_TIPODOC == 'DB' .And. Empty(Alltrim(SE5->E5_RECONC))
			
		//Posiciona no Movimento Bancario
		dbSelectArea("SE5")
		RecLock("SE5",.F.)
		
		// Tiago Rossini Coradini  - 23/02/2016 - OS: 4461-15 e 4663-15 - Clebes Jose - Alteração nas naturezas finaceiras por ocorrencia
		//Banco do Brasil
		If SE5->E5_BANCO == '001'
			
			If Alltrim(cOcorr) $ '02_05' //ENTRADA CONFIRMADA / LIQUIDACAO SEM REGISTRO
				SE5->E5_NATUREZ:= '2915'
				SE5->E5_HISTOR:= 'TAR. ENVIO COBRANCA '+Alltrim(SE1->E1_NUM)+" "+Alltrim(SE1->E1_PARCELA)
			ElseIf Alltrim(cOcorr) $ '23_96_98'
				SE5->E5_NATUREZ:= '2938'
				SE5->E5_HISTOR:= 'DESP. CART. COBRANCA '+Alltrim(SE1->E1_NUM)+" "+Alltrim(SE1->E1_PARCELA)
			EndIf
			
		//Bradesco
		ElseIf SE5->E5_BANCO == '237'
			
			If Alltrim(cOcorr) == '02'
				SE5->E5_NATUREZ	:= '2915'
				SE5->E5_HISTOR	:= 'TAR. ENVIO COBRANCA '+Alltrim(SE1->E1_NUM)+" "+Alltrim(SE1->E1_PARCELA)
			ElseIf Alltrim(cOcorr) == '28'
				SE5->E5_NATUREZ	:= '2938'
				SE5->E5_HISTOR	:= 'DESP. CART. COBRANCA '+Alltrim(SE1->E1_NUM)+" "+Alltrim(SE1->E1_PARCELA)
			EndIf
			
		EndIf	
		
		SE5->E5_CNABOC	:= cOcorr
		
		//PRECISA ACERTAR A DATA DO DISPONIVEL NAS TARIFAS
		If SE5->E5_BANCO == '001'
			If Alltrim(cOcorr) <> '05'
				SE5->E5_DTDISPO	:= SE5->E5_DATA
			EndIf
		EndIf
		
		If SE5->E5_BANCO == '237'
			If Alltrim(cOcorr) <> '28' //TARIFA DE PROTESTO
				SE5->E5_DTDISPO	:= SE5->E5_DATA
			EndIf
		EndIf

		//SE5->E5_CLVLDB := IIF(cEmpAnt == '01', '1101', IIF(cEmpAnt == '05', '1102', IIF(cEmpAnt == '06', '1055', IIF(cEmpAnt == '07', '1150', IIF(cEmpAnt == '12', '1090', IIF(cEmpAnt == '13', '1080', IIF(cEmpAnt == '14', '1500', '0')))))))
		SE5->E5_CLVLDB := U_BIA478G("ZJ0_CLVLDB", SE5->E5_NATUREZ, "P")
		
		SE5->E5_CCD	:= '1000'	
		
		//SE5->E5_PREFIXO := SE1->E1_PREFIXO
		//SE5->E5_NUMERO  := SE1->E1_NUM
		//SE5->E5_PARCELA := SE1->E1_PARCELA
		SE5->E5_ARQCNAB	:= MV_PAR04
		SE5->(MsUnLock())
		
	EndIf

	SE5->(dbskip())
EndDo

RestArea(aAreaSE1)
RestArea(aAreaSE5)

//Volta area de Trabalho
DbSelectArea(cArq)
DbSetOrder(cInd)
DbGoTo(cReg)

Return