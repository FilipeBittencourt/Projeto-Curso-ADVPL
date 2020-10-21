#include "Protheus.ch"
#include "TopConn.ch"
#include "rwmake.ch"
#include "Ap5Mail.ch"
#include 'shell.ch'
#INCLUDE  "Fileio.ch"
#Include "RPTDEF.CH"
#Include "FWPrintSetup.ch"

/*/{Protheus.doc} PTAnalisaDocFiscal
@description Classe para analisar os documentos fiscais
@author Pontin - Facile Sistemas
@since 06.04.19
@version 1.0
/*/

Class PTAnalisaDocFiscal From LongClassName

  Data oXML		    //|Objeto com o XML do documento fiscal |
  Data lCte		    //|Indica que esta analisando CT-e |
  Data lNfe		    //|Indica que esta analisando NF-e |
  Data lBlind		    //|Indica se esta em modo job |
  Data lPedCompra	    //|Indica se achou o pedido de compra |
  Data lFornecedor    //|Indica se achou o fornecedor no ERP |
  Data aTempNF		//|Array com o template do que sera analisado no cabeçalho da NF |
  Data aTempFor		//|Array com o template do que sera analisado no Fornecedor |
  Data aTempProd		//|Array com o template do que sera analisado nos Produtos |
  Data aDadosNF		//|Array com os dados analisados do cabeçalho da NF |
  Data aDadosFor		//|Array com os dados analisados do Fornecedor |
  Data aDadosProd		//|Array com os dados analisados do Produto |
  Data cHtml		    //|HTML com o resultado da analise |
  Data cChaveDoc	    //|Chave eletronica do documento fiscal |
  Data cClrRed        //|Codigo da cor vermelha |
  Data cClrWhite      //|Codigo da cor branca |
  Data cClrBlue       //|Codigo da cor azul |
  Data cClrGray       //|Codigo da cor cinza |
  Data cClrYellow    //|Codigo da cor amarela |
  Data nPosXML        //|Posicao do valor do XML |
  Data nPosERP        //|Posicao do valor do ERP |
  Data nRecnoZZZ      //|Recno da ZZZ a ser analisado |
  Data cPathHtml      //|Caminho do arquivo HTML |
  Data lDivergencia   //|Indica se existe divergência nas informações |

  Method New() Constructor

  Method BuscaProd()    		//|Busca amarração do produto |
  Method Template()    			//|Monta template de analise |
  Method Comunica()    			//|Metodo para comunicacao com o usuario ou console |

  Method CabecHtml()    		//|Monta o cabeçalho do Html |
  Method FechaHtml()    		//|Fecha o Html |

  Method Executa()    			  //|Executa as analises |
  Method AnalisaNF()    			//|Analisa o cabeçalho do documento fiscal |
  Method AnalisaFor()    			//|Analisa o fornecedor |
  Method AnalisaProd()   			//|Analisa o fornecedor |

  Method Finaliza()    			//|Finaliza o processamento |
  Method AbreHtml()    			//|Realiza a abertura do HTML |

  Method LimpVar()    			//|Limpa as variaveis da rotina |
  Method ToleraQTD(nQtdXML, nQtdERP)    		//|tolerencia pela quantidade  entregue pelo fornecedor |
  Method ToleraVLR(nVlrXML, nVlrERP)    		//|tolerencia pelo valor/preço entregue pelo fornecedor |
  Method ToleraPrecoUnitario(nPUXML, nPUERP)    //|tolerencia pelo preço unitário praticado pelo fornecedor |



EndClass


//-------------------------------------------------------------------
/*/{Protheus.doc} New
description método construtor da classe
@author  Pontin - Facile Sistemas
@since   06.04.19
@version 1.0
/*/
//-------------------------------------------------------------------
Method New() Class PTAnalisaDocFiscal

  ::LimpVar()

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} LimpVar
description Limpa as variaveis da Classe
@author  Pontin - Facile Sistemas
@since   06.04.19
@version 1.0
/*/
//-------------------------------------------------------------------
Method LimpVar() Class PTAnalisaDocFiscal

  ::oXML          := Nil
  ::lCte          := .F.
  ::lNfe          := .F.
  ::lDivergencia  := .F.
  ::lPedCompra    := .F.
  ::lFornecedor   := .F.
  ::lBlind        := IsBlind()
  ::aTempNF       := {}
  ::aTempFor      := {}
  ::aTempProd     := {}
  ::aDadosNF      := {}
  ::aDadosFor     := {}
  ::aDadosProd    := {}
  ::cHtml         := ""
  ::cChaveDoc     := ""
  ::cClrRed       := "#ff0000"
  ::cClrWhite     := "#ffffff"
  ::cClrBlue      := "#1E90FF"
  ::cClrGray      := "#dddddd"
  ::cClrYellow    := "#ffff00"
  ::cPathHtml     := ""
  ::nPosXML       := 0
  ::nPosERP       := 0
  ::nRecnoZZZ     := 0

  ::Template()

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} AnalisaNF
description Executa as analises do documento fiscal
@author  Pontin - Facile Sistemas
@since   06.04.19
@version 1.0
/*/
//-------------------------------------------------------------------
Method Executa() Class PTAnalisaDocFiscal

  Local aArea     := GetArea()
  Local aAreaZZZ  := ZZZ->(GetArea())
  Local cError    := ""
  Local cWarning  := ""

  If ::lCte
    ::nPosXML       := 3
    ::nPosERP       := 5
  Else
    ::nPosXML       := 2
    ::nPosERP       := 4
  EndIf

  //|Abertura das tabelas |
  dbSelectArea("SC7")
  SC7->(dbSetOrder(1))

  dbSelectArea("ZZW")
  ZZW->(dbSetOrder(1))

  dbSelectArea("SB1")
  SB1->(dbSetOrder(1))

  dbSelectArea("ZZZ")
  ZZZ->(dbSetOrder(1))

  ZZZ->(dbGoTo(::nRecnoZZZ))

  If ZZZ->(Recno()) <> ::nRecnoZZZ
    ::Comunica("Nao foi possivel encontrar o RECNO informado: " + cValToChar(::nRecnoZZZ))
    Return
  EndIf

  ::cChaveDoc     := ZZZ->ZZZ_CHAVE
  ::oXML          := XmlParser( ZZZ->ZZZ_XML, "_", @cError, @cWarning )

  If !Empty(AllTrim(cError))
    ::oXML := NIL
    ::Comunica("Erro no Parser do XML: " + cValToChar(cError))
  EndIf

  //|Tratamento caso o xml possua a tag NFEPROC |
  If ::oXML <> NIL .And. ::lNfe

    If XmlChildEx(::oXML, "_NFEPROC") <> NIL
      ::oXML := XmlChildEx(::oXML, "_NFEPROC")
    EndIf
    If XmlChildEx(::oXML, "_NFE") == NIL
      ::oXML := NIL
    ElseIf ValType(::oXML:_NFE:_INFNFE:_DET) <> "A"
      XmlNode2Arr(::oXML:_NFE:_INFNFE:_DET,"_DET")
    EndIf

  EndIf

  If ::oXML == NIL
    ::Comunica("Nao foi possivel ler o XML")
  EndIf

  //|Monta o cabeçalho do HTML |
  ::CabecHtml()

  //|Monta os arrays de template |
  ::Template()

  //|Analisa o cabeçalho do Documento Fiscal |
  ::AnalisaNF()

  //|Analisa o fornecedor |
  ::AnalisaFor()

  //|Analisa os produtos |
  ::AnalisaProd()

  //|Fecha o HTML |
  ::FechaHtml()

  //|Finaliza o processamento |
  ::Finaliza()

  If Type("oXML") <> "U"
    FreeObj(oXML)
  EndIf

  If Type("oItem") <> "U"
    FreeObj(oItem)
  EndIf

  If Type("oDet") <> "U"
    FreeObj(oDet)
  EndIf

  RestArea(aAreaZZZ)
  RestArea(aArea)

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} AnalisaNF
description Analisa o cabeçalho do documento fiscal
@author  Pontin - Facile Sistemas
@since   06.04.19
@version 1.0
/*/
//-------------------------------------------------------------------
Method AnalisaNF() Class PTAnalisaDocFiscal

  Private oXML      := ::oXML
  Private cChave    := ::cChaveDoc

  ::cHtml += '        <div class="gwd-div-10aj"> ' + CRLF

  //|Documento Fiscal |
  ::cHtml += '            <h3 class="gwd-span-uv76 gwd-h3-sa33 gwd-h3-xl3y">' + AllTrim(::aTempNF[1,1]) + ':&nbsp;</h3> ' + CRLF
  ::cHtml += '            <p class="gwd-span-uv76 gwd-h3-sa33 gwd-h3-14rb gwd-p-uull">' + &(::aTempNF[1,::nPosXML]) + '&nbsp;</p> ' + CRLF

  //|Série |
  ::cHtml += '            <h3 class="gwd-span-uv76 gwd-h3-1ueg">' + AllTrim(::aTempNF[2,1]) + ':&nbsp;</h3> ' + CRLF
  ::cHtml += '            <p class="gwd-span-uv76 gwd-h3-sa33 gwd-h3-14rb gwd-p-1lbb gwd-p-18zh">' + &(::aTempNF[2,::nPosXML]) + '&nbsp;</p> ' + CRLF

  //|Chave |
  ::cHtml += '            <h3 class="gwd-span-uv76 gwd-h3-1nu3 gwd-h3-ion6 gwd-h3-11xb">' + AllTrim(::aTempNF[3,1]) + ':&nbsp;</h3> ' + CRLF
  ::cHtml += '            <p class="gwd-span-uv76 gwd-h3-sa33 gwd-h3-14rb gwd-p-1lbb gwd-p-qczt gwd-p-gp9i gwd-p-kph8">' + &(::aTempNF[3,::nPosXML]) + '&nbsp;</p> ' + CRLF

  //|Data de Emissão |
  ::cHtml += '            <h3 class="gwd-span-uv76 gwd-h3-1nu3 gwd-h3-1r2j">' + AllTrim(::aTempNF[4,1]) + ':&nbsp;</h3> ' + CRLF
  ::cHtml += '            <p class="gwd-span-uv76 gwd-h3-sa33 gwd-h3-14rb gwd-p-1lbb gwd-p-qczt gwd-p-gp9i gwd-p-1vus gwd-p-1pho">' + &(::aTempNF[4,::nPosXML]) + '</p> ' + CRLF

  //|Natureza da Operacao |
  ::cHtml += '            <h3 class="gwd-span-uv76 gwd-h3-1nu3 gwd-h3-1rwp">' + AllTrim(::aTempNF[5,1]) + ':&nbsp;</h3> ' + CRLF
  ::cHtml += '            <p class="gwd-span-uv76 gwd-h3-sa33 gwd-h3-14rb gwd-p-1lbb gwd-p-qczt gwd-p-d5yj">' + &(::aTempNF[5,::nPosXML]) + '&nbsp;</p> ' + CRLF

  //|Valor Total |
  ::cHtml += '            <h3 class="gwd-span-uv76 gwd-h3-1nu3 gwd-h3-ion6 gwd-h3-1s5c">' + AllTrim(::aTempNF[6,1]) + ':&nbsp;</h3> ' + CRLF
  ::cHtml += '            <p class="gwd-span-uv76 gwd-h3-sa33 gwd-h3-14rb gwd-p-1lbb gwd-p-qczt gwd-p-gp9i gwd-p-1vus gwd-p-4jvt">' + Transform(Val(&(::aTempNF[6,::nPosXML])),PesqPict("SD1","D1_TOTAL")) + '</p> ' + CRLF

  ::cHtml += '        </div> ' + CRLF

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} AnalisaFor
description Analisa o fornecedor do documento fiscal
@author  Pontin - Facile Sistemas
@since   06.04.19
@version 1.0
/*/
//-------------------------------------------------------------------
Method AnalisaFor() Class PTAnalisaDocFiscal

  Local nI            := 0
  Local nZ            := 0
  Local nPosCNPJ      := 0
  Local cColor        := ""

  Private oXML        := ::oXML
  Private cChave      := ::cChaveDoc

  ::lFornecedor       := .F.

  ::aDadosFor := {}

  ::cHtml += '              <div class="gwd-div-2u3i"> ' + CRLF
  ::cHtml += '                <span class="gwd-span-1vw1">Fornecedor</span> ' + CRLF
  ::cHtml += '              </div> ' + CRLF
  ::cHtml += '              <table class="gwd-table-1rr1"> ' + CRLF
  ::cHtml += '                <tbody> ' + CRLF

  nPosCNPJ := aScan(::aTempFor, {|x| AllTrim(x[1]) == AllTrim(FWX3Titulo( "A2_CGC" ))})

  dbSelectArea("SA2")
  SA2->(dbSetOrder(3))
  If SA2->(dbSeek(xFilial("SA2") + &(::aTempFor[nPosCNPJ,::nPosXML])))
    ::lFornecedor   := .T.
  EndIf

  //|Cabeçalho da tabela |
  ::cHtml += '                  <tr class="gwd-tr-lj5c"> ' + CRLF
  For nI := 1 To Len(::aTempFor)

    ::cHtml += '                    <th bgcolor="#1E90FF">' + AllTrim(::aTempFor[nI,1]) + '</th> ' + CRLF

    //|Busca dados do fornecedor para analise |
    aAdd(::aDadosFor,   {   Upper(&(::aTempFor[nI,::nPosXML])),;
      Upper(IIf((::lFornecedor .Or. nI == 1),&(::aTempFor[nI,::nPosERP]),"")),;
      ::aTempFor[nI,6];
      };
      )

  Next nI
  ::cHtml += '                  </tr> ' + CRLF

  //|Itens da tabela |
  For nZ := 1 To 2

    ::cHtml += '                  <tr> ' + CRLF
    For nI := 1 To Len(::aDadosFor)

      //|Analisa se a informação entre o XML e o ERP estão corretas |
      If !::aDadosFor[nI,3] .Or. Empty(::aDadosFor[nI,1]) .Or. AllTrim(::aDadosFor[nI,1]) == AllTrim(::aDadosFor[nI,2])
        cColor  := ::cClrWhite
      Else
        cColor  := ::cClrRed
        ::lDivergencia  := .T.
      EndIf

      //|Insere a coluna |
      ::cHtml += '                    <td bgcolor="' + cColor + '">' + AllTrim(::aDadosFor[nI,nZ]) + '</td> ' + CRLF

    Next nI
    ::cHtml += '                  </tr> ' + CRLF

  Next nZ

  ::cHtml += '                </tbody> ' + CRLF
  ::cHtml += '              </table> ' + CRLF

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} AnalisaProd
description Analisa os produtos do documento fiscal
@author  Pontin - Facile Sistemas
@since   15.04.19
@version 1.0
/*/
//-------------------------------------------------------------------
Method AnalisaProd() Class PTAnalisaDocFiscal

  Local cColor        := ""
  Local cClrBg        := ""
  Local cProduto      := ""

  Local nI            := 0
  Local nJ            := 0
  Local nK            := 0
  Local oDet          := Nil
  Local oJSSB1        := Nil
  Local cMsgErro	    := ""
  Local lAchouSB1     := .F.
  Local lOnlyOne      := .T.



  Private cUnMed1   := ""
  Private nQtdUM1	  := 0
  Private nQtdUM2	  := 0
  Private nQtdOri   := 0
  Private nVlrUM1	  := 0
  Private nVlrTotal := 0


  Private oXML        := ::oXML
  Private oItem       := Nil

  ::aDadosProd := {}

  If ::lNfe
    oDet := ::oXML:_NFE:_INFNFE:_DET
    oDet := IIf(ValType(oDet)=="O",{oDet},oDet)
  Else
    Return .T.
  EndIf

  ::cHtml += '              <div class="gwd-div-2u3i gwd-div-ovty"> ' + CRLF
  ::cHtml += '                <span class="gwd-span-1vw1">Produtos</span> ' + CRLF
  ::cHtml += '              </div> ' + CRLF
  ::cHtml += '              <table class="gwd-table-164o"> ' + CRLF
  ::cHtml += '                <tbody> ' + CRLF

  //|Cabeçalho da tabela |
  ::cHtml += '                  <tr class="gwd-tr-lj5c"> ' + CRLF
  For nI := 1 To Len(::aTempProd)
    ::cHtml += '                    <th bgcolor="#1E90FF">' + AllTrim(::aTempProd[nI,1]) + '</th> ' + CRLF
  Next nI
  ::cHtml += '                  </tr> ' + CRLF

  //|Para cada item do XML |
  For nI := 1 To Len(oDet)

    oItem       := oDet[nI]
    oJSSB1      := ::BuscaProd(oItem) // Retorna um JsonObject
    cProduto    := oJSSB1["B1_COD"]
    lOnlyOne    := .T.

    If Mod(nI,2) == 0
      cClrBg      := ::cClrWhite
    Else
      cClrBg      := ::cClrGray
    EndIf

    //|Busca dados do produto para analise | Preechendo as linhas com os dados do XML e do ERP
    ::aDadosProd := {}
    For nK := 1 To Len(::aTempProd)
      aAdd(::aDadosProd,   {  Upper(&(::aTempProd[nK,::nPosXML])),;
        Upper(IIf((!Empty(cProduto) .Or. nK == 1),&(::aTempProd[nK,::nPosERP]),"")),;
        ::aTempProd[nK,6];
        };
        )
    Next nK

    // Começandos as validações de regras vendo parametros etc...
    For nJ := 1 To 2

      //|Preenche as colunas |
      ::cHtml += '                  <tr> ' + CRLF

      For nK := 1 To Len(::aTempProd)


        // Varaiaveis tratadas  necessárias para o ponto de entrada  P018UM
        If lOnlyOne
          cUnMed1   := oJSSB1["cUnMed1"]
          nQtdUM1	  := oJSSB1["nQtdUM1"]
          nQtdUM2	  := oJSSB1["nQtdUM2"]
          nQtdOri   := oJSSB1["nQtdOri"]
          nVlrUM1	  := oJSSB1["nVlrUM1"]
          nVlrTotal := oJSSB1["nVlrTotal"]

          If cUnMed1 == oJSSB1["B1_UM"]
            nQtdUM1	:= nQtdOri
            nQtdUM2	:= 0
            nVlrUM1	:= nVlrTotal / nQtdOri
          ElseIf oJSSB1["B1_CONV"] > 0
            nQtdUM1 	:= ConvUM(oJSSB1["B1_COD"], 0, nQtdOri, 1)  // PRI UM
            nQtdUM2 	:= nQtdOri   // SEG UM
            nVlrUM1	:= nVlrTotal / nQtdUM1 // nQtdUM2
            //lSegUM	:= .T.
          Else
            nQtdUM1	:= nQtdOri
            nQtdUM2	:= 0
            nVlrUM1	:= nVlrTotal / nQtdOri
          EndIf

          If ( ExistBlock("P018UM") )
            aAreaPri	:= GetArea()
            aAreaSB1	:= SB1->(GetArea())

            ExecBlock("P018UM",.F.,.F.,{cUnMed1,nQtdOri,nVlrTotal,oJSSB1["nVlrUnit"],oJSSB1["C7_NUM"],oJSSB1["C7_ITEM"],@cMsgErro})

            If !Empty(cMsgErro)
              MsgStop(cMsgErro)
              Return
            EndIf .F.

            RestArea(aAreaSB1)
            RestArea(aAreaPri)
          EndIf

        EndIf

        // FIM DO PONTO DE ENTRADA P018UM

        //|Analisa se a informação entre o XML e o ERP estão corretas |
        If !::aDadosProd[nK,3] .Or. Empty(::aDadosProd[nK,1]) .Or. AllTrim(::aDadosProd[nK,1]) == AllTrim(::aDadosProd[nK,2])

          cColor  := cClrBg

        Else

          cColor  := ::cClrRed
          ::lDivergencia  := .T.

          //QUANTIDADE
          If(Lower(AllTrim(::aTempProd[Nk,1])) == "quantidade")
            ::aDadosProd[nK,1] := Transform(nQtdUM1,PesqPict('SC7','C7_QUANT'))
            if(AllTrim(::aDadosProd[nK,1]) == AllTrim(::aDadosProd[nK,2]))
              cColor  := cClrBg
              ::lDivergencia  := .F.
            Else
              cColor  := ::ToleraQTD(AllTrim(::aDadosProd[nK,1]), AllTrim(::aDadosProd[nK,2]))
            EndIf
            ::aDadosProd[nK,1] := cValTochar(nQtdOri)
          EndIf

          //VALOR TOTAL DO ITEM
          If(Lower(AllTrim(::aTempProd[Nk,1])) == "vlr.total")
            if(AllTrim(::aDadosProd[nK,1]) == AllTrim(::aDadosProd[nK,2]))
              cColor  := cClrBg
              ::lDivergencia  := .F.
            Else
              cColor  := ::ToleraVLR(AllTrim(::aDadosProd[nK,1]), AllTrim(::aDadosProd[nK,2]))
            EndIf

          EndIf


        EndIf


        //|Insere a coluna |
        ::cHtml += '                    <td bgcolor="' + cColor + '">' + AllTrim(::aDadosProd[nK,nJ]) + '</td> ' + CRLF


      Next nK
      ::cHtml += '                  </tr> ' + CRLF

    Next nJ

  Next nI

  ::cHtml += '                </tbody> ' + CRLF
  ::cHtml += '              </table> ' + CRLF

Return .T.

Method ToleraQTD(nQtdXML, nQtdERP) Class PTAnalisaDocFiscal

  Local nPQTDE := 0
  Local cCor       := "#ff0000" //vermelho

  //nQtdXML := Val(STRTRAN(STRTRAN(nQtdXML, ".", "") , ",", "."))
  //nQtdERP := ValSTRTRAN(STRTRAN(nQtdERP, ".", "") , ",", "."))


  IF nQtdXML > nQtdERP

    dbSelectArea("AIC")
    AIC->(dbSetOrder(2))	 //AIC_FILIAL, AIC_FORNEC, AIC_LOJA, AIC_PRODUT, AIC_GRUPO, R_E_C_N_O_, D_E_L_E_T_
    If AIC->(dbSeek(xFilial("AIC") + SA2->A2_COD + SA2->A2_LOJA + SB1->B1_COD ))
      nPQTDE := AIC->AIC_PQTDE
    Else
      nPQTDE  := SuperGetMV("ZZ_PQTDE",.F.,0)
    EndIf

    nQtdERP := nQtdERP + ((nQtdERP*nPQTDE)/100)

    If nQtdERP > 0 .AND. nQtdERP >= nQtdXML
      cCor := "#ffff00" // amarelo
    EndIf

  EndIf

Return cCor


Method ToleraVLR(nVlrXML, nVlrERP) Class PTAnalisaDocFiscal

  Local nPPRECO := 0
  Local cCor       := "#ff0000" //vermelho
  nVlrERP := Val(STRTRAN(STRTRAN(nVlrERP, ".", "") , ",", "."))
  nVlrXML := ValSTRTRAN(STRTRAN(nVlrXML, ".", "") , ",", "."))


  IF nVlrERP > nVlrXML


    dbSelectArea("AIC")
    AIC->(dbSetOrder(2))	 //AIC_FILIAL, AIC_FORNEC, AIC_LOJA, AIC_PRODUT, AIC_GRUPO, R_E_C_N_O_, D_E_L_E_T_
    If AIC->(dbSeek(xFilial("AIC") + SA2->A2_COD + SA2->A2_LOJA + SB1->B1_COD ))
      nPPRECO := AIC->AIC_PPRECO
    Else
      nPPRECO  := SuperGetMV("ZZ_PPRECO",.F.,0)
    EndIf

    nVlrERP := nVlrERP + ((nVlrERP*nPPRECO)/100)

    If nVlrERP > 0 .AND. nVlrERP > nVlrXML
      cCor := "#ffff00"
    EndIf

  EndIf

Return cCor

//-------------------------------------------------------------------
/*/{Protheus.doc} BuscaProd
description Busca o produto no ERP
@author  Pontin - Facile Sistemas
@since   06.04.19
@version 1.0
/*/
//-------------------------------------------------------------------
Method BuscaProd(oItem) Class PTAnalisaDocFiscal

  Local nPosPed   := aScan(::aTempProd, {|x| AllTrim(x[1]) == AllTrim(FWX3Titulo( "C7_NUM" ))})
  Local nPosItem  := aScan(::aTempProd, {|x| AllTrim(x[1]) == AllTrim(FWX3Titulo( "C7_ITEM" ))})
  Local nPosProd  := aScan(::aTempProd, {|x| AllTrim(x[1]) == AllTrim(FWX3Titulo( "B1_COD" ))})
  Local cPedido   := PadR(AllTrim(&(::aTempProd[nPosPed,::nPosXML])),TamSX3("C7_NUM")[1])
  Local cItem     := AllTrim(&(::aTempProd[nPosItem,::nPosXML])) // PadR(AllTrim(&(::aTempProd[nPosItem,::nPosXML])),TamSX3("C7_ITEM")[1])
  Local cProduto  := Space(TamSX3("B1_COD")[1])
  Local aPedido   := {}
  Local oJson     := JsonObject():New()

  Local nPosUND   := aScan(::aTempProd, {|x| AllTrim(x[1]) == AllTrim(FWX3Titulo( "C7_UM" ))})
  Local nPosQTD   := aScan(::aTempProd, {|x| AllTrim(x[1]) == AllTrim(FWX3Titulo( "C7_QUANT" ))})
  Local nPosVlrU  := aScan(::aTempProd, {|x| AllTrim(x[1]) == AllTrim(FWX3Titulo( "C7_PRECO" ))})
  Local nPosVlrT  := aScan(::aTempProd, {|x| AllTrim(x[1]) == AllTrim(FWX3Titulo( "C7_TOTAL" ))})

  ::lPedCompra       := .F.
  oJson["cUnMed1"]   := AllTrim(&(::aTempProd[nPosUND,::nPosXML]))
  oJson["nQtdOri"]   := Val(AllTrim(&(::aTempProd[nPosQTD,::nPosXML])))
  oJson["nVlrUnit"]  := Val(AllTrim(&(::aTempProd[nPosVlrU,::nPosXML])))
  oJson["nVlrTotal"] := Val(AllTrim(&(::aTempProd[nPosVlrT,::nPosXML])))
  oJson["cUnMed2"]   := ""		//|Segunda Unidade de Medida D1_SEGUM |
  oJson["nQtdUM1"]   := 0			//|Qtd UM 1 D1_QUANT |
  oJson["nQtdUM2"]   := 0			//|Qtd UM 2 D1_QTSEGUM |
  oJson["nVlrUM1"]   := 0			//|Valor Unit UM 1 D1_VUNIT |

  //|Verifica se tem o pedido no XML |
  aPedido := StaticCall(PTX0018,fAmarraPedido, cPedido, cItem, SA2->A2_COD, SA2->A2_LOJA)

  If Len(aPedido) > 0
    SC7->(dbGoTo(aPedido[4]))
    cProduto        := SC7->C7_PRODUTO
    ::lPedCompra    := .T.
  Else
    //|Posiciona no EoF da SC7 |
    SC7->(dbSeek("ZZZZZZZZZZZZZ"))
  EndIf

  //|Busca pela amarração produto x fornecedor |
  If !::lPedCompra .And. ::lFornecedor

    ZZW->(dbsetorder(1))
    If ZZW->(dbSeek(xFilial('ZZW') + SA2->A2_COD + SA2->A2_LOJA + PADR(AllTrim(&(::aTempProd[nPosProd,::nPosXML])),TamSX3("ZZW_CODPRF")[1])))
      cProduto    := ZZW->ZZW_PRODUT
    EndIf

  EndIf

  //|Procura pedido UNICO para o produto e fornecedor |
  If !::lPedCompra .And. !Empty(cProduto)

    aPedido := {}
    aPedido := StaticCall(PTX0018,fBuscaPC, cProduto, SA2->A2_COD, SA2->A2_LOJA)

    //|Retorno do aPedido |
    //"Item","Pedido","Produto","Observ.","Qtd.Compra","Qtd.Pendente","Vlr Unit."

    If Len(aPedido) == 1
      SC7->(dbSetOrder(1))
      If SC7->(dbSeek(xFilial("SC7") + aPedido[1,2] + aPedido[1,1]))
        //cProduto        := SC7->C7_PRODUTO
        ::lPedCompra    := .T.
      EndIf
    EndIf
  EndIf

  If !Empty(cItem) .and. ::lPedCompra
    cItem := val(cItem)
    cItem := PadL(cItem, TamSX3("C7_ITEM")[1],"0")
  EndIf

  //|Ajusta o posicionamento da SB1 |
  SB1->(dbSetOrder(1))
  If SB1->(dbSeek(xFilial("SB1") + cProduto))
    cProduto := SB1->B1_COD
    oJson["B1_UM"]    := SB1->B1_UM
    oJson["B1_CONV"]  := SB1->B1_CONV
  Else
    //|Posiciona no EoF da SB1 |
    SB1->(dbSeek("ZZZZZZZZZZZZZ"))
  EndIf

  oJson["B1_COD"]    := cProduto
  oJson["C7_NUM"]    := cPedido
  oJson["C7_ITEM"]   := cItem


Return oJson

//-------------------------------------------------------------------
/*/{Protheus.doc} Template
description Monta o array com o template a ser analisado no documento fiscal
@author  Pontin - Facile Sistemas
@since   06.04.19
@version 1.0
/*/
//-------------------------------------------------------------------
Method Template() Class PTAnalisaDocFiscal

  ::aTempNF       := {}
  ::aTempFor      := {}
  ::aTempProd     := {}

    /*dicionario
    [1] - Nome
    [2] - Regra para retorno do valor do XML do campo para NF-e
    [3] - Regra para retorno do valor do XML do campo para CT-e
    [4] - Regra para retorno do valor do Protheus do campo para NF-e
    [5] - Regra para retorno do valor do Protheus do campo para CT-e
    */

  //|Template do cabeçalho da NF |
  aAdd(::aTempNF, {   FWX3Titulo( "F1_DOC" ),;
    "Substr(cChave,26,9)",;
    "Substr(cChave,26,9)",;
    "",;
    "";
    };
    )
  aAdd(::aTempNF,{    FWX3Titulo( "F1_SERIE" ),;
    "Substr(cChave,23,3)",;
    "Substr(cChave,23,3)",;
    "",;
    "";
    };
    )
  aAdd(::aTempNF,{    FWX3Titulo( "F1_CHVNFE" ),;
    "cChave",;
    "cChave",;
    "",;
    "";
    };
    )
  aAdd(::aTempNF,{    FWX3Titulo( "F1_EMISSAO" ),;
    "ConvDate(SUBSTR(ValidTag('oXML:_NFE:_INFNFE:_IDE:_DHEMI:TEXT'),1,10))",;
    "ConvDate(SUBSTR(ValidTag('oXML:_CTEPROC:_CTE:_INFCTE:_IDE:_DHEMI:TEXT'),1,10))",;
    "",;
    "";
    };
    )
  aAdd(::aTempNF,{    "Nat.Operacao",;
    "ValidTag('oXML:_NFE:_INFNFE:_IDE:_NATOP:TEXT')",;
    "ValidTag('oXML:_CTEPROC:_CTE:_INFCTE:_IDE:_NATOP:TEXT')",;
    "",;
    "";
    };
    )
  aAdd(::aTempNF,{    FWX3Titulo( "D1_TOTAL" ),;
    "ValidTag('oXML:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VNF:TEXT')",;
    "ValidTag('oXML:_CTEPROC:_CTE:_INFCTE:_VPREST:_VTPREST:TEXT')",;
    "",;
    "";
    };
    )

    /*dicionario
    [1] - Nome
    [2] - Regra para retorno do valor do XML do campo para NF-e
    [3] - Regra para retorno do valor do XML do campo para CT-e
    [4] - Regra para retorno do valor do Protheus do campo para NF-e
    [5] - Regra para retorno do valor do Protheus do campo para CT-e
    [6] - Se a regra deve ser validada
    */

  //|Template do Fornecedor |
  aAdd(::aTempFor,{   "Origem",;
    "'XML'",;
    "'XML'",;
    "'ERP'",;
    "'ERP'",;
    SuperGetMV("ZZ_FORNC1",.F.,.F.);
    };
    )
  aAdd(::aTempFor,{   FWX3Titulo( "A2_NOME" ),;
    "ValidTag('oXML:_NFE:_INFNFE:_EMIT:_XNOME:TEXT')",;
    "ValidTag('oXML:_CTEPROC:_CTE:_INFCTE:_EMIT:_XNOME:TEXT')",;
    "SA2->A2_NOME",;
    "SA2->A2_NOME",;
    SuperGetMV("ZZ_FORNC2",.F.,.T.);
    };
    )
  aAdd(::aTempFor,{   FWX3Titulo( "A2_NREDUZ" ),;
    "ValidTag('oXML:_NFE:_INFNFE:_EMIT:_XFANT:TEXT')",;
    "SA2->A2_NREDUZ",;
    "SA2->A2_NREDUZ",;
    "SA2->A2_NREDUZ",;
    SuperGetMV("ZZ_FORNC3",.F.,.T.);
    };
    )
  aAdd(::aTempFor,{   FWX3Titulo( "A2_CGC" ),;
    "ValidTag('oXML:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT')",;
    "ValidTag('oXML:_CTEPROC:_CTE:_INFCTE:_EMIT:_CNPJ:TEXT')",;
    "SA2->A2_CGC",;
    "SA2->A2_CGC",;
    SuperGetMV("ZZ_FORNC4",.F.,.T.);
    };
    )
  aAdd(::aTempFor,{   FWX3Titulo( "A2_INSCR" ),;
    "ValidTag('oXML:_NFE:_INFNFE:_EMIT:_IE:TEXT')",;
    "ValidTag('oXML:_CTEPROC:_CTE:_INFCTE:_EMIT:_IE:TEXT')",;
    "SA2->A2_INSCR",;
    "SA2->A2_INSCR",;
    SuperGetMV("ZZ_FORNC5",.F.,.T.);
    };
    )
  aAdd(::aTempFor,{   FWX3Titulo( "A2_BAIRRO" ),;
    "ValidTag('oXML:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_XBAIRRO:TEXT')",;
    "ValidTag('oXML:_CTEPROC:_CTE:_INFCTE:_EMIT:_ENDEREMIT:_XBAIRRO:TEXT')",;
    "SA2->A2_BAIRRO",;
    "SA2->A2_BAIRRO",;
    SuperGetMV("ZZ_FORNC6",.T.,.F.);
    };
    )
  aAdd(::aTempFor,{   FWX3Titulo( "A2_COD_MUN" ),;
    "SubStr(ValidTag('oXML:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_CMUN:TEXT'),3,10)",;
    "SubStr(ValidTag('oXML:_CTEPROC:_CTE:_INFCTE:_EMIT:_ENDEREMIT:_CMUN:TEXT'),3,10)",;
    "SA2->A2_COD_MUN",;
    "SA2->A2_COD_MUN",;
    SuperGetMV("ZZ_FORNC7",.F.,.T.);
    };
    )
  aAdd(::aTempFor,{   FWX3Titulo( "A2_MUN" ),;
    "ValidTag('oXML:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_XMUN:TEXT')",;
    "ValidTag('oXML:_CTEPROC:_CTE:_INFCTE:_EMIT:_ENDEREMIT:_XMUN:TEXT')",;
    "SA2->A2_MUN",;
    "SA2->A2_MUN",;
    SuperGetMV("ZZ_FORNC8",.F.,.F.);
    };
    )
  aAdd(::aTempFor,{   FWX3Titulo( "A2_EST" ),;
    "ValidTag('oXML:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_UF:TEXT')",;
    "ValidTag('oXML:_CTEPROC:_CTE:_INFCTE:_EMIT:_ENDEREMIT:_UF:TEXT')",;
    "SA2->A2_EST",;
    "SA2->A2_EST",;
    SuperGetMV("ZZ_FORNC9",.F.,.T.);
    };
    )
  aAdd(::aTempFor,{   FWX3Titulo( "A2_CEP" ),;
    "ValidTag('oXML:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_CEP:TEXT')",;
    "ValidTag('oXML:_CTEPROC:_CTE:_INFCTE:_EMIT:_ENDEREMIT:_CEP:TEXT')",;
    "SA2->A2_CEP",;
    "SA2->A2_CEP",;
    SuperGetMV("ZZ_FORNC10",.F.,.T.);
    };
    )

    /*dicionario
    [1] - Nome
    [2] - Regra para retorno do valor do XML do campo para NF-e
    [3] - Regra para retorno do valor do XML do campo para CT-e
    [4] - Regra para retorno do valor do Protheus do campo para NF-e
    [5] - Regra para retorno do valor do Protheus do campo para CT-e
    [6] - Se a regra deve ser validada
    */

  //|Template do produto |
  aAdd(::aTempProd,{   FWX3Titulo( "D1_ITEM" ),;
    "ValidTag('oItem:_NITEM:TEXT')",;
    "",;
    "ValidTag('oItem:_NITEM:TEXT')",;
    "SB1->B1_COD",;
    SuperGetMV("ZZ_PRODC1",.F.,.T.);
    };
    )
  aAdd(::aTempProd,{   "Origem",;
    "'XML'",;
    "'XML'",;
    "'ERP'",;
    "'ERP'",;
    SuperGetMV("ZZ_PRODC2",.F.,.F.);
    };
    )
  aAdd(::aTempProd,{   FWX3Titulo( "B1_COD" ),;
    "ValidTag('oItem:_PROD:_CPROD:TEXT')",;
    "",;
    "SB1->B1_COD",;
    "SB1->B1_COD",;
    SuperGetMV("ZZ_PRODC3",.F.,.F.);
    };
    )
  aAdd(::aTempProd,{   FWX3Titulo( "B1_DESC" ),;
    "ValidTag('oItem:_PROD:_XPROD:TEXT')",;
    "",;
    "SB1->B1_DESC",;
    "SB1->B1_DESC",;
    SuperGetMV("ZZ_PRODC4",.F.,.F.);
    };
    )
  aAdd(::aTempProd,{   FWX3Titulo( "B1_POSIPI" ),;
    "ValidTag('oItem:_PROD:_NCM:TEXT')",;
    "",;
    "SB1->B1_POSIPI",;
    "SB1->B1_POSIPI",;
    SuperGetMV("ZZ_PRODC5",.F.,.T.);
    };
    )
  aAdd(::aTempProd,{   FWX3Titulo( "C7_NUM" ),;
    "ValidTag('oItem:_PROD:_XPED:TEXT')",;
    "",;
    "SC7->C7_NUM",;
    "SC7->C7_NUM",;
    SuperGetMV("ZZ_PRODC6",.F.,.T.);
    };
    )
  aAdd(::aTempProd,{   FWX3Titulo( "C7_ITEM" ),;
    "ValidTag('oItem:_PROD:_NITEMPED:TEXT')",;
    "",;
    "SC7->C7_ITEM",;
    "SC7->C7_ITEM",;
    SuperGetMV("ZZ_PRODC7",.F.,.T.);
    };
    )
  aAdd(::aTempProd,{   FWX3Titulo( "C7_QUANT" ),;
    "ValidTag('oItem:_PROD:_QCOM:TEXT')",;
    "",;
    "Transform(SC7->C7_QUANT,PesqPict('SC7','C7_QUANT'))",;
    "Transform(SC7->C7_QUANT,PesqPict('SC7','C7_QUANT'))",;
    SuperGetMV("ZZ_PRODC8",.F.,.T.);
    };
    )


  aAdd(::aTempProd,{   FWX3Titulo( "C7_PRECO" ),;
    "ValidTag('oItem:_PROD:_VUNCOM:TEXT')",;
    "",;
    "Transform(SC7->C7_PRECO,PesqPict('SC7','C7_PRECO'))",;
    "Transform(SC7->C7_PRECO,PesqPict('SC7','C7_PRECO'))",;
    SuperGetMV("ZZ_PRODC9",.F.,.T.);
    };
    )

  aAdd(::aTempProd,{   FWX3Titulo( "C7_TOTAL" ),;
    "ValidTag('oItem:_PROD:_VPROD:TEXT')",;
    "",;
    "Transform(SC7->C7_TOTAL,PesqPict('SC7','C7_TOTAL'))",;
    "Transform(SC7->C7_TOTAL,PesqPict('SC7','C7_TOTAL'))",;
    SuperGetMV("ZZ_PROD10",.F.,.T.);
    };
    )

  aAdd(::aTempProd,{   FWX3Titulo( "C7_UM" ),;
    "ValidTag('oItem:_PROD:_UCOM:TEXT')",;
    "",;
    "Transform(SC7->C7_UM,PesqPict('SC7','C7_UM'))",;
    "Transform(SC7->C7_UM,PesqPict('SC7','C7_UM'))",;
    SuperGetMV("ZZ_PROD11",.F.,.T.);
    };
    )

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} Finaliza
description Finaliza a analise do documento
@author  Pontin - Facile Sistemas
@since   06.04.19
@version 1.0
/*/
//-------------------------------------------------------------------
Method Finaliza() Class PTAnalisaDocFiscal

  Local cStatus   := ""

  If !Empty(::cHtml) .And. ZZZ->(FieldPos("ZZZ_PEDOBS"))

    cStatus := U_VerifNF()

    RecLock("ZZZ",.F.)
    ZZZ->ZZZ_PEDOBS := ::cHtml

    If ::lDivergencia
      ZZZ->ZZZ_OK := IIf(cStatus<>"C","X",cStatus)
    Else
      ZZZ->ZZZ_OK := cStatus
    EndIf

    ZZZ->(MsUnLock())
  EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Comunica
description Tratamento de alert
@author  Pontin - Facile Sistemas
@since   06.04.19
@version 1.0
/*/
//-------------------------------------------------------------------
Method Comunica(cMsg) Class PTAnalisaDocFiscal

  Local cTitulo   := "Facile Central XML-e"

  If lBlind
    FwLogMsg("INFO", /*cTransactionId*/, "XMLE", FunName(), "", "01", cMsg, 0, 0, {})
  Else
    MsgInfo(cMsg,cTitulo)
  EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} CabecHtml
description Monta o cabeçalho do Html
@author  Pontin - Facile Sistemas
@since   06.04.19
@version 1.0
/*/
//-------------------------------------------------------------------
Method CabecHtml() Class PTAnalisaDocFiscal

  ::cHtml := ''

  ::cHtml += ' <!DOCTYPE html> ' + CRLF
  ::cHtml += ' <html> ' + CRLF
  ::cHtml += '  ' + CRLF
  ::cHtml += ' <head> ' + CRLF
  ::cHtml += '   <meta charset="utf-8"> ' + CRLF
  ::cHtml += '   <meta name="generator" content="Google Web Designer 5.0.4.0226"> ' + CRLF
  ::cHtml += '   <meta name="template" content="Banner 3.0.0"> ' + CRLF
  ::cHtml += '   <meta name="environment" content="gwd-genericad"> ' + CRLF
  ::cHtml += '   <meta name="viewport" content="width=device-width, initial-scale=1.0"> ' + CRLF
  ::cHtml += '   <link href="gwdpage_style.css" rel="stylesheet" data-version="12" data-exports-type="gwd-page"> ' + CRLF
  ::cHtml += '   <link href="gwdpagedeck_style.css" rel="stylesheet" data-version="12" data-exports-type="gwd-pagedeck"> ' + CRLF
  ::cHtml += '   <style type="text/css" id="gwd-lightbox-style"> ' + CRLF
  ::cHtml += '     .gwd-lightbox { ' + CRLF
  //::cHtml += '       overflow: hidden; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '   </style> ' + CRLF
  ::cHtml += '   <style type="text/css" id="gwd-text-style"> ' + CRLF
  ::cHtml += '     p { ' + CRLF
  ::cHtml += '       margin: 0px; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     h1 { ' + CRLF
  ::cHtml += '       margin: 0px; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     h2 { ' + CRLF
  ::cHtml += '       margin: 0px; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     h3 { ' + CRLF
  ::cHtml += '       margin: 0px; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '   </style> ' + CRLF
  ::cHtml += '   <style type="text/css"> ' + CRLF
  ::cHtml += '     html, body { ' + CRLF
  ::cHtml += '       width: 100%; ' + CRLF
  ::cHtml += '       height: 100%; ' + CRLF
  ::cHtml += '       margin: 0 auto; ' + CRLF
  ::cHtml += '       overflow: auto; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     .gwd-page-container { ' + CRLF
  ::cHtml += '       position: relative; ' + CRLF
  ::cHtml += '       width: 100%; ' + CRLF
  ::cHtml += '       height: 100%; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     .gwd-page-content { ' + CRLF
  ::cHtml += '       background-color: transparent; ' + CRLF
  ::cHtml += '       transform: perspective(1400px) matrix3d(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1); ' + CRLF
  ::cHtml += '       transform-style: preserve-3d; ' + CRLF
  ::cHtml += '       position: absolute; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     .gwd-page-wrapper { ' + CRLF
  ::cHtml += '       background-color: rgb(255, 255, 255); ' + CRLF
  ::cHtml += '       position: absolute; ' + CRLF
  ::cHtml += '       transform: translateZ(0px); ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     .gwd-page-size { ' + CRLF
  ::cHtml += '       width: 1280px; ' + CRLF
  ::cHtml += '       height: 960px; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     .gwd-div-ftac { ' + CRLF
  ::cHtml += '       position: absolute; ' + CRLF
  ::cHtml += '       left: 0px; ' + CRLF
  ::cHtml += '       top: 0px; ' + CRLF
  ::cHtml += '       width: 1280px; ' + CRLF
  ::cHtml += '       height: 86px; ' + CRLF
  ::cHtml += '       transform-origin: 512.125px 42.9262px 0px; ' + CRLF
  ::cHtml += '       background-image: none; ' + CRLF
  ::cHtml += '       background-color: rgb(30, 144, 255); ' + CRLF
  ::cHtml += '       border-image-source: none; ' + CRLF
  ::cHtml += '       border-image-width: 1; ' + CRLF
  ::cHtml += '       border-image-outset: 0; ' + CRLF
  ::cHtml += '       border-image-repeat: stretch; ' + CRLF
  ::cHtml += '       border-color: transparent; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     .gwd-p-b6yh { ' + CRLF
  ::cHtml += '       position: absolute; ' + CRLF
  ::cHtml += '       color: rgb(255, 255, 255); ' + CRLF
  ::cHtml += '       font-family: "Trebuchet MS"; ' + CRLF
  ::cHtml += '       font-weight: normal; ' + CRLF
  ::cHtml += '       left: 655px; ' + CRLF
  ::cHtml += '       top: 55px; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     .gwd-h3-1trv { ' + CRLF
  ::cHtml += '       height: 22px; ' + CRLF
  ::cHtml += '       top: 27px; ' + CRLF
  ::cHtml += '       left: 162px; ' + CRLF
  ::cHtml += '       width: 350px; ' + CRLF
  ::cHtml += '       transform-origin: 5.60739px 10.8px 0px; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     .gwd-h3-12a4 { ' + CRLF
  ::cHtml += '       left: 495px; ' + CRLF
  ::cHtml += '       top: 36.8px; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     .gwd-div-10aj { ' + CRLF
  ::cHtml += '       position: absolute; ' + CRLF
  ::cHtml += '       height: 128px; ' + CRLF
  ::cHtml += '       left: 29px; ' + CRLF
  ::cHtml += '       width: 943px; ' + CRLF
  ::cHtml += '       transform-origin: 471.5px 64px 0px; ' + CRLF
  ::cHtml += '       top: 108px; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     .gwd-span-uv76 { ' + CRLF
  ::cHtml += '       position: absolute; ' + CRLF
  ::cHtml += '       font-family: "Trebuchet MS"; ' + CRLF
  ::cHtml += '       font-size: 18.72px; ' + CRLF
  ::cHtml += '       color: rgb(0, 0, 0); ' + CRLF
  ::cHtml += '       left: 31px; ' + CRLF
  ::cHtml += '       top: 122px; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     .gwd-h3-1ueg { ' + CRLF
  ::cHtml += '       left: 519px; ' + CRLF
  ::cHtml += '       top: 0px; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     .gwd-h3-1nu3 { ' + CRLF
  ::cHtml += '       top: 150px; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     .gwd-h3-1r2j { ' + CRLF
  ::cHtml += '       left: 519px; ' + CRLF
  ::cHtml += '       top: 71px; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     .gwd-h3-ion6 { ' + CRLF
  ::cHtml += '       left: 30px; ' + CRLF
  ::cHtml += '       top: 178px; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     .gwd-h3-1s5c { ' + CRLF
  ::cHtml += '       left: 29px; ' + CRLF
  ::cHtml += '       top: 106px; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     .gwd-h3-sa33 { ' + CRLF
  ::cHtml += '       left: 29px; ' + CRLF
  ::cHtml += '       top: 0px; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     .gwd-h3-1rwp { ' + CRLF
  ::cHtml += '       left: 29px; ' + CRLF
  ::cHtml += '       top: 35px; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     .gwd-h3-11xb { ' + CRLF
  ::cHtml += '       left: 29px; ' + CRLF
  ::cHtml += '       top: 71px; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     .gwd-h3-14rb { ' + CRLF
  ::cHtml += '       left: 205px; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     .gwd-p-1lbb { ' + CRLF
  ::cHtml += '       left: 589px; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     .gwd-p-18zh { ' + CRLF
  ::cHtml += '       width: 241px; ' + CRLF
  ::cHtml += '       height: 22px; ' + CRLF
  ::cHtml += '       transform-origin: 120.7px 10.8px 0px; ' + CRLF
  ::cHtml += '       font-size: 15px; ' + CRLF
  ::cHtml += '       top: 3px; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     .gwd-p-qczt { ' + CRLF
  ::cHtml += '       left: 246px; ' + CRLF
  ::cHtml += '       top: 35px; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     .gwd-p-gp9i { ' + CRLF
  ::cHtml += '       top: 71px; ' + CRLF
  ::cHtml += '       left: 104px; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     .gwd-p-1vus { ' + CRLF
  ::cHtml += '       left: 640px; ' + CRLF
  ::cHtml += '       top: 71px; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     .gwd-p-4jvt { ' + CRLF
  ::cHtml += '       left: 137px; ' + CRLF
  ::cHtml += '       height: 22px; ' + CRLF
  ::cHtml += '       width: 201px; ' + CRLF
  ::cHtml += '       transform-origin: 100.42px 10.8px 0px; ' + CRLF
  ::cHtml += '       font-size: 15px; ' + CRLF
  ::cHtml += '       top: 109px; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     .gwd-p-d5yj { ' + CRLF
  ::cHtml += '       width: 645px; ' + CRLF
  ::cHtml += '       height: 22px; ' + CRLF
  ::cHtml += '       transform-origin: 322.7px 10.8px 0px; ' + CRLF
  ::cHtml += '       font-size: 15px; ' + CRLF
  ::cHtml += '       top: 38px; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     .gwd-p-uull { ' + CRLF
  ::cHtml += '       width: 273px; ' + CRLF
  ::cHtml += '       height: 22px; ' + CRLF
  ::cHtml += '       transform-origin: 136.68px 10.8px 0px; ' + CRLF
  ::cHtml += '       font-size: 15px; ' + CRLF
  ::cHtml += '       top: 3px; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     .gwd-p-kph8 { ' + CRLF
  ::cHtml += '       width: 415px; ' + CRLF
  ::cHtml += '       height: 22px; ' + CRLF
  ::cHtml += '       transform-origin: 207.499px 10.8px 0px; ' + CRLF
  ::cHtml += '       font-size: 15px; ' + CRLF
  ::cHtml += '       top: 74px; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     .gwd-p-1pho { ' + CRLF
  ::cHtml += '       width: 204px; ' + CRLF
  ::cHtml += '       height: 22px; ' + CRLF
  ::cHtml += '       transform-origin: 102px 10.8px 0px; ' + CRLF
  ::cHtml += '       font-size: 15px; ' + CRLF
  ::cHtml += '       top: 74px; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     .gwd-h3-xl3y { ' + CRLF
  ::cHtml += '       top: 0px; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '   </style> ' + CRLF
  ::cHtml += '   <style> ' + CRLF
  ::cHtml += '     table { ' + CRLF
  ::cHtml += '       border-collapse: collapse; ' + CRLF
  ::cHtml += '       width: 100%; ' + CRLF
  ::cHtml += '       padding: 5px; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     td, th { ' + CRLF
  ::cHtml += '       border: 1px solid rgb(221, 221, 221); ' + CRLF
  ::cHtml += '       text-align: left; ' + CRLF
  ::cHtml += '       font-size: 9px; ' + CRLF
  ::cHtml += '       padding: 8px; ' + CRLF
  ::cHtml += '     } ' + CRLF
  //::cHtml += '     tr:nth-child(2n) { ' + CRLF
  //::cHtml += '       background-color: rgb(221, 221, 221); ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     caption { ' + CRLF
  ::cHtml += '       font-size: 10px; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     colgroup { ' + CRLF
  ::cHtml += '       background: rgb(255, 102, 0); ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     .gwd-table-1rr1 { ' + CRLF
  ::cHtml += '       position: relative; ' + CRLF
  ::cHtml += '       top: 295px; ' + CRLF
  ::cHtml += '       left: 9px; ' + CRLF
  ::cHtml += '       height: 96px; ' + CRLF
  ::cHtml += '       width: 1143px; ' + CRLF
  ::cHtml += '       transform-origin: 570.769px 40.094px 0px; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     .gwd-tr-lj5c { ' + CRLF
  ::cHtml += '       left: 5px; ' + CRLF
  ::cHtml += '       top: 6px; ' + CRLF
  ::cHtml += '       font-family: "Trebuchet MS"; ' + CRLF
  ::cHtml += '       font-size: 10px; ' + CRLF
  ::cHtml += '       background-image: none; ' + CRLF
  ::cHtml += '       background-color: rgb(90, 106, 232); ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     .gwd-div-2u3i { ' + CRLF
  ::cHtml += '       position: absolute; ' + CRLF
  ::cHtml += '       font-family: "Trebuchet MS"; ' + CRLF
  ::cHtml += '       font-size: 10px; ' + CRLF
  ::cHtml += '       height: 37px; ' + CRLF
  ::cHtml += '       width: 1141px; ' + CRLF
  ::cHtml += '       transform-origin: 570.449px 18.6721px 0px; ' + CRLF
  ::cHtml += '       left: 8px; ' + CRLF
  ::cHtml += '       top: 258px; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     .gwd-span-1vw1 { ' + CRLF
  ::cHtml += '       position: absolute; ' + CRLF
  ::cHtml += '       font-family: "Trebuchet MS"; ' + CRLF
  ::cHtml += '       font-size: 18.72px; ' + CRLF
  ::cHtml += '       top: 15px; ' + CRLF
  ::cHtml += '       font-weight: bold; ' + CRLF
  ::cHtml += '       left: 8px; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     .gwd-h3-xl3y { ' + CRLF
  ::cHtml += '       left: 2px; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     .gwd-p-uull { ' + CRLF
  ::cHtml += '       left: 100px; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     .gwd-p-d5yj { ' + CRLF
  ::cHtml += '       left: 140px; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     .gwd-h3-1rwp { ' + CRLF
  ::cHtml += '       left: 2px; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     .gwd-h3-11xb { ' + CRLF
  ::cHtml += '       left: 2px; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     .gwd-p-kph8 { ' + CRLF
  ::cHtml += '       left: 110px; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     .gwd-h3-1s5c { ' + CRLF
  ::cHtml += '       left: 2px; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     .gwd-p-4jvt { ' + CRLF
  ::cHtml += '       left: 100px; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     .gwd-div-10aj { ' + CRLF
  ::cHtml += '       left: 9px; ' + CRLF
  ::cHtml += '       top: 108px; ' + CRLF
  ::cHtml += '       height: 128px; ' + CRLF
  ::cHtml += '       width: 1142px; ' + CRLF
  ::cHtml += '       transform-origin: 570.746px 63.97px 0px; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     .gwd-div-ftac { ' + CRLF
  ::cHtml += '       left: 0px; ' + CRLF
  ::cHtml += '       top: 0px; ' + CRLF
  ::cHtml += '       width: 1149px; ' + CRLF
  ::cHtml += '       height: 86px; ' + CRLF
  ::cHtml += '       transform-origin: 574.578px 42.9177px 0px; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     .gwd-div-ovty { ' + CRLF
  ::cHtml += '       left: 10px; ' + CRLF
  ::cHtml += '       top: 418px; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     .gwd-h3-1trv { ' + CRLF
  ::cHtml += '       left: 213px; ' + CRLF
  ::cHtml += '       top: 25px; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     .gwd-h3-12a4 { ' + CRLF
  ::cHtml += '       left: 546px; ' + CRLF
  ::cHtml += '       top: 35px; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     .gwd-table-1thm { ' + CRLF
  ::cHtml += '       transform-origin: 571.015px 47.3115px 0px; ' + CRLF
  ::cHtml += '       left: 10px; ' + CRLF
  ::cHtml += '       top: 456px; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     .gwd-tbody-1ajm { ' + CRLF
  ::cHtml += '       left: 0px; ' + CRLF
  ::cHtml += '       top: 0px; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '     .gwd-table-164o { ' + CRLF
  ::cHtml += '       position: absolute; ' + CRLF
  ::cHtml += '       width: 1141.49px; ' + CRLF
  ::cHtml += '       height: 84.5642px; ' + CRLF
  ::cHtml += '       left: 10px; ' + CRLF
  ::cHtml += '       top: 456.997px; ' + CRLF
  ::cHtml += '     } ' + CRLF
  ::cHtml += '   </style> ' + CRLF
  ::cHtml += '   <script data-source="googbase_min.js" data-version="4" data-exports-type="googbase" src="googbase_min.js"></script> ' + CRLF
  ::cHtml += '   <script data-source="gwd_webcomponents_min.js" data-version="6" data-exports-type="gwd_webcomponents" src="gwd_webcomponents_min.js"></script> ' + CRLF
  ::cHtml += '   <script data-source="gwdpage_min.js" data-version="12" data-exports-type="gwd-page" src="gwdpage_min.js"></script> ' + CRLF
  ::cHtml += '   <script data-source="gwdpagedeck_min.js" data-version="12" data-exports-type="gwd-pagedeck" src="gwdpagedeck_min.js"></script> ' + CRLF
  ::cHtml += '   <script data-source="gwdgenericad_min.js" data-version="5" data-exports-type="gwd-genericad" src="gwdgenericad_min.js"></script> ' + CRLF
  ::cHtml += ' </head> ' + CRLF
  ::cHtml += '  ' + CRLF
  ::cHtml += ' <body> ' + CRLF
  ::cHtml += '   <gwd-genericad id="gwd-ad"> ' + CRLF
  ::cHtml += '     <gwd-pagedeck class="gwd-page-container" id="pagedeck"> ' + CRLF
  ::cHtml += '       <gwd-page id="page1" class="gwd-page-wrapper gwd-page-size gwd-lightbox" data-gwd-width="1024px" data-gwd-height="768px"> ' + CRLF
  ::cHtml += '         <div class="gwd-page-content gwd-page-size"> ' + CRLF
  ::cHtml += '           <div class="gwd-div-ftac"> ' + CRLF
  ::cHtml += '             <h3 class="gwd-p-b6yh gwd-h3-12a4">CheckDoc - Analise Documento Fiscal</h3> ' + CRLF
  ::cHtml += '             <h1 class="gwd-p-b6yh gwd-h3-1trv">Facile Central XML-e |</h1> ' + CRLF
  ::cHtml += '           </div> ' + CRLF


Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} FechaHtml
description Fecha o HTML
@author  Pontin - Facile Sistemas
@since   06.04.19
@version 1.0
/*/
//-------------------------------------------------------------------
Method FechaHtml() Class PTAnalisaDocFiscal

  ::cHtml += '        </div> ' + CRLF
  ::cHtml += '      </gwd-page> ' + CRLF
  ::cHtml += '    </gwd-pagedeck> ' + CRLF
  ::cHtml += '  </gwd-genericad> ' + CRLF
  ::cHtml += '  </body> ' + CRLF
  ::cHtml += '  </html> '

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} AbreHtml
description Abre o arquivo HTML
@author  Pontin - Facile Sistemas
@since   13.04.19
@version 1.0
/*/
//-------------------------------------------------------------------
Method AbreHtml() Class PTAnalisaDocFiscal

  Local cNomeArq  := "" //StrZero(Randomize( 1, 1000),4) + DtoS(dDataBase) + StrTran(Time(),":","") + "html"

  //|Solicita o caminho onde sera salvo o html |
  If Empty(::cPathHtml) .And. !Empty(::cHtml)

    ::cPathHtml := cGetFile( "Arquivos HTML|*.html", "Selecione o local para salvar o arquivo", 0, "C:\", .T., GETF_NETWORKDRIVE + GETF_LOCALHARD+GETF_RETDIRECTORY, .F., .T. )

  EndIf

  //|inclui a extensão html |
  If !Empty(::cPathHtml) .And. !".html" $ Lower(::cPathHtml)
    ::cPathHtml := AllTrim(::cPathHtml)+"checkdoc_"+AllTrim(ZZZ->ZZZ_CHAVE)+".html"
  Else
    Return .F.
  EndIf

  //|Cria o arquivo html no diretorio informado |
  If !Empty(::cPathHtml) .And. !Empty(::cHtml)

    nHandle := FCreate(::cPathHtml)

    FWrite(nHandle, ::cHtml)

    FClose(nHandle)

  EndIf

  //|Executa o HTML |
  If File(::cPathHtml)

    ShellExecute('open',::cPathHtml,"","",SW_SHOWMAXIMIZED)

  Else
    ::Comunica("Não foi possivel criar/encontrar o arquivo HTML, favor revisar os parametros!")
  EndIf

Return .T.


// Tratamento para evitar erros por falta de TAG
Static Function ValidTag(cTag)

  Local cRet      := ""
  Local cPai      := ""
  Local cFilho    := ""

  cPai    := SubStr(ctag,1,RAT("_",cTag)-2)
  cFilho  := SubStr(cTag,RAT("_",cTag),RAT(":",cTag) - RAT("_",cTag))

  If XmlChildEx(&(cPai), cFilho) <> NIL
    cRet    := &(cTag)
  EndIf

Return ALLTrim(cRet)


//|Tratamento para Data |
Static Function ConvDate(cData)

  Local dData

  cData  := StrTran(cData,"-","")
  dData  := StoD(cData)
  dData  := PadR(StrZero(Day(dData),2)+ "/" + StrZero(Month(dData),2)+ "/" + StrZero(Year(dData),4),15)

Return ALLTrim(dData)
