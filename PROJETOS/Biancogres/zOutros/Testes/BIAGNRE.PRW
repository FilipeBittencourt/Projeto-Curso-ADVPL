#include "PROTHEUS.CH"
#include "TOPCONN.CH"



user function ZGnreXMLEnv( cAliasSF6 )

  local	aDestinat	  := {}
  local 	aTelEmi		:= {}
  local 	aInfAdic	:= {}

  local 	cId			:= ''
  local 	cEmissNF	:= ''
  local 	cNumeroNF	:= ''
  local 	cSerieNf	:= ''
  local	cEspecie	:= ''
  local 	cTipoNf		:= ''
  local	cChvNFe		:= ''
  local	cCpfCnpj	:= ''
  local	cInscDest	:= ''
  local	cNomeDest	:= ''
  local	cMunDest	:= ''
  local 	cInsc		:= ''
  local 	cString		:= ''
  local  cProduto		:= ''
  local  cEmail		:= ''
  local  cFoneEmi		:= ''
  local 	cUf			:= ''
  local  cCodRec		:= ''
  local  cCodAdic		:= ''
  local 	cTpAdic		:= ''
  local 	cValor		:= ''
  local  cExtra		:= ''
  local  cDescMunDs	:= ''
  local  cTpDocOrig := ''
  local  cTitulo  	:= ''
  local	cCodInt  	:= ''
  local  cMVUFGNWS	:= GetNewPar('MV_UFGNWS' ,'') //Apenas as UF's que possuem GNRE Web Service.

  local lObriga		:= .f.
  local lGera		:= .t.

  local	nValPrinc 	:= 0
  local	nValTotal 	:= 0
  local  nX		   	:= 0


  default cAliasSF6:= ( PARAMIXB[1] )

  cUF			:= alltrim((cAliasSF6)->F6_EST)
  cNumGNRE	:= alltrim((cAliasSF6)->F6_NUMERO)

  //Tratamento para ID
  cId	 := cUF + cNumGNRE

  //Produto
  cProduto := iif(! empty((cAliasSF6)->F6_CODPROD), cValtoChar((cAliasSF6)->F6_CODPROD),"")

  //Cabeçalho XML
  cString := '<gnre id="gnre:' +  cNumGNRE  + '" tssversao="2.00">'

  //Código Receita
  cCodRec:= alltrim((cAliasSF6)->F6_CODREC)

  //Informações da GNRE

  if cUF $ cMVUFGNWS

    cString	+= '<identgnre>'

    cString	+= '<uf>' + cUF + '</uf>'
    cString	+= '<numerognre>' +  cNumGNRE  + '</numerognre>'
    cString	+= '<receita>' + cCodRec + '</receita>'
    cString	+= '<detreceita>' + allTrim((cAliasSF6)->F6_DETRECE) + '</detreceita>'
    cString	+= '<produto>' + cProduto + '</produto>'
    cString	+= '<vencimento>' + dtos((cAliasSF6)->F6_DTVENC)  + '</vencimento>'
    cString	+= '<convenio>' + allTrim((cAliasSF6)->F6_NUMCONV) + '</convenio>'
    cString	+= '<pagamento>' + dtos((cAliasSF6)->F6_DTPAGTO) + '</pagamento>'
    cString	+= '<fatogerador>' + (cAliasSF6)->F6_DTARREC + '</fatogerador>'
    cString	+= '<tipoperiodoapur>M</tipoperiodoapur>'
    cString	+= '<mesref>'+ ConvType((cAliasSF6)->F6_MESREF) + '</mesref>'
    cString	+= '<anoref>' + ConvType((cAliasSF6)->F6_ANOREF) + '</anoref>'
    cString	+= '<decref></decref>'
    cString	+= '<observacoes>' + ConvType((cAliasSF6)->F6_OBSERV)+ '</observacoes>'
    cString	+= '<informacoes>' + ConvType((cAliasSF6)->F6_INF) + '</informacoes>'
    cString	+= '<infcompl>' + ConvType((cAliasSF6)->F6_DESCOMP) + '</infcompl>'
    cString	+= '<dtsaimerc></dtsaimerc>'
    cString	+= '<diavencimento></diavencimento>'
    cString	+= '<tipoimport></tipoimport>'

    //Demais informações GNRE
    cString	+= '<banco>'+ AllTrim((cAliasSF6)->F6_BANCO) +'</banco>'
    cString	+= '<agencia>' + AllTrim((cAliasSF6)->F6_AGENCIA) + '</agencia>'
    cString	+= '<classevcto>' + AllTrim((cAliasSF6)->F6_CLAVENC) + '</classevcto>'
    cString	+= '<cnpjcontrib>' + AllTrim((cAliasSF6)->F6_CNPJ) + '</cnpjcontrib>'
    cString	+= '<vencaut>' + AllTrim((cAliasSF6)->F6_VENCAUT) + '</vencaut>'
    cString	+= '<docorigem>' + AllTrim((cAliasSF6)->F6_DOCOR) + '</docorigem>'
    cString	+= '<autentbanc>' + AllTrim((cAliasSF6)->F6_AUTENT) + '</autentbanc>'
    cString	+= '<numproc>' + AllTrim((cAliasSF6)->F6_NUMPROC) + '</numproc>'
    cString	+= '<indproc>' + AllTrim((cAliasSF6)->F6_INDPROC) + '</indproc>'
    cString	+= '<pedidodeducao>' + AllTrim((cAliasSF6)->F6_PEDDED) + '</pedidodeducao>'
    cString	+= '<issor>' + AllTrim((cAliasSF6)->F6_ISSOR) + '</issor>'
    cString	+= '<codmuniss>' + AllTrim((cAliasSF6)->F6_CODMUN) + '</codmuniss>'


    //Nota Fiscal - Quando for por operação
    if !( empty((cAliasSF6)->F6_DOC) .And. empty((cAliasSF6)->F6_SERIE) .And. empty((cAliasSF6)->F6_CLIFOR) .And. empty((cAliasSF6)->F6_LOJA) )

      dbselectarea("SF3") //Livros Fiscais
      SF3->(dbsetorder(4)) //F3_FILIAL+F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE

      if SF3->(dbseek(xFilial("SF3")+ (cAliasSF6)->F6_CLIFOR+(cAliasSF6)->F6_LOJA+(cAliasSF6)->F6_DOC+(cAliasSF6)->F6_SERIE))

        cEmissNF	:= dtos(SF3->F3_EMISSAO)
        cNumeroNF	:= alltrim(SF3->F3_NFISCAL)
        cSerieNf	:= alltrim(SF3->F3_SERIE)
        cEspecie	:= alltrim(SF3->F3_ESPECIE)
        cTipoNf	:= iif(cEspecie=="SPED","NF-e","M")
        cChvNFe	:= alltrim(SF3->F3_CHVNFE)

        //Tipo Doc Origem
        cTpDocOrig :=	RetTpDoc( alltrim(SF3->F3_ESPECIE))
        cTpDocOrig := iif(! empty( cTpDocOrig ), cTpDocOrig,(cAliasSF6)->F6_TIPODOC)

        //Informações Fornecedor / Cliente
        aDestinat := RetDest(SF3->F3_CLIEFOR, SF3->F3_LOJA, (cAliasSF6)->F6_OPERNF, (cAliasSF6)->F6_TIPODOC, cAliasSF6)

        if len(aDestinat) > 0
          cCpfCnpj	:= allTrim(aDestinat[1,1])
          cInscDest	:= allTrim(aDestinat[1,2])
          cNomeDest	:= allTrim(aDestinat[1,3])
          cMunDest	:= allTrim(aDestinat[1,4])
          cDescMunDs	:= allTrim(aDestinat[1,5])
        endif

      endif
    endif

    cString	+= '<docorig>' + allTrim((cAliasSF6)->F6_DOC) + '</docorig>'
    cString	+= '<tipodocorig>' + allTrim(cTpDocOrig) + '</tipodocorig>'

    cString	+= '<cnpjcpfnf>'+ cCpfCnpj + '</cnpjcpfnf>'
    cString	+= '<dataemissaonf>'+ cEmissNF + '</dataemissaonf>'
    cString	+= '<numeronf>'+ cNumeroNF + '</numeronf>'
    cString	+= '<serienf>'+ cSerieNf + '</serienf>'
    cString	+= '<tiponf>'+ cTipoNf + '</tiponf>'
    cString	+= '<chavenf>'+ cChvNFe + '</chavenf>'

    cString	+= '</identgnre>'

    //Emitente
    cInsc 	 := IESubTrib(cUF)
    cEmail	 := GetNewPar("MV_EMAILGN","")

    aTelEmi	 := FisGetTel(SM0->M0_TEL)
    cFoneEmi := iif(aTelEmi[2] > 0,ConvType(aTelEmi[2],3),"") // Código da Área
    cFoneEmi += iif(aTelEmi[3] > 0,ConvType(aTelEmi[3],9),"") // Código do Telefone

    cString	+= '<emitente>'

    cString	+= '<cnpjcpf>' + SM0->M0_CGC + '</cnpjcpf>'
    cString	+= '<nome>' + ConvType(SM0->M0_NOMECOM) + '</nome>'
    cString	+= '<ie>' + cInsc + '</ie>'
    cString	+= '<endereco>' + ConvType(SM0->M0_ENDENT) + '</endereco>'
    cString	+= '<municipio>' + alltrim(SM0->M0_CODMUN) + '</municipio>'
    cString	+= '<descmun>' + alltrim(SM0->M0_CIDENT) + '</descmun>'
    cString	+= '<uf>' + alltrim(SM0->M0_ESTENT) + '</uf>'
    cString	+= '<cep>' + allTrim(SM0->M0_CEPENT) + '</cep>'
    cString	+= '<telefone>' + cFoneEmi + '</telefone>'
    cString	+= '<email>' + alltrim(cEmail) + '</email>'
    cString	+= '<inscufavorecida>' + iif(!empty(cInsc), "1","2") + '</inscufavorecida>' // Indica se tem ou não IE na UF favorecida para utilização do TSS

    cString	+= '</emitente>'

    //Valores

    nValPrinc := (cAliasSF6)->F6_VALOR
    nValTotal := (cAliasSF6)->F6_VALOR + (cAliasSF6)->F6_ATMON + (cAliasSF6)->F6_JUROS + (cAliasSF6)->F6_MULTA

    cString	+= '<valores>'

    cString	+= '<atumonetaria>'+ ConvType((cAliasSF6)->F6_ATMON,15,2)  + '</atumonetaria>'
    cString	+= '<juros>' + ConvType((cAliasSF6)->F6_JUROS,15,2) + '</juros>'
    cString	+= '<multa>' + ConvType((cAliasSF6)->F6_MULTA,15,2) + '</multa>'
    cString	+= '<valordeducao>' + ConvType((cAliasSF6)->F6_VIMPDED,15,2) + '</valordeducao>'
    cString	+= '<principal>' + ConvType(nValPrinc,15,2) + '</principal>'
    cString	+= '<total>' + ConvType(nValTotal,15,2) + '</total>'

    cString	+= '</valores>'


    //Destinatário

    cString	+= '<destinatario>'

    cString	+= '<cnpjcpf>' + cCpfCnpj + '</cnpjcpf>'
    cString	+= '<ie>' + cInscDest + '</ie>'
    cString	+= '<nome>' + ConvType(cNomeDest) + '</nome>'
    cString	+= '<municipio>' + cMunDest + '</municipio>'
    cString	+= '<descmun>' + cDescMunDs + '</descmun>'
    cString	+= '<inscufavorecida>' + iif(!empty(cInscDest), "1","2") + '</inscufavorecida>' // Indica se tem ou não IE na UF favorecida para utilização do TSS

    cString	+= '</destinatario>'


    //Referencia

    cString	+= '<referencia>'

    cString	+= '<periodo>' + iif(! empty((cAliasSF6)->F6_REF) .And. (cAliasSF6)->F6_REF$"1","0","") + '</periodo>'
    cString	+= '<mes>' + strzero((cAliasSF6)->F6_MESREF,2) + '</mes>'
    cString	+= '<ano>' + cvaltochar((cAliasSF6)->F6_ANOREF) + '</ano>'
    cString	+= '<parcela>1</parcela>'

    cString	+= '</referencia>'

    //Transporte
    cString	+= '<transporte>'

    cString	+= '<manifcarga></manifcarga>'
    cString	+= '<cti></cti>'
    cString	+= '<dtdesmbaraco></dtdesmbaraco>'
    cString	+= '<manifcarga></manifcarga>'
    cString	+= '<valoradua></valoradua>'

    cString	+= '</transporte>'

    //Sintegra
    cString	+= '<sintegra>'

    cString	+= '<protocoloTED></protocoloTED>'
    cString	+= '<justificativa></justificativa>'

    cString	+= '</sintegra>'

    //Campos Adicionais
    aInfAdic := RetCampAdic( cUF, cCodRec)

    for nX:= 1 to len( aInfAdic )

      cCodAdic := alltrim(aInfAdic [nX,1])
      cTpAdic  := alltrim(aInfAdic [nX,2])
      cValor   := RetVlrAdic( aInfAdic [nX,3], cAliasSF6 )
      lObriga  := iif( aInfAdic [nX,4]$'S', .T., .F. )
      cTitulo  := alltrim(upper(aInfAdic [nX,5]))
      cCodInt  := alltrim(aInfAdic [nX,6])

      if lObriga .or. ! empty( cValor )

        //Tratamento quando for do tipo Data
        if cTpAdic $ 'D'
          cValor := substr(cValor,1,4)+ '-' + substr(cValor,5,2) + '-' + substr(cValor,7,2)
        endif

        //Tratamento para considerar apenas uma Chave quando há mais de uma Chave cadastrada na tabela F0N
        if cCodInt == 'CHV'

          //Tratamento quando a espécie é SPED
          cEspecie	:= iif( cEspecie == 'SPED', 'NFE', cEspecie)

          if ! empty(cEspecie)
            if ! (cEspecie $  cTitulo .or. ( cEspecie == 'NFE' .and. cTitulo $ 'CHAVE DE ACESSO|CHAVE DA NOTA FISCAL ELETRONICA' ))
              lGera := .f.
            endif
          endif

        endif

        if lGera

          cExtra	+= '<campoadic>'
          cExtra	+= '<cod>' +  cCodAdic + '</cod>'
          cExtra	+= '<tipo>' + cTpAdic +'</tipo>'
          cExtra	+= '<valor>' + cValor + '</valor>'
          cExtra	+= '</campoadic>'

        endif
      endif

    next

    if ! empty( cExtra )
      cString	+= '<camposadic>'

      cString += cExtra

      cString	+= '</camposadic>'
    endif

    cString += '</gnre>'

    cString := IIf(!empty(cString),encodeUTF8(cString ), "")

  endif

return ({cId,cString})

//-----------------------------------------------------------------------
/*/{Protheus.doc} RetDest
Função retorna o Destinatário da GNRE.

@author Simone dos Santos de Oliveira
@since 26.06.2015
@version 11.80

@return	aDest		Array com informações do Destinatário.
/*/
//-----------------------------------------------------------------------
static function RetDest(cCliFor, cLjCliFor, cOper, cTpDoc, cAliasSF6)

  local aReturn		:= {}
  local cTpPessoa		:= ""
  local cCpfCnpj		:= ""
  local cInsEst		:= ""
  local cRzSocial		:= ""
  local cCodMun		:= ""


  default cCliFor		:= ""
  default cLjCliFor	:= ""
  default cOper		:= ""


  if cOper == '2' .And. !cTpDoc $ 'B|D' 	//Saída
    dbselectarea ('SA1')				//Cadastro do Cliente
    SA1->(dbsetorder (1))
    SA1->(dbseek(xFilial('SA1')+cCliFor+cLjCliFor))

    cCpfCnpj	:= alltrim( SA1->A1_CGC )
    cInsEst		:= iif(!empty(SA1->A1_INSCR) .And. alltrim(SA1->A1_INSCR)<>'ISENTO',ConvType(VldIE(SA1->A1_INSCR,.F.,.F.)),'')
    cRzSocial	:= Alltrim( SA1->A1_NOME )
    cCodMun		:= alltrim( SA1->A1_COD_MUN )
    cDescMun	:= alltrim( SA1->A1_MUN )
  else
    dbselectarea ('SA2')				//Cadastro do Cliente
    SA2->(dbsetorder (1))
    SA2->(dbseek(xFilial('SA2')+(cAliasSF6)->F6_CLIFOR+(cAliasSF6)->F6_LOJA))

    cCpfCnpj	:= alltrim( SA2->A2_CGC )
    cInsEst		:= iif(!empty(SA2->A2_INSCR) .And. alltrim(SA2->A2_INSCR)<>'ISENTO',ConvType(VldIE(SA2->A2_INSCR,.F.,.F.)),'')
    cRzSocial	:= alltrim( SA2->A2_NOME )
    cCodMun		:= alltrim( SA2->A2_COD_MUN )
    cDescMun	:= alltrim( SA2->A2_MUN )
  endif

//Preenchimento do Array
  aadd(aReturn,{ cCpfCnpj,;
    cInsEst,;
    cRzSocial,;
    cCodMun,;
    cDescMun})

return aReturn
//-----------------------------------------------------------------------
/*/{Protheus.doc} ConvType

@author Simone dos Santos de Oliveira
@since 26.06.2015
@version 11.80

/*/
//-----------------------------------------------------------------------
static function ConvType(xValor,nTam,nDec)

  local cNovo 	:= ''

  default nDec 	:= 0

  do case
  case valtype(xValor)=='N'
    if xValor <> 0
      cNovo := AllTrim(Str(xValor,nTam,nDec))
    else
      cNovo := '0'
    endif
  case valtype(xValor)== 'D'
    cNovo := FsDateConv(xValor,'YYYYMMDD')
    cNovo := substr(cNovo,1,4)+'-'+substr(cNovo,5,2)+'-'+substr(cNovo,7)
  case valtype(xValor)=='C'
    if nTam == nil
      xValor := AllTrim(xValor)
    endif

    default nTam := 60

    cNovo := AllTrim(EnCodeUtf8(NoAcento(substr(xValor,1,nTam))))
  endcase

return(cNovo)

//-----------------------------------------------------------------------
/*/{Protheus.doc} RetDest
Função retorna as informações extras referente à gnre.

@author Simone dos Santos de Oliveira
@since 03/03/2016
@version 11.80

/*/
//-----------------------------------------------------------------------
static function RetCampAdic( cUF, cCodRec )

  local aInfExtra		:= {}

  local cCodEx		:= ''
  local cTipo			:= ''
  local cValor		:= ''
  local cWhere		:= ''
  local cFiltro		:= ''
  local cIndex		:= ''
  local cAmbiente		:= alltrim(GetNewPar('MV_AMBGNRE','2'))
  local cAliasF0N		:= 'F0N'

  local nX			:= 0

  default cUF			:= ''
  default cCodRec		:= ''


  if !( empty(cUF) .and. empty(cCodRec) .and. empty(cAmbiente) )

    dbselectarea('F0N')
    F0N->(dbsetorder(1))

    #IFDEF TOP

      if (TcSrvType ()<>"AS/400")
        lQuery    := .T.
        cAliasF0N := GetNextAlias()

        cWhere := "%"
        cWhere += "F0N.F0N_FILIAL = '"+xFilial ("F0N")+"' AND"
        cWhere += " F0N.F0N_UF = '"+ cUF +"' AND F0N.F0N_CODREC = '"+ cCodRec +"' "
        cWhere += " AND F0N.F0N_AMBWS = '" + cAmbiente + "' "
        cWhere += "AND F0N.D_E_L_E_T_ = '' "
        cWhere += "%"


        BeginSql Alias cAliasF0N
				SELECT * FROM %Table:F0N% F0N WHERE %Exp:cWhere%	ORDER BY %Order:F0N%
        EndSql

      else
      #EndIf
      cIndex  := CriaTrab(NIL,.F.)
      cFiltro := 'F0N_FILIAL=="'+xFilial ("F0N")+'".And.'
      cFiltro += 'F0N_UF =="'+ cUF +'".And. F0N_CODREC =="'+ cCodRec +'" '
      cFiltro += '.And. F0N_AMBWS == "'+cAmbiente+'" '
      indregua (cAliasF0N, cIndex, F0N->(IndexKey ()),, cFiltro)
      nIndex := retindex(cAliasF0N)
      #IFNDEF TOP
        dbSetIndex(cIndex+OrdBagExt())
      #ENDIF
      dbSelectArea (cAliasF0N)
      dbSetOrder (nIndex+1)
      #IFDEF TOP
      endif
    #EndIf

    dbSelectArea (cAliasF0N)
    (cAliasF0N)->(dbGoTop ())

    while !(cAliasF0N)->(eof ())

      aadd(aInfExtra,{})
      nX := len(aInfExtra)

      aadd(aInfExtra[nX],(cAliasF0N)->F0N_CODSEF)
      aadd(aInfExtra[nX],(cAliasF0N)->F0N_TIPO)
      aadd(aInfExtra[nX],(cAliasF0N)->F0N_CODINT)
      aadd(aInfExtra[nX],(cAliasF0N)->F0N_OBRIGA)
      aadd(aInfExtra[nX],(cAliasF0N)->F0N_TITULO)
      aadd(aInfExtra[nX],(cAliasF0N)->F0N_CODINT)

      (cAliasF0N)->(dbSkip())
    enddo
  endif

  #IFDEF TOP
    dbSelectArea(cAliasF0N)
    dbCloseArea()
  #ELSE
    dbSelectArea(cAliasF0N)
    retindex(cAliasF0N)
    ferase(nIndex+OrdBagExt())
  #ENDIF

return aInfExtra

//-----------------------------------------------------------------------
/*/{Protheus.doc} RetVlrAdic
Função retorna o campo conforme Código interno apresentado na tabela F0N

@author Simone dos Santos de Oliveira
@since 03/03/2016
@version 11.80

/*/
//-----------------------------------------------------------------------
static function RetVlrAdic( cCodInterno, cAliasSF6 )

  local cValAdic	:= ''
  local cCampo		:= ''

  default cCodInterno := ''

  if ! empty(cCodInterno)

    do case
    case cCodInterno $ 'OBS' 												//Observação
      cValAdic	:= (cAliasSF6)->(FieldGet(FieldPos('F6_OBSERV')))

    case cCodInterno $ 'INF' 												//Informação Complementar
      cValAdic	:= (cAliasSF6)->(FieldGet(FieldPos('F6_INF')))

    case cCodInterno $ 'CHV' 												//Chave NF-e / DF-e / Ct-e
      cValAdic	:= SF3->(FieldGet(FieldPos('F3_CHVNFE')))

    case cCodInterno $ 'DEM#DSA' 											//Data de Emissão NF#Data Saída
      cValAdic	:= SF3->(FieldGet(FieldPos('F3_EMISSAO')))
      cValAdic	:= iif(! empty(cValAdic), dtos(cValAdic), '')

    case cCodInterno $ 'DET'  												//Detalhamento da Receita
      cValAdic	:= (cAliasSF6)->(FieldGet(FieldPos('F6_DETRECE')))

    case cCodInterno $ 'NNF'  												//Num. NF
      cValAdic	:= SF3->(FieldGet(FieldPos('F3_NFISCAL')))

    case cCodInterno $ 'ATM'  												//Atualização Monetária
      cValAdic	:= (cAliasSF6)->(FieldGet(FieldPos('F6_ATMON')))
      cValAdic	:= ConvType(cValAdic,15,2)

    case cCodInterno $ 'NRE' 		 										//Nome Remetente
      cValAdic	:= SM0->(FieldGet(FieldPos('M0_NOMECOM')))

    case cCodInterno $ 'CNP'  												//CNPJ Remetente
      cValAdic	:= SM0->(FieldGet(FieldPos('M0_CGC')))

    case cCodInterno $ 'JRS'  												//Juros
      cValAdic	:= (cAliasSF6)->(FieldGet(FieldPos('F6_JUROS')))
      cValAdic	:= ConvType(cValAdic,15,2)

    case cCodInterno $ 'MLT'  												//Multa
      cValAdic	:= (cAliasSF6)->(FieldGet(FieldPos('F6_MULTA')))
      cValAdic	:= ConvType(cValAdic,15,2)

    case cCodInterno $ 'MOR'  												//Municipio de Origem
      cValAdic	:= SM0->(FieldGet(FieldPos('M0_CODMUN')))

    case cCodInterno $ 'CRG#CNA#CIN#DES#GST#MCR#PCA#PTS#VLD'				//Carga#Cnae#Conhec. Interno#Cnae#Dt Desembaraço#Guia ST#Manif. de Carga#Placa Caminhão#Prot. de caminhão#Valor Aduaneiro
      cCampo		:= RetNwCmp( cCodInterno )
      cValAdic	:= iif(! empty(cCampo), (cAliasSF6)->(FieldGet(FieldPos(cCampo))),'')

    otherwise
      cValAdic	:= ' '

    endCase
  endif

return cValAdic

//-----------------------------------------------------------------------
/*/{Protheus.doc} RetNwCmp
Função retorna campo que não é tratado por padrão no sistema

@author Simone dos Santos de Oliveira
@since 03/03/2016
@version 11.80

/*/
//-----------------------------------------------------------------------
static function RetNwCmp( cCdInt )

  local cValAdc		:= ''
  local cMVNWCODGN	:= alltrim(GetNewPar('MV_NWCODGN',' '))

  default cCdInt	:= ''

  if !(empty( cCdInt ) .and. empty( cMVNWCODGN )) .and. ( cCdInt $ cMVNWCODGN)

    cValAdc := substr(cMVNWCODGN,at(cCdInt,cMVNWCODGN),at('/',cMVNWCODGN)-1)
    cValAdc := substr(cValAdc,at('F6',cValAdc),len(cValAdc))

  endif

return cValAdc


//-----------------------------------------------------------------------
/*/{Protheus.doc} RetTpDoc
Função retorna tipo de documento de origem

@author Simone dos Santos de Oliveira
@since 06/04/2016
@version 11.80

/*/
//-----------------------------------------------------------------------
static function RetTpDoc( cEspecie )

  local cTipoDoc	:= ''

  default cEspecie	:= ''

  if ! empty( cEspecie )
    do case
    case alltrim( cEspecie )== "NFA"
      cTipoDoc := '01'
    case Alltrim( cEspecie )$ "NF/SPED/NTST/NFCEE"
      cTipoDoc := '10'
    case Alltrim( cEspecie )== "CA"
      cTipoDoc := '08'
    case Alltrim( cEspecie )$ "CTR/CTE"
      cTipoDoc := '07'
    OtherWise
      cTipoDoc := ''
    endcase
  endif


return cTipoDoc