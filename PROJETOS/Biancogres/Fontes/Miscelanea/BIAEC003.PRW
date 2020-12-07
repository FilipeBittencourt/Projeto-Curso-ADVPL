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
	Private lLimV := 3000
	Private lLimH := 2290

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

		nLinha += 10*nSalto

		oPrint:Say  (nLinha,lPosCol1+100,"DECLARAÇÃO DE RESPONSABILIDADE DO TRANSPORTADOR/MOTORISTA",oFont7)
		nLinha += 4*nSalto   

		oPrint:Say  (nLinha,lPosCol1,"Eu, "+ALLTRIM((cQry)->ZZV_MOTOR)+" , motorista devidamente",oFont8)
		nLinha += nSalto   
		oPrint:Say  (nLinha,lPosCol1,"habilitado conforme Carteira de Habilitação nº "+ALLTRIM((cQry)->ZZV_DOCMOT)+"",oFont8)
		nLinha += nSalto   
		oPrint:Say  (nLinha,lPosCol1,"responsável pelo veículo Placa  "+ALLTRIM((cQry)->ZZV_PLACA)+" declaro para todos",oFont8)
		nLinha += nSalto   
		oDanfe:Say  (nLinha,nPosCol1,"os fins de direito, que os produtos descritos na(s) nota(s)",oFont8)
		nLinha += nSalto   
		oDanfe:Say  (nLinha,nPosCol1,"fiscal(is)  abaixo  relacionada(s)  estão   adequadamente",oFont8)
		nLinha += nSalto   	
		oDanfe:Say  (nLinha,nPosCol1,"acondicionados   para   transporte,  estando a  carga dis-",oFont8)
		nLinha += nSalto   
		oDanfe:Say  (nLinha,nPosCol1,"tribuída na carroceria de maneira uniforme sobre os  eixos",oFont8)
		nLinha += nSalto   
		oDanfe:Say  (nLinha,nPosCol1,"do  veículo, sendo este veículo adequado  para  suportar o",oFont8)
		nLinha += nSalto   
		oDanfe:Say  (nLinha,nPosCol1,"peso da carga e os riscos normais de carregamento, descar-",oFont8)
		nLinha += nSalto   
		oDanfe:Say  (nLinha,nPosCol1,"regamento, transbordo e transporte terrestre nas  rodovias",oFont8)
		nLinha += nSalto   
		oDanfe:Say  (nLinha,nPosCol1,"estaduais e federais que irá transitar, tudo de acordo com",oFont8)
		nLinha += nSalto
		oDanfe:Say  (nLinha,nPosCol1,"a legislação específica, declarando que  a  carga constante",oFont8)
		nLinha += nSalto
		oDanfe:Say  (nLinha,nPosCol1,"da(s) referida(s) nota(s) fiscal(is) não excede o peso bruto",oFont8)
		nLinha += nSalto
		oDanfe:Say  (nLinha,nPosCol1,"total e nem ao peso  permitido  entre  eixo, adequando-se",oFont8)
		nLinha += nSalto
		oDanfe:Say  (nLinha,nPosCol1,"ao limite legalmente permitido  para  este tipo de veículo;",oFont8)
		nLinha += nSalto
		oDanfe:Say  (nLinha,nPosCol1,"declaro ter ciência do trajeto a ser seguido sendo de minha",oFont8)
		nLinha += nSalto
		oDanfe:Say  (nLinha,nPosCol1,"inteira responsabilidade qualquer penalidade, fiscal ou de",oFont8)
		nLinha += nSalto
		oDanfe:Say  (nLinha,nPosCol1,"trânsito, que decorra da inobservância do trajeto original,",oFont8)
		nLinha += nSalto
		oDanfe:Say  (nLinha,nPosCol1,"excetuados os casos de força maior; declaro, por fim, que,",oFont8)
		nLinha += nSalto
		oDanfe:Say  (nLinha,nPosCol1,"não assumirei novas cargas que comprometam a capacidade,",oFont8)
		nLinha += nSalto
		oDanfe:Say  (nLinha,nPosCol1,"total e/ou entre eixos do veículo, sendo de minha inteira",oFont8)
		nLinha += nSalto
		oDanfe:Say  (nLinha,nPosCol1,"responsabilidade  eventuais  penalidades  decorrentes do",oFont8)
		nLinha += nSalto
		oDanfe:Say  (nLinha,nPosCol1,"excesso de peso total e/ou entre eixos quando o peso afe-",oFont8)
		nLinha += nSalto
		oDanfe:Say  (nLinha,nPosCol1,"rido pela  fiscalização  for  superior ao peso aferido na",oFont8)
		nLinha += nSalto
		oDanfe:Say  (nLinha,nPosCol1,"saída do estabelecimento de embarque",oFont8)
		
		nLinha += 4*nSalto
		oPrint:Say  (nLinha,lPosCol1+50,"Serra, "+SUBSTR(DTOS(dDataBase),7,2)+" de "+aMeses[VAL(SUBSTR(DTOS(dDataBase),5,2))]+" de "+SUBSTR(DTOS(dDataBase),1,4),oFont5) 
		nLinha += 4*nSalto
		oPrint:Say  (nLinha,lPosCol1+50,"Assinatura:_____________________________________",oFont5) 
		nLinha += 4*nSalto                                                                         
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
