#Include "Totvs.ch"
#Include "Protheus.ch"
#Include "TopConn.ch"

/*
+----------+----------+-------+-----------------------+------+------------+
|CLASSE    | TWBOLBB  | AUTOR |MARCELO SPILARES SECATE| DATA | 15.04.2016 |
+----------+----------+-------+-----------------------+------+------------+
|DESCRIÇÃO | CLASSE RESPONSÁVEL POR GERAR BOLETO DO SANTANDER PARA        |
|          | A CARTEIRA 101, EM TELA E SCHEDULE                           |
+----------+--------------------------------------------------------------+
|USO       | FINACEIRO                                                    |
+----------+--------------------------------------------------------------+
*/

Class TWBolSantan From LongClassName
  Data aInstrucoes
  Data cAviso
  Data cBanco
  Data cCarteira
  Data cCodigoBarras
  Data cConvenio
  Data cCRLF
  Data cDigCodBar
  Data cFatorVencto
  Data cFile //relatio.rel
  Data cLinhaDigitavel
  Data cLogo
  Data cMoeda
  Data cNossoNumero
  Data cNumDocto
  Data cPathServer
  Data cPathPDF
  Data cVariacao

  Data dEmissao
  Data dVencto

  Data lCartValida
  Data lMostraErro
  Data lEnviado
  Data lSalvarBoleto

  Data nValor
  Data nValorAbat
  Data nValorAcre
  Data nMulta
  Data Juros

  Data aInfoBco

  Data oBanco
  Data oCedente
  Data oSacado
  Data oTitulos
  Data oPrint

  Method New() Constructor
  Method CartValida() //Carteira válida?
  Method CodBarras()
  Method DigCodBar() //Calcuca digito do codigo de barras
  Method DigCampo(cVariavel,nOp) //Calcula digito das partes
  Method EnviaEmail()
  Method Enviar()
  Method FatorVencto()
  Method LinhaDigitavel()
  Method Montar()
  Method Preparar()
  Method PrepTit()
  Method SalvarPDF()
  Method SelecTits()
  Method Ver() //com msprinter
  Method VerPDF()
  Method DefineDiretorio()
EndClass
//
/*
::oBanco:SetItem("NUMERO", SA6->A6_COD)
::oBanco:SetItem("NOME", SA6->A6_NREDUZ)	
::oBanco:SetItem("AGENCIA", AllTrim(SA6->A6_AGENCIA))
::oBanco:SetItem("DVAGENCIA", AllTrim(SA6->A6_DVAGE))
::oBanco:SetItem("CONTA", AllTrim(SA6->A6_NUMCON))
::oBanco:SetItem("DVCONTA",AllTrim(SA6->A6_DVCTA))
*/
//
Method New() Class TWBolSantan
  ::aInstrucoes   := {}
  ::cAviso        := ""
  ::cBanco        := ""
  ::cCarteira     := ""
  ::cCodigoBarras := ""
  ::cConvenio     := ""
  ::cCRLF         := Chr(13) + Chr(10)
  ::cFatorVencto  := ""
  ::cLogo 		:= Curdir() + "logo\Santander.png"
  ::cMoeda        := "9"
  ::cNossoNumero  := ""
  ::cPathPDF      := "schedule\"
  ::cPathServer   := "\spool" 	//"schedule\"
  ::cVariacao     := ""
  ::lCartValida   := .F.
  ::lEnviado      := .F.
  ::lMostraErro   := .T.
  ::lSalvarBoleto	:= .F.

  ::nValorAbat    := 0.00
  ::nValorAcre    := 0.00
  ::nMulta		:= 10.00

  ::oBanco        := HashTable():New()
  ::oCedente      := HashTable():New()
  ::oSacado       := HashTable():New()

  ::aInfoBco		:= STRTOKARR( GETMV("MV_YINFBCO"),"/")
Return Self
//
//tem de estar posicionado no SE1, SA6 e SEE
Method PrepTit() Class TWBolSantan

  If SE1->(E1_PORTADO + E1_AGEDEP + E1_CONTA) != SA6->(A6_COD + A6_AGENCIA + A6_NUMCON)
    RecLock("SE1", .F.)
    SE1->E1_PORTADO := SA6->A6_COD
    SE1->E1_AGEDEP  := SA6->A6_AGENCIA
    SE1->E1_CONTA   := SA6->A6_NUMCON
    //SE1->E1_NUMBCO  := Space(TamSX3("E1_NUMBCO")[1])
    SE1->(MsUnlock())
  EndIf

  U_NNSantan()

Return Self
/*
  IF GetEnvServer() != "TESTE"
oEmail:cCc      := If(FwCodFil() == "0201", "nfmg@tecnocryo.com.br", "")
  else
oEmail:cCc      := ""
  endif

*/

Method Enviar() Class TWBolSantan

  Local cServidor   := AllTrim(GetMv("MV_RELSERV"))
  Local cConta      := AllTrim(GetMv("MV_RELACNT")) //IIF( GetEnvServer() != "TESTE", AllTrim(GetMv("MV_RELACNT")), "augustooliveira@msn.com" )
  Local cContaSenha := AllTrim(GetMv("MV_RELPSW"))
  Local cUsuarioAut := AllTrim(GetMv("MV_RELAUSR"))
  Local cMsg        := ""
  Local cSenhaAut   := AllTrim(GetMv("MV_RELAPSW"))
  Local cDe         := AllTrim(GetMv("MV_RELFROM"))
  Local lAut        := GetMv("MV_RELAUTH")
  Local lSSL        := GetMv("MV_RELSSL")
  Local lTSL        := GetMv("MV_RELTSL")
  Local nTimeOut    := GetMv("MV_RELTIME")
  Local nPorta      := 0
  Local oGerencia, oEmail
  Local nErro, nPosPorta

  ::lEnviado := .F.

  cUsuarioAut := If(Empty(cUsuarioAut), cConta, cUsuarioAut)
  cSenhaAut   := If(Empty(cSenhaAut), cContaSenha, cSenhaAut)
  cDe         := If(Empty(cDe), "workflow@protheus.com.br", cDe)
  nTimeOut    := If(Empty(nTimeOut), 120, nTimeOut)
  nPosPorta   := At(":", cServidor)

  If nPosPorta > 0
    nPorta    := Val(AllTrim(SubStr(cServidor, nPosPorta + 1)))
    cServidor := SubStr(cServidor, 1, nPosPorta - 1)
  End If

  oGerencia := TMailManager():New()

  If Empty(nPorta)
    Do Case
    Case lTSL
      nPorta := 587
    Case !lTSL .And. lSSL
      nPorta := 465
    OtherWise
      nPorta := 25
    End Case
  End If

  If lTSL
    oGerencia:SetUseTLS(lTSL)
  ElseIf lSSL
    oGerencia:SetUseSSL(lSSL)
  End If

  oGerencia:Init("", cServidor, cConta, cContaSenha, 0, nPorta)
  oGerencia:SetSmtpTimeOut(nTimeOut)

  ConOut('Conectando ao SMTP')

  Begin Sequence
    nErro := oGerencia:SmtpConnect()
    If nErro <> 0
      ConOut("ERRO: " + oGerencia:GetErrorString(nErro))
      Break
    End If

    If lAut
      ConOut('Autenticando no SMTP')

      nErro := oGerencia:SMTPAuth(cUsuarioAut, cSenhaAut)
      If nErro <> 0
        ConOut("ERRO:" + oGerencia:GetErrorString(nErro))
        Break
      Endif
    End If

    oEmail := TMailMessage():New()

    oEmail:Clear()
    oEmail:cFrom    := cDe
    /*
    oEmail:cTo      := IIF( GetEnvServer() != "TESTE", Alltrim(SA1->A1_EMAIL), "augustooliveira@msn.com" )   

    IF GetEnvServer() != "TESTE"
      oEmail:cCc      := If(FwCodFil() == "0201", "nfmg@tecnocryo.com.br", cConta)
    else
      oEmail:cCc      := ""
    endif
     oEmail:cSubject := "Boleto Ref. NF " + AllTrim(SE1->E1_NUM) + If(Empty(SE1->E1_PARCELA), "", " - Parcela: " + AllTrim(SE1->E1_PARCELA))
    */
    oEmail:cTo      := "filipe.bittencourt@facilesistemas.com.br"
    oEmail:cCc      := "financeiro@tecnocryo.com.br"
    oEmail:cSubject := "FACILE TESTE - Boleto Ref. NF " + AllTrim(SE1->E1_NUM) + If(Empty(SE1->E1_PARCELA), "", " - Parcela: " + AllTrim(SE1->E1_PARCELA))

    cMsg := "A<br/>"
    cMsg += AllTrim(SA1->A1_NOME) + "<br/><br/>"
    cMsg += "Prezado, segue boleto referente a NF " + AllTrim(SE1->E1_NUM)
    cMsg += " com vencimento em " + Dtoc(SE1->E1_VENCTO) + ".<br/><br/>"
    cMsg += "Estamos a disposição para maiores esclarecimentos.<br/><br/>"
    cMsg += "Atenciosamente,<br/>"

    oEmail:cBody := cMsg

    nErro := oEmail:AttachFile(::cPathPDF + ::cFile + ".pdf")
    If nErro <> 0
      ConOut("Erro ao atachar o arquivo")
      Break
    End If

    nErro := oEmail:Send(oGerencia)
    If nErro <> 0
      ConOut("ERRO:" + oGerencia:GetErrorString(nErro))
    Else
      ::lEnviado := .T.
    Endif
  End Sequence

  ConOut("Desconectando do SMTP")

  oGerencia:SMTPDisconnect()
Return(::lEnviado)




Method SelecTits() Class TWBolSantan
  Local aArea  := GetArea()
  Local cAlias := GetNextAlias()
  Local cSql   := ""
  Local oTit

  ::oTitulos := ArrayList():New()

  cSql += "SELECT E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, SE1.R_E_C_N_O_ "
  cSql += "  FROM " + RetSqlName("SE1") + " SE1 (NOLOCK) "
  cSql += "  JOIN " + RetSqlName("SA6") + " SA6 (NOLOCK) ON A6_FILIAL = '" + xFilial("SA6") + "' "
  cSql += "                         AND A6_COD = E1_PORTADO "
  cSql += "						  AND A6_AGENCIA = E1_AGEDEP "
  cSql += "						  AND A6_NUMCON = E1_CONTA "
  cSql += "						  AND A6_NUMBCO = '001' "
  cSql += "						  AND SA6.D_E_L_E_T_ != '*' "
  cSql += "  JOIN " + RetSqlName("SEE") + " SEE (NOLOCK) ON EE_FILIAL = '" + xFilial("SEE") + "' "
  cSql += "                         AND EE_CODIGO = E1_PORTADO "
  cSql += "						  AND EE_AGENCIA = E1_AGEDEP "
  cSql += "						  AND EE_CONTA = E1_CONTA "
  cSql += "						  AND EE_SUBCTA = E1_YSUBCTA "
  cSql += "						  AND EE_CODCART = '17' "
  cSql += "						  AND SEE.D_E_L_E_T_ != '*' "
  cSql += " WHERE E1_FILIAL = '" + xFilial("SE1") + "' "
  cSql += "   AND E1_PORTADO != '   ' "
  cSql += "   AND E1_SALDO > 0 "
  cSql += "   AND E1_YENVMAI = 'S' "
  cSql += "   AND SE1.D_E_L_E_T_ != '*' "

  TcQuery cSql New Alias (cAlias)

  DbSelectArea(cAlias)

  While !Eof()
    oTit := HashTable():New()
    oTit:SetItem("E1_FILIAL"	, (cAlias)->E1_FILIAL)
    oTit:SetItem("E1_CLIENTE"	, (cAlias)->E1_CLIENTE)
    oTit:SetItem("E1_LOJA"		, (cAlias)->E1_LOJA)
    oTit:SetItem("E1_PREFIXO"	, (cAlias)->E1_PREFIXO)
    oTit:SetItem("E1_NUM"		, (cAlias)->E1_NUM)
    oTit:SetItem("E1_PARCELA"	, (cAlias)->E1_PARCELA)
    oTit:SetItem("E1_TIPO"		, (cAlias)->E1_TIPO)
    oTit:SetItem("R_E_C_N_O_"	, (cAlias)->R_E_C_N_O_)

    ::oTitulos:Add(oTit)
    DbSkip()
  End

  DbCloseArea()

  RestArea(aArea)
Return Self
//
Method EnviaEmail() Class TWBolSantan
  Local aArea    := GetArea()
  Local aAreaSE1 := SE1->(GetArea())
  Local cChave   := ""
  Local nT       := 0
  Local oTit

  ::SelecTits()

  If ::oTitulos:GetCount() == 0
    Return Self
  EndIf

  DbSelectArea("SE1")
  DbSetOrder(2)

  //2 - E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_

  For nT := 1 To ::oTitulos:GetCount()
    oTit   := ::oTitulos:GetItem(nT)
    cChave := oTit:GetItem("E1_FILIAL")+oTit:GetItem("E1_CLIENTE")+oTit:GetItem("E1_LOJA")
    cChave += oTit:GetItem("E1_PREFIXO")+oTit:GetItem("E1_NUM")+oTit:GetItem("E1_PARCELA")+oTit:GetItem("E1_TIPO")

    If SE1->(DbSeek(cChave))
      If ::CartValida()
        ::Preparar()
        ::Montar()
        ::SalvarPDF()
        If ::Enviar()
          RecLock("SE1",.F.)
          SE1->E1_YENVMAI := '*'
          SE1->(MSUnlock())
        EndIf
      Else
        ConOut(cChave)
        ConOut(::cAviso)
      EndIf
    EndIf
  Next nT

  RestArea(aAreaSE1)
  RestArea(aArea)
Return Self
//
Method Montar() Class TWBolSantan
  //Local aBolText1 := { "MORA DIARIA DE 0,33%","PROTESTO AUTOMATICO APOS 05 DIAS DE VENCIMENTO"}
  Local cCnpjCpf  := "", cString   := ""
  Local nRow1 := 0, nRow2 := 0, nRow3 := 0
  Local nCol  := 0, nCol1 := 0
  Local nI    := 0
  Local nM    := 0

  Local oFont8
  Local oFont10
  Local oFont11c
  Local oFont11n
  Local oFont12
  Local oFont12n
  Local oFont13
  Local oFont14
  Local oFont14n
  Local oFont15
  Local oFont15n
  Local oFont16n
  Local oFont20
  Local oFont20n
  Local oFont21
  Local oFont24
  Local oFont24n

  oFont8   := TFont():New("Arial",9,8,.T.,.F.,5,.T.,5,.T.,.F.)
  oFont11c := TFont():New("Courier New",9,11,.T.,.T.,5,.T.,5,.T.,.F.)
  oFont11n := TFont():New("Arial",9,11,.T.,.F.,5,.T.,5,.T.,.F.)
  oFont10  := TFont():New("Arial",9,8,.T.,.T.,5,.T.,5,.T.,.F.)
  oFont12n := TFont():New("Arial",9,12,.T.,.F.,5,.T.,5,.T.,.F.)
  oFont12  := TFont():New("Arial",9,12,.T.,.T.,5,.T.,5,.T.,.F.)
  oFont13  := TFont():New("Arial",9,13,.T.,.T.,5,.T.,5,.T.,.F.)
  oFont14  := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
  oFont14n := TFont():New("Arial",9,14,.T.,.F.,5,.T.,5,.T.,.F.)
  oFont15  := TFont():New("Arial",9,15,.T.,.T.,5,.T.,5,.T.,.F.)
  oFont15n := TFont():New("Arial",9,15,.T.,.F.,5,.T.,5,.T.,.F.)
  oFont16n := TFont():New("Arial",9,16,.T.,.F.,5,.T.,5,.T.,.F.)
  oFont20  := TFont():New("Arial",9,20,.T.,.T.,5,.T.,5,.T.,.F.)
  oFont20n := TFont():New("Arial",9,20,.T.,.F.,5,.T.,5,.T.,.F.)
  oFont21  := TFont():New("Arial",9,21,.T.,.T.,5,.T.,5,.T.,.F.)
  oFont24  := TFont():New("Arial",9,24,.T.,.T.,5,.T.,5,.T.,.F.)
  oFont24n := TFont():New("Arial",9,24,.T.,.F.,5,.T.,5,.T.,.F.)

  ::cFile := "BOL_SANTANDER_" + SE1->(AllTrim(E1_PREFIXO) + "_" + AllTrim(E1_NUM) + "_" + AllTrim(E1_PARCELA) + "_" + AllTrim(E1_TIPO))

  //FWMsPrinter():New(cFilePrintert,nDevice,lAdjustToLegacy,cPathInServer,lDisabeSetup,lTReport,@oPrintSetup,cPrinter,lServer,lPDFAsPNG,lRaw,lViewPDF,nQtdCopy)
  ::oPrint := FWMSPrinter():New (::cFile + ".rel"/*cFilePrintert*/,6/*nDevice*/,.T./*lAdjustToLegacy*/,::cPathServer/*cPathInServer*/, ;
    .T./*lDisabeSetup*/,/*lTReport*/,/*@oPrintSetup*/, ;
	/*cPrinter*/,.T./*lServer*/,/*lPDFAsPNG*/,/*lRaw*/,/*lViewPDF*/)

  ::oPrint:StartPage()   // Inicia uma nova página

	/******************/                                     	
	/* PRIMEIRA PARTE */
	/******************/
  nRow1 := 060
  nCol1 := 100

  ::oPrint:SayBitmap(nRow1, nCol1, ::cLogo, 400, 080) //logo
  ::oPrint:Line(nRow1, nCol1 + 0400, nRow1 + 0080, nCol1 + 0400) //v
  ::oPrint:Say(nRow1 + 0070, nCol1 + 0415, ::cBanco + "-7", oFont24)		// [1]Numero do Banco
  ::oPrint:Line(nRow1, nCol1 + 0610, nRow1 + 0080, nCol1 + 0610) //v
  ::oPrint:Say(nRow1 + 0070, nCol1 + 1800, "Comprovante de Entrega", oFont12)  //

  //Linhs verticias do quadro 01
  ::oPrint:Line(nRow1 + 0080, nCol1, nRow1 + 0400, nCol1)        //v borda esquerda 01
  ::oPrint:Line(nRow1 + 0080, nCol1 + 0950, nRow1 + 0400, nCol1 + 0950) //v 02
  ::oPrint:Line(nRow1 + 0240, nCol1 + 1300, nRow1 + 0400, nCol1 + 1300) //v 03
  ::oPrint:Line(nRow1 + 0080, nCol1 + 1400, nRow1 + 0240, nCol1 + 1400) //v 04
  ::oPrint:Line(nRow1 + 0080, nCol1 + 1800, nRow1 + 0400, nCol1 + 1800) //v 05
  ::oPrint:Line(nRow1 + 0080, nCol1 + 2200, nRow1 + 0400, nCol1 + 2200)  //v borda direita

  //Linhs horizontais do quadro 01
  ::oPrint:Line(nRow1 + 0080, nCol1, nRow1 + 0080, nCol1 + 2200) //h 01
  ::oPrint:Line(nRow1 + 0160, nCol1, nRow1 + 0160, nCol1 + 1800) //h 02
  ::oPrint:Line(nRow1 + 0240, nCol1, nRow1 + 0240, nCol1 + 1800) //h 03
  ::oPrint:Line(nRow1 + 0320, nCol1 + 0950, nRow1 + 0320, nCol1 + 1800) //h 04
  ::oPrint:Line(nRow1 + 0400, nCol1, nRow1 + 0400, nCol1 + 2200) //h 05
  //
  ::oPrint:Say(nRow1 + 0110, nCol1 + 0010, "Cedente", oFont12n)
  //::oPrint:Say(nRow1 + 0145, nCol1 + 0010 ,FWFilName(cEmpAnt,"0201"), oFont12)				//Nome + CNPJ
  ::oPrint:Say(nRow1 + 0145, nCol1 + 0010 ,::oCedente:GetItem("NOME"), oFont12)				//Nome + CNPJ

  ::oPrint:Say(nRow1 + 0110, nCol1 + 0960, "Agência/Código Cedente", oFont12n)
  //::oPrint:Say(nRow1 + 0145, nCol1 + 0960, ::oBanco:GetItem("AGENCIA") + "/" + ::aInfoBco[3]+ ::cConvenio, oFont12) //Ag, cod cedente
  ::oPrint:Say(nRow1 + 0145, nCol1 + 0960, ::aInfoBco[2] + "/" + ::cConvenio, oFont12) //Ag, cod cedente

  ::oPrint:Say(nRow1 + 0110, nCol1 + 1410, "Nro.Documento", oFont12n)
  ::oPrint:Say(nRow1 + 0145, nCol1 + 1410, ::cNumDocto, oFont12)//Prefixo + Numero + Parcela
  //
  ::oPrint:Say(nRow1 + 0190, nCol1 + 0010, "Sacado", oFont12n)
  ::oPrint:Say(nRow1 + 0225, nCol1 + 0010, ::oSacado:GetItem("NOME"), oFont12) // Nome

  ::oPrint:Say(nRow1 + 0190, nCol1 + 0960, "Vencimento", oFont12n)
  ::oPrint:Say(nRow1 + 0225, nCol1 + 0960, StrZero(Day(::dVencto),2) +"/"+ StrZero(Month(::dVencto),2) +"/"+ Right(Str(Year(::dVencto)),4), oFont12)

  ::oPrint:Say(nRow1 + 0190, nCol1 + 1410, "(=)Valor do Documento", oFont12n)
  ::oPrint:Say(nRow1 + 0225, nCol1 + 1410, AllTrim(Transform(::nValor,"@E 999,999,999.99")), oFont12)
  //
  ::oPrint:Say(nRow1 + 0270, nCol1 + 0010, "Recebi(emos) o bloqueto/título", oFont12)
  ::oPrint:Say(nRow1 + 0320, nCol1 + 0010, "com as características acima.", oFont12)
  //
  ::oPrint:Say(nRow1 + 0270, nCol1 + 0960, "Data", oFont12n)
  ::oPrint:Say(nRow1 + 0270, nCol1 + 1310, "Assinatura", oFont12n)
  //
  ::oPrint:Say(nRow1 + 0350, nCol1 + 0960, "Data", oFont12n)
  ::oPrint:Say(nRow1 + 0350, nCol1 + 1310, "Entregador", oFont12n)
  //
  ::oPrint:Say(nRow1 + 0110, nCol1 + 1810, "(  )Mudou-se", oFont12n)
  ::oPrint:Say(nRow1 + 0145, nCol1 + 1810, "(  )Ausente", oFont12n)
  ::oPrint:Say(nRow1 + 0180, nCol1 + 1810, "(  )Não existe nº indicado", oFont12n)
  ::oPrint:Say(nRow1 + 0215, nCol1 + 1810, "(  )Recusado", oFont12n)
  ::oPrint:Say(nRow1 + 0250, nCol1 + 1810, "(  )Não procurado", oFont12n)
  ::oPrint:Say(nRow1 + 0285, nCol1 + 1810, "(  )Endereço insuficiente", oFont12n)
  ::oPrint:Say(nRow1 + 0320, nCol1 + 1810, "(  )Desconhecido", oFont12n)
  ::oPrint:Say(nRow1 + 0355, nCol1 + 1810, "(  )Falecido", oFont12n)
  ::oPrint:Say(nRow1 + 0390, nCol1 + 1810, "(  )Outros(anotar no verso)", oFont12n)

	/*****************/
	/* SEGUNDA PARTE */
	/*****************/
  nRow2 := 0480

  ::oPrint:SayBitmap(nRow2, nCol1, ::cLogo, 400, 080) //logo
  ::oPrint:Line(nRow2, nCol1 + 0400, nRow2 + 0080, nCol1 + 0400) //v
  ::oPrint:Say(nRow2 + 0070, nCol1 + 0415, ::cBanco+"-7", oFont24)		// [1]Numero do Banco
  ::oPrint:Line(nRow2, nCol1 + 0610, nRow2 + 0080, nCol1 + 0610) //v
  ::oPrint:Say(nRow2 + 0070, nCol1 + 0620, ::cLinhaDigitavel, oFont20n)
  ::oPrint:Say(nRow2 + 0020, nCol1 + 1800, "Recibo do Sacado", oFont12)  //

  ::oPrint:Line(nRow2 + 0080, nCol1, nRow2 + 0910, nCol1)        //v borda esquerda 01
  ::oPrint:Line(nRow2 + 0240, nCol1 + 0395, nRow2 + 0380, nCol1 + 0395) //v 02
  ::oPrint:Line(nRow2 + 0310, nCol1 + 0645, nRow2 + 0380, nCol1 + 0645) //v 03
  ::oPrint:Line(nRow2 + 0240, nCol1 + 0895, nRow2 + 0380, nCol1 + 0895) //v 04
  ::oPrint:Line(nRow2 + 0240, nCol1 + 1195, nRow2 + 0310, nCol1 + 1195) //v 05 ACEITE
  ::oPrint:Line(nRow2 + 0240, nCol1 + 1375, nRow2 + 0380, nCol1 + 1375) //v 06 DATA PROCESSAMENTO
  ::oPrint:Line(nRow2 + 0080, nCol1 + 1700, nRow2 + 0730, nCol1 + 1700) //v 07	VENCIMENTO
  ::oPrint:Line(nRow2 + 0080, nCol1 + 2200, nRow2 + 0910, nCol1 + 2200) //v borda esquerda 01

  //Linhs horizontais do quadro 02
  ::oPrint:Line(nRow2 + 0080, nCol1, nRow2 + 0080, nCol1 + 2200) //h 01
  ::oPrint:Line(nRow2 + 0160, nCol1, nRow2 + 0160, nCol1 + 2200) //h 02
  ::oPrint:Line(nRow2 + 0240, nCol1, nRow2 + 0240, nCol1 + 2200) //h 03
  ::oPrint:Line(nRow2 + 0310, nCol1, nRow2 + 0310, nCol1 + 2200) //h 04
  ::oPrint:Line(nRow2 + 0380, nCol1, nRow2 + 0380, nCol1 + 2200) //h 05

  ::oPrint:Line(nRow2 + 0450, nCol1 + 1700, nRow2 + 0450, nCol1 + 2200) //h 06
  ::oPrint:Line(nRow2 + 0520, nCol1 + 1700, nRow2 + 0520, nCol1 + 2200) //h 07
  ::oPrint:Line(nRow2 + 0590, nCol1 + 1700, nRow2 + 0590, nCol1 + 2200) //h 08
  ::oPrint:Line(nRow2 + 0660, nCol1 + 1700, nRow2 + 0660, nCol1 + 2200) //h 09

  ::oPrint:Line(nRow2 + 0730, nCol1, nRow2 + 0730, nCol1 + 2200) //h 10
  ::oPrint:Line(nRow2 + 0910, nCol1, nRow2 + 0910, nCol1 + 2200) //h 11
  //
  ::oPrint:Say(nRow2 + 0110, nCol1 + 0010, "Local de Pagamento", oFont12n)
  ::oPrint:Say(nRow2 + 0145, nCol1 + 0010, "PAGÁVEL EM QUALQUER BANCO ATÉ O VENCIMENTO", oFont12)

  ::oPrint:Say(nRow2 + 0110, nCol1 + 1710, "Vencimento", oFont12n)
  cString	:= StrZero(Day(::dVencto),2) +"/"+ StrZero(Month(::dVencto),2) +"/"+ Right(Str(Year(::dVencto)),4)
  nCol    := 1880+(374-(len(cString)*22))
  ::oPrint:Say(nRow2 + 0145, nCol, cString, oFont12)
  //
  ::oPrint:Say(nRow2 + 0190, nCol1 + 0010, "Cedente", oFont12n)
  ::oPrint:Say(nRow2 + 0225, nCol1 + 0010, ::oCedente:GetItem("NOME")+" - "+::oCedente:GetItem("CNPJ"), oFont12) //Nome + CNPJ

  ::oPrint:Say(nRow2 + 0190, nCol1 + 1710, "Agência/Código Cedente", oFont12n)
  //cString := ::oBanco:GetItem("AGENCIA") + "/" + ::cConvenio
  cString := ::aInfoBco[2] + "/" + ::cConvenio

  nCol    := 1880+(374-(len(cString)*22))
  ::oPrint:Say(nRow2 + 0225, nCol-40, cString, oFont12)
  //
  ::oPrint:Say(nRow2 + 0270, nCol1 + 0010, "Data do Documento", oFont12n)
  ::oPrint:Say(nRow2 + 0305, nCol1 + 0010, StrZero(Day(::dEmissao),2) +"/"+ StrZero(Month(::dEmissao),2) +"/"+ Right(Str(Year(::dEmissao)),4), oFont12)

  ::oPrint:Say(nRow2 + 0270, nCol1 + 0405, "Nro.Documento", oFont12n)
  ::oPrint:Say(nRow2 + 0305, nCol1 + 0505, ::cNumDocto, oFont12) //Prefixo +Numero+Parcela

  ::oPrint:Say(nRow2 + 0270, nCol1 + 0905, "Espécie Doc.", oFont12n)
  ::oPrint:Say(nRow2 + 0305, nCol1 + 0905, "DM", oFont12) //Tipo do Titulo

  ::oPrint:Say(nRow2 + 0270, nCol1 + 1205, "Aceite", oFont12n)
  ::oPrint:Say(nRow2 + 0305, nCol1 + 1300, "N", oFont12)

  ::oPrint:Say(nRow2 + 0270, nCol1 + 1385, "Data do Processamento", oFont12n)
  ::oPrint:Say(nRow2 + 0305, nCol1 + 1450 ,StrZero(Day(dDataBase),2) +"/"+ StrZero(Month(dDataBase),2) +;
    "/"+ Right(Str(Year(dDataBase)),4),oFont12) // Data impressao

  ::oPrint:Say(nRow2 + 0270, nCol1 + 1710, "Nosso Número", oFont12n)
  nCol    := 1880+(374-(len(::cNossoNumero)*22))
  ::oPrint:Say(nRow2 + 0305, nCol, ::cNossoNumero, oFont12)
  //
  ::oPrint:Say(nRow2 + 0340, nCol1 + 0010, "Uso do Banco", oFont12n)
  ::oPrint:Say(nRow2 + 0340, nCol1 + 0405, "Carteira", oFont12n)
  ::oPrint:Say(nRow2 + 0375, nCol1 + 0455, If(::cCarteira=="5","101",""), oFont12)
  ::oPrint:Say(nRow2 + 0340, nCol1 + 0655, "Espécie", oFont12n)
  ::oPrint:Say(nRow2 + 0375, nCol1 + 0705, "R$", oFont12)
  ::oPrint:Say(nRow2 + 0340, nCol1 + 0905, "Quantidade", oFont12n)
  ::oPrint:Say(nRow2 + 0340, nCol1 + 1385, "Valor", oFont12n)
  ::oPrint:Say(nRow2 + 0340, nCol1 + 1710, "(=)Valor do Documento", oFont12n)
  cString := Alltrim(Transform(::nValor,"@E 99,999,999.99"))
  nCol := 1880+(374-(len(cString)*22))
  ::oPrint:Say(nRow2 + 0375, nCol, cString, oFont12)
  //
  ::oPrint:Say(nRow2 + 0410, nCol1 + 0010, "INSTRUÇÕES (DE RESPONSABILIDADE DO CEDENTE)", oFont12n)

  aAdd(::aInstrucoes, "MORA DIÁRIA DE R$ " + AllTrim(Transform(::nValor * 0.0033333333,"@E 999,999.99"))   )
  //aAdd(::aInstrucoes, "MORA DIÁRIA DE R$ " + StrZero(::nValor * 0.0033333333*100,13,0)   )
  //STRZERO(SE1->E1_SALDO*0.0033333333*100,13,0)
  aAdd(::aInstrucoes, "SUJEITO A PROTESTO APÓS 5 DIAS DE VENCIMENTO")

  For nM := 1 To Len(::aInstrucoes)
    ::oPrint:Say(nRow2 + 0410 + (nM * 35), nCol1 + 0010, ::aInstrucoes[nM], oFont12)
  Next nM

  //::oPrint:Say(nRow2 + 0480, nCol1 + 0010, aBolText1[1], oFont12)
  //::oPrint:Say(nRow2 + 0515, nCol1 + 0010, aBolText1[2], oFont12)
  //::oPrint:Say(nRow2 + 0725, nCol1 + 0010, "Título sujeito a protesto após 7 dias corridos depois de vencido.", oFont12)
  //::oPrint:Say(nRow2 + 0725, nCol1 + 0010, 'CHAVE ASBACE:' + Transform(M->ASBACE, '@R 9999.9999.9999.9999.9999.9999') + '  R.V.A.', oFont12)
  //
  ::oPrint:Say(nRow2 + 0410, nCol1 + 1710, "(-)Desconto/Abatimento", oFont12n)
  ::oPrint:Say(nRow2 + 0480, nCol1 + 1710, "(-)Outras Deduções", oFont12n)
  ::oPrint:Say(nRow2 + 0550, nCol1 + 1710, "(+)Mora/Multa", oFont12n)
  ::oPrint:Say(nRow2 + 0620, nCol1 + 1710, "(+)Outros Acréscimos", oFont12n)
  ::oPrint:Say(nRow2 + 0690, nCol1 + 1710, "(=)Valor Cobrado", oFont12n)
  //
  ::oPrint:Say(nRow2 + 0760, nCol1 + 0010, "Sacado", oFont12n)

  cCnpjCpf := Space(10) + If(::oSacado:GetItem("TIPO") == "J","CNPJ: ","CPF.: ")
  cCnpjCpf += Transform(::oSacado:GetItem("CGC"),If(::oSacado:GetItem("TIPO") == "J","@R 99.999.999/9999-99","@R 999.999.999-99"))
  ::oPrint:Say(nRow2 + 0795, nCol1 + 0010, ::oSacado:GetItem("NOME")+" ("+::oSacado:GetItem("CODLOJA")+")"+cCnpjCpf, oFont12) // RAZAO+CODIGO+CNPJ

  ::oPrint:Say(nRow2 + 0830, nCol1 + 0010 ,::oSacado:GetItem("ENDERECO"), oFont12)
  ::oPrint:Say(nRow2 + 0865, nCol1 + 0010, "CEP: " + ::oSacado:GetItem("CEP")+" - " + ::oSacado:GetItem("MUNICIPIO") + " - " + ::oSacado:GetItem("ESTADO"),oFont12) // CEP+Cidade+Estado
  //::oPrint:Say(nRow2 + 0865, nCol1 + 0600, ::cNossoNumero, oFont12)

  ::oPrint:Say(nRow2 + 0900, nCol1 + 0010 , "Sacador/Avalista", oFont12n)
  ::oPrint:Say(nRow2 + 0900, nCol1 + 1710, "Código de baixa", oFont12n)
  ::oPrint:Say(nRow2 + 0940, nCol1 + 1400, "Autenticação Mecânica", oFont12n)
  //FWMsBar(cTypeBar,nRow,nCol,cCode   ,oPrint,lCheck,Color,lHorz,nWidth,nHeigth,lBanner,cFont,cMode,lPrint,nPFWidth,nPFHeigth,lCmtr2Pix)-->
  //::oPrint:FWMsBar("INT25" ,0036,0002,_cCodBar,oPrint,.F.   ,     ,.T.  ,0.025 ,1.2    ,.F.    ,     ,     ,.F.   ,1       ,1        ,)

	/******************/
	/* TERCEIRA PARTE */
	/******************/
  nRow3 := 1620

  //Imprime linha de corte da ficha de compensacao
  For nI := 100 to 2300 step 50
    ::oPrint:Line(nRow3 - 0020, nI, nRow3 - 00020, nI + 30)
  Next nI

  ::oPrint:SayBitmap(nRow3, nCol1, ::cLogo, 400, 080) //logo
  ::oPrint:Line(nRow3, nCol1 + 0400, nRow3 + 0080, nCol1 + 0400) //v
  ::oPrint:Say(nRow3 + 0070, nCol1 + 0415, ::cBanco+"-7", oFont24)		// [1]Numero do Banco
  ::oPrint:Line(nRow3, nCol1 + 0610, nRow3 + 0080, nCol1 + 0610) //v
  ::oPrint:Say(nRow3 + 0070, nCol1 + 0620, ::cLinhaDigitavel, oFont20n)
  //::oPrint:Say(nRow3 + 0020, nCol1 + 1800, "Recibo do Sacado", oFont12)  //

  ::oPrint:Line(nRow3 + 0080, nCol1, nRow3 + 0945, nCol1)        //v borda esquerda 01
  ::oPrint:Line(nRow3 + 0240, nCol1 + 0395, nRow3 + 0380, nCol1 + 0395) //v 02
  ::oPrint:Line(nRow3 + 0310, nCol1 + 0645, nRow3 + 0380, nCol1 + 0645) //v 03
  ::oPrint:Line(nRow3 + 0240, nCol1 + 0895, nRow3 + 0380, nCol1 + 0895) //v 04
  ::oPrint:Line(nRow3 + 0240, nCol1 + 1195, nRow3 + 0310, nCol1 + 1195) //v 05 ACEITE
  ::oPrint:Line(nRow3 + 0240, nCol1 + 1375, nRow3 + 0380, nCol1 + 1375) //v 06 DATA PROCESSAMENTO
  ::oPrint:Line(nRow3 + 0080, nCol1 + 1700, nRow3 + 0730, nCol1 + 1700) //v 07	VENCIMENTO
  ::oPrint:Line(nRow3 + 0080, nCol1 + 2200, nRow3 + 0945, nCol1 + 2200) //v borda esquerda 01

  //Linhs horizontais do quadro 02
  ::oPrint:Line(nRow3 + 0080, nCol1, nRow3 + 0080, nCol1 + 2200) //h 01
  ::oPrint:Line(nRow3 + 0160, nCol1, nRow3 + 0160, nCol1 + 2200) //h 02
  ::oPrint:Line(nRow3 + 0240, nCol1, nRow3 + 0240, nCol1 + 2200) //h 03
  ::oPrint:Line(nRow3 + 0310, nCol1, nRow3 + 0310, nCol1 + 2200) //h 04
  ::oPrint:Line(nRow3 + 0380, nCol1, nRow3 + 0380, nCol1 + 2200) //h 05

  ::oPrint:Line(nRow3 + 0450, nCol1 + 1700, nRow3 + 0450, nCol1 + 2200) //h 06
  ::oPrint:Line(nRow3 + 0520, nCol1 + 1700, nRow3 + 0520, nCol1 + 2200) //h 07
  ::oPrint:Line(nRow3 + 0590, nCol1 + 1700, nRow3 + 0590, nCol1 + 2200) //h 08
  ::oPrint:Line(nRow3 + 0660, nCol1 + 1700, nRow3 + 0660, nCol1 + 2200) //h 09

  ::oPrint:Line(nRow3 + 0730, nCol1, nRow3 + 0730, nCol1 + 2200) //h 10
  ::oPrint:Line(nRow3 + 0945, nCol1, nRow3 + 0945, nCol1 + 2200) //h 11
  //
  ::oPrint:Say(nRow3 + 0110, nCol1 + 0010, "Local de Pagamento", oFont12n)
  ::oPrint:Say(nRow3 + 0145, nCol1 + 0010, "PAGÁVEL EM QUALQUER BANCO ATÉ O VENCIMENTO", oFont12)

  ::oPrint:Say(nRow3 + 0110, nCol1 + 1710, "Vencimento", oFont12n)
  cString	:= StrZero(Day(::dVencto),2) +"/"+ StrZero(Month(::dVencto),2) +"/"+ Right(Str(Year(::dVencto)),4)
  nCol    := 1880+(374-(len(cString)*22))
  ::oPrint:Say(nRow3 + 0145, nCol, cString, oFont12)
  //
  ::oPrint:Say(nRow3 + 0190, nCol1 + 0010, "Cedente", oFont12n)
  ::oPrint:Say(nRow3 + 0225, nCol1 + 0010, ::oCedente:GetItem("NOME")+" - "+::oCedente:GetItem("CNPJ"), oFont12) //Nome + CNPJ

  ::oPrint:Say(nRow3 + 0190, nCol1 + 1710, "Agência/Código Cedente", oFont12n)
  //cString := ::oBanco:GetItem("AGENCIA") + "/" + ::cConvenio
  cString := ::aInfoBco[2] + "/" + ::cConvenio

  nCol    := 1880+(374-(len(cString)*22))
  ::oPrint:Say(nRow3 + 0225, nCol-40, cString, oFont12)
  //
  ::oPrint:Say(nRow3 + 0270, nCol1 + 0010, "Data do Documento", oFont12n)
  ::oPrint:Say(nRow3 + 0305, nCol1 + 0010, StrZero(Day(::dEmissao),2) +"/"+ StrZero(Month(::dEmissao),2) +"/"+ Right(Str(Year(::dEmissao)),4), oFont12)

  ::oPrint:Say(nRow3 + 0270, nCol1 + 0405, "Nro.Documento", oFont12n)
  ::oPrint:Say(nRow3 + 0305, nCol1 + 0505, ::cNumDocto, oFont12) //Prefixo +Numero+Parcela

  ::oPrint:Say(nRow3 + 0270, nCol1 + 0905, "Espécie Doc.", oFont12n)
  ::oPrint:Say(nRow3 + 0305, nCol1 + 0905, "DM", oFont12) //Tipo do Titulo

  ::oPrint:Say(nRow3 + 0270, nCol1 + 1205, "Aceite", oFont12n)
  ::oPrint:Say(nRow3 + 0305, nCol1 + 1300, "N", oFont12)

  ::oPrint:Say(nRow3 + 0270, nCol1 + 1385, "Data do Processamento", oFont12n)
  ::oPrint:Say(nRow3 + 0305, nCol1 + 1450 ,StrZero(Day(dDataBase),2) +"/"+ StrZero(Month(dDataBase),2) +"/"+ Right(Str(Year(dDataBase)),4),oFont12) // Data impressao

  ::oPrint:Say(nRow3 + 0270, nCol1 + 1710, "Nosso Número", oFont12n)
  nCol    := 1880+(374-(len(::cNossoNumero)*22))
  ::oPrint:Say(nRow3 + 0305, nCol, ::cNossoNumero, oFont12)
  //
  ::oPrint:Say(nRow3 + 0340, nCol1 + 0010, "Uso do Banco", oFont12n)
  ::oPrint:Say(nRow3 + 0340, nCol1 + 0405, "Carteira", oFont12n)
  ::oPrint:Say(nRow3 + 0375, nCol1 + 0455, If(::cCarteira == "5", "101", ""), oFont12)
  ::oPrint:Say(nRow3 + 0340, nCol1 + 0655, "Espécie", oFont12n)
  ::oPrint:Say(nRow3 + 0375, nCol1 + 0705, "R$", oFont12)
  ::oPrint:Say(nRow3 + 0340, nCol1 + 0905, "Quantidade", oFont12n)
  ::oPrint:Say(nRow3 + 0340, nCol1 + 1385, "Valor", oFont12n)
  ::oPrint:Say(nRow3 + 0340, nCol1 + 1710, "(=)Valor do Documento", oFont12n)
  cString := Alltrim(Transform(::nValor  ,"@E 99,999,999.99"))
  nCol := 1880+(374-(len(cString)*22))
  ::oPrint:Say(nRow3 + 0375, nCol, cString, oFont12)
  //
  ::oPrint:Say(nRow3 + 0410, nCol1 + 0010, "INSTRUÇÕES (DE RESPONSABILIDADE DO CEDENTE)", oFont12n)

  For nM := 1 To Len(::aInstrucoes)
    ::oPrint:Say(nRow3 + 0410 + (nM * 35), nCol1 + 0010, ::aInstrucoes[nM], oFont12)
  Next nM

  //::oPrint:Say(nRow3 + 0480, nCol1 + 0010, aBolText1[1], oFont12)
  //::oPrint:Say(nRow3 + 0515, nCol1 + 0010, aBolText1[2], oFont12)
  //::oPrint:Say(nRow3 + 0725, nCol1 + 0010 ,'Título sujeito a protesto após 7 dias corridos depois de vencido.',oFont12)
  //::oPrint:Say(nRow3 + 0725, nCol1 + 0010, 'CHAVE ASBACE:' + Transform(M->ASBACE, '@R 9999.9999.9999.9999.9999.9999') + '  R.V.A.', oFont12)
  //
  ::oPrint:Say(nRow3 + 0410, nCol1 + 1710, "(-)Desconto/Abatimento", oFont12n)
  ::oPrint:Say(nRow3 + 0480, nCol1 + 1710, "(-)Outras Deduções", oFont12n)
  ::oPrint:Say(nRow3 + 0550, nCol1 + 1710, "(+)Mora/Multa", oFont12n)
  ::oPrint:Say(nRow3 + 0620, nCol1 + 1710, "(+)Outros Acréscimos", oFont12n)
  ::oPrint:Say(nRow3 + 0690, nCol1 + 1710, "(=)Valor Cobrado", oFont12n)
  //
  ::oPrint:Say(nRow3 + 0760, nCol1 + 0010, "Sacado", oFont12n)
  ::oPrint:Say(nRow3 + 0795, nCol1 + 0010, ::oSacado:GetItem("NOME")+" ("+::oSacado:GetItem("CODLOJA")+")"+cCnpjCpf, oFont12) // RAZAO+CODIGO+CNPJ
  ::oPrint:Say(nRow3 + 0830, nCol1 + 0010 ,::oSacado:GetItem("ENDERECO"), oFont12)

  ::oPrint:Say(nRow3 + 0865, nCol1 + 0010, "CEP: " + ::oSacado:GetItem("CEP")+" - "+::oSacado:GetItem("MUNICIPIO")+" - "+::oSacado:GetItem("ESTADO"),oFont12) // CEP+Cidade+Estado
  //::oPrint:Say(nRow3 + 0865, nCol1 + 0600, ::cNossoNumero, oFont12)

  ::oPrint:Say(nRow3 + 0935, nCol1 + 0010 , "Sacador/Avalista", oFont12n)
  ::oPrint:Say(nRow3 + 0935, nCol1 + 1710, "Código de baixa", oFont12n)

  ::oPrint:Say(nRow3 + 0970, nCol1 + 1400, "Autenticação Mecânica/Ficha de Compensação", oFont12n)
  ::oPrint:FWMsBar("INT25"/*cTypeBar*/,0062/*nRow*/,0002/*nCol*/,::cCodigoBarras,::oPrint,.F./*lCheck*/, ;
	/*Color*/,.T./*lHorz*/,0.025/*nWidth*/,1.2/*nHeigth*/,.F./*lBanner*/,/*cFont*/, ;
	/*cMode*/,.F./*lPrint*/,1/*nPFWidth*/,1/*nPFHeigth*/,/*lCmtr2Pix*/)
    ::oPrint:EndPage() // Finaliza a página
Return Self


Method DefineDiretorio() Class TWBolSantan



Return  ::oPrint:nModalResult == 1
//
Method SalvarPDF() Class TWBolSantan

  ::oPrint:cPathPDF := ::cPathPDF
  ::oPrint:lInJob   := .T.

  If File(::cPathPDF + ::cFile + ".pdf")
    //FErase(::cPathPDF + ::cFile + ".pdf",,.F.)
  End If

  ::oPrint:SetPortrait()   // ou SetLandscape()
  ::oPrint:SetViewPDF(.F.)
  ::oPrint:Print()

Return Self
//
Method VerPDF() Class TWBolSantan
  ::oPrint:Setup()

  If ::oPrint:nModalResult == 1
    ::oPrint:SetPortrait() // ou SetLandscape()
    ::oPrint:SetViewPDF(.T.)

    ::cPathPDF := ::oPrint:cPathPDF

    If File(::cPathPDF + ::cFile + ".pdf")
      //
      //FErase(::cPathPDF + ::cFile + ".pdf",,.F.)
    End If

    ::oPrint:Print()
  EndIf
Return Self
//
Method CartValida() Class TWBolSantan
  Local lAchouConta := .F.

  ::lCartValida := .F.

  Begin Sequence

    //______________________________________________________________________________
    //                                                                              |
    // Valida o Banco conforme o conteúdo do parâmetro MV_YINFBCO                   |
    //______________________________________________________________________________|

    SA6->(dbSetOrder(1))

    If SA6->(dbSeek(xFilial("SA6")+SA6->(::aInfoBco[1] +::aInfoBco[2] + ::aInfoBco[3])))
      lAchouConta := .T.
    Else
      //::cAviso := "Não foi possivel determinar o banco da conta: " + aInfoBco[1] + aInfoBco[2] + aInfoBco[3]
      ::cAviso := " Dados bancário inválido para o processo. Verifique o cadastro do Banco."
      Break
    Endif

    If !lAchouConta
      //::cAviso := "Não foi possivel determinar o banco da conta: " + SE1->(E1_PORTADO + E1_AGEDEP + E1_CONTA)
      ::cAviso := "Não foi possivel determinar o banco da conta: " + aInfoBco[1] + aInfoBco[2] + aInfoBco[3]
      Break
    EndIf

    DbSelectArea("SEE")
    DbSetOrder(1)

    //If DbSeek(xFilial("SEE") + SE1->(E1_PORTADO + E1_AGEDEP + E1_CONTA + "101")) // Alterar
    If DbSeek(xFilial("SEE") + ::aInfoBco[1] + ::aInfoBco[2] + ::aInfoBco[3] )

      If AllTrim(SEE->EE_CODCART) == "5"
        ::lCartValida := .T.
      Else
        ::cAviso := "Carteira inválida para a parametrização:" 	+ ::cCRLF
        ::cAviso += "FILIAL..: " + xFilial("SEE") 				+ ::cCRLF
        ::cAviso += "BANCO...: " + SE1->E1_PORTADO 				+ ::cCRLF
        ::cAviso += "AGENCIA.: " + SE1->E1_AGEDEP 				+ ::cCRLF
        ::cAviso += "CONTA...: " + SE1->E1_CONTA 				+ ::cCRLF
        ::cAviso += "SUBCONTA: " + "101" 						+ ::cCRLF
        ::cAviso += "CARTEIRA: " + SEE->EE_CODCART
        Break
      EndIf
    Else
      ::cAviso := "Não foi encontrada parametrização bancária para a conta:" + ::cCRLF
      ::cAviso += "FILIAL..: " + xFilial("SEE") 	+ ::cCRLF
      ::cAviso += "BANCO...: " + SE1->E1_PORTADO 	+ ::cCRLF
      ::cAviso += "AGENCIA.: " + SE1->E1_AGEDEP 	+ ::cCRLF
      ::cAviso += "CONTA...: " + SE1->E1_CONTA 	+ ::cCRLF
      ::cAviso += "SUBCONTA: " + "101"
      Break
    EndIf

    DbSelectArea("SA1")
    DbSetOrder(1)

    SA1->(DbSeek(xFilial("SA1") + SE1->(E1_CLIENTE + E1_LOJA)))
  End Sequence

  If !::lCartValida .And. ::lMostraErro
    If IsInCallStack("u_sched004")
      Conout( cAviso )
    else
      Aviso("Aviso", ::cAviso,{"Ok"},2)
    endif
  Endif

Return(::lCartValida)
//
Method Preparar() Class TWBolSantan
  ::oCedente:SetItem("NOME", SM0->M0_NOMECOM)
  ::oCedente:SetItem("ENDERECO", SM0->M0_ENDCOB)
  ::oCedente:SetItem("BAIRRO", SM0->M0_BAIRCOB)
  ::oCedente:SetItem("CIDADE", SM0->M0_CIDCOB)
  ::oCedente:SetItem("ESTADO", SM0->M0_ESTCOB)
  ::oCedente:SetItem("COMPLEMENTO", SM0->(AllTrim(M0_BAIRCOB)+", "+AllTrim(M0_CIDCOB)+", "+M0_ESTCOB))
  ::oCedente:SetItem("CEP", "CEP: "+SubStr(SM0->M0_CEPCOB,1,5) + "-" + SubStr(SM0->M0_CEPCOB,6,3))
  ::oCedente:SetItem("TELEFONE", "PABX/FAX: " + SM0->M0_TEL)
  ::oCedente:SetItem("CNPJ", "CNPJ: "+SubStr(SM0->M0_CGC,1,2)+"."+SubStr(SM0->M0_CGC,3,3)+"."+SubStr(SM0->M0_CGC,6,3)+"/"+ ;
    SubStr(SM0->M0_CGC,9,4)+"-"+SubStr(SM0->M0_CGC,13,2))
  ::oCedente:SetItem("IE", "I.E.: "+SubStr(SM0->M0_INSC,1,3)+"."+SubStr(SM0->M0_INSC,4,3)+"."+ ;
    SubStr(SM0->M0_INSC,7,3)+"."+SubStr(SM0->M0_INSC,10,3))

  ::oBanco:SetItem("NUMERO", SA6->A6_COD)
  ::oBanco:SetItem("NOME", SA6->A6_NREDUZ)
  ::oBanco:SetItem("AGENCIA", AllTrim(SA6->A6_AGENCIA))
  ::oBanco:SetItem("DVAGENCIA", AllTrim(SA6->A6_DVAGE))
  ::oBanco:SetItem("CONTA", AllTrim(SA6->A6_NUMCON))
  ::oBanco:SetItem("DVCONTA",AllTrim(SA6->A6_DVCTA))

  ::oSacado:SetItem("CODLOJA", AllTrim(SA1->A1_COD)+"-"+SA1->A1_LOJA)
  ::oSacado:SetItem("NOME", AllTrim(SA1->A1_NOME))
  ::oSacado:SetItem("CGC", SA1->A1_CGC)
  ::oSacado:SetItem("TIPO", SA1->A1_PESSOA)

  If Empty(SA1->A1_ENDCOB)
    ::oSacado:SetItem("ENDERECO", AllTrim(SA1->A1_END)+"-"+AllTrim(SA1->A1_BAIRRO))
    ::oSacado:SetItem("MUNICIPIO", AllTrim(SA1->A1_MUN))
    ::oSacado:SetItem("ESTADO", SA1->A1_EST)
    ::oSacado:SetItem("CEP", SA1->A1_CEP)
  Else
    ::oSacado:SetItem("ENDERECO", AllTrim(SA1->A1_ENDCOB)+"-"+AllTrim(SA1->A1_BAIRROC))
    ::oSacado:SetItem("MUNICIPIO", AllTrim(SA1->A1_MUNC))
    ::oSacado:SetItem("ESTADO", SA1->A1_ESTC)
    ::oSacado:SetItem("CEP", SA1->A1_CEPC)
  Endif

  ::cCarteira    := AllTrim(SEE->EE_CODCART)
  ::cConvenio    := AllTrim(SEE->EE_CODEMP)
  ::cVariacao    := "" //StrTokArr(SEE->EE_CODEMP,"-")[2]
  ::nValorAbat   := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
  ::cNumDocto    := SE1->(E1_PREFIXO + E1_NUM + E1_PARCELA)
  ::cNossoNumero := Alltrim(U_NNSantan())								//AllTrim(SE1->E1_NUMBCO)
  ::nValorAcre   := 0.00
  ::nValor       := SE1->E1_SALDO - ::nValorAbat + ::nValorAcre
  ::dVencto      := SE1->E1_VENCTO
  ::dEmissao     := SE1->E1_EMISSAO
  ::cBanco       := AllTrim(SA6->A6_NUMBCO)

  ::aInstrucoes  := {}

  If !Empty(SEE->EE_FORMEN1)
    aAdd(::aInstrucoes, &(SEE->EE_FORMEN1))
  EndIf
  If !Empty(SEE->EE_FORMEN2)
    aAdd(::aInstrucoes, &(SEE->EE_FORMEN2))
  EndIf
  If !Empty(SEE->EE_FOREXT1)
    aAdd(::aInstrucoes, &(SEE->EE_FOREXT1))
  EndIf
  If !Empty(SEE->EE_FOREXT2)
    aAdd(::aInstrucoes, &(SEE->EE_FOREXT2))
  EndIf

  ::CodBarras()
  ::LinhaDigitavel()

Return Self
//
Method Ver() Class TWBolSantan
  Local oPrint
  Local oFont8
  Local oFont11c
  Local oFont11n
  Local oFont10
  Local oFont14
  Local oFont16n
  Local oFont15
  Local oFont14n
  Local oFont24
  Local nI        := 0
  Local aBolText1 := { "MORA DIARIA DE 0,33%",;
    "PROTESTO AUTOMATICO APOS 05 DIAS DE VENCIMENTO"}

  //Parametros de TFont.New()
  //1.Nome da Fonte (Windows)
  //3.Tamanho em Pixels
  //5.Bold (T/F)
  oFont8  		:= TFont():New("Arial",9,8,.T.,.F.,5,.T.,5,.T.,.F.)
  oFont11c 		:= TFont():New("Courier New",9,11,.T.,.T.,5,.T.,5,.T.,.F.)
  oFont11n 		:= TFont():New("Arial",9,11,.T.,.F.,5,.T.,5,.T.,.F.)
  oFont12  		:= TFont():New("Arial",9,12,.T.,.T.,5,.T.,5,.T.,.F.)
  oFont10  		:= TFont():New("Arial",9,8,.T.,.T.,5,.T.,5,.T.,.F.)
  oFont14  		:= TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
  oFont20  		:= TFont():New("Arial",9,20,.T.,.T.,5,.T.,5,.T.,.F.)
  oFont21  		:= TFont():New("Arial",9,21,.T.,.T.,5,.T.,5,.T.,.F.)
  oFont16n 		:= TFont():New("Arial",9,16,.T.,.F.,5,.T.,5,.T.,.F.)
  oFont15  		:= TFont():New("Arial",9,15,.T.,.T.,5,.T.,5,.T.,.F.)
  oFont15n 		:= TFont():New("Arial",9,15,.T.,.F.,5,.T.,5,.T.,.F.)
  oFont14n 		:= TFont():New("Arial",9,14,.T.,.F.,5,.T.,5,.T.,.F.)
  oFont24  		:= TFont():New("Arial",9,24,.T.,.T.,5,.T.,5,.T.,.F.)

  oPrint:= TMSPrinter():New( "Boleto Laser" )
  oPrint:SetPortrait() // ou SetLandscape()
  oPrint:StartPage()   // Inicia uma nova página

	/******************/
	/* PRIMEIRA PARTE */
	/******************/

  nRow1 := 100

  oPrint:Line (nRow1+0150,500,nRow1+0070, 500)
  oPrint:Line (nRow1+0150,710,nRow1+0070, 710)

  oPrint:Line (nRow1+0150,100,nRow1+0550,100)
  oPrint:Line (nRow1+0150,2300,nRow1+0550,2300)

  oPrint:SayBitmap(nRow1+0055, 100, ::cLogo, 390, 090)

  oPrint:Say  (nRow1+0075,513,::cBanco+"-"+::cMoeda,oFont21 )		// [1]Numero do Banco

  oPrint:Say  (nRow1+0084,1900,"Comprovante de Entrega",oFont10)
  oPrint:Line (nRow1+0150,100,nRow1+0150,2300)

  oPrint:Say  (nRow1+0150,110 ,"Cedente",oFont8)
  oPrint:Say  (nRow1+0200,110 ,::oCedente:GetItem("NOME"),oFont10)				//Nome + CNPJ

  oPrint:Say  (nRow1+0150,1060,"Agência/Código Cedente",oFont8)
  //oPrint:Say  (nRow1+0200,1060,::oBanco:GetItem("AGENCIA")+"/"+::oBanco:GetItem("CONTA")+"-"+::oBanco:GetItem("DVCONTA"),oFont10)
  oPrint:Say  (nRow1+0200,1060,::aInfoBco[2]+"/"+ ::aInfoBco[2]+"-"+::oBanco:GetItem("DVCONTA"),oFont10)

  oPrint:Say  (nRow1+0150,1510,"Nro.Documento",oFont8)
  oPrint:Say  (nRow1+0200,1510,::cNumDocto,oFont10)//Prefixo +Numero+Parcela

  oPrint:Say  (nRow1+0250,110 ,"Sacado",oFont8)
  oPrint:Say  (nRow1+0300,110 ,::oSacado:GetItem("NOME"),oFont10)			//Nome

  oPrint:Say  (nRow1+0250,1060,"Vencimento",oFont8)
  oPrint:Say  (nRow1+0300,1060,StrZero(Day(::dVencto),2) +"/"+ StrZero(Month(::dVencto),2) +"/"+ Right(Str(Year(::dVencto)),4),oFont10)

  oPrint:Say  (nRow1+0250,1510,"(=)Valor do Documento",oFont8)
  oPrint:Say  (nRow1+0300,1550,AllTrim(Transform(::nValor,"@E 999,999,999.99")),oFont10)

  oPrint:Say  (nRow1+0400,0110,"Recebi(emos) o bloqueto/título",oFont10)
  oPrint:Say  (nRow1+0450,0110,"com as características acima.",oFont10)
  oPrint:Say  (nRow1+0350,1060,"Data",oFont8)
  oPrint:Say  (nRow1+0350,1410,"Assinatura",oFont8)
  oPrint:Say  (nRow1+0450,1060,"Data",oFont8)
  oPrint:Say  (nRow1+0450,1410,"Entregador",oFont8)

  oPrint:Line (nRow1+0250, 100,nRow1+0250,1900 )
  oPrint:Line (nRow1+0350, 100,nRow1+0350,1900 )
  oPrint:Line (nRow1+0450,1050,nRow1+0450,1900 ) //---
  oPrint:Line (nRow1+0550, 100,nRow1+0550,2300 )

  oPrint:Line (nRow1+0550,1050,nRow1+0150,1050 )
  oPrint:Line (nRow1+0550,1400,nRow1+0350,1400 )
  oPrint:Line (nRow1+0350,1500,nRow1+0150,1500 ) //--
  oPrint:Line (nRow1+0550,1900,nRow1+0150,1900 )

  oPrint:Say  (nRow1+0165,1910,"(  )Mudou-se"					,oFont8)
  oPrint:Say  (nRow1+0205,1910,"(  )Ausente"					,oFont8)
  oPrint:Say  (nRow1+0245,1910,"(  )Não existe nº indicado"	,oFont8)
  oPrint:Say  (nRow1+0285,1910,"(  )Recusado"					,oFont8)
  oPrint:Say  (nRow1+0325,1910,"(  )Não procurado"			,oFont8)
  oPrint:Say  (nRow1+0365,1910,"(  )Endereço insuficiente"	,oFont8)
  oPrint:Say  (nRow1+0405,1910,"(  )Desconhecido"				,oFont8)
  oPrint:Say  (nRow1+0445,1910,"(  )Falecido"					,oFont8)
  oPrint:Say  (nRow1+0485,1910,"(  )Outros(anotar no verso)"	,oFont8)

	/*****************/
	/* SEGUNDA PARTE */
	/*****************/

  nRow2 := 150

  oPrint:Line (nRow2+0710,100,nRow2+0710,2300)
  oPrint:Line (nRow2+0710,500,nRow2+0630, 500)
  oPrint:Line (nRow2+0710,710,nRow2+0630, 710)

  oPrint:Say  (nRow2+0600,2000,"Recibo do Sacado",oFont10) //oPrint:Line (nRow2+0710,710,nRow2+0630, 710)

  oPrint:SayBitmap(nRow2+0615, 100, ::cLogo, 390, 090)

  oPrint:Say  (nRow2+0635,513,::cBanco+"-"+::cMoeda,oFont21 )	// [1]Numero do Banco

  oPrint:Say  (nRow2+645,755,::cLinhaDigitavel,oFont15n)

  oPrint:Line (nRow2+0810,100,nRow2+0810,2300)
  oPrint:Line (nRow2+0910,100,nRow2+0910,2300)
  oPrint:Line (nRow2+0980,100,nRow2+0980,2300)
  oPrint:Line (nRow2+1050,100,nRow2+1050,2300)

  oPrint:Line (nRow2+0710,100,nRow2+1640,100)
  oPrint:Line (nRow2+0710,2300,nRow2+1640,2300)

  oPrint:Line (nRow2+0910,500,nRow2+1050,500)
  oPrint:Line (nRow2+0980,750,nRow2+1050,750)
  oPrint:Line (nRow2+0910,1000,nRow2+1050,1000)
  oPrint:Line (nRow2+0910,1300,nRow2+0980,1300)
  oPrint:Line (nRow2+0910,1480,nRow2+1050,1480)

  oPrint:Say  (nRow2+0710,110 ,"Local de Pagamento"        ,oFont8)
  oPrint:Say  (nRow2+0725,400 ,"PAGÁVEL EM QUALQUER BANCO ATÉ O VENCIMENTO",oFont10)

  oPrint:Say  (nRow2+0710,1810,"Vencimento"                ,oFont8)
  cString	:= StrZero(Day(::dVencto),2) +"/"+ StrZero(Month(::dVencto),2) +"/"+ Right(Str(Year(::dVencto)),4)
  nCol := 1880+(374-(len(cString)*22))
  oPrint:Say  (nRow2+0750,nCol,cString,oFont11c)

  oPrint:Say  (nRow2+0810,110 ,"Cedente"                   ,oFont8)
  oPrint:Say  (nRow2+0850,110 ,::oCedente:GetItem("NOME")+" - "+::oCedente:GetItem("CNPJ")	,oFont10) //Nome + CNPJ

  oPrint:Say  (nRow2+0810,1810,"Agência/Código Cedente"    ,oFont8)
  //cString := ::oBanco:GetItem("AGENCIA")+"/"+::oBanco:GetItem("CONTA")+"-"+::oBanco:GetItem("DVCONTA")
  cString := ::aInfoBco[2]+"/"+3[3]+"-"+::oBanco:GetItem("DVCONTA")

  nCol := 1880+(374-(len(cString)*22))
  oPrint:Say  (nRow2+0850,nCol,cString,oFont11c)

  oPrint:Say  (nRow2+0910,110 ,"Data do Documento"         ,oFont8)
  oPrint:Say  (nRow2+0940,110, StrZero(Day(::dEmissao),2) +"/"+ StrZero(Month(::dEmissao),2) +"/"+ Right(Str(Year(::dEmissao)),4),oFont10)

  oPrint:Say  (nRow2+0910,505 ,"Nro.Documento"             ,oFont8)
  oPrint:Say  (nRow2+0940,605 ,::cNumDocto  ,oFont10) //Prefixo +Numero+Parcela

  oPrint:Say  (nRow2+0910,1005,"Espécie Doc."              ,oFont8)
  oPrint:Say  (nRow2+0940,1050,"DM"				  ,oFont10) //Tipo do Titulo

  oPrint:Say  (nRow2+0910,1305,"Aceite"                    ,oFont8)
  oPrint:Say  (nRow2+0940,1400,"N"                         ,oFont10)

  oPrint:Say  (nRow2+0910,1485,"Data do Processamento"     ,oFont8)
  oPrint:Say  (nRow2+0940,1550,StrZero(Day(dDataBase),2) +"/"+ StrZero(Month(dDataBase),2) +;
    "/"+ Right(Str(Year(dDataBase)),4),oFont10) // Data impressao

  oPrint:Say  (nRow2+0910,1810,"Nosso Número",oFont8)

  nCol := 1880+(374-(len(::cNossoNumero)*22))
  oPrint:Say  (nRow2+0940,nCol,::cNossoNumero,oFont11c)

  oPrint:Say  (nRow2+0980,110 ,"Uso do Banco", oFont8)

  oPrint:Say  (nRow2+0980,505 ,"Carteira", oFont8)
  oPrint:Say  (nRow2+1010,555 ,::cCarteira+"-"+::cVariacao, oFont10)

  oPrint:Say  (nRow2+0980,755 ,"Espécie", oFont8)
  oPrint:Say  (nRow2+1010,805 ,"R$", oFont10)

  oPrint:Say  (nRow2+0980,1005,"Quantidade", oFont8)
  oPrint:Say  (nRow2+0980,1485,"Valor", oFont8)

  oPrint:Say  (nRow2+0980,1810,"(=)Valor do Documento", oFont8)
  cString := Alltrim(Transform(::nValor,"@E 99,999,999.99"))
  nCol := 1880+(374-(len(cString)*22))
  oPrint:Say  (nRow2+1010,nCol,cString ,oFont11c)

  oPrint:Say  (nRow2+1050,110 ,"INSTRUÇÕES (DE RESPONSABILIDADE DO CEDENTE)",oFont8)
  nPosObs := 1150

  oPrint:Say  (nRow2+nPosObs,110 ,aBolText1[1],oFont10)
  nPosObs += 50

  oPrint:Say  (nRow2+nPosObs,110 ,aBolText1[2],oFont10)
  nPosObs += 50

  oPrint:Say  (nRow2+nPosObs+050,110 ,'Título sujeito a protesto após 7 dias corridos depois de vencido.',oFont10)
  //oPrint:Say  (nRow2+nPosObs+100,110 ,'CHAVE ASBACE:' + Transform(M->ASBACE, '@R 9999.9999.9999.9999.9999.9999') + '  R.V.A.', oFont10)

  oPrint:Say  (nRow2+1050,1810,"(-)Desconto/Abatimento"                         ,oFont8)
  oPrint:Say  (nRow2+1120,1810,"(-)Outras Deduções"                             ,oFont8)
  oPrint:Say  (nRow2+1190,1810,"(+)Mora/Multa"                                  ,oFont8)
  oPrint:Say  (nRow2+1260,1810,"(+)Outros Acréscimos"                           ,oFont8)
  oPrint:Say  (nRow2+1330,1810,"(=)Valor Cobrado"                               ,oFont8)

  oPrint:Say  (nRow2+1400,110 ,"Sacado"                                         ,oFont8)
  cCNPJ_CPF := ""
  If ::oSacado:GetItem("TIPO") = "J"
    cCNPJ_CPF := SPACE(10)+"CNPJ: "+TRANSFORM(::oSacado:GetItem("CGC"),"@R 99.999.999/9999-99") // CGC
  Else
    cCNPJ_CPF :=SPACE(10)+"CPF.: "+TRANSFORM(::oSacado:GetItem("CGC"),"@R 999.999.999-99") 	// CPF
  EndIf

  oPrint:Say  (nRow2+1440,110 ,::oSacado:GetItem("NOME")+" ("+::oSacado:GetItem("CODLOJA")+")"+cCNPJ_CPF             ,oFont10) // RAZAO+CODIGO+CNPJ
  oPrint:Say  (nRow2+1470,110 ,::oSacado:GetItem("ENDERECO")                                   ,oFont10)
  oPrint:Say  (nRow2+1500,110 ,"CEP.: "+::oSacado:GetItem("CEP")+"    "+::oSacado:GetItem("MUNICIPIO")+" - "+::oSacado:GetItem("ESTADO"),oFont10) // CEP+Cidade+Estado

  oPrint:Say  (nRow2+1500,700,::cNossoNumero,oFont10)

  oPrint:Say  (nRow2+1605,0110 ,"Sacador/Avalista",oFont8)
  oPrint:Say  (nRow2+1645,1500,"Autenticação Mecânica",oFont8)

  oPrint:Say  (nRow2+1605,1810,"Código de baixa",oFont8)

  //	oPrint:Line (nRow2+0710,1800,nRow2+1640,1800 )
  oPrint:Line (nRow2+0710,1800,nRow2+1400,1800 )
  oPrint:Line (nRow2+1120,1800,nRow2+1120,2300 )
  oPrint:Line (nRow2+1190,1800,nRow2+1190,2300 )
  oPrint:Line (nRow2+1260,1800,nRow2+1260,2300 )
  oPrint:Line (nRow2+1330,1800,nRow2+1330,2300 )
  oPrint:Line (nRow2+1400,100 ,nRow2+1400,2300 )
  oPrint:Line (nRow2+1640,100 ,nRow2+1640,2300 )

  oPrint:Line (nRow2+1640,100 ,nRow2+1640,2300 )

  //MSBAR3("INT25",15.85,1,::cCodigoBarras,oPrint,.F.,Nil,.T.,0.028,1.02,Nil,Nil,Nil,.F.) //Impressora Laser
  MSBAR3("INT25",07.80,0.5,::cCodigoBarras,oPrint,.F.,Nil,.T.,0.028,1.02,Nil,Nil,Nil,.F.) //Impressora Laser

	/******************/
	/* TERCEIRA PARTE */
	/******************/

  nRow3 := 350

  //Imprime linha de corte da ficha de compensacao
  For nI := 100 to 2300 step 50
    oPrint:Line(nRow3+1880, nI, nRow3+1880, nI+30)
  Next nI

  oPrint:Line (nRow3+2000,100,nRow3+2000,2300)
  oPrint:Line (nRow3+2000,500,nRow3+1920, 500)
  oPrint:Line (nRow3+2000,710,nRow3+1920, 710)

  oPrint:sayBitmap(nRow3+1908, 100, ::cLogo, 390, 090)

  oPrint:Say  (nRow3+1925,513,::cBanco+"-"+::cMoeda,oFont21 )	// 	[1]Numero do Banco

  oPrint:Say  (nRow3+1934,755,::cLinhaDigitavel,oFont15n)			//	Linha Digitavel do Codigo de Barras

  oPrint:Line (nRow3+2100,100,nRow3+2100,2300 )
  oPrint:Line (nRow3+2200,100,nRow3+2200,2300 )
  oPrint:Line (nRow3+2270,100,nRow3+2270,2300 )
  oPrint:Line (nRow3+2340,100,nRow3+2340,2300 )

  oPrint:Line (nRow3+2000,100,nRow3+2850,100)
  oPrint:Line (nRow3+2000,2300,nRow3+2850,2300)

  oPrint:Line (nRow3+2200,500 ,nRow3+2340,500 )
  oPrint:Line (nRow3+2270,750 ,nRow3+2340,750 )
  oPrint:Line (nRow3+2200,1000,nRow3+2340,1000)
  oPrint:Line (nRow3+2200,1300,nRow3+2270,1300)
  oPrint:Line (nRow3+2200,1480,nRow3+2340,1480)

  oPrint:Say  (nRow3+2000,110 ,"Local de Pagamento",oFont8)
  oPrint:Say  (nRow3+2015,400 ,"PAGÁVEL EM QUALQUER BANCO ATÉ O VENCIMENTO",oFont10)

  oPrint:Say  (nRow3+2000,1810,"Vencimento",oFont8)
  cString := StrZero(Day(::dVencto),2) +"/"+ StrZero(Month(::dVencto),2) +"/"+ Right(Str(Year(::dVencto)),4)
  nCol	 	 := 1880+(374-(len(cString)*22))
  oPrint:Say  (nRow3+2040,nCol,cString,oFont11c)

  oPrint:Say  (nRow3+2100,110 ,"Cedente",oFont8)
  oPrint:Say  (nRow3+2140,110 ,::oCedente:GetItem("NOME")+" - "+::oCedente:GetItem("CNPJ")	,oFont10) //Nome + CNPJ

  oPrint:Say  (nRow3+2100,1810,"Agência/Código Cedente",oFont8)
  //cString := ::oBanco:GetItem("AGENCIA")+"/"+::oBanco:GetItem("CONTA")+"-"+::oBanco:GetItem("DVCONTA")
  cString := ::aInfoBco[2]+"/"+::aInfoBco[3]+"-"+::oBanco:GetItem("DVCONTA")

  nCol 	 := 1880+(374-(len(cString)*22))
  oPrint:Say  (nRow3+2140,nCol,cString ,oFont11c)

  oPrint:Say  (nRow3+2200,110 ,"Data do Documento"                              ,oFont8)
  oPrint:Say (nRow3+2230,110, StrZero(Day(::dEmissao),2) +"/"+ StrZero(Month(::dEmissao),2) +"/"+ Right(Str(Year(::dEmissao)),4), oFont10)

  oPrint:Say  (nRow3+2200,505 ,"Nro.Documento"                                  ,oFont8)
  oPrint:Say  (nRow3+2230,605 ,::cNumDocto  ,oFont10) //Prefixo +Numero+Parcela

  oPrint:Say  (nRow3+2200,1005,"Espécie Doc."                                   ,oFont8)
  oPrint:Say  (nRow3+2230,1050,"DM"										,oFont10) //Tipo do Titulo

  oPrint:Say  (nRow3+2200,1305,"Aceite"                                         ,oFont8)
  oPrint:Say  (nRow3+2230,1400,"N"                                             ,oFont10)

  oPrint:Say  (nRow3+2200,1485,"Data do Processamento"                          ,oFont8)
  oPrint:Say  (nRow3+2230,1550,StrZero(Day(dDataBase),2) +"/"+ StrZero(Month(dDataBase),2) +"/"+ Right(Str(Year(dDataBase)),4)                               ,oFont10) // Data impressao

  oPrint:Say  (nRow3+2200,1810,"Nosso Número"                                   ,oFont8)

  nCol 	 := 1880+(374-(len(::cNossoNumero)*22))
  oPrint:Say  (nRow3+2230,nCol,::cNossoNumero,oFont11c)

  oPrint:Say  (nRow3+2270,110 ,"Uso do Banco"                                   ,oFont8)
  oPrint:Say  (nRow3+2270,505 ,"Carteira"                                       ,oFont8)
  oPrint:Say  (nRow3+2300,555 ,::cCarteira+"-"+::cVariacao	,oFont10)

  oPrint:Say  (nRow3+2270,755 ,"Espécie"                                        ,oFont8)
  oPrint:Say  (nRow3+2300,805 ,"R$"                                             ,oFont10)

  oPrint:Say  (nRow3+2270,1005,"Quantidade"                                     ,oFont8)
  oPrint:Say  (nRow3+2270,1485,"Valor"                                          ,oFont8)

  oPrint:Say  (nRow3+2270,1810,"(=)Valor do Documento"                          	,oFont8)
  cString := Alltrim(Transform(::nValor,"@E 99,999,999.99"))
  nCol 	 := 1880+(374-(len(cString)*22))
  oPrint:Say  (nRow3+2300,nCol,cString,oFont11c)

  nPosObs := 2440
  oPrint:Say  (nRow3+2340,110 ,"INSTRUÇÕES (DE RESPONSABILIDADE DO CEDENTE)",oFont8)

  oPrint:Say  (nRow3+2440,110 ,aBolText1[1]   	,oFont10)
  nPosObs += 50

  oPrint:Say  (nRow3+nPosObs,110 ,aBolText1[2]  	,oFont10)
  nPosObs += 50

  oPrint:Say  (nRow3+nPosObs+050,110 ,'Título sujeito a protesto após 7 dias corridos depois de vencido.',oFont10)
  //oPrint:Say  (nRow3+nPosObs+100,110 ,'CHAVE ASBACE:' + Transform(M->ASBACE, '@R 9999.9999.9999.9999.9999.9999') + '  R.V.A.',oFont10)

  oPrint:Say  (nRow3+2340,1810,"(-)Desconto/Abatimento"                         ,oFont8)
  oPrint:Say  (nRow3+2410,1810,"(-)Outras Deduções"                             ,oFont8)
  oPrint:Say  (nRow3+2480,1810,"(+)Mora/Multa"                                  ,oFont8)
  oPrint:Say  (nRow3+2550,1810,"(+)Outros Acréscimos"                           ,oFont8)
  oPrint:Say  (nRow3+2620,1810,"(=)Valor Cobrado"                               ,oFont8)

  oPrint:Say  (nRow3+2690,110 ,"Sacado"                                         ,oFont8)
  //	oPrint:Say  (nRow3+2720,110 ,aDatSacado[1]+" ("+aDatSacado[2]+")"             ,oFont10)
  oPrint:Say  (nRow3+2720,110 ,::oSacado:GetItem("NOME")+" ("+::oSacado:GetItem("CODLOJA")+")"+cCNPJ_CPF,oFont10) // RAZAO+CODIGO+CNPJ

  oPrint:Say  (nRow3+2750,110 ,::oSacado:GetItem("ENDERECO") ,oFont10)
  oPrint:Say  (nRow3+2780,110 ,"CEP.: "+::oSacado:GetItem("CEP")+"    "+::oSacado:GetItem("MUNICIPIO")+" - "+::oSacado:GetItem("ESTADO"),oFont10) // CEP+Cidade+Estado
  oPrint:Say  (nRow3+2780,700,::cNossoNumero, oFont10)

  oPrint:Say  (nRow3+2815,110 ,"Sacador/Avalista"                               ,oFont8)
  oPrint:Say  (nRow3+2855,1500,"Autenticação Mecânica/Ficha de Compensação"                        ,oFont8)

  oPrint:Say  (nRow3+2815,1810,"Código de baixa",oFont8)

  //	oPrint:Line (nRow3+2000,1800,nRow3+2850,1800 )
  oPrint:Line (nRow3+2000,1800,nRow3+2690,1800 )
  oPrint:Line (nRow3+2410,1800,nRow3+2410,2300 )
  oPrint:Line (nRow3+2480,1800,nRow3+2480,2300 )
  oPrint:Line (nRow3+2550,1800,nRow3+2550,2300 )
  oPrint:Line (nRow3+2620,1800,nRow3+2620,2300 )
  oPrint:Line (nRow3+2690,100 ,nRow3+2690,2300 )

  oPrint:Line (nRow3+2850,100,nRow3+2850,2300  )

  MSBAR3("INT25",13.80,0.5,::cCodigoBarras,oPrint,.F.,Nil,.T.,0.028,1.03,Nil,Nil,Nil,.F.) //Impressora Laser
  //MSBAR3("INT25",26.35+1.35,1,::cCodigoBarras,oPrint,.F.,Nil,.T.,0.028,1.03,Nil,Nil,Nil,.F.) //Impressora Laser

  oPrint:EndPage() // Finaliza a página
  oPrint:Preview()
Return Self

//
Method LinhaDigitavel() Class TWBolSantan
  Local cCampo1, cCampo2, cCampo3, cCampo4, cCampo5

  cCampo1 := ::cBanco + ::cMoeda + "9" + SubStr(::cConvenio,1,4)
  cCampo1 += ::DigCampo(cCampo1, 1)

  cCampo2 := SubStr(::cConvenio,5,3)
  cCampo2 += "00000" + SubStr(::cNossoNumero,1,2)
  cCampo2 += ::DigCampo(cCampo2, 2)

  cCampo3 := SubStr(::cNossoNumero,3,6)
  cCampo3 += "0" + If(::cCarteira=="5","101","102")
  cCampo3 += ::DigCampo(cCampo3, 3)

  cCampo4 := ::cDigCodBar

  cCampo5 := ::cFatorVencto + StrZero(::nValor * 100, 10, 0)

  ::cLinhaDigitavel := Left(cCampo1, 5) + "." + Right(cCampo1, 5) + " "
  ::cLinhaDigitavel += Left(cCampo2, 5) + "." + Right(cCampo2, 6) + " "
  ::cLinhaDigitavel += Left(cCampo3, 5) + "." + Right(cCampo3, 6) + " "
  ::cLinhaDigitavel += cCampo4 + " " + cCampo5
Return(::cLinhaDigitavel)
//
Method CodBarras() Class TWBolSantan
  Local cFatorVlr := StrTran(StrZero(::nValor, 11, 2),".","")
  Local cDV       := ""

  ::FatorVencto()

  ::cCodigoBarras := ::cBanco + ::cMoeda
  //::cCodigoBarras += " "
  ::cCodigoBarras += ::cFatorVencto
  ::cCodigoBarras += cFatorVlr + "9"
  ::cCodigoBarras += ::cConvenio + "00000"
  ::cCodigoBarras += ::cNossoNumero + "0"
  ::cCodigoBarras += "101"

  ::DigCodBar()

  ::cCodigoBarras := ::cBanco + ::cMoeda
  ::cCodigoBarras += ::cDigCodBar
  ::cCodigoBarras += ::cFatorVencto
  ::cCodigoBarras += cFatorVlr + "9"
  ::cCodigoBarras += ::cConvenio + "00000"
  ::cCodigoBarras += Alltrim(::cNossoNumero) + "0"
  ::cCodigoBarras += "101"
Return(::cCodigoBarras)
//
Method FatorVencto() Class TWBolSantan
  Local dBase   := Stod("19971007")
  Local dVencto := SE1->E1_VENCTO
  Local nFator  := dVencto - dBase

  ::cFatorVencto := cValToChar(nFator)
Return(::cFatorVencto)
//
Method DigCodBar() Class TWBolSantan
  Local Auxi      := 0
  Local aBaseCalc := {4,3,2,9,8,7,6,5,4,3,2,9,8,7,6,5,4,3,2,9,8,7,6,5,4,3,0,0,0,0,0,5,4,3,2,9,8,7,6,5,4,3,2}
  Local nMult     := 0
  Local nD        := 0
  Local nE        := 0
  Local aMult     := {}
  Local nDigBar   := 0
  Local nSoma     := 0
  Local cBase     := ::cCodigoBarras

  For nD := 1 To Len(cBase)
    nMult := Val(SubStr(cBase,nD,1) ) * aBaseCalc[nD]
    Aadd(aMult,StrZero(nMult,2) )
  Next nD

  nSoma := 0
  nAlgarism1 := 0
  nAlgarism2 := 0

  For nE := 1 To Len(aMult)
    nAlgarism1 := Val(aMult[nE])
    nSoma      := nSoma + nAlgarism1 // + nAlgarism2
  Next nC

  nDigBar := 11 - Mod(nSoma,11)

  If nDigBar == 0 .or. nDigBar == 1 .or. nDigBar == 10 .or. nDigBar == 11
    nDigBar := 1
  EndIf

  ::cDigCodBar := cValToChar(nDigBar)
Return(::cDigCodBar)
//
Method DigCampo(cVariavel,nOp) Class TWBolSantan
  Local aMultiplic := {}  // Resultado das Multiplicacoes de cada algarismo
  Local _cRet      := " "
  Local aBaseNum   := {}
  Local cDigVer    := 0
  Local nB         := 0
  Local nC         := 0
  Local nSum       := 0
  Local _cNossoNum := ""
  Local _cCalcdig  := ""

  cBase  := cVariavel

  If nOp == 1
    aBaseNum   := {2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2}
  Else
    aBaseNum   := {1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1}
  EndIf

  For nB := 1 To Len(cBase)
    nMultiplic := Val(Subs(cBase,nB,1) ) * aBaseNum[nB]
    Aadd(aMultiplic,StrZero(nMultiplic,2) )
  Next nB

  For nC := 1 To Len(aMultiplic)
    nAlgarism1 := Val(Subs(aMultiplic[nC],1,1) )
    nAlgarism2 := Val(Subs(aMultiplic[nC],2,1) )
    nSum       := nSum + nAlgarism1 + nAlgarism2
  Next nC

  cDigVer := 10 - Mod(nSum,10)

  IF cDigVer == 10
    cDigVer := 0
  Endif
Return(Str(cDigVer,1,0))
