#include "rwmake.ch"
#include "protheus.ch"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAEC003
@description TERMO DE RESPONSABILIDADE - CONTROLE DE CARGAS
@author Fernando Rocha
@since 18/02/2011
@version 1.0
@type function
/*/
User Function BIAEC003()

	Private Titulo       := "Termo de Responsabilidade"
	Private wnPag :=0
	Private wnLin
	Private oPrint
	Private nLinha := 0
	Private nSalto := 55

	//Colunas             
	Private lPosCol1 := 070

	//LINHA INICIAL
	Private nRow1 := 050

	//LINHA VERTICAL
	Private nLeft   := 030        // Margem esquerda
	Private nTopo   := 050       // Linha do Topo
	Private nBase   := 050      // Linha da Base

	//Retrato A4
	Private lLimV := 3700
	Private lLimH := 2350

	//PAISAGEM A4
	//Private lLimV := 2300          
	//Private lLimH := 3330       

	//ESPECIFICOS
	Private aMeses := {"Janeiro","Fevereiro","Março","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"}

	Private cQry := GetNextAlias()

	//CONFIGURACOES DO RELATORIO
	#IFDEF WINDOWS
	Processa({|| RptDetail()})
Return

Static Function RptDetail()
	#ENDIF

	oPrint:= TMSPrinter():New(Titulo)
	oPrint:SetPortrait()
	//oPrint:SetLandScape()

	//Definicao das fontes
	oFont5 := TFont():New("Arial"   	 	,12,10,.T.,.T.,5,.T.,5,.T.,.F.) // Arial   12 Bold  - Cabeçalho Ficha de Compra
	oFont6 := TFont():New("Arial"   	 	,12,10,.T.,.F.,5,.T.,5,.T.,.F.) // Arial   12 Plain  - Cabeçalho Ficha de Compra
	oFont7 := TFont():New("Arial"   	 	,15,15,.T.,.T.,5,.T.,5,.T.,.F.) // Arial   18 Bold
	oFont8 := TFont():New("Courier New"	 	,18,18,.T.,.F.,5,.T.,5,.T.,.F.) // Arial   15 Plain

	fQuery() 

	IF (cQry)->(Eof()) 
		MsgAlert("Sem Dados!"+CHR(13)+"Carga inexistente.")
		Return
	ENDIF

	fImpDet()

	oPrint:Preview()

Return

//Descricao: Funcao que imprime o cabecalho do relatorio  na primeira
Static Function fImpCabec()

	oPrint:StartPage()        

	wnPag ++
	wnLin := 1

	//Linha vertical esquerda
	oPrint:Line (nTopo, nLeft,  nBase+lLimV  , nLeft)//(linha, coluna, linha, coluna)
	//Linha vertical direita
	oPrint:Line (nTopo, nLeft+lLimH,  nBase+lLimV  , nLeft+lLimH)
	//Linha horizontal do topo
	oPrint:Line (nRow1, nLeft, nRow1, nLeft+lLimH)
	//Linha horizontal da base
	oPrint:Line (nRow1+lLimV,  nLeft, nRow1+lLimV, nLeft+lLimH)

Return

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±± Descricao:  CONSULTA DOS DADOS PARA O RELATORIO                         ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function fQuery()

	Local cZZV := RetSqlName("ZZV")
	Local cSQL := ""

	cSQL+="SELECT * FROM "+cZZV+" ZZV WHERE ZZV_CARGA = "+ ValToSQL(ZZV->ZZV_CARGA)

	If Select(cQry) > 1
		(cQry)->(DbCloseArea())
	EndIf

	TcQuery cSQL New Alias (cQry)

	DbselectArea(cQry)

Return                         


//IMPRIMIR OS DADOS DO DETALHE
Static Function fImpDet()       

	Local cAliasTmp   
	Local I   

	While .Not. (cQry)->(Eof())     

		oPrint:StartPage()
		fImpCabec()  

		nLinha += nSalto

		oPrint:Say  (nLinha,lPosCol1+50,"DECLARAÇÃO DE RESPONSABILIDADE DO TRANSPORTADOR/MOTORISTA",oFont7)
		nLinha += 2*nSalto   

		oPrint:Say  (nLinha,lPosCol1,"Eu, "+ALLTRIM((cQry)->ZZV_MOTOR)+" , motorista devidamente",oFont8)
		nLinha += nSalto   
		oPrint:Say  (nLinha,lPosCol1,"habilitado conforme Carteira de Habilitação nº "+ALLTRIM((cQry)->ZZV_DOCMOT)+"",oFont8)
		nLinha += nSalto   
		oPrint:Say  (nLinha,lPosCol1,"responsável pelo veículo Placa  "+ALLTRIM((cQry)->ZZV_PLACA)+" declaro para todos",oFont8)
		 nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"os fins de direito, que os produtos descritos na(s)",oFont8)
         nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"nota(s) fiscal(is) abaixo relacionada(s) estão",oFont8)
         nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"adequadamente acondicionados para transporte, estando",oFont8)
         nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"a carga distribuída na carroceria de maneira uniforme",oFont8)
         nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"sobre os eixos do veículo, sendo este veículo adequado",oFont8)
         nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"para suportar o peso da carga e os riscos normais de",oFont8)
         nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"carregamento, descarregamento, transbordo e transporte",oFont8)
         nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"terrestre nas rodovias estaduais e federais que irá",oFont8)
         nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"transitar, tudo de acordo com a legislação específica;",oFont8)
         nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"declaro que a carga constante da(s) referida(s)",oFont8)
         nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"nota(s) fiscal(is) não excede o peso bruto total e nem",oFont8)
         nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"o peso permitido entre eixos, adequando-se ao limite",oFont8)
         nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"legalmente permitido para este tipo de veículo;",oFont8)
         nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"declaro ter ciência do trajeto a ser seguido, sendo de",oFont8)
         nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"minha inteira responsabilidade qualquer penalidade,",oFont8)
         nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"fiscal ou de trânsito, que decorra da inobservância do",oFont8)
         nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"trajeto original, excetuados os casos de força maior;",oFont8)
         nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"declaro, por fim, que não assumirei novas cargas que",oFont8)
         nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"comprometam a capacidade total e/ou entre eixos do",oFont8)
         nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"veículo, sendo de minha inteira responsabilidade",oFont8)
         nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"eventuais penalidades decorrentes do excesso de peso",oFont8)
        nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"total e/ou entre eixos quando o peso aferido pela",oFont8)
        nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"fiscalização for superior ao peso aferido na saída do",oFont8)
        nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"estabelecimento de embarque.",oFont8)

        nLinha += nSalto
        oPrint:Say  (nLinha,lPosCol1+20,"Também autorizo expressamente o tratamento dos meus",oFont8)
        nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"dados pessoais e meus dados pessoais sensíveis tais",oFont8)
        nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"como, nome, data de nascimento e/ou idade, sexo,",oFont8)
        nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"nacionalidade, estado civil, número e cópia dos",oFont8)
        nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"documentos de identificação profissional, CPF, RG,",oFont8)
        nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"RNE, PIS, CTPS, habilitações, contrato de trabalho,",oFont8)
        nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"função/cargo, matrícula, fotografia, endereço de",oFont8)
        nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"residência, e-mail, telefones para contato e repasse",oFont8)
        nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"perante os Órgãos Públicos, incluindo os Judiciais e",oFont8)
        nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"Administrativos, Seguradoras e Planos de Saúde,",oFont8)
        nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"Empresa de Transporte, visando o fiel cumprimento das",oFont8)
        nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"obrigações de natureza contratual, trabalhista,",oFont8)
        nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"previdenciária, tributária, cível, em harmonia com a",oFont8)
        nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"Lei n. 13.709/2018 e com o inciso XII do Artigo 5º da",oFont8)
        nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"Constituição Federal. Declaro que, em caso de",oFont8)
        nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"revogação da autorização e/ou alteração dos dados, o",oFont8)
        nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"farei mediante comunicação por escrito, expressamente",oFont8)
        nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"e informando quais os dados autorizados devem ser",oFont8)
        nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"excluídos e/ou quais foram alterados. Concordo ainda",oFont8)
        nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"que os dados eventualmente não descritos neste",oFont8)
        nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"documento e fornecidos por livre e espontânea vontade",oFont8)
        nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"encontram-se também expressamente autorizados, sem",oFont8)
        nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"necessidade de celebração de novo termo.",oFont8)
        

		nLinha += 2*nSalto
		oPrint:Say  (nLinha,lPosCol1+50,"Serra, "+SUBSTR(DTOS(dDataBase),7,2)+" de "+aMeses[VAL(SUBSTR(DTOS(dDataBase),5,2))]+" de "+SUBSTR(DTOS(dDataBase),1,4),oFont5) 
		nLinha += 2*nSalto
		oPrint:Say  (nLinha,lPosCol1+50,"Assinatura:_____________________________________",oFont5) 
		nLinha += 2*nSalto                                                                         
		oPrint:Say  (nLinha,lPosCol1+50,"Relação das notas fiscais: ",oFont5) 


		cAliasTmp := GetNextAlias()

		cSQL := ""+CRLF
		cSQL += " with "+CRLF
		cSQL += " tab_carga as ( "+CRLF
		cSQL += " select * from FNC_CARGA_EMP('"+AllTrim(CEMPANT)+AllTrim(CFILANT)+"','"+(cQry)->ZZV_CARGA+"','"+(cQry)->ZZV_TICKET+"') "+CRLF
		cSQL += " ), "+CRLF
		cSQL += " tab_nf as ( "+CRLF
		cSQL += " select DOC = C9_NFISCAL "+CRLF 
		cSQL += " from SC9010 "+CRLF
		cSQL += " where C9_AGREG in (select CARGA from tab_carga where EMPRESA = '0101') "+CRLF 
		cSQL += " and C9_CLIENTE <> '010064' "+CRLF
		cSQL += " and D_E_L_E_T_ = '' "+CRLF
		cSQL += " union all "+CRLF
		cSQL += " select DOC = C97.C9_NFISCAL "+CRLF 
		cSQL += " from SC9010 C9 "+CRLF
		cSQL += " join SC9070 C97 on C97.C9_BLINF = ('01'+C9.C9_NFISCAL+C9.C9_SERIENF+C9.C9_PEDIDO+C9.C9_ITEM+C9.C9_SEQUEN) "+CRLF 
		cSQL += " where C9.C9_AGREG in (select CARGA from tab_carga where EMPRESA = '0101') "+CRLF
		cSQL += " and C9.C9_CLIENTE = '010064' "+CRLF
		cSQL += " and C9.D_E_L_E_T_ = '' "+CRLF
		cSQL += " and C97.D_E_L_E_T_ = '' "+CRLF
		cSQL += " union all "+CRLF
		cSQL += " select DOC = C9_NFISCAL "+CRLF 
		cSQL += " from SC9050 "+CRLF 
		cSQL += " where C9_AGREG in (select CARGA from tab_carga where EMPRESA = '0501') "+CRLF 
		cSQL += " and C9_CLIENTE <> '010064' "+CRLF 
		cSQL += " and D_E_L_E_T_ = '' "+CRLF 
		cSQL += " union all "+CRLF 
		cSQL += " select DOC = C97.C9_NFISCAL "+CRLF 
		cSQL += " from SC9050 C9 "+CRLF 
		cSQL += " join SC9070 C97 on C97.C9_BLINF = ('05'+C9.C9_NFISCAL+C9.C9_SERIENF+C9.C9_PEDIDO+C9.C9_ITEM+C9.C9_SEQUEN) "+CRLF 
		cSQL += " where C9.C9_AGREG in (select CARGA from tab_carga where EMPRESA = '0501') "+CRLF 
		cSQL += " and C9.C9_CLIENTE = '010064' "+CRLF 
		cSQL += " and C9.D_E_L_E_T_ = '' "+CRLF 
		cSQL += " and C97.D_E_L_E_T_ = '') "+CRLF 
		cSQL += " select distinct DOC from tab_nf order by DOC "+CRLF

		TcQuery cSQL New Alias (cAliasTmp)	

		While !(cAliasTmp)->(Eof())

			nLinha += nSalto
			_nColT := lPosCol1+50

			FOR I := 1 To 5  
				If !(cAliasTmp)->(Eof())
					oPrint:Say  (nLinha,_nColT,(cAliasTmp)->DOC,oFont6) 
					_nColT += 300
					(cAliasTmp)->(DbSkip())
				Else        
					exit
				EndIf			
			NEXT                        

		EndDo

		(cAliasTmp)->(DbCloseArea())

		(cQry)->(DbSkip())
	Enddo

return
