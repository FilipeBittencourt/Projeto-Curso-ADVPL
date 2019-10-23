#include "protheus.ch"
#include "totvs.ch"


//
//
//
User Function FImOrdWG()
Local wnRel
Local cAlias    := "AB6"
Local cTitulo   := "Impressão OS CAC WEG"
Local cPrograma := "FImOrdWG"
Local cTamanho  := "M"

Private aReturn  := {"Zebrado", 1, "Administraçao", 1, 2, 1, "", 1}
Private nLastKey := 0     

// ALFONSO, PARA VERIFICAR SE ENTRA NESTE PROGRAMA
// Alert( 'Mensagem de Alerta', 'FImOrdWG ****' )

	wnRel := SetPrint(cAlias, cPrograma, "" , @cTitulo, "", "", "", .F., .F., .T., cTamanho, , .F.)
		     //SetPrint(cAlias, cProgram,  cPergunte, cTitle, cDesc1, cDesc2, cDesc3, lDic, aOrd, lCompres, cSize, uParm12, lFilter, lCrystal, cNameDrv, uParm16, lServer, cPortPrint)

	If nLastKey == 27
		Return
	EndIf

	SetDefault(aReturn, cAlias)

	RptStatus({| lEnd | U_ImOrdWg(@lEnd, wnRel, cAlias, cTamanho, cPrograma)}, cTitulo)
Return
//
//
// 
User Function ImOrdWg(lEnd, wnRel, cAlias, cTamanho, cPrograma)
Local aAreaAA1  := AA1->(GetArea())
Local aAreaAA3  := AA3->(GetArea())
Local aAreaAB7  := AB7->(GetArea())
Local aAreaSA1  := SA1->(GetArea())
Local aAreaSX3  := SX3->(GetArea())
local aAreaSB1  := SB1->(GetArea())
Local nLi       := 00
Local nPosItem  := 00
Local lAchouAA1 := .F.
Local lAchouAA3 := .F.
Local lAchouAB7 := .F.
Local lAchouSA1 := .F.
Local lAchouSB1 := .F.
//
Local cTag      := ""
Local cDados    := "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789"
Local cEsc0     := Chr(27) + "0"
Local cEsc1     := Chr(27) + "1"
Local cEsc2     := Chr(27) + "2"
Local cDescSer  := " "

	m_Pag := 1

	SetRegua(AB6->(Recno()))

	/*
	ESC 0		48	30	Seleciona espaçamento de linha de 1/8 polegada
	ESC 1		49	31	Seleciona espaçamento de linha de 7/72 polegada
	ESC 2		50	32	Seleciona espaçamento de linha de 1/6 polegada
	ESC 3 n		51	33	Seleciona espaçamento de linha de n/216 polegada	(n=0 a 255)
	ESC A n	65	41	Seleciona espaçamento de linha de n/72 polegada	(n = 0-85)
	ESC J n		74	4A	Executa alimentação de linha n/216 polegada  n=0-255
	*/
   
   // ALFONSO, PARA VERIFICAR SE ENTRA NESTE PROGRAMA
   // Alert( 'Mensagem de Alerta', 'FImOrdWG ****' )

	SA1->(DbSetOrder(1)) //clientes
	lAchouSA1 := SA1->(DbSeek(xFilial("SA1") + AB6->AB6_CODCLI + AB6->AB6_LOJA))

	AB7->(DbSetOrder(1))  //equipamento
	If Type("aCols") == "A"
		nPosItem  := aScan(aHeader, { |x| AllTrim(x[2]) == "AB7_ITEM" })
		lAchouAB7 := AB7->(DbSeek(xFilial("AB7") + AB6->AB6_NUMOS + aCols[n, nPosItem]))
	Else
		If xFilial("AB7") + AB7->AB7_NUMOS <> xFilial("AB6") + AB6->AB6_NUMOS
			lAchouAB7 := AB7->(DbSeek(xFilial("AB7") + AB6->AB6_NUMOS))
		Else
			lAchouAB7 := .T.
		EndIf
	EndIf
	
	AA3->(DbSetOrder(1)) //base instalada
	If lAchouAB7 
	   //	lAchouAA3 := AA3->(DbSeek(xFilial("AA3") +  AB6->AB6_CODCLI + AB6->AB6_LOJA + AB7->AB7_CODPRO + AB7->AB7_NUMSER))
	   	lAchouAA3 := AA3->(DbSeek(xFilial("AA3") +  AB6->AB6_CODCLI + AB6->AB6_LOJA + AB7->AB7_CODPRO + AB7->AB7_NUMSER + AB7->AB7_FILIAL))	
	EndIf

	SB1->(DbSetOrder(1))    
	If lAchouAA3 
		lAchouSB1 := SB1->(DbSeek(xFilial("SB1") + AA3->AA3_CODPRO))
	EndIf

	AA1->(DbSetOrder(1)) //tecnicos
	lAchouAA1 := AA1->(DbSeek(xFilial("AA1") + AB6->AB6_YCODTE))

	SX3->(DbSetOrder(2))

	@nLi,00 PSay cEsc0
	
	nLi := 05//04
	@nLi,74 PSay fTratar(,,"AB6", "AB6_NUMOS")   //COD SERV.
	@nLi,86 PSay fTratar(lAchouAB7,, "AB7", "AB7_YDTATE") //provavel data atendimento

	nLi := 07 //05
	@nLi,00 PSay fTratar(lAchouSA1,, "SA1", "A1_NOME") //NOME
	@nLi,74 PSay "(" + fTratar(lAchouSA1,, "SA1", "A1_DDD", "") + ") " + fTratar(lAchouSA1,, "SA1", "A1_TEL", "")  //FONE
	@nLi,98 PSay fTratar(,, "AB6", "AB6_YTELCO") //CELULAR

	nLi := 09 //07  3 CAMPOS
	@nLi,00 PSay fTratar(lAchouSA1,, "SA1", "A1_END")    //ENDERECO DE ATENDIMENTO
	@nLi,74 PSay SubStr(fTratar(lAchouSA1,, "SA1", "A1_BAIRRO"), 1, 15) //BAIRRO
	@nLi,98 PSay SubStr(fTratar(lAchouSA1,, "SA1", "A1_MUN"), 1, 15)//MUNICIPIO

	nLi := 11 //08  4 CAMPOS
	@nLi,00 PSay fTratar(,, "AB6", "AB6_YLOREF") //LOCAL DE REFERENCIA
   //	@nLi,53 PSay fTratar(lAchouAA1,, "AA3", "AA3_DTFABR") //DATA FABRICACAO	      - alfonso
   	@nLi,53 PSay fTratar(lAchouAA3,, "AA3", "AA3_DTFABR") //DATA FABRICACAO	
   	
	@nLi,74 PSay SubStr(fTratar(,, "AB6", "AB6_YSOLIC"), 1, 15) //SOLICITADO POR
	@nLi,98 PSay SubStr(fTratar(,, "AB6", "AB6_YPROCU"), 1, 15) //PROCURAR SR
      

	nLi := 13 //10  5 CAMPOS
	cTag := fTratar(lAchouAA3,,"AA3", "AA3_YTAG")
	@nLi,00 PSay SubStr(fTratar(lAchouSB1,, "SB1", "B1_DESC"), 1, 25) //TIPO DE MAQUINA
	@nLi,30 PSay fTratar(lAchouAA3,, "AA3", "AA3_NUMSER") + IIf(!Empty(cTag), "/" + cTag, "") //Nº SERIE DA MAQUINA
	//@nLi,53 PSay fTratar(lAchouAA3,, "AA3", "AA3_YMATER") //MATERIAL
	@nLi,53 PSay SubStr(fTratar(lAchouAA3,, "AA3", "AA3_YMATER"), 1, 20) //MATERIAL WEG
   // @nLi,74 PSay fTratar(lAchouAA3,, "SA1", "A1_EMAIL")  //EMAIL CLIENTE      - alfonso
   	@nLi,74 PSay fTratar(lAchouAA1,, "SA1", "A1_EMAIL")  //EMAIL CLIENTE  
   	   
	//@nLi,98 PSay SubStr(fTratar(lAchouAA3,, "AA3", "AA3_YELEAP"), 1, 15) //ELEMENTO AP

	// nLi := 15 //10  4 CAMPOS 
   //	nLi := 17 //10  4 CAMPOS    
    nLi := 15 //10  4 CAMPOS   -- ALFONSO 2018ABR20                                  
   	@nLi,00 PSay fTratar(,, "AA3", "AA3_YAEQPT") //APLICADO NO EQUIPAMENTO 
   
   // 	@nLi,40 PSay fTratar(,, "AA3", "AA3_YAEQMD") //APLICADO NO EQUIPAMENTO MODELO 
	@nLi,50 PSay fTratar(,, "AA3", "AA3_YAEQMD") //APLICADO NO EQUIPAMENTO MODELO  - ALFONSO 2018ABR20
	// @nLi,80 PSay fTratar(,, "AA3", "AA3_YAEQSE") //APLICADO NO EQUIPAMENTO SERIE	 
	@nLi,90 PSay fTratar(,, "AA3", "AA3_YAEQSE") //APLICADO NO EQUIPAMENTO SERIE- ALFONSO 2018ABR20

	//---DESCRICAO DOS SERVIÇOS
//	nLi := 17 //11
//	If lAchouAB7
//		If !Empty(AB7->AB7_MEMO1)
//			cDescSer := fTratar(, .F.,, MSMM(AB7->AB7_MEMO1, 95))
//		Else
//			cDescSer := Substr(fTratar(,, "AB6", "AB6_YDSSER"), 1, 95)	//DESCRICAO DE SERVICO
//		EndIf
//	EndIf
//
//   	@nLi,00 PSay cDescSer      
   
   //	nLi := 19  //13     
   	nLi := 17 // ALFONSO 2018ABR20 
	@nLi,76 PSay fTratar(lAchouAA1,, "AA1", "AA1_NOMTEC") //TECNICO

	nLi++
	@nLi,00 PSay cEsc1
     
// ALFONSO
	//---DESCRICAO DOS SERVIÇOS
   // 	nLi := 35 //11 
	nLi := 39 //11   ALFONSO 2018ABR20
	If lAchouAB7
		If !Empty(AB7->AB7_MEMO1)
			cDescSer := fTratar(, .F.,, MSMM(AB7->AB7_MEMO1, 95))
		Else
			cDescSer := Substr(fTratar(,, "AB6", "AB6_YDSSER"), 1, 95)	//DESCRICAO DE SERVICO
		EndIf
	EndIf

   	@nLi,00 PSay cDescSer 
   //	@nLi,00 PSay "XXXXXXXXXXXXXXXXXXXX"	    

	//MOTOR - RODAPÉ O.S.
	nLi := 79	//49
	@nLi,20 PSay fTratar(lAchouAA3,, "AA3", "AA3_YMOTMA") //MOTOR MARCA
	@nLi,40 PSay fTratar(lAchouAA3,, "AA3", "AA3_YMOTTP") //MOTOR TIPO
	
   //	nLi := 81  //51 // ALFONSO 2018ABR20 TROCADA P/LIN 89
 // @nLi,20 PSay fTratar(lAchouAA3,, "AA3", "AA3_YMSERI") //MOTOR SERIE 
 //	@nLi,40 PSay fTratar(lAchouAA3,, "AA3", "AA3_YMFATO") //FATOR SERVICO
 //	@nLi,60 PSay fTratar(lAchouAA3,, "AA3", "AA3_YCONTB") //CORRENTE NOMINAL DE TRABALHO
	
	
	nLi := 88 //53
	@nLi,20 PSay fTratar(lAchouAA3,, "AA3", "AA3_YCONOM") //CORRENTE NOMINAL
	//	@nLi,93 PSay fTratar(lAchouAA3,, "AA3", "AA3_YEMARC") //CORRENTE NOMINAL    
	
	nLi := 91  //51    // ALFONSO 2018ABR20
	@nLi,05 PSay fTratar(lAchouAA3,, "AA3", "AA3_YMSERI") //MOTOR SERIE 
	@nLi,20 PSay fTratar(lAchouAA3,, "AA3", "AA3_YMFATO") //FATOR SERVICO
	@nLi,60 PSay fTratar(lAchouAA3,, "AA3", "AA3_YCONTB") //CORRENTE NOMINAL DE TRABALHO
	
	nLi := 93  //52
	@nLi,05 PSay fTratar(lAchouAA3,, "AA3", "AA3_YTENAL") //POTENCIA CV
	@nLi,40 PSay fTratar(lAchouAA3,, "AA3", "AA3_YTENKW") //POTENCIA KW
		
//	nLi := 89 //55
//	@nLi,93 PSay fTratar(lAchouAA3,, "AA3", "AA3_YEPOT2")
		
//	nLi := 91  //56
//	@nLi,93 PSay fTratar(lAchouAA3,, "AA3", "AA3_YETIPO")
		
//	nLi := 93 //57
//	@nLi,93 PSay fTratar(lAchouAA3,, "AA3", "AA3_YESERI")
	
//	nLi := 95 //57
//	@nLi,74 PSay fTratar(lAchouAA3,, "AA3", "AA3_YMFATO")	

	nLi++
	@nLi,00 PSay cEsc2

	RestArea(aAreaSX3)
	RestArea(aAreaAA1)
	RestArea(aAreaAA3)
	RestArea(aAreaAB7)
	RestArea(aAreaSA1)
	RestArea(aAreaSB1)	

	Set Device to Screen

	If aReturn[5] == 1
		Set Printer To
		DbCommitAll()
		OurSpool(wnRel)
	Endif

	Ms_Flush()
Return

Static Function fTratar(lAchou, lField, cAlias, cField, xPadrao)
Local cPermitidas := " 0123456789ABCDEFGHIJKLMNOPQRSTUVXYZW!@#$%¨&*()_+-=[]{},.;/\|<>:?"
Local cChar       := ""
Local xResult     := ""
Local xValor
Default lAchou    := .T.
Default lField    := .T.
Default cAlias    := ""
Default xPadrao   := " "

	Begin Sequence
		If lAchou
			If lField .And. !Empty(cAlias)
				If SX3->(DbSeek(cField))
		      		xValor := &(cAlias + "->" + cField)
		      	Else
		    		Aviso(cField, "O campo " + cAlias + "->" + cField + " não foi encontrado.", {"Ok"})
		        	Break		      		
		    	EndIf
		    Else
		    	xValor := cField
			EndIf
			
			If ValType(xValor) == "C"
				xValor := Upper(NoAcento(AllTrim(xValor)))

				For nPos := 1 to Len(xValor)
					cChar := SubStr(xValor, nPos, 1)

					If cChar $ cPermitidas
						xResult += cChar
					EndIf
				Next nPos
			Else
				xResult := xValor
			EndIf
		EndIf
	End Sequence

	If Empty(xResult)
		xResult := xPadrao
	EndIf
Return xResult

Static Function fSx3(cField)
Local aAreaSX3 := SX3->(GetArea())
Local lAchou

	SX3->(DbSetOrder(2))
	lAchou := SX3->(DbSeek(cField))
	RestArea(aAreaSX3)
Return lAchou