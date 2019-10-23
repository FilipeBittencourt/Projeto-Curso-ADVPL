#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FWMVCDEF.CH'

User Function VIXR021(lRom) 

	Local aPergs := {}
	Local lRet
	Local aCampos
	lOCAL aStru  := {}
	Local cTrab
	Local aSeek := {}
	Local aRet := {}

	Default lRom := .F.
	
	Private __aHead := {}
	Private __cRomaneio := IIF(lRom,Z53->Z53_NUM,Space(6))

	
	aAdd( aPergs ,{1,"Romaneio : ",__cRomaneio,"@!",'.T.',"",'.T.',40,.T.})

	If ParamBox(aPergs ,"Impressใo U.M.A. Romaneio",aRet)       
		lRet := .T.   		
	Else      
		lRet := .F.   
	EndIf
	
	IF !lRet 
		Return
	End if

	__cRomaneio := aRet[1]

	MsgRun("Selecionando registros para exibi็ใo ", "Selecionando registros...", {||SqlUMA(__cRomaneio,@__aHead)} )


	oBrwRoman := FWMarkBrowse():New()
	oBrwRoman:SetAlias('TRBROMAN')
	oBrwRoman:SetFields(__aHead)
	oBrwRoman:SetDescription("Romaneio: " + __cRomaneio + "   ETIQUETA U.M.A" )
	oBrwRoman:SetFieldMark('D1_OK')
	oBrwRoman:SetAllMark({|| VA21AllMark()})
	oBrwRoman:SetSeek(.T.,CriaSeek())
	oBrwRoman:SetMenuDef('VIXR021')
	
	oBrwRoman:AddLegend("TRBROMAN->ZS_STATUS == '1'","RED"	  ,"Bloqueada")
	oBrwRoman:AddLegend("TRBROMAN->ZS_STATUS == '2'","GREEN"  ,"Liberada")
	oBrwRoman:AddLegend("TRBROMAN->ZS_STATUS == '3'","YELLOW" ,"Enderecado")
	oBrwRoman:Activate()
	
Return

Static Function CriaSeek()
	
	Local nInd1 := TamSX3("D1_FORNECE")[1] + TamSX3("D1_COD")[1]
	//Local nInd2 := TamSX3("D1_COD")[1]
	
	Local aSeek := {}
	aAdd(aSeek,{"Cod Fornece + Cod Prod" ,{{"","C",nInd1,0,"Cod Fornece + Cod Prod"					,"@!"}} } )
//	aAdd(aSeek,{"Cod produto" ,{{"","C",nInd2,0,"Cod Produto"					,"@!"}} } )
	
Return aSeek

Static Function MenuDef()
	
	Local aRot1 := {}
	ADD OPTION aRot1 TITLE 'Imprimir'      ACTION 'u_IMPUMA'       OPERATION 1 ACCESS 0

Return aRot1


User Function IMPUMA()

	Local cMarca   := oBrwRoman:Mark()
	Local cImpressora := Space(TAMSX3("CB5_CODIGO")[1])
	
	Local nCopias		:= Space(3)
	Local aPergs := {}
	Local aRet := {}
	Local aEtiq := {}
	
	
	aAdd( aPergs ,{1,"Impressora: ",cImpressora,"@!",'.T.',"CB5",'.T.',40,.T.})
	//aAdd( aPergs ,{1,"Copias: ",nCopias,"@!",Val(nCopias) > 0 ,"",'.T.',3,.T.})
	
	If !ParamBox(aPergs ,"Local de impressใo",aRet)        
			Return
	EndIf      
	
	cImpressora := aRet[1]
	nCopias	  := "1"
	
	
	TRBROMAN->(DbGoTop())
	TRBROMAN->(DbSetOrder(1))
	
	While !TRBROMAN->(Eof())
	
		If TRBROMAN->D1_OK == cMarca
		
			AADD(aEtiq,{TRBROMAN->D1_COD,;
						TRBROMAN->B1_DESC,;
						TRBROMAN->B1_UM,;
						TRBROMAN->D1_QUANT,;
						TRBROMAN->BE_LOCALIZ,;
						Alltrim(TRBROMAN->ZS_CODIGO),;
						TRBROMAN->D1_LOCAL})
		End If
		
		TRBROMAN->(DBSkip())
	EndDo
	
	U_VIX21UMA(aEtiq,cImpressora,nCopias,__cRomaneio)	

	SqlUMA(__cRomaneio,@__aHead)
	oBrwRoman:Refresh(.T.)


Return

Static Function VA21AllMark()
	
	Local cMarca   := oBrwRoman:Mark()
	Local aArea    := GetArea()
	
	DBSELECTAREA('TRBROMAN')
	DBGOTOP()
	WHILE TRBROMAN->(!EOF())
		
		IF AllTrim(TRBROMAN->D1_OK) == cMarca
			Reclock('TRBROMAN',.F.)
			Replace TRBROMAN->D1_OK with Space(2)
			MsUnlock()
		ELSE
			Reclock('TRBROMAN',.F.)
			Replace TRBROMAN->D1_OK with cMarca
			MsUnlock()
		ENDIF
		
		TRBROMAN->(DBSKIP())
	ENDDO
	
	oBrwRoman:Refresh(.T.)
	
Return



User Function VIX21UMA(aEtiq,cImpressora,nCopias,cRomaneio) 

Local cAlias := GetNextAlias()
Local cSeq   := ""

IF CB5SetImp(cImpressora)
	
		For i:= 1 to len(aEtiq)
		
			// Verifica se jแ estแ atrelada a uma etiqueta UMA
			If Empty(aEtiq[i][6])
			
					//Query para selecionar o ultimo numero do sequencial
					BEGINSQL Alias cAlias
						
						/*SELECT TOP 1 SUBSTRING(ZS_CODIGO,9,12) as SEQ
						FROM %table:SZS%
						WHERE %table:SZS%.%NOTDEL%
						AND ZS_FILIAL = %exp:xFilial("SZS")%
						ORDER BY ZS_CODIGO DESC*/
							
		             SELECT  ISNULL(MAX(SUBSTRING(ZS_CODIGO, 7, 8)),'0000000') AS SEQ
		             FROM    %table:SZS% SZS
		             WHERE   SZS.ZS_DOC = %Exp:cRomaneio%
		                     AND SZS.D_E_L_E_T_ = ''

					ENDSQL
					
					/*//Verifica se e' o primeiro registro da tabela, e insere se for
					IF EMPTY((cAlias)->SEQ)
						cSeq := DTOS(dDataBase) + STRZERO(1,12)
					ELSE
						cSeq :=  DTOS(dDataBase) + (SOMA1((cAlias)->SEQ))
					ENDIF*/
			
					
					cSeq :=  cRomaneio + cValtoChar((SOMA1((cAlias)->SEQ)))
			
					(cAlias)->(dbCloseArea())
					
					//Recebe a Etiqueta
					cEtiUMA := cSeq
					
					//Cria a Etiqueta			
					RecLock('SZS',.T.)
						SZS->ZS_FILIAL := xFilial("SZS")
						SZS->ZS_CODIGO := cSeq
						SZS->ZS_ORIGEM := "Z54"
						SZS->ZS_DOC	 := cRomaneio
						SZS->ZS_PROD	 := aEtiq[i][1] //Produto
						SZS->ZS_LOCAL  := aEtiq[i][7] //lOCAL
						SZS->ZS_STATUS := '1'
					SZS->(MsUnlock())
						
					//Coloca no Array a etiqueta UMA	
					aEtiq[i][6] := Alltrim(cSeq)
				
			End If
			
		Next

	
		For i:= 1 to len(aEtiq)// Step 3
					
			MSCBWrite("CT~~CD,~CC^~CT~")
			MSCBWrite("^XA~TA000~JSN^LT0^MNW^MTD^PON^PMN^LH0,0^JMA^PR4,4~SD15^JUS^LRN^CI0^XZ")
			MSCBWrite("^XA")
			MSCBWrite("^MMT")
			MSCBWrite("^PW816")
			MSCBWrite("^LL0168")
			MSCBWrite("^LS0")


			nLeft :=  1
			For i := i to Min(i+2, len(aEtiq)) 
				
			
			//	MSCBWrite("^FT"+cValToChar(nLeft)+",130^A0N,15,14^FH\^FDRomaneio^FS")
			//	MSCBWrite("^FT"+cValToChar(nLeft)+",157^A0N,25,24^FH\^FD" + cRomaneio + "^FS")
			//	MSCBWrite("^FT"+cValToChar(nLeft)+",60^A0N,17,14^FH\^FD" + Alltrim(SubStr(aEtiq[i][2],1,34)) + "^FS")
			//	MSCBWrite("^FT"+cValToChar(nLeft)+",81^A0N,17,14^FH\^FD" + Alltrim(SubStr(aEtiq[i][2],35,34)) + "^FS")
//				MSCBWrite("^FT"+cValToChar(nLeft)+",76^A0N,31,40^FH\^FD" + Alltrim(SubStr(aEtiq[i][5],1,12)) + "^FS")
//				MSCBWrite("^BY2,3,56^FT"+cValToChar(92+nLeft)+",142^BCN,,Y,N")
//				MSCBWrite("^FD>;" + aEtiq[i][6] + "^FS") //Codigo Etiqueta
//				MSCBWrite("^FT"+cValToChar(nLeft)+",38^A0N,34,33^FH\^FD"+aEtiq[i][1]+"^FS")
//				MSCBWrite("^LRY^FO"+cValToChar(nLeft)+",84^GB246,0,33^FS^LRN")
			
			
				/*MSCBWrite("^FT"+cValToChar(nLeft)+",38^A0N,34,33^FH\^FD"+Alltrim(aEtiq[i][1])+"^FS")
				MSCBWrite("^FT"+cValToChar(nLeft)+",76^A0N,31,40^FH\^FD"+Alltrim(aEtiq[i][5])+"^FS")
				MSCBWrite("^BY2,3,56^FT"+cValToChar(nLeft)+",142^BCN,,Y,N")
				MSCBWrite("^FD>;" + aEtiq[i][6] + "^FS")
				MSCBWrite("^LRY^FO"+cValToChar(nLeft)+",48^GB246,0,33^FS^LRN")*/
				
				MSCBWrite("^FT"+cValToChar(nLeft)+",76^A0N,31,40^FH\^FD"+Alltrim(SubStr((aEtiq[i][5]),1,12))+"^FS")
				MSCBWrite("^BY2,3,56^FT"+cValToChar(nLeft)+",142^BCN,,Y,N")
				MSCBWrite("^FD>;"+ aEtiq[i][6]  +">6"+ SUBSTR(aEtiq[i][6],LEN(aEtiq[i][6]),1)+"^FS")
				MSCBWrite("^FT"+cValToChar(nLeft)+",38^A0N,34,33^FH\^FD"+Alltrim(aEtiq[i][1])+"^FS")
				MSCBWrite("^LRY^FO"+cValToChar(nLeft)+",48^GB246,0,33^FS^LRN")

				nLeft += 280
			Next
			
		MSCBWrite("^PQ1,0,1,Y^XZ")


		MSCBEND()

		I -= 1
		Next
		
		MSCBCLOSEPRINTER() 
		

End If

Return

Static Function ModelDef()
	
	Local oStruZ54 := FWFormStruct(1,cAliasRoman)							// Cria a estrutura a ser usada no Modelo de Dados
	Local oModel 															  // Modelo de dados que serแ construํdo
	
	oModel := MPFormModel():New('VIXR021MVC')						    	// Cria o objeto do Modelo de Dados
	oModel:AddFields('Z54MASTER',/*cOwner*/,oStruZ54)	   				// Adiciona ao modelo um componente de formulแrio
	oModel:SetDescription('Etiqueta UMA')							// Adiciona a descri็ใo do Modelo de Dados
	oModel:SetPrimaryKey({'D1_COD'})
	
Return oModel


Static Function ViewDef()
	
	Local oModel 	:= FWLoadModel('VIXR021')	   		// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
	Local oStruZ54	:= FWFormStruct(2,cAliasRoman)   			// Cria a estrutura a ser usada na View
	Local oView		:= FWFormView():New()				// Cria o objeto de View
	
	oView:SetModel(oModel)								// Define qual o Modelo de dados serแ utilizado na View
	oView:CreateHorizontalBox('TELA',100)				// Criar um "box" horizontal para receber algum elemento da view
		
Return oView

Static Function SqlUMA(__cRomaneio,__aHead)

	Local aStru := {}
	Local cAliasRoman := GetNextAlias()
	Local cTrab := ""
	Local cTexto := ""
		
	BeginSql alias cAliasRoman
		
		SELECT  '' D1_OK,
				 SZS.ZS_STATUS,
				 SZS.ZS_CODIGO,
				 SBE.BE_LOCALIZ,
				 SD1.D1_FORNECE,
				 SD1.D1_COD ,
				 SD1.D1_LOCAL,
		        SB1.B1_DESC ,
		        SB1.B1_UM,
		        SUM(SD1.D1_QUANT) D1_QUANT,
		        SZS.ZS_QUANT,
		        CASE WHEN SZS.ZS_STATUS = '2' THEN '0' ELSE SUM(SD1.D1_QUANT) - ISNULL(( SELECT SUM(SZS1.ZS_QUANT)
                                         FROM   %table:SZS% SZS1
                                         WHERE  SZS1.ZS_DOC = %exp:__cRomaneio% 
                                                AND SZS1.ZS_PROD = SD1.D1_COD
                                                AND SZS.ZS_STATUS = '2'
                                                AND D_E_L_E_T_ = ''
                                       ), 0) END DB_QTDLID 
		        
		FROM    %table:Z54% Z54
		        JOIN %table:SD1% SD1 ON SD1.D1_FILIAL =  %xFilial:SD1%  
		                           AND SD1.D1_DOC = Z54.Z54_DOC
		                           AND SD1.D1_SERIE = Z54.Z54_SERIE
		                           AND SD1.D1_FORNECE = Z54.Z54_FORN
		                           AND SD1.D1_LOJA = Z54.Z54_LOJA
		                           AND SD1.D_E_L_E_T_ = ''
		                           
		        JOIN %table:SB1% SB1 ON SB1.B1_FILIAL = ''
		                           AND SB1.B1_COD = SD1.D1_COD
		                           AND SB1.D_E_L_E_T_ = ''
		                           
		        LEFT JOIN %table:SBE% SBE ON SBE.BE_FILIAL = SD1.D1_FILIAL
		                           AND SBE.BE_CODPRO = SD1.D1_COD
		                           AND SBE.BE_LOCAL = SD1.D1_LOCAL
		                           AND SBE.D_E_L_E_T_ = ''
		                                
		        LEFT JOIN %table:SZS% SZS ON SZS.ZS_FILIAL = SD1.D1_FILIAL
		                           AND SZS.ZS_PROD = SD1.D1_COD
		                           AND SZS.ZS_LOCAL = SD1.D1_LOCAL
		                           AND SZS.ZS_DOC = Z54.Z54_NUM
		                           AND SZS.D_E_L_E_T_ = ''
		                           
		WHERE   Z54.Z54_NUM = %exp:__cRomaneio% 
		        AND Z54.D_E_L_E_T_ = ''
		GROUP BY SD1.D1_COD ,
				  SD1.D1_LOCAL,
		        SB1.B1_DESC ,
		        SB1.B1_UM,
		        SZS.ZS_QUANT,
		        SBE.BE_LOCALIZ ,
		        SZS.ZS_CODIGO ,
		        SZS.ZS_STATUS,
		        SD1.D1_FORNECE
		ORDER BY SD1.D1_FORNECE,SB1.B1_DESC

	EndSql

	If Select('TRBROMAN') > 1
		TRBROMAN->(DbCloseArea())
	EndIf
	
	// Cria Strutura
	aStru := (cAliasRoman)->(dbStruct())
	cTrab := CriaTrab(aStru)

	dbUseArea(.T.,,cTrab,"TRBROMAN")
	//IndRegua( "TRBROMAN","TRBROMAN1","D1_COD",,,"Indexando bra...")		//"Selecionando Registros..."
	IndRegua( "TRBROMAN",cTrab,"D1_FORNECE + D1_COD",,,"Indexando bra...")		//"Selecionando Registros..."
	
	dbClearIndex()
	dbSetIndex(cTrab+OrdBagExt())
//	dbSetIndex("TRBROMAN2"+OrdBagExt())
	
	(cAliasRoman)->(dbGoTop())
	
	//Alimenta a tabela
	While (cAliasRoman)->(!Eof())
	RecLock('TRBROMAN', .t.)
		For i := 1 to Len(aStru)
			
			If TRBROMAN->(aStru[i, 1]) == "BE_LOCALIZ"
				TRBROMAN->&(aStru[i, 1]) := u_EndUMA((cAliasRoman)->D1_COD,(cAliasRoman)->D1_LOCAL)
			Else
				TRBROMAN->&(aStru[i, 1]) := (cAliasRoman)->&(aStru[i, 1])
			End If		
		Next
	TRBROMAN->(MsUnLock())
	(cAliasRoman)->(DbSkip())
	EndDo
	
	//Para usar tabelas temporarias no MVC ้ necessแrio que informe um cabe็alho da tabela no comando SetFields
	//Cria็ใo do Cabe็alho
	__aHead := {}
	
	For i := 1 to Len(aStru)
		DbSelectArea("SX3")
		DbSetOrder(2)
		If DbSeek(aStru[i, 1]) .and. aStru[i, 1] != 'D1_OK'
			
			If aStru[i, 1] == "D1_QUANT"
				cTexto := "Qtd Roman"
			ElseIf aStru[i, 1] == "DB_QTDLID"
				cTexto := "Qtd Saldo"
			ElseIf aStru[i, 1] == "ZS_QUANT"
				cTexto := "Qtd Conf"
			End If
			
	
			aAdd(	__aHead,{IIF (Empty(cTexto),SX3->X3_TITULO,cTexto),;
				aStru[i, 1],;
				SX3->X3_TIPO,;
				SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL,;
				SX3->X3_PICTURE} )
				
			cTexto	:= ""
				
		Endif
	Next
	
				
Return


User Function EndUMA(cCodProd,cLocal)

Local cAliasEndPro := GetNextAlias()
Local cEndereco

BeginSql alias cAliasEndPro
	
	SELECT  *
	FROM    ( SELECT    ROW_NUMBER() OVER ( PARTITION BY B1_COD ORDER BY SBF.BF_QUANT ASC ) PRIORIDADE ,
	                    SB1.B1_COD ,
	                    SBE.BE_LOCALIZ ,
	                    SBF.BF_LOCALIZ ,
	                    SBF.BF_QUANT ,
	                    DC4.DC4_DESZON
	          FROM      %table:SB1% (NOLOCK) SB1
	                    LEFT JOIN %table:SBF% (NOLOCK) SBF ON SBF.BF_FILIAL = %xFilial:SBF%
	                                            AND SBF.BF_PRODUTO = SB1.B1_COD
	                                            AND SBF.BF_LOCAL = %exp:cLocal% 
	                                            AND SBF.BF_ESTFIS IN (
	                                            SELECT  DC8_CODEST
	                                            FROM    %table:DC8% DC8
	                                            WHERE   DC8.DC8_FILIAL = %xFilial:DC8%
	                                            		   AND DC8.D_E_L_E_T_ = ''
	                                                    AND DC8.DC8_TPESTR = '2' )
	                                            AND SBF.D_E_L_E_T_ = ''
	                    LEFT JOIN %table:SBE% (NOLOCK) SBE ON SBE.BE_FILIAL = %xFilial:SBE%
	                                            AND SBE.BE_CODPRO = SB1.B1_COD
	                                            AND SBE.BE_LOCAL =  %exp:cLocal% 
	                                            AND SB1.D_E_L_E_T_ = ''
	                    LEFT JOIN %table:SB5% (NOLOCK) SB5 ON SB5.B5_FILIAL = SB1.B1_FILIAL
	                                            AND SB5.B5_COD = SB1.B1_COD
	                                            AND SB5.D_E_L_E_T_ = ''
	                    LEFT JOIN %table:DC4% (NOLOCK) DC4 ON DC4.DC4_FILIAL = %xFilial:DC4%
	                                            AND DC4.DC4_CODZON = SB5.B5_CODZON
	                                            AND DC4.D_E_L_E_T_ = ''
	          WHERE     SB1.B1_FILIAL = %xFilial:SB1%
	                    AND B1_COD = %exp:cCodProd% 
	                   
	                   
	                    AND SB1.D_E_L_E_T_ = ''
	        ) A
	WHERE   A.PRIORIDADE = '1'

EndSQL

	// Caso possua Endere็o Escravizado
	If !Empty( (cAliasEndPro)->BE_LOCALIZ)
		cEndereco := (cAliasEndPro)->BE_LOCALIZ
	// Caso possua Endere็o fisico
	ElseIf !Empty( (cAliasEndPro)->BF_LOCALIZ)
		cEndereco := (cAliasEndPro)->BF_LOCALIZ
	//Caso possua Zona
	ElseIf !Empty( (cAliasEndPro)->DC4_DESZON)
		cEndereco := (cAliasEndPro)->DC4_DESZON
	Else
		cEndereco := ""
	End If
	
	(cAliasEndPro)->(DbCloseArea())
	
Return cEndereco


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVIXR021   บAutor  ณF.Kuhn              บ Data ณ  17/10/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ RELATORIO PARA IMPRESSAO DE ETIQUETA GENERICA              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
/*USER FUNCTION VIXR021()

Local cPerg     := 'VIXR021'
Local nQtd      := 0
Local cImp 		:= ""
Local cCadastro	:= "Impressao de Etiqueta Burra"
Local aSays		:= {}
Local aButtons	:= {}
Local aRet		:= {{},{}}
Local nOpcA		:= 0

//Perguntas
CriaSX1(cPerg)
Pergunte(cPerg,.F.)

If IsTelNet()
	
	If Pergunte(cPerg,.t.)
		nQtd := mv_par01
		cImp := mv_par02
		
		Processa({|| Imprime(nQtd, cImp) }, "Etiqueta Burra","Aguarde, Imprimindo as etiquetas",.F.  )
		
	Else
		Return
	EndIf
	
Else
	
	//Inclusใo de informa็๕es para tela de processamento
	aAdd(aSays," Este programa tem como objetivo imprimir uma etiqueta burra ")
	aAdd(aButtons,{5,.T.,{||	Pergunte(cPerg,.T.)}})
	aAdd(aButtons,{1,.T.,{|o| 	nOpca:= 1, o:oWnd:End()}})
	aAdd(aButtons,{2,.T.,{|o| 	o:oWnd:End()}})
	
	FormBatch(cCadastro,aSays,aButtons)
	
	If nOpca == 1
		
		nQtd := mv_par01
		cImp := mv_par02
		
		Processa({|| Imprime(nQtd, cImp) }, "Etiqueta Burra","Aguarde, Imprimindo as etiquetas",.F.  )
				
	EndIf
		
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVIXR021   บAutor  ณF.Kuhn              บ Data ณ  17/10/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ IMPRIME A ETIQUETA DE ACORDO COM A QUANTIDADE SOLICITADA   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
/*Static Function Imprime(nQtd, cImp)

Local cSeq
Local cTitulo	:= "ETIQUETA BURRA"
Local nDireita  := 105
Local nEsquerda := 04
Local nSup      := 05
Local nInf      := 74
Local nTamM0    := 18
Local nTamNum	:= TamSx3("ZS_CODIGO")[1]
Local nSayPos   := 0
Local nSayBarPos:= 0
Local nSeqPos   := 0
Local nCont     := 0
Local cAlias

IF CB5SetImp(cImp)
	
	For nCont := 1 to nQtd
		
		cAlias := GetNextAlias()
		
		//Query para selecionar o ultimo numero do sequencial
		BEGINSQL Alias cAlias
			
			SELECT TOP 1 SUBSTRING(ZS_CODIGO,9,12) as SEQ
			FROM %table:SZS%
			WHERE %table:SZS%.%NOTDEL%
			AND ZS_FILIAL = %exp:xFilial("SZS")%
			ORDER BY ZS_CODIGO DESC
			
		ENDSQL
		
		//Verifica se e' o primeiro registro da tabela, e insere se for
		IF EMPTY((cAlias)->SEQ)
			cSeq := DTOS(dDataBase) + STRZERO(1,12)
		ELSE
			cSeq :=  DTOS(dDataBase) + (SOMA1((cAlias)->SEQ))
		ENDIF

		(cAlias)->(dbCloseArea())

		DBSELECTAREA('SZS')

		//Imprime a etiqueta

		MSCBINFOETI(cTitulo)

		MSCBBEGIN(1,4)

		nSayPos    := ((90-(nTamM0*3.3))/2)
		nSayBarPos := 16 //((90-50)/2)
		nSeqPos    := ((90-44)/2)

		MSCBBOX(nEsquerda,1,nDireita,nInf,10)
		MSCBSAY(22,8,"ETIQUETA BURRA WMS","N",'B','36',.t.)

		nSayPos    := ((90-(nTamNum*3.3))/2)
		
		MSCBSAY(nSayPos,22,cSeq,"N",'0','110,70')
		
		MSCBSAYBAR(nSayBarPos,42,cSeq,"N","MB02",16,.F.,.F.,.F.,,2,2)
				
//		MSCBSAY(nSayPos,10,rTrim(SM0->M0_NOMECOM),"N",'B','36')
	  	//

		
		MSCBEND()
		
		//APOS EMISSAO GRAVA NA TABELA O REGISTRO		
		RecLock('SZS',.T.)
		SZS->ZS_FILIAL := xFilial("SZS")
		SZS->ZS_CODIGO := cSeq
		SZS->(MsUnlock())		
		
	Next
	
	MSCBCLOSEPRINTER()
	
ELSE    

	IF IsTelnet()
		CBAlert('Erro na impressora ao imprimir a etiqueta!','Aviso',.T.,3000,2)
	ELSE
		MsgAlert("Erro na impressora ao imprimir a etiqueta!")
	ENDIF

ENDIF

RETURN*/

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณCriaSX1   ณ Autor ณF.Kuhn         		ณData  ณ 17/10/13 บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณFun็ใo para cria็ใo do grupo de perguntas                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณNenhum                                                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณExpO1: Grupo de perguntas			                          ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

Static Function CriaSX1(cPerg)

PutSx1(cPerg,"01","Qtd Etiquetas??","","","mv_ch1","N",4	 	,0,0,"G","","","","","mv_par01")
PutSx1(cPerg,"02","Local de Impressใo?"	,"","","mv_ch2","C",TAMSX3("CB5_CODIGO")[1]	,0,0,"G","","CB5","","","mv_par02")

Return/*/
