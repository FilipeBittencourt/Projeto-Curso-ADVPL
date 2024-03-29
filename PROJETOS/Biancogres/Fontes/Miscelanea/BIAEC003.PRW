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
	Private aMeses := {"Janeiro","Fevereiro","Mar鏾","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"}

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
	oFont5 := TFont():New("Arial"   	 	,12,10,.T.,.T.,5,.T.,5,.T.,.F.) // Arial   12 Bold  - Cabe鏰lho Ficha de Compra
	oFont6 := TFont():New("Arial"   	 	,12,10,.T.,.F.,5,.T.,5,.T.,.F.) // Arial   12 Plain  - Cabe鏰lho Ficha de Compra
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

/*北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北 Descricao:  CONSULTA DOS DADOS PARA O RELATORIO                         北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�*/
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

		oPrint:Say  (nLinha,lPosCol1+50,"DECLARA敲O DE RESPONSABILIDADE DO TRANSPORTADOR/MOTORISTA",oFont7)
		nLinha += 2*nSalto   

		oPrint:Say  (nLinha,lPosCol1,"Eu, "+ALLTRIM((cQry)->ZZV_MOTOR)+" , motorista devidamente",oFont8)
		nLinha += nSalto   
		oPrint:Say  (nLinha,lPosCol1,"habilitado conforme Carteira de Habilita玢o n� "+ALLTRIM((cQry)->ZZV_DOCMOT)+"",oFont8)
		nLinha += nSalto   
		oPrint:Say  (nLinha,lPosCol1,"respons醰el pelo ve韈ulo Placa  "+ALLTRIM((cQry)->ZZV_PLACA)+" declaro para todos",oFont8)
		 nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"os fins de direito, que os produtos descritos na(s)",oFont8)
         nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"nota(s) fiscal(is) abaixo relacionada(s) est鉶",oFont8)
         nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"adequadamente acondicionados para transporte, estando",oFont8)
         nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"a carga distribu韉a na carroceria de maneira uniforme",oFont8)
         nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"sobre os eixos do ve韈ulo, sendo este ve韈ulo adequado",oFont8)
         nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"para suportar o peso da carga e os riscos normais de",oFont8)
         nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"carregamento, descarregamento, transbordo e transporte",oFont8)
         nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"terrestre nas rodovias estaduais e federais que ir�",oFont8)
         nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"transitar, tudo de acordo com a legisla玢o espec韋ica;",oFont8)
         nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"declaro que a carga constante da(s) referida(s)",oFont8)
         nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"nota(s) fiscal(is) n鉶 excede o peso bruto total e nem",oFont8)
         nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"o peso permitido entre eixos, adequando-se ao limite",oFont8)
         nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"legalmente permitido para este tipo de ve韈ulo;",oFont8)
         nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"declaro ter ci阯cia do trajeto a ser seguido, sendo de",oFont8)
         nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"minha inteira responsabilidade qualquer penalidade,",oFont8)
         nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"fiscal ou de tr鈔sito, que decorra da inobserv鈔cia do",oFont8)
         nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"trajeto original, excetuados os casos de for鏰 maior;",oFont8)
         nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"declaro, por fim, que n鉶 assumirei novas cargas que",oFont8)
         nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"comprometam a capacidade total e/ou entre eixos do",oFont8)
         nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"ve韈ulo, sendo de minha inteira responsabilidade",oFont8)
         nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"eventuais penalidades decorrentes do excesso de peso",oFont8)
        nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"total e/ou entre eixos quando o peso aferido pela",oFont8)
        nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"fiscaliza玢o for superior ao peso aferido na sa韉a do",oFont8)
        nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"estabelecimento de embarque.",oFont8)

        nLinha += nSalto
        oPrint:Say  (nLinha,lPosCol1+20,"Tamb閙 autorizo expressamente o tratamento dos meus",oFont8)
        nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"dados pessoais e meus dados pessoais sens韛eis tais",oFont8)
        nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"como, nome, data de nascimento e/ou idade, sexo,",oFont8)
        nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"nacionalidade, estado civil, n鷐ero e c髉ia dos",oFont8)
        nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"documentos de identifica玢o profissional, CPF, RG,",oFont8)
        nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"RNE, PIS, CTPS, habilita珲es, contrato de trabalho,",oFont8)
        nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"fun玢o/cargo, matr韈ula, fotografia, endere鏾 de",oFont8)
        nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"resid阯cia, e-mail, telefones para contato e repasse",oFont8)
        nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"perante os 觬g鉶s P鷅licos, incluindo os Judiciais e",oFont8)
        nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"Administrativos, Seguradoras e Planos de Sa鷇e,",oFont8)
        nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"Empresa de Transporte, visando o fiel cumprimento das",oFont8)
        nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"obriga珲es de natureza contratual, trabalhista,",oFont8)
        nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"previdenci醨ia, tribut醨ia, c韛el, em harmonia com a",oFont8)
        nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"Lei n. 13.709/2018 e com o inciso XII do Artigo 5� da",oFont8)
        nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"Constitui玢o Federal. Declaro que, em caso de",oFont8)
        nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"revoga玢o da autoriza玢o e/ou altera玢o dos dados, o",oFont8)
        nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"farei mediante comunica玢o por escrito, expressamente",oFont8)
        nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"e informando quais os dados autorizados devem ser",oFont8)
        nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"exclu韉os e/ou quais foram alterados. Concordo ainda",oFont8)
        nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"que os dados eventualmente n鉶 descritos neste",oFont8)
        nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"documento e fornecidos por livre e espont鈔ea vontade",oFont8)
        nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"encontram-se tamb閙 expressamente autorizados, sem",oFont8)
        nLinha += nSalto
		oPrint:Say  (nLinha,lPosCol1,"necessidade de celebra玢o de novo termo.",oFont8)
        

		nLinha += 2*nSalto
		oPrint:Say  (nLinha,lPosCol1+50,"Serra, "+SUBSTR(DTOS(dDataBase),7,2)+" de "+aMeses[VAL(SUBSTR(DTOS(dDataBase),5,2))]+" de "+SUBSTR(DTOS(dDataBase),1,4),oFont5) 
		nLinha += 2*nSalto
		oPrint:Say  (nLinha,lPosCol1+50,"Assinatura:_____________________________________",oFont5) 
		nLinha += 2*nSalto                                                                         
		oPrint:Say  (nLinha,lPosCol1+50,"Rela玢o das notas fiscais: ",oFont5) 


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
