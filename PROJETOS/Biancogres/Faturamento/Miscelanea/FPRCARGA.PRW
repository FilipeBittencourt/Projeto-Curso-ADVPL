#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "PARMTYPE.CH" 
#INCLUDE "TOPCONN.CH"

User Function FPRCARGA(cCodCarga, lJob, lTermo)

	Default lJob 			:= .F.
	Default lTermo			:= .T.

	If (lJob)
		U_CARGA01(cCodCarga, lJob, lTermo)
	Else
		Processa( {|| U_CARGA01(cCodCarga, lJob, lTermo) }, "Carga", "Processando danfe das notas fiscais da carga...", .T.)
	EndIf

Return

User Function CARGA01(_cCarga, lJob, lTermo)

	Local aList			:= Nil
	oTDadosCarga		:= TDadosCarga():New(_cCarga)
	aList 				:= oTDadosCarga:GetListaNF()

	StartJob("U_NFCARPDF", GetEnvServer(), .T., _cCarga, cEmpAnt, cFilAnt, aList, lJob, lTermo)
	
	//U_NFCARPDF(_cCarga, cEmpAnt, cFilAnt, aList, lJob, lTermo)

Return 

User Function NFCARPDF( _cCarga, _cEmpOri, _cFilOri, aListNota, lJob, lTermo) 

	Local cIdEnt 		:= ""
	Local oDanfe		:= Nil
	Local oSetup		:= Nil
	Local cNomeArq		:= ""
	Local cPathArq		:= ""	
	Local lAchou		:= .F.

	Local nI			:= 0
	Local cEmpOri		:= _cEmpOri
	Local cFilOri		:= _cFilOri
	Local cEmpNF		:= ""
	Local cFilNF		:= ""
	Local cData			:= ""
	Local cLocal		:= ""

	Default lTermo		:= .T.

	If (Len(aListNota) > 0)
		cData := aListNota[1][4]
	EndIF

	//TODO CRIAR PARAMETRO LOCAL	
	If (lJob)
		cLocal		:= "\P10\AUTOMACAO\MONITOR_IMPRESSAO\"
		cNomeArq	:= Upper(AllTrim(_cCarga)+'_'+AllTrim(cEmpOri) + '_DANFE')
	Else
		cLocal		:= "\P10\AUTOMACAO\DANFE\TEMP\"

		dataForm := cData
		//Ticket 34053 - alteração no formato da data que vai pro nome do arquivo por solicitação da DocSystem para comunicação entre sistemas.
		//Exemplo do formato desejado: 01_INSF_02072021
		If .Not. Empty(Alltrim(cData))
			dataD := StoD(cData)
			dataForm := Day2Str(dataD)+Month2Str(dataD)+Year2Str(dataD)
		EndIf

		cNomeArq	:= Upper(AllTrim(cEmpOri)+"_"+AllTrim(_cCarga)+'_'+AllTrim(dataForm))
	EndIf

	oDanfe := FWMSPrinter():New(cNomeArq, IMP_PDF, .F., '\spool\', .T., , ,, .T., .F.)

	oDanfe:lViewPDF		:= .F.
	oDanfe:cPathPDF		:= cLocal
	oDanfe:lServer  	:= .T.

	//Todas empresas que tem a carga 
	For nI:=1 To Len (aListNota)
		
		lAchou	:= .T.
		
		cEmpNF	:= aListNota[nI][1]
		cNota	:= aListNota[nI][2]
		cSerie	:= aListNota[nI][3]

		RPCSetType(3)
		RPCSetEnv(cEmpNF, "01")

		cIdEnt		:= GetCfgEntidade()

		u_fautdanfe(cIdEnt ,/*cVal1*/ ,/*cVal2*/ ,oDanfe , oSetup, cNomeArq, cNota, cSerie)

		RpcClearEnv()

	Next nI		

	If ( lTermo ) 

		RPCSetType(3)
		RPCSetEnv(cEmpOri, cFilOri)

		ImpTermo(oDanfe, _cCarga)

		RpcClearEnv()

	EndIf
	
	If lAchou
	
		oDanfe:Print()
	
	Else
	
		ConOut("FPRCARGA -> TDadosCarga() não retornou dados!" )
	
	EndIf
	
	FreeObj(oDanfe)

	oDanfe := Nil

Return()

Static Function ImpTermo(oDanfe, _cCarga)

	Local nSalto 		:= 16
	Local nLinha 		:= 20
	Local nPosCol1 		:= 20
	Local cAliasTmp		:= Nil
	Local cAliasZZV		:= GetNextAlias()
	Local I

	Local oFont8 := TFont():New("Courier New"	 	,18,18,.T.,.F.,5,.T.,5,.T.,.F.) // Arial   15 Plain
	Local oFont7 := TFont():New("Arial"   	 	,15,15,.T.,.T.,5,.T.,5,.T.,.F.) // Arial   18 Bold
	Local oFont5 := TFont():New("Arial"   	 	,12,10,.T.,.T.,5,.T.,5,.T.,.F.) // Arial   12 Bold  - Cabeçalho Ficha de Compra
	Local oFont6 := TFont():New("Arial"   	 	,12,10,.T.,.F.,5,.T.,5,.T.,.F.) // Arial   12 Plain  - Cabeçalho Ficha de Compra


	Private aMeses		:= {"Janeiro","Fevereiro","Março","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"}

	BeginSql Alias cAliasZZV
		%NoParser%

		SELECT  * FROM %Table:ZZV% ZZV		
		WHERE
		ZZV_CARGA = %Exp:_cCarga% 	
		AND ZZV.%notdel%
	EndSql

	If (!(cAliasZZV)->(Eof()))

		oDanfe:StartPage()

		oDanfe:Box(000,000,600,600)

		oDanfe:Say(nLinha,070, "DECLARAÇÃO DE RESPONSABILIDADE DO TRANSPORTADOR/MOTORISTA", oFont7)
		nLinha += 3*nSalto


		oDanfe:Say  (nLinha,nPosCol1,"Eu, "+ALLTRIM((cAliasZZV)->ZZV_MOTOR)+" , motorista devidamente",oFont8)
		nLinha += nSalto   
		oDanfe:Say  (nLinha,nPosCol1,"habilitado conforme Carteira de Habilitação nº "+ALLTRIM((cAliasZZV)->ZZV_DOCMOT)+"",oFont8)
		nLinha += nSalto   
		oDanfe:Say  (nLinha,nPosCol1,"responsável pelo veículo Placa  "+ALLTRIM((cAliasZZV)->ZZV_PLACA)+" declaro para todos",oFont8)
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
		oDanfe:Say  (nLinha,nPosCol1+50,"Serra, "+SUBSTR(DTOS(dDataBase),7,2)+" de "+aMeses[VAL(SUBSTR(DTOS(dDataBase),5,2))]+" de "+SUBSTR(DTOS(dDataBase),1,4),oFont5) 
		nLinha += 4*nSalto
		oDanfe:Say  (nLinha,nPosCol1+50,"Assinatura:_____________________________________",oFont5) 
		nLinha += 4*nSalto                                                                         
		oDanfe:Say  (nLinha,nPosCol1+50,"Relação das Notas Fiscais: ",oFont5) 


		cAliasTmp := GetNextAlias()

		cSQL := ""+CRLF
		cSQL += " with "+CRLF
		cSQL += " tab_carga as ( "+CRLF
		cSQL += " select * from FNC_CARGA_EMP('"+AllTrim(cEmpAnt)+AllTrim(cFilAnt)+"','"+(cAliasZZV)->ZZV_CARGA+"','"+(cAliasZZV)->ZZV_TICKET+"') "+CRLF
		cSQL += " ), "+CRLF
		cSQL += " tab_nf as ( "+CRLF
		cSQL += " select EMPRESA='01',DOC = C9_NFISCAL, SERIE = C9_SERIENF   "+CRLF 
		cSQL += " from SC9010 "+CRLF
		cSQL += " where C9_AGREG in (select CARGA from tab_carga where EMPRESA = '0101') "+CRLF 
		cSQL += " and C9_CLIENTE <> '010064' "+CRLF
		cSQL += " and D_E_L_E_T_ = '' "+CRLF
		cSQL += " union all "+CRLF
		cSQL += " select EMPRESA='07',DOC = C97.C9_NFISCAL, SERIE = C97.C9_SERIENF  "+CRLF 
		cSQL += " from SC9010 C9 "+CRLF
		cSQL += " join SC9070 C97 on C97.C9_BLINF = ('01'+C9.C9_NFISCAL+C9.C9_SERIENF+C9.C9_PEDIDO+C9.C9_ITEM+C9.C9_SEQUEN) "+CRLF 
		cSQL += " where C9.C9_AGREG in (select CARGA from tab_carga where EMPRESA = '0101') "+CRLF
		cSQL += " and C9.C9_CLIENTE = '010064' "+CRLF
		cSQL += " and C9.D_E_L_E_T_ = '' "+CRLF
		cSQL += " and C97.D_E_L_E_T_ = '' "+CRLF
		cSQL += " union all "+CRLF
		cSQL += " select EMPRESA='05', DOC = C9_NFISCAL, SERIE = C9_SERIENF "+CRLF 
		cSQL += " from SC9050 "+CRLF 
		cSQL += " where C9_AGREG in (select CARGA from tab_carga where EMPRESA = '0501') "+CRLF 
		cSQL += " and C9_CLIENTE <> '010064' "+CRLF 
		cSQL += " and D_E_L_E_T_ = '' "+CRLF 
		cSQL += " union all "+CRLF 
		cSQL += " select EMPRESA='07',DOC = C97.C9_NFISCAL, SERIE = C97.C9_SERIENF "+CRLF 
		cSQL += " from SC9050 C9 "+CRLF 
		cSQL += " join SC9070 C97 on C97.C9_BLINF = ('05'+C9.C9_NFISCAL+C9.C9_SERIENF+C9.C9_PEDIDO+C9.C9_ITEM+C9.C9_SEQUEN) "+CRLF 
		cSQL += " where C9.C9_AGREG in (select CARGA from tab_carga where EMPRESA = '0501') "+CRLF 
		cSQL += " and C9.C9_CLIENTE = '010064' "+CRLF 
		cSQL += " and C9.D_E_L_E_T_ = '' "+CRLF 
		cSQL += " and C97.D_E_L_E_T_ = '' "+CRLF

		cSQL += " union all "+CRLF 

		cSQL += " select EMPRESA='13', DOC = C9_NFISCAL, SERIE = C9_SERIENF "+CRLF 
		cSQL += " from SC9130 "+CRLF 
		cSQL += " where C9_AGREG in (select CARGA from tab_carga where EMPRESA = '1301') "+CRLF 
		cSQL += " and C9_CLIENTE <> '010064' "+CRLF 
		cSQL += " and D_E_L_E_T_ = '' "+CRLF 
		cSQL += " union all "+CRLF 
		cSQL += " select EMPRESA='07',DOC = C97.C9_NFISCAL, SERIE = C97.C9_SERIENF "+CRLF 
		cSQL += " from SC9130 C9 "+CRLF 
		cSQL += " join SC9070 C97 on C97.C9_BLINF = ('13'+C9.C9_NFISCAL+C9.C9_SERIENF+C9.C9_PEDIDO+C9.C9_ITEM+C9.C9_SEQUEN) "+CRLF 
		cSQL += " where C9.C9_AGREG in (select CARGA from tab_carga where EMPRESA = '1301') "+CRLF 
		cSQL += " and C9.C9_CLIENTE = '010064' "+CRLF 
		cSQL += " and C9.D_E_L_E_T_ = '' "+CRLF 
		cSQL += " and C97.D_E_L_E_T_ = '') "+CRLF

		cSQL += " select distinct * from tab_nf order by DOC "+CRLF

		TcQuery cSQL New Alias (cAliasTmp)	

		While !(cAliasTmp)->(Eof())

			nLinha += nSalto
			_nColT := nPosCol1+50

			FOR I := 1 To 5  
				If !(cAliasTmp)->(Eof())

					oDanfe:Say  (nLinha,_nColT,(cAliasTmp)->DOC+"/"+(cAliasTmp)->SERIE,oFont6)

					_nColT += 100
					(cAliasTmp)->(DbSkip())
				Else        
					exit
				EndIf			
			NEXT                        

		EndDo

		(cAliasTmp)->(DbCloseArea())

		oDanfe:EndPage()

	EndIf

	(cAliasZZV)->(DbCloseArea())

Return

