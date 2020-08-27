#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FONT.CH"
#INCLUDE "MSOBJECT.CH"
#include "TOTVS.CH"
#INCLUDE "FWPrintSetup.ch"
#Include "RPTDEF.CH"

Class TWFormularioDEB From LongClassName
  Data cTitulo
  Data cNome
  Data cCNPJ
  Data cEndereco
  Data cBairro
  Data cCEP
  Data cMunicipio
  Data cFone
  Data cUF
  Data cIE
  Data cCodigo
  Data cDescricao
  Data cDocumento
  Data cClieteDe
  Data cClienteAte
  Data cNFDe
  Data cNFAte
  Data cPathPDF
  Data cFile
  Data aTexto
  Data cTexto
  Data nTamTxt
  Data cJob
  Data cFil


  Data lEnviado

  Data aRecSE1

  Data cLogo
  Data dDataEmissao
  Data dDataVencimento
  Data dDataDe
  Data dDataAte

  Data nQuantidade
  Data nValorUnitario
  Data nValorTotal
  Data nAnt
  Data nCurrentPrint

  Data lLimitePorPagina

  Data oPrint

  Data aDestinatario

  Method New() Constructor 		// Metodo construtor
  Method ConfigLayoutCabecalho()  // Determina as configurações do Layout
  Method AcionaImpressa()
  Method ObtemDadosNF()
  Method ImprimeItens()
  Method ImprimeProdutosPendentes()
  Method ObtemVencimentoFatura()
  Method Init()
  Method PopDest()
  Method Enviar()
  Method QuebraTexto()
EndClass

Method New() Class TWFormularioDEB

  self:cTitulo		  := ""
  self:cNome			  := ""
  self:cCNPJ			  := ""
  self:cEndereco	  	  := ""
  self:cBairro		  := ""
  self:cCEP			  := ""
  self:cMunicipio	  := ""
  self:cFone			  := ""
  self:cUF			  := ""
  self:cIE			  := ""
  self:cCodigo	  	  := ""
  self:cDescricao  	  := ""
  self:cDocumento	      := ""
  self:cNFDe			  := ""
  self:cNFAte		      := ""
  self:cLogo			  := "\system\tecnocryo.bmp"
  self:cPathPDF         := ""
  self:cFile            := ""
  self:cJob             := ""
  self:cFil             := ""

  self:aTexto		 := {}
  self:cTexto		 := ""
  self:nTamTxt		 := 0

  self:dDataEmissao	  := CTOD("")
  self:dDataVencimento := CTOD("")
  self:nAnt			  := 0
  self:nCurrentPrint   := 0
  self:nValorTotal	  := 0

  self:lLimitePorPagina:= .F.
  self:lEnviado        := .F.

  self:aDestinatario	  := {}
  self:aRecSE1         := {}
  self:oPrint		  := Nil

Return

Method Init() Class TWFormularioDEB
Return

Method ConfigLayoutCabecalho()  Class TWFormularioDEB

  Local oFont8
  Local oFont12n
  Local oFont12In
  Local oFont11n
  Local oAzulTecno	:= TBrush():New(,RGB(153,204,255),,)
  //	Local oDarkGray		:= TBrush():New(,RGB(169,169,169),,)
  //	Local oSilver		:= TBrush():New(,RGB(192,192,192),,)
  //	Local oLightGray	:= TBrush():New(,RGB(211,211,211),,)
  //	Local oGainsboro	:= TBrush():New(,RGB(220,220,220),,)
  //	Local oCinza		:= TBrush():New( , CLR_GRAY)

  Local nRow := 0
  Local nCol := 0

  oFont8   := TFont():New("Arial",9, 8,.T.,.F.,5,.T.,5,.T.,.F.)
  oFont11n := TFont():New("Arial",9,11,.T.,.T.,5,.T.,5,.T.,.F.)
  oFont11	 := TFont():New("Arial",9,11,.T.,.F.,5,.T.,5,.T.,.F.)
  oFont10n := TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
  oFont12n := TFont():New("Arial",9,12,.T.,.T.,5,.T.,5,.T.,.F.)
  oFont12In:= TFont():New("Arial",9,12,.T.,.T.,5,.T.,5,.T.,.F.)

  self:oPrint:StartPage()    // Inicia uma nova página

  nRow := 040
  nCol := 030

  self:oPrint:SayBitmap(nRow, nCol, self:cLogo, 180, 035)

  self:oPrint:Fillrect( {nRow + 002, 475, nRow + 022, 565 }, oAzulTecno)
  self:oPrint:Say( nRow + 015 , 478   , "NOTA COBRANÇA", oFont12n)
  self:oPrint:Line( nRow + 002, 475, nRow + 002, 565,, "-4")     						//Linha superior do box
  self:oPrint:Line( nRow + 002, 475, nRow + 022, 475,, "-4")     						//Linha superior do box
  self:oPrint:Line( nRow + 002, 565, nRow + 022, 565,, "-4")     						//Linha superior do box

  self:oPrint:Box( nRow + 023, 475, nRow + 037, 565 , "-4")
  self:oPrint:Say( nRow + 033, 494.74, self:cDocumento     , oFont12n)

  //____________________________________________________________________________________________
  //                                                                                            |
  // Dados ligados a identificação da Empresa                                                   |
  //____________________________________________________________________________________________|

  self:oPrint:Say(nRow + 060, nCol, SM0->M0_NOMECOM, oFont12In)

  //	self:oPrint:Say(nRow + 015, nCol + 110, cFilAnt +" - "+ FWFilName (cEmpAnt, cFilAnt )					, oFont12n)
  self:oPrint:Say(nRow + 082, nCol, "ENDEREÇO: "+SM0->M0_ENDENT+""									, oFont12In)
  self:oPrint:Say(nRow + 094, nCol, "BAIRRO/DISTRITO: "+SM0->M0_BAIRENT+""							, oFont12In)
  self:oPrint:Say(nRow + 106, nCol, "MUNICIPIO: "+Alltrim(SM0->M0_CIDENT)+" "						, oFont12In)
  self:oPrint:Say(nRow + 116, nCol, "UF: "+Alltrim(SM0->M0_ESTENT)+""								, oFont12In)
  self:oPrint:Say(nRow + 128, nCol, "CEP: "+Transform(Alltrim(SM0->M0_CEPENT),"@R 99.999-999")+""	, oFont12In)


  //____________________________________________________________________________________________
  //                                                                                            |
  // NOTA DE COBRANÇA | Nº                                                                      |
  //____________________________________________________________________________________________|



  //____________________________________________________________________________________________
  //                                                                                            |
  // CNPJ                                                                      				  |
  //____________________________________________________________________________________________|

  self:oPrint:Box( nRow + 105, 342,  nRow + 138, 487										  , "-4")       // Caixa Principal
  self:oPrint:Say( nRow + 118, 350, "CNPJ"												  , oFont12n)  	//
  self:oPrint:Say( nRow + 132, 350, Transform(Alltrim(SM0->M0_CGC),"@R 99.999.999/9999-99"), oFont11)   	//


  self:oPrint:Box( nRow + 138, 342, nRow + 168, 487, "-4") 												// Linha Divisória
  self:oPrint:Say( nRow + 150, 350, "INSCRIÇÃO ESTADUAL"	, oFont12n) 									//
  self:oPrint:Say( nRow + 164, 350, SM0->M0_INSC		, oFont11)

  SF2->(DbSetOrder(1))
  SF2->(DbSeek(xFilial("SF2") + self:cDocumento + self:aDestinatario[self:nAnt,06]))

  //____________________________________________________________________________________________
  //                                                                                            |
  // EMISSÃO                                                                      			  |
  //____________________________________________________________________________________________|

  self:oPrint:Fillrect( {nRow + 105, 490, nRow + 125, 565}, oAzulTecno)
  self:oPrint:Say( nRow + 118, 503, "EMISSÃO" , oFont12n)

  self:oPrint:Line( nRow + 105, 490, nRow + 105, 565,, "-4")     						//Linha superior do box
  self:oPrint:Line( nRow + 105, 490, nRow + 126, 490,, "-4")     						//Linha superior do box
  self:oPrint:Line( nRow + 105, 565, nRow + 126, 565,, "-4")     						//Linha superior do box


  self:oPrint:Box( nRow + 126, 490, nRow + 140, 565)
  self:oPrint:Say( nRow + 135, 503, DToC(SF2->F2_EMISSAO) , oFont11)
  //	self:oPrint:SayAlign ( nRow + 133, 478, DToC(SF2->F2_EMISSAO) , oFont11 , , , , 2,  )

  //____________________________________________________________________________________________
  //                                                                                            |
  // DESTINATÁRIO                                                                      		  |
  //____________________________________________________________________________________________|

  nRow := 210

  self:oPrint:Say(nRow - 005	, nCol, "DESTINATÁRIO"	, oFont12n)

  SA1->(DbSetOrder(1))
  SA1->(DbSeek(xFilial("SA1") + (SF2->F2_CLIENTE + SF2->F2_LOJA)))

  self:oPrint:Box( nRow 		, nCol, nRow + 085, 565, "-4")   				// Caixa Principal
  self:oPrint:Say(nRow + 013	, nCol + 003, "NOME/RAZÃO SOCIAL" 	, oFont12n)  				//
  self:oPrint:Say(nRow + 028	, nCol + 003, SA1->A1_NOME , oFont8  )  						//


  self:oPrint:Box( nRow 	 	, 415, nRow + 030, 565 	, "-4")  						   		// Linha divisória Vertical
  self:oPrint:Say( nRow + 013, 418, "CPF/CNPJ"		, oFont12n)  		 					//
  self:oPrint:Say( nRow + 028, 418, Transform( Alltrim(SA1->A1_CGC), "@R 99.999.999/9999-99" ), oFont11)

  //______________________________________________________________________________________
  //                                                                                      |
  //                                                                                      |
  //______________________________________________________________________________________|

  self:oPrint:Box( nRow + 060 , 215, nRow + 085, 565 	, "-4")								// Linha divisória Vertical
  self:oPrint:Say( nRow + 073 , 218, "FONE"	, oFont12n)                         			//
  self:oPrint:Say( nRow + 083 , 218, TWPicture(SA1->(A1_DDD+A1_TEL))	, oFont8)  									//

  self:oPrint:Box( nRow + 060 , 303, nRow + 085, 565 	, "-4")								// Linha divisória Vertical

  self:oPrint:Box( nRow + 030 , 300, nRow + 085, 565 	, "-4")                             // Linha divisória Vertical
  self:oPrint:Say( nRow + 043 , 303, "BAIRRO/DISTRITO"	, oFont12n)
  self:oPrint:Say( nRow + 058 , 303, SA1->A1_BAIRRO		, oFont8)  							//

  self:oPrint:Box( nRow + 030 , 490, nRow + 060, 565 	, "-4")                             // Linha divisória Vertical
  self:oPrint:Say( nRow + 043 , 493, "CEP"				, oFont12n)                         //
  self:oPrint:Say( nRow + 058 , 493, Transform(Alltrim(SA1->A1_CEP),"@R 99.999-999")			, oFont8)  							//

  self:oPrint:Box( nRow + 060 , 400, nRow + 085, 565 	, "-4")                             // Linha divisória Vertical
  self:oPrint:Say( nRow + 073 , 403, "INSC. ESTADUAL"	, oFont12n)                         //
  self:oPrint:Say( nRow + 083 , 403, SA1->A1_INSCR		, oFont8)  							//


  self:oPrint:Box( nRow + 030 , nCol, nRow + 030, 565 	, "-4")  							// Primeira Linha divisória  Horizontal
  self:oPrint:Say( nRow + 043 , nCol + 003, "ENDEREÇO"	, oFont12n)  						//
  self:oPrint:Say( nRow + 058 , nCol + 003, SA1->A1_END	, oFont8)  							//


  self:oPrint:Box( nRow + 060 , nCol, nRow + 060, 565	, "-4")  							// Segunda Linha divisória Horizontal
  self:oPrint:Say( nRow + 073 , nCol + 003, "MUNICÍPIO"	, oFont12n)  						//
  self:oPrint:Say( nRow + 083 , nCol + 003, SA1->A1_MUN	, oFont8)  							//


  self:oPrint:Say( nRow + 073 , 303, "UF"				, oFont12n)                         //
  self:oPrint:Say( nRow + 083 , 303, SA1->A1_EST         , oFont8)  							//

Return

	/**/

Method AcionaImpressa() Class TWFormularioDEB

  self:oPrint:EndPage() 		// Finaliza a página
  self:oPrint:Preview()		// Vizualizar
Return

	/**/

Method ImprimeItens() Class TWFormularioDEB
  Local cMsg 		 := ""
  Local nRow 		 := 320
  Local nCol 		 := 030
  Local nK		 := 0
  Local nI         := 0
  Local aAux 		 := {}
  Local oFont8	 := TFont():New("Courier New",9,8,.T.,.F.,5,.T.,5,.T.,.F.)
  Local oFont12n 	 := TFont():New("Arial",9,12,.T.,.T.,5,.T.,5,.T.,.F.)
  Local oFont14n   := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
  Local aArea      := GetArea()
  Local cPicPrcVen := ""
  Local cPicQuant  := ""
  Local cPicTotal  := "", nTamStr
  Local oAzulTecno := TBrush():New(,RGB(153,204,255),,)


  DbSelectArea("SD2")

  cPicPrcVen := X3Picture("D2_PRCVEN")
  cPicQuant  := X3Picture("D2_QUANT")
  cPicTotal  := X3Picture("D2_TOTAL")

  RestArea(aArea)

  //____________________________________________________________________________________________
  //                                                                                            |
  // DADOS DO DOCUMENTO                                                                      	  |
  //____________________________________________________________________________________________|

  self:oPrint:Say( nRow  , nCol, "DADOS DO DOCUMENTO", oFont12n)         				//

  self:oPrint:Fillrect( {nRow + 003, nCol, nRow + 030, 565}, oAzulTecno, "-4")				//Cor de fundo do cabeçalho

  self:oPrint:Line( nRow + 003, nCol, nRow + 003, 565,, "-4")     						//Linha superior do box
  self:oPrint:Line( nRow + 003, nCol      , nRow + 030, nCol,, "-4")     				// Primeira coluna do BOX

  self:oPrint:Say ( nRow + 023, nCol + 003, "Código", oFont12n)         					// CÓDIGO
  self:oPrint:Line( nRow + 003, nCol + 070, nRow + 030, nCol + 070,, "-4")     			// segunda coluna Divisória Vertical
  self:oPrint:Say ( nRow + 023, nCol + 075, "Descrição", oFont12n)         				// Descrição
  self:oPrint:Line( nRow + 003, nCol + 300, nRow + 030, nCol + 300,, "-4")     			// Segunda Linha Divisória Vertical
  self:oPrint:Say ( nRow + 023, nCol + 320, "Quantidade", oFont12n)         					//
  self:oPrint:Line( nRow + 003, nCol + 380, nRow + 030, nCol + 380,, "-4")     			// Terceira Linha Divisória Vertical
  self:oPrint:Say ( nRow + 023, nCol + 398, "Unitário (R$)", oFont12n)         				//
  self:oPrint:Line( nRow + 003, nCol + 460, nRow + 030, nCol + 460,, "-4")     			// Quarta Linha Divisória
  self:oPrint:Say ( nRow + 023, nCol + 483, "Total (R$)", oFont12n)         				//
  self:oPrint:Line( nRow + 003, 565, nRow + 030, 565,, "-4")     						// Primeira Linha Divisória Vertical

  self:oPrint:Line( nRow + 030, nCol, nRow + 030, 565,, "-4")     						// Primeira Linha Divisória Vertical

  IF self:cDocumento == "000006511"
    cAchei := .T.
  ENDIF

  //___________________________________________________________________________________
  //                                                                                   |
  // Parte que controla a impressão dos dados                                          |
  //___________________________________________________________________________________|

  aAux := self:aDestinatario[self:nAnt][3]
  nRow += 012

  For nK := 1 To  Len( aAux )

    self:cTexto	:= aAux[nK][2]
    self:nTamTxt	:= 51

    self:QuebraTexto()


    If self:lLimitePorPagina

      If nK > self:nCurrentPrint

        self:oPrint:Line( nRow +18, nCol      , nRow + 030, nCol ,, "-4")     			// Primeira Linha Divisória Vertical
        self:oPrint:Say ( nRow +27, nCol + 003, aAux[nK][1]     , oFont8)
        self:oPrint:Line( nRow +18, nCol + 070, nRow + 030, nCol + 070,, "-4")     			// Primeira Linha Divisória Vertical
        self:oPrint:Say ( nRow +27, nCol + 075, self:aTexto[ 1 ]	  , oFont8)
        self:oPrint:Line( nRow +18, nCol + 300, nRow + 030, nCol + 300,, "-4")     			// Segunda Linha Divisória Vertical
        self:oPrint:Say ( nRow +27, nCol + 325, Transform(aAux[nK][4], cPicQuant), oFont8)  //
        self:oPrint:Line( nRow +18, nCol + 380, nRow + 030, nCol + 380,, "-4")     			// Terceira Linha Divisória Vertical
        self:oPrint:Say ( nRow +27, nCol + 373, Transform(aAux[nK][3], cPicPrcVen), oFont8)  //D2_PRCVEN
        self:oPrint:Line( nRow +18, nCol + 460, nRow + 030, nCol + 460,, "-4")     			// Quarta Linha Divisória
        self:oPrint:Say ( nRow +27, nCol + 468, Transform(aAux[nK][5], cPicTotal), oFont8)  //D2_TOTAL
        self:oPrint:Line( nRow +18, 565 , nRow + 030, 565,, "-4")     						// Primeira Linha Divisória Vertical

        FOR nI := 2 TO Len( self:aTexto )
          nRow += 010
          self:oPrint:Line( nRow +18, nCol      , nRow + 030, nCol ,, "-4")     			// Primeira Linha Divisória Vertical
          self:oPrint:Line( nRow +18, nCol + 070, nRow + 030, nCol + 070,, "-4")     			// Primeira Linha Divisória Vertical
          self:oPrint:Say ( nRow +27, nCol + 075, self:aTexto[ nI ], oFont8)
          self:oPrint:Line( nRow +18, nCol + 300, nRow + 030, nCol + 300,, "-4")     			// Segunda Linha Divisória Vertical
          self:oPrint:Line( nRow +18, nCol + 380, nRow + 030, nCol + 380,, "-4")     			// Terceira Linha Divisória Vertical
          self:oPrint:Line( nRow +18, nCol + 460, nRow + 030, nCol + 460,, "-4")     			// Quarta Linha Divisória
          self:oPrint:Line( nRow +18, 565 , nRow + 030, 565,, "-4")     						// Primeira Linha Divisória Vertical
        NEXT

        self:oPrint:Line( nRow + 030, nCol, nRow + 030, 565,, "-4")     			// Primeira Linha Divisória Vertical

        self:nCurrentPrint := nK
        nRow += 012


      End If
    Else

      self:oPrint:Line( nRow +18, nCol      , nRow + 030, nCol ,, "-4")     			// Primeira Linha Divisória Vertical
      self:oPrint:Say ( nRow +27, nCol + 003, aAux[nK][1]     , oFont8)
      self:oPrint:Line( nRow +18, nCol + 070, nRow + 030, nCol + 070,, "-4")     			// Primeira Linha Divisória Vertical
      self:oPrint:Say ( nRow +27, nCol + 075, self:aTexto[1], oFont8)
      self:oPrint:Line( nRow +18, nCol + 300, nRow + 030, nCol + 300,, "-4")     			// Segunda Linha Divisória Vertical
      self:oPrint:Say ( nRow +27, nCol + 325, Transform(aAux[nK][4], cPicQuant), oFont8)  //
      self:oPrint:Line( nRow +18, nCol + 380, nRow + 030, nCol + 380,, "-4")     			// Terceira Linha Divisória Vertical
      self:oPrint:Say ( nRow +27, nCol + 373, Transform(aAux[nK][3], cPicPrcVen), oFont8)  //D2_PRCVEN
      self:oPrint:Line( nRow +18, nCol + 460, nRow + 030, nCol + 460,, "-4")     			// Quarta Linha Divisória
      self:oPrint:Say ( nRow +27, nCol + 468, Transform(aAux[nK][5], cPicTotal), oFont8)  //D2_TOTAL
      self:oPrint:Line( nRow +18, 565 , nRow + 030, 565,, "-4")     						// Primeira Linha Divisória Vertical

      FOR nI := 2 TO Len( self:aTexto )
        nRow += 010
        self:oPrint:Line( nRow +18, nCol      , nRow + 030, nCol ,, "-4")     			// Primeira Linha Divisória Vertical
        self:oPrint:Line( nRow +18, nCol + 070, nRow + 030, nCol + 070,, "-4")     			// Primeira Linha Divisória Vertical
        self:oPrint:Say ( nRow +27, nCol + 075, self:aTexto[ nI ], oFont8)
        self:oPrint:Line( nRow +18, nCol + 300, nRow + 030, nCol + 300,, "-4")     			// Segunda Linha Divisória Vertical
        self:oPrint:Line( nRow +18, nCol + 380, nRow + 030, nCol + 380,, "-4")     			// Terceira Linha Divisória Vertical
        self:oPrint:Line( nRow +18, nCol + 460, nRow + 030, nCol + 460,, "-4")     			// Quarta Linha Divisória
        self:oPrint:Line( nRow +18, 565 , nRow + 030, 565,, "-4")     						// Primeira Linha Divisória Vertical
      NEXT

      self:oPrint:Line( nRow + 030, nCol, nRow + 030, 565,, "-4")     			// Primeira Linha Divisória Vertical

      nRow += 012

    End If

    //____________________________________________________________
    //                                                            |
    // Controle de limite de impressão                            |
    //____________________________________________________________|
    If  nRow >= 440

      self:lLimitePorPagina := .T.
      self:nCurrentPrint    := nK

      Exit
    End If

  Next nK

  nRow := 560

  self:oPrint:Fillrect( {nRow + 002, nCol + 297, nRow + 025, 565 }, oAzulTecno)
  self:oPrint:Say( nRow + 015, nCol + 318, "VALOR TOTAL DA NOTA DE COBRANÇA", oFont12n)  		//

  self:oPrint:Line( nRow + 002, nCol + 297, nRow + 002, 565,, "-4")     						//Linha superior do box
  self:oPrint:Line( nRow + 002, nCol + 297, nRow + 026, nCol + 297,, "-4")     						//Linha superior do box
  self:oPrint:Line( nRow + 002, 565       , nRow + 026, 565,, "-4")     						//Linha superior do box

  self:oPrint:Box( nRow + 026, nCol + 297, nRow + 054, 565 , "-4")
  self:oPrint:Say( nRow + 044, nCol + 375, "R$ " + Transform(self:nValorTotal, "@E 999,999.99"), oFont14n)  //

  self:oPrint:Box( nRow + 058, nCol + 003, nRow + 190, 565, "-4") 															  // Caixa cujo conteúdo será preenchido com as observações
  self:oPrint:Say( nRow + 056, nCol + 006, "INFORMAÇÕES ADICIONAIS"												  ,	oFont12n) //
  self:oPrint:Say( nRow + 073, nCol + 006, "Nosso site: http://www.tecnocryo.com.br/"							  , oFont8)	  //
  self:oPrint:Say( nRow + 083, nCol + 006, "E-mail: " + If(cFilAnt == "0201", "nfmg@tecnocryo.com.br", "contato@tecnocryo.com.br"), oFont8)	  //
  self:oPrint:Say( nRow + 093, nCol + 006, "Atendimento a clientes - Tel.: " + If(cFilAnt == "0201", "(31)3849-6491", "(27)3225-6533"), oFont8)	  //
  self:oPrint:Say( nRow + 103, nCol + 006, "OPERAÇÃO NÃO SUJEITA AO I.S.S DE ACORDO COM A LEI COMPLEMENTAR 116/03" , oFont8)	  //

  self:oPrint:Say( nRow + 118, nCol + 006, "VENCIMENTO: "+DTOC(self:aDestinatario[self:nAnt][4])+"   CLIENTE: "+SubStr(self:aDestinatario[self:nAnt][1],1,9)+"", oFont8)  															  //

  //	self:oPrint:Say( nRow + 143, nCol + 006, self:aDestinatario[self:nAnt, 05], oFont8)

  cMsgAdic := self:aDestinatario[self:nAnt, 05]
  //	nTam	 := 120
  //	nStr	 := 1
  nRow 	 += 128
  nOldRow	 := nRow

  self:cTexto	:= cMsgAdic
  self:nTamTxt	:= 120

  self:QuebraTexto()

  IF  self:aTexto[1] != "SEM TEXTO"

    FOR nI := 1 TO Len( self:aTexto )
      self:oPrint:Say( nRow, nCol + 006, self:aTexto[ nI ], oFont8)
      nRow += 10
    NEXT

  ENDIF

  nRow := nOldRow

  self:oPrint:Box( nRow + 080, nCol + 003, nRow + 140, 565, "-4") 								// Última caixa da página
  self:oPrint:Box( nRow + 100, nCol + 003, nRow + 140, 565 , "-4")     		            		// Linha Divisória Horizontal

  cMsg := "EM CASO DE LOCAÇÃO, ATESTAMOS QUE OS DADOS ACIMA CONFEREM COM OS BENS CEDIDOS EM LOCAÇÃO."

  self:oPrint:Say( nRow + 93, nCol + 006, cMsg, oFont8)  										//
  self:oPrint:Say( nRow + 108, nCol + 006, "DATA DO RECEBIMENTO:", oFont8)  			    		//

  self:oPrint:Box( nRow + 100, nCol + 190, nRow + 0140, nCol + 190 , "-4")                		// Linha Divisória Vertical
  self:oPrint:Say( nRow + 108, nCol + 193, "IDENT./ASS. RECEBEDOR:", oFont8)  					//

  self:oPrint:Box( nRow + 100, nCol + 380, nRow + 0140, nCol + 380 , "-4")                		// Linha Divisória Vertical
  self:oPrint:Say( nRow + 108, nCol + 383, "NOTA COBRANÇA. Nº: "+self:cDocumento+" ", oFont8)  		//

Return

Method QuebraTexto() Class TWFormularioDEB

  Local nStr 	 := 1

  self:aTexto	:= {}

  WHILE nStr < Len( self:cTexto )

    nTamStr	:= self:nTamTxt
    lTamDif := Empty( SubStr( self:cTexto, nTamStr + 1,  1  ) ) .OR. Empty( SubStr( self:cTexto, nTamStr,  1  ) )

    IF ! lTamDif

      nTamStr	:= rAT( " ", SubStr( self:cTexto, nStr, nTamStr  ) )

      IF nTamStr < 1
        nTamStr := LEN( self:cTexto )
      ENDIF

      //			nTamStr += 1

    ENDIF

    aAdd( self:aTexto, AllTrim( SubStr( self:cTexto, nStr, nTamStr ) ) )

    nStr += nTamStr

  ENDDO

  IF Len(self:aTexto) == 0
    self:aTexto := {"SEM TEXTO"}
  ENDIF

Return

	/**/
Method ImprimeProdutosPendentes() Class TWFormularioDEB

  While self:nCurrentPrint < Len(self:aDestinatario[self:nAnt][3])

    self:ConfigLayoutCabecalho()

    self:ImprimeItens()

    If  self:nCurrentPrint == Len(self:aDestinatario[self:nAnt][3])

      self:lLimitePorPagina := .F.

      Exit
    End If
  End

Return
	/**/
Method PopDest() Class TWFormularioDEB
  Local aArea     := GetArea()
  Local cRecs     := ""
  Local cWorkArea := GetNextAlias()
  Local cSql      := ""
  Local n         := 0
  Local nPosLoc

  chkfile("SC5")
  chkfile("SA1")

  If Empty(self:aRecSE1)
    Return
  EndIf

  For n := 1 To Len(self:aRecSE1)
    cRecs += cValToChar(self:aRecSE1[n])

    If n != Len(self:aRecSE1)
      cRecs += ","
    EndIf
  Next n

  cSql := "SELECT E1_VENCREA, D2_PEDIDO, D2_CLIENTE, D2_LOJA, D2_SERIE, D2_DOC, A1_COD, A1_LOJA, B1_COD, (CASE WHEN A1_YAGLLOC = 'S' THEN B1_DESC ELSE C6_DESCRI END ) B1_DESC, D2_PRCVEN, D2_QUANT, D2_TOTAL, F2_MENNOTA, A1_YAGLLOC "
  cSql += "  FROM " + RetSqlName("SE1") + " SE1 (NOLOCK) "
  cSql += "  JOIN " + RetSqlName("SF2") + " SF2 (NOLOCK) ON F2_FILIAL = E1_FILIAL "
  cSql += "                          AND F2_DOC = E1_NUM "
  cSql += "						  AND F2_SERIE = E1_PREFIXO "
  cSql += "						  AND F2_CLIENTE = E1_CLIENTE "
  cSql += "						  AND F2_LOJA = E1_LOJA "
  cSql += "						  AND SF2.D_E_L_E_T_ != '*' "
  cSql += "  JOIN " + RetSqlName("SA1") + " SA1 (NOLOCK) ON A1_FILIAL = '" + xFilial("SA1") + "' "
  cSql += "                          AND A1_COD = F2_CLIENTE "
  cSql += "						  AND A1_LOJA = F2_LOJA "
  cSql += "						  AND SA1.D_E_L_E_T_ != '*' "
  cSql += "  JOIN " + RetSqlName("SD2") + " SD2 (NOLOCK) ON D2_FILIAL = F2_FILIAL "
  cSql += "                          AND D2_DOC = F2_DOC "
  cSql += "						  AND D2_SERIE = F2_SERIE "
  cSql += "						  AND D2_CLIENTE = F2_CLIENTE "
  cSql += "						  AND D2_LOJA = F2_LOJA "
  cSql += "						  AND SD2.D_E_L_E_T_ != '*' "
  cSql += "  JOIN " + RetSqlName("SB1") + " SB1 (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' "
  cSql += "                          AND B1_COD = D2_COD "
  cSql += "						  AND SB1.D_E_L_E_T_ != '*' "
  cSQL += "JOIN  " +RetSqlName("SC6")+" SC6 ON "
  cSQL += "C6_PRODUTO = D2_COD 	 AND "
  cSQL += "C6_NUM = D2_PEDIDO	 AND "
  cSQL += "C6_FILIAL = D2_FILIAL AND "
  cSQL += "C6_ITEM = D2_ITEMPV "
  cSql += " WHERE SE1.R_E_C_N_O_ IN (" + cRecs + ") "
  cSql += "   AND SE1.D_E_L_E_T_ != '*' "
  cSql += " ORDER BY D2_FILIAL, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_ITEM "

  TcQuery cSql New Alias (cWorkArea)

  While !(cWorkArea)->(Eof())

    nPos :=  aScan(self:aDestinatario,{|x| x[2] == (cWorkArea)->(D2_DOC) })

    Posicione( "SC5", 1, xFilial("SC5") + (cWorkArea)->D2_PEDIDO, "Found()" )
    Posicione( "SA1", 1, xFilial("SA1") + (cWorkArea)->( D2_CLIENTE + D2_LOJA ), "Found()" )

    If nPos  == 0
      aAdd(self:aDestinatario, {	(cWorkArea)->(A1_COD + A1_LOJA) ,;
        (cWorkArea)->(D2_DOC)			  ,;
        {{ (cWorkArea)->B1_COD   		  ,;
        (cWorkArea)->B1_DESC  		  ,;
        (cWorkArea)->D2_PRCVEN		  ,;
        (cWorkArea)->D2_QUANT		  ,;
        (cWorkArea)->D2_TOTAL         ;
        }} ,;
        STOD((cWorkArea)->E1_VENCREA) ,;
        upper( allTrim(Formula(SC5->C5_MENPAD)) ) + ". " + AllTrim((cWorkArea)->F2_MENNOTA), ;
        (cWorkArea)->D2_SERIE ;
        })
    Else
      nPosLoc := 0
      //Aglutina ocorrências de um produto num linha.
      IF (cWorkArea) -> A1_YAGLLOC == "S"
        nPosLoc := aScan( self:aDestinatario[nPos][3], {|x| x[1] == (cWorkArea)->(B1_COD) })
      ENDIF

      IF nPosLoc == 0
        aAdd(self:aDestinatario[nPos][3], {	(cWorkArea)->B1_COD      ,;
          (cWorkArea)->B1_DESC     ,;
          (cWorkArea)->D2_PRCVEN   ,;
          (cWorkArea)->D2_QUANT	   ,;
          (cWorkArea)->D2_TOTAL     ;
          })
      ELSE
        self:aDestinatario[nPos][3][nPosLoc][4] += (cWorkArea)->D2_QUANT
        self:aDestinatario[nPos][3][nPosLoc][5] += (cWorkArea)->D2_TOTAL
      ENDIF
    EndIf

    (cWorkArea)->(DbSkip())
  EndDo

  (cWorkArea)-> ( DbCloseArea() )

  RestArea(aArea)
Return Self
	/**/
Method ObtemDadosNF() Class TWFormularioDEB
  Local cWorkArea := GetNextAlias()
  Local cSQL		:= ""
  //	Local cQuebra   := Chr(13) + Chr(10)

  cSQL += "SELECT 	 	 	  "
  cSQL += "A1_COD			 	 ,"
  cSQL += "A1_LOJA			 ,"
  cSQL += "A1_NOME			 ,"
  cSQL += "A1_END				 ,"
  cSQL += "A1_EST				 ,"
  cSQL += "A1_INSCR			 ,"
  cSQL += "A1_MUN				 ,"
  cSQL += "A1_BAIRRO			 ,"
  cSQL += "A1_CGC				 ,"
  cSQL += "A1_CEP				 ,"
  cSQL += "D2_EMISSAO			 ,"
  cSQL += "A1_DDD + A1_TEL 	 ,"
  cSQL += "A1_FAX				 ,"
  cSQL += "D2_PEDIDO			 ,"
  cSQL += "D2_ITEM			 ,"
  cSQL += "B1_COD				 ,"
  cSQL += "D2_CLIENTE			 ,"
  cSQL += "D2_LOJA			 ,"
  cSQL += "D2_PRCVEN			 ,"
  cSQL += "D2_TOTAL AS D2_TOTAL,"
  cSQL += "D2_QUANT 			 ,"
  cSQL += "D2_DOC 			 ,"
  cSQL += "D2_SERIE 			 ,"
  cSQL += "E1_VENCREA			 ,"
  cSQL += "A1_YAGLLOC			 ,"
  cSQL += "F2_MENNOTA			  "
  cSQL += "FROM " +RetSqlName("SD2")+" AS SD2 JOIN " + RetSqlName("SA1")+" SA1 "

  cSQL += "ON A1_COD = D2_CLIENTE "
  cSQL += "AND A1_LOJA = D2_LOJA  "
  cSQL += "JOIN  " +RetSqlName("SB1")+" SB1 ON "
  cSQL += "D2_COD = B1_COD 	"

  cSQL += "INNER JOIN  " +RetSqlName("SF2")+" SF2 ON  "
  cSQL +=" SF2.D_E_L_E_T_=''							"
  cSQL +=" SC6.D_E_L_E_T_=''							"
  cSQL += "AND SF2.F2_FILIAL 	= "+xFilial("SF2")+" 	"
  cSQL +=" AND SF2.F2_FILIAL  = SD2.D2_FILIAL 		"
  cSQL +=" AND SF2.F2_DOC     = SD2.D2_DOC			"
  cSQL +=" AND SF2.F2_CLIENTE = SA1.A1_COD			"
  cSQL +=" AND SF2.F2_LOJA    = SA1.A1_LOJA  			"
  cSQL +=" AND SF2.F2_CLIENTE	= SD2.D2_CLIENTE 		"
  cSQL +=" AND SF2.F2_LOJA    = SD2.D2_LOJA			"

  cSQL += " LEFT JOIN  " +RetSqlName("SE1")+" SE1 ON  "
  cSQL += " SE1.E1_FILIAL 	  = "+xFilial("SE1")+" 	"
  cSQL += " AND SE1.D_E_L_E_T_  =''    				"
  cSQL += " AND SE1.E1_FILIAL	  = SF2.F2_FILIAL		"
  cSQL += " AND SE1.E1_PREFIXO  = SF2.F2_PREFIXO		"
  cSQL += " AND SE1.E1_NUM	  = SF2.F2_DOC      	"
  cSQL += " AND SE1.E1_CLIENTE  = SF2.F2_CLIENTE  	"
  cSQL += " AND SE1.E1_LOJA	  = SF2.F2_LOJA     	"
  cSQL += " AND SE1.E1_SERIE    = SF2.F2_SERIE    	"
  cSQL += " AND SE1.E1_NUM	  = SD2.D2_DOC      	"
  cSQL += " AND SE1.E1_SERIE    = SD2.D2_SERIE    	"
  cSQL += " AND SE1.E1_CLIENTE  = SD2.D2_CLIENTE  	"
  cSQL += " AND SE1.E1_CLIENTE  = SA1.A1_COD      	"
  cSQL += " AND SE1.E1_LOJA	  = SA1.A1_LOJA     	"

  cSQL += "WHERE SD2.D_E_L_E_T_ <> '*' 				"
  cSQL += "AND SB1.D_E_L_E_T_ <> '*' 					"
  cSQL += "AND SA1.D_E_L_E_T_ <> '*'	 				"
  cSQL += "AND A1_FILIAL 	= "+xFilial("SA1")+" 		"
  cSQL += "AND B1_FILIAL  = "+xFilial("SB1")+"  		"

  If !Empty(self:dDataAte)
    cSQL += "AND SF2.F2_EMISSAO BETWEEN '"+self:dDataDe+"' AND '"+self:dDataAte+"' "
  End If

  If !Empty(self:cClienteAte)
    cSQL += "AND SF2.F2_CLIENTE BETWEEN '"+self:cClieteDe+"' AND '"+self:cClienteAte+"' "
  End If

  If !Empty(self:cNFAte)
    cSQL += "AND SF2.F2_DOC BETWEEN '"+self:cNFDe+"' AND '"+self:cNFAte+"' "
  End If

  dbUseArea( .T., "TOPCONN", TcGenQry(,,cSQL), cWorkArea, .T., .F. )

  While ( cWorkArea ) -> ( ! Eof() )

    nPos :=  aScan(self:aDestinatario,{|x| Alltrim(x[2]) == (cWorkArea)->(D2_DOC) })

    Posicione( "SC5", 1, xFilial("SC5") + (cWorkArea)->D2_PEDIDO, "Found()" )
    Posicione( "SA1", 1, xFilial("SA1") + (cWorkArea)->( D2_CLIENTE + D2_LOJA ), "Found()" )

    If nPos  == 0
      aAdd(self:aDestinatario,;
        {;
        (cWorkArea) -> ( A1_COD + A1_LOJA ) ,;
        (cWorkArea) -> ( D2_DOC )			,;
        {;
        {;
        (cWorkArea) -> B1_COD   		,;
        (cWorkArea)	-> B1_DESC  		,;
        (cWorkArea) -> D2_PRCVEN		,;
        (cWorkArea) -> D2_QUANT		  	,;
        (cWorkArea) -> D2_TOTAL         ;
        };
        },;
        STOD   ( (cWorkArea) -> E1_VENCREA ) ,;
        upper(allTrim(Formula(SC5->C5_MENPAD))) + ". " + AllTrim( (cWorkArea) -> F2_MENNOTA ), ;
        (cWorkArea) -> D2_SERIE ;
        })
    Else

      aAdd(self:aDestinatario[nPos][3], {;
        (cWorkArea)->B1_COD      ,;
        (cWorkArea)->B1_DESC     ,;
        (cWorkArea)->D2_PRCVEN   ,;
        (cWorkArea)->D2_QUANT	   ,;
        (cWorkArea)->D2_TOTAL     ;
        })

    EndIf

    (cWorkArea)->(dbSkip())
  End Do

  (cWorkArea)-> ( DbCloseArea() )

Return

Method Enviar() Class TWFormularioDEB
  //Local cServidor   := AllTrim(GetMv("MV_RELSERV"))
  //Local cConta      := AllTrim(GetMv("MV_RELACNT"))
  //Local cContaSenha := AllTrim(GetMv("MV_RELAPSW"))
  //Local cUsuarioAut := AllTrim(GetMv("MV_RELAUSR"))
  //Local cMsg        := ""
  //Local cSenhaAut   := AllTrim(GetMv("MV_RELAPSW"))
  //Local cDe         := AllTrim(GetMv("MV_RELFROM"))
  //Local lAut        := GetMv("MV_RELAUTH")
  //Local lSSL        := GetMv("MV_RELSSL")
  //Local lTSL        := GetMv("MV_RELTLS")
  //Local nTimeOut    := GetMv("MV_RELTIME")
  //Local nPorta      := 0
  //Local cNmJob      := self:cJob
  //Local cCodFil     := self:cFil
  //Local oGerencia, oEmail
  //Local nErro, nPosPorta
//
  //self:lEnviado := .F.
//
  //cUsuarioAut := If(Empty(cUsuarioAut), cConta, cUsuarioAut)
  //cSenhaAut   := If(Empty(cSenhaAut), cContaSenha, cSenhaAut)
  //cDe         := If(Empty(cDe), "workflow@protheus.com.br", cDe)
  //nTimeOut    := If(Empty(nTimeOut), 120, nTimeOut)
  //nPosPorta   := At(":", cServidor)
//
  //If nPosPorta > 0
  //	nPorta    := Val(AllTrim(SubStr(cServidor, nPosPorta + 1)))
  //	cServidor := SubStr(cServidor, 1, nPosPorta - 1)
  //End If
//
  //conout("")
  //conout("")
  //conout("===============================================")
  //conout( iif(!empty(cNmJob), "["+alltrim(cNmJob)+"]","")+iif(!empty(cCodFil),"[Fil.: "+alltrim(cCodFil)+"]","")+"[MAIL] NEW()" )
  //oGerencia := TMailManager():New()
  //
  //If Empty(nPorta)
  //	Do Case
  //		Case lTSL
  //		nPorta := 587
  //		Case !lTSL .And. lSSL
  //		nPorta := 465
  //		OtherWise
  //		nPorta := 25
  //	End Case
  //End If
//
  //If lTSL
  //    conout( iif(!empty(cNmJob), "["+alltrim(cNmJob)+"]","")+iif(!empty(cCodFil),"[Fil.: "+alltrim(cCodFil)+"]","")+"[MAILSET] SetUseTLS()" )
  //	oGerencia:SetUseTLS(lTSL)
  //EndIf
//
  //If lSSL
  //    conout( iif(!empty(cNmJob), "["+alltrim(cNmJob)+"]","")+iif(!empty(cCodFil),"[Fil.: "+alltrim(cCodFil)+"]","")+"[MAILSET] SetUseSSL()" )
  //	oGerencia:SetUseSSL(lSSL)
  //End If
//
  //oGerencia:Init("", cServidor, cConta, cContaSenha, 0, nPorta)
  //
  //Begin Sequence
  //
  //    conout("")
  //    conout( iif(!empty(cNmJob), "["+alltrim(cNmJob)+"]","")+iif(!empty(cCodFil),"[Fil.: "+alltrim(cCodFil)+"]","")+"[TIMEOUT] ENABLE()" )
  //    nErro := oGerencia:SetSmtpTimeOut(nTimeOut)
  //      If nErro != 0
  //          conout( iif(!empty(cNmJob), "["+alltrim(cNmJob)+"]","")+iif(!empty(cCodFil),"[Fil.: "+alltrim(cCodFil)+"]","")+"[TIMEOUT] Fail to set" )
  //          conout( iif(!empty(cNmJob), "["+alltrim(cNmJob)+"]","")+iif(!empty(cCodFil),"[Fil.: "+alltrim(cCodFil)+"]","")+"[TIMEOUT][ERROR] " + str( nErro, 6 ), oGerencia:GetErrorString( nErro ) )
  //		Break
  //      EndIf
//
  // 	conout("")
  //    conout(iif(!empty(cNmJob), "["+alltrim(cNmJob)+"]","")+iif(!empty(cCodFil),"[Fil.: "+alltrim(cCodFil)+"]","")+"[SMTPCONNECT] connecting ... "+alltrim(cConta))
  //	nErro := oGerencia:SmtpConnect()
  //	If nErro <> 0
  //	    conout( iif(!empty(cNmJob), "["+alltrim(cNmJob)+"]","")+iif(!empty(cCodFil),"[Fil.: "+alltrim(cCodFil)+"]","")+"[SMTPCONNECT] Falha ao conectar" )
  //          conout( iif(!empty(cNmJob), "["+alltrim(cNmJob)+"]","")+iif(!empty(cCodFil),"[Fil.: "+alltrim(cCodFil)+"]","")+"[SMTPCONNECT][ERROR] " + str( nErro, 6 ), oGerencia:GetErrorString( nErro ) )
  //  		Break
  //  	Else
  //  	    conout( iif(!empty(cNmJob), "["+alltrim(cNmJob)+"]","")+iif(!empty(cCodFil),"[Fil.: "+alltrim(cCodFil)+"]","")+"[SMTPCONNECT] Sucesso ao conectar" )
  //	End If
//
  //	If lAut
  //
  //        // tentando CONTA E SENHA
  // 	    conout("")
  //        conout( iif(!empty(cNmJob), "["+alltrim(cNmJob)+"]","")+iif(!empty(cCodFil),"[Fil.: "+alltrim(cCodFil)+"]","")+"[AUTH] ENABLE" )
  //          conout( iif(!empty(cNmJob), "["+alltrim(cNmJob)+"]","")+iif(!empty(cCodFil),"[Fil.: "+alltrim(cCodFil)+"]","")+"[AUTH] TRY with ACCOUNT() and PASS()" )
  //		nErro := oGerencia:SMTPAuth(cConta, cSenhaAut)
  //		If nErro <> 0
  //
  //              conout( iif(!empty(cNmJob), "["+alltrim(cNmJob)+"]","")+iif(!empty(cCodFil),"[Fil.: "+alltrim(cCodFil)+"]","")+"[AUTH] FAIL TRY with ACCOUNT() and PASS()")
  //              conout( iif(!empty(cNmJob), "["+alltrim(cNmJob)+"]","")+iif(!empty(cCodFil),"[Fil.: "+alltrim(cCodFil)+"]","")+"[AUTH][ERROR] " + str(nErro,6) , oGerencia:GetErrorString( nErro ) )
  //              conout( iif(!empty(cNmJob), "["+alltrim(cNmJob)+"]","")+iif(!empty(cCodFil),"[Fil.: "+alltrim(cCodFil)+"]","")+"[AUTH] TRY with USER() and PASS()" )
//
  //            // tentando USUARIO E SENHA
  //		    nErro := oGerencia:SMTPAuth(cUsuarioAut, cSenhaAut)
  //		    If nErro <> 0
  //
  //                 conout("")
  //                 conout( iif(!empty(cNmJob), "["+alltrim(cNmJob)+"]","")+iif(!empty(cCodFil),"[Fil.: "+alltrim(cCodFil)+"]","")+"[AUTH] FAIL TRY with USER() and PASS()" )
  //                 conout( iif(!empty(cNmJob), "["+alltrim(cNmJob)+"]","")+iif(!empty(cCodFil),"[Fil.: "+alltrim(cCodFil)+"]","")+"[AUTH][ERROR] " + str( nErro, 6 ), oGerencia:GetErrorString( nErro ) )
  //      		   Break
  //
  //              Else
  //
  //                 conout("")
  //                 conout( iif(!empty(cNmJob), "["+alltrim(cNmJob)+"]","")+iif(!empty(cCodFil),"[Fil.: "+alltrim(cCodFil)+"]","")+"[AUTH] SUCEEDED TRY with USER() and PASS()" )
  //
  //			Endif
  //
  //		Else
  //             conout("")
  //		   conout( iif(!empty(cNmJob), "["+alltrim(cNmJob)+"]","")+iif(!empty(cCodFil),"[Fil.: "+alltrim(cCodFil)+"]","")+"[AUTH] SUCEEDED TRY with ACCOUNT and PASS" )
  //		Endif
  //	End If
//
  //      conout("")
  //      conout( iif(!empty(cNmJob), "["+alltrim(cNmJob)+"]","")+iif(!empty(cCodFil),"[Fil.: "+alltrim(cCodFil)+"]","")+"[MESSAGE] Criando mail message" )
  //	oEmail := TMailMessage():New()
//
  //	oEmail:Clear()
  //	oEmail:cFrom    := cDe
  //	oEmail:cTo      := Alltrim(SA1->A1_EMAIL)
  //	oEmail:cCc      := If(FwCodFil() == "0201", "nfmg@tecnocryo.com.br", "")
  //	oEmail:cSubject := SF2->F2_SERIE + " " + SF2->F2_DOC
//
  //	cMsg := "A<br/>"
  //	cMsg += AllTrim(SA1->A1_NOME) + "<br/><br/>"
  //	cMsg += "Prezado, segue nota de cobrança " + SF2->F2_SERIE + " " + SF2->F2_DOC
  //	cMsg += " com vencimento em " + Dtoc(SE1->E1_VENCTO) + ".<br/><br/>"
  //	cMsg += "Estamos a disposição para maiores esclarecimentos.<br/><br/>"
  //	cMsg += "Atenciosamente,<br/>"
//
  //	oEmail:cBody := cMsg
//
  //      conout( iif(!empty(cNmJob), "["+alltrim(cNmJob)+"]","")+iif(!empty(cCodFil),"[Fil.: "+alltrim(cCodFil)+"]","")+"[MESSAGE] TRY ATACH "+self:cPathPDF + self:cFile + ".pdf ..." )
  //	nErro := oEmail:AttachFile(self:cPathPDF + self:cFile + ".pdf")
  //	If nErro <> 0
  //
  //          conout( iif(!empty(cNmJob), "["+alltrim(cNmJob)+"]","")+iif(!empty(cCodFil),"[Fil.: "+alltrim(cCodFil)+"]","")+"[MESSAGE]FAIL TRY ATACH" )
  //          conout( iif(!empty(cNmJob), "["+alltrim(cNmJob)+"]","")+iif(!empty(cCodFil),"[Fil.: "+alltrim(cCodFil)+"]","")+"[MESSAGE][ERROR] "+ str( nErro, 6 ), oGerencia:GetErrorString( nErro ) )
  //		Break
  //	End If
//
  //      conout("")
  //      conout( iif(!empty(cNmJob), "["+alltrim(cNmJob)+"]","")+iif(!empty(cCodFil),"[Fil.: "+alltrim(cCodFil)+"]","")+"[SEND] Cliente: "+SA1->A1_COD+"/"+SA1->A1_LOJA+" - "+ Alltrim(SA1->A1_NOME))
  //      conout( iif(!empty(cNmJob), "["+alltrim(cNmJob)+"]","")+iif(!empty(cCodFil),"[Fil.: "+alltrim(cCodFil)+"]","")+"[SEND] Sending to "+Alltrim(SA1->A1_EMAIL)+"..." )
  //	nErro := oEmail:Send(oGerencia)
  //	If nErro <> 0
  //
  //	    conout( iif(!empty(cNmJob), "["+alltrim(cNmJob)+"]","")+iif(!empty(cCodFil),"[Fil.: "+alltrim(cCodFil)+"]","")+"[SEND] Fail to send message" )
  //          conout( iif(!empty(cNmJob), "["+alltrim(cNmJob)+"]","")+iif(!empty(cCodFil),"[Fil.: "+alltrim(cCodFil)+"]","")+"[SEND][ERROR] " + str( nErro, 6 ), oGerencia:GetErrorString( nErro ) )
  //
  //	Else
  //
  //	    conout( iif(!empty(cNmJob), "["+alltrim(cNmJob)+"]","")+iif(!empty(cCodFil),"[Fil.: "+alltrim(cCodFil)+"]","")+"[SEND] Success to send message" )
  //		self:lEnviado := .T.
  //	Endif
  //End Sequence
//
  //  conout("")
  //  conout( iif(!empty(cNmJob), "["+alltrim(cNmJob)+"]","")+iif(!empty(cCodFil),"[Fil.: "+alltrim(cCodFil)+"]","")+"[DISCONNECT] smtp disconnecting ... " )
  //nRet := oGerencia:SMTPDisconnect()
  //If nErro <> 0
  //     conout( iif(!empty(cNmJob), "["+alltrim(cNmJob)+"]","")+iif(!empty(cCodFil),"[Fil.: "+alltrim(cCodFil)+"]","")+"[DISCONNECT] Fail smtp disconnecting ... " )
  //     conout( iif(!empty(cNmJob), "["+alltrim(cNmJob)+"]","")+iif(!empty(cCodFil),"[Fil.: "+alltrim(cCodFil)+"]","")+"[DISCONNECT][ERROR] " + str( nErro, 6 ), oGerencia:GetErrorString( nErro ) )
  //  Else
  //     conout( iif(!empty(cNmJob), "["+alltrim(cNmJob)+"]","")+iif(!empty(cCodFil),"[Fil.: "+alltrim(cCodFil)+"]","")+"[DISCONNECT] Success smtp disconnecting ... " )
  //Endif
  //conout("===============================================")
//Return(self:lEnviado)	
Return .T.

Static Function TWPicture(cTel)

  Local cRetTel := Transform( cTel, "@R 9999-9999")
  cTel 	:= strTran(cTel," ", "")

  IF Len( cTel ) == 9
    cRetTel := Transform( cTel, "@R 9 9999-9999")
  ELSEIF Len( cTel ) == 10
    cRetTel := Transform( cTel, "@R (99) 9999-9999")
  ELSEIF Len( cTel ) == 11
    if subst(cTel,1,1) <> "0"

      if Left(Right(cTel,9),1) == "9"
        cRetTel := Transform( cTel, "@R (99) 9 9999-9999")
      else
        cRetTel := Transform( cTel, "@R (999) 9999-9999")
      endif

    else
      cRetTel := Transform( cTel, "@R (999) 9999-9999")
    endif
  ELSEIF Len( cTel ) > 11
    cRetTel := Transform( cTel, "@R (999) 9 9999-9999")
  ENDIF

Return cRetTel
