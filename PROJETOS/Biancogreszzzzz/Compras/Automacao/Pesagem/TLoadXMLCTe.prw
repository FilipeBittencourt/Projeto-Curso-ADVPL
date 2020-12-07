#Include "TOTVS.CH"
#Include "Protheus.CH"
#INCLUDE "XMLXFUN.CH"

Class TLoadXMLCTe from LongClassName

	Public Data nTipo
	Public Data cBuffer
	Public Data oCTeResulStruct
	
	Public Method New() Constructor

	Public Method GetCTe()
	
EndClass

Method New(_cBuffer, _nTipo) Class TLoadXMLCTe
	
	::cBuffer 			:= _cBuffer
	::nTipo 			:= _nTipo
	::oCTeResulStruct	:= Nil
	
Return

Method GetCTe() Class TLoadXMLCTe
	
	Local oCT				:= Nil
	Local oIdent    		:= Nil
	Local oTotal    		:= Nil
	Local oInfDoc    		:= Nil
	Local oEmitente			:= Nil
	Local oRemetente		:= Nil
	
	Local oCTeStruct		:= TCTeStruct():New()
	Local oCTeResulStruct 	:= TCTeResulStruct():New()
	
	Local cLogMsg			:= ""
	Local lRet				:= .T.
	
	Local nI				:= 0
	Local cCgc				:= ""
	Local cData				:= ""
	Local cChave			:= ""
	
	cAviso 		:= ""
	cErro  		:= ""
	If (::nTipo == Nil .Or. ::nTipo == 1)
		oCTe   	:= XmlParser(::cBuffer,"_", @cAviso,@cErro)
	Else
		oCTe   	:= XmlParserFile(::cBuffer,"_", @cAviso,@cErro)
	EndIf
	
	If (oCTe <> Nil)
	
		If Type("oCTe:_cteProc") <> "U"
			oCT := oCTe:_cteProc:_CTe
		Else
			oCT := oCTe:_CTe
		EndIf
		
		oIdent		:= oCT:_infCte:_IDE
		oEmitente	:= oCT:_infCte:_Emit
		oRemetente	:= oCT:_infCte:_Rem
		oTotal		:= oCT:_infCte:_vPrest
		oInfDoc		:= Nil
		
		
		If (XmlChildEx(oCT:_infCte, "_INFCTENORM") <> NIL)
		 	oInfDoc := oCT:_infCte:_infCTeNorm:_infDoc
		EndIf
		 
		oInfCteComp := Nil 
		If (XmlChildEx(oCT:_infCte, "_INFCTECOMP")  <> NIL)
		 	oInfCteComp := oCT:_infCte:_infCteComp
		EndIf
		
				
		cCgc := AllTrim(IIf(Type("oEmitente:_CPF") == "U", oEmitente:_CNPJ:TEXT, oEmitente:_CPF:TEXT))
		
		DbSelectArea('SA2')
		SA2->(DbSetOrder(3))
		
		If SA2->(DbSeek(xFilial("SA2")+PADR(cCgc, TamSx3("A2_CGC")[1])))
				
			oCTeStruct:cDoc				:= Right(REPLICATE("0", 9)+Alltrim(oIdent:_nCT:TEXT), 9)
			oCTeStruct:cSerie			:= AllTrim(oIdent:_serie:TEXT)
			oCTeStruct:cFornece			:= SA2->A2_COD
			oCTeStruct:cLoja			:= SA2->A2_LOJA
			oCTeStruct:cForneceEst		:= SA2->A2_EST	
			oCTeStruct:cCond 			:= SA2->A2_COND //condicao pagamento padrao
			
				
			cData 						:= Alltrim(oIdent:_dhEmi:TEXT)
			oCTeStruct:dDataEmissao		:= stod(Left(cData, 4) + Substr(cData, 6, 2) + Substr(cData, 9, 2)) 
			oCTeStruct:cChave			:= IIf(Type("oCTe:_cteProc:_protCTe:_infProt:_chCTe") <> "U", oCTe:_cteProc:_protCTe:_infProt:_chCTe:TEXT, "")
			oCTeStruct:nValorServico	:= Val(oTotal:_vTPrest:TEXT)
			
			oCTeStruct:lImpFor := .F.
			If (XmlChildEx(oCT:_infCte:_imp, "_ICMS") <> NIL)
				oCTeStruct:lImpFor 		:= .T.
				If (XmlChildEx(oCT:_infCte:_imp:_ICMS, "_ICMS00") <> NIL)
					oCTeStruct:nAliqICMS	:= Val(oCT:_infCte:_imp:_ICMS:_ICMS00:_pICMS:TEXT)
				EndIf
			EndIf
			
			cCgc := AllTrim(IIf(Type("oRemetente:_CPF") == "U", oRemetente:_CNPJ:TEXT, oRemetente:_CPF:TEXT))
		
			DbSelectArea('SA2')
			SA2->(DbSetOrder(3))
			
			If SA2->(DbSeek(xFilial("SA2")+PADR(cCgc, TamSx3("A2_CGC")[1])))
					
				oCTeStruct:cRemet			:= SA2->A2_COD
				oCTeStruct:cRemetLoja		:= SA2->A2_LOJA
				
				If (oInfDoc <> Nil)
					If 	(XmlChildEx(oInfDoc, "_INFNFE") <> NIL)
						oInf 	:= oInfDoc:_infNFe
						cTipoNF	:= '1'
					Else
						oInf := oInfDoc:_infNF
						cTipoNF	:= '2'
					EndIf
					oInf	:= IIf(ValType(oInf) == "O", {oInf}, oInf)
				Else//problemas xml com tag diferente 
					oInf	:= IIf(ValType(oInfCteComp) == "O", {oInfCteComp}, oInfCteComp)
					cTipoNF	:= '1'
				EndIf
				
				For nI := 1 To Len(oInf)
					
					If (oInfDoc <> Nil)
						If (cTipoNF == '1')
							cChave := oInf[nI]:_chave:TEXT
						Else
							cDocCTe 	:= Right(REPLICATE("0", 9)+cvaltochar(oInf[nI]:_nDoc:TEXT), 9)
							cSerieCTe	:= oInf[nI]:_serie:TEXT
							cForneCTe	:= oCTeStruct:cRemet
							cLojaCTe	:= oCTeStruct:cRemetLoja
						EndIf
					Else
						cChave 	:= oInf[nI]:_chCTe:TEXT
					EndIf
					
					If (!Empty(cChave) .Or. (!Empty(cDocCTe) .And. !Empty(cSerieCTe)))
						
						DbSelectArea("SF1")
						cSeek := ""
						If (cTipoNF == '1')
							SF1->(DbSetOrder(8))
							cSeek := xFilial('SF1')+PADR(cChave, TamSx3("F1_CHVNFE")[1])
						Else
							SF1->(DbSetOrder(1))
							cSeek := xFilial('SF1')+PADR(cDocCTe, TamSx3("F1_DOC")[1])+PADR(cSerieCTe, TamSx3("F1_SERIE")[1])+PADR(cForneCTe, TamSx3("F1_FORNECE")[1])+PADR(cLojaCTe, TamSx3("F1_LOJA")[1])
						EndIf
						
						
						If SF1->(DbSeek(cSeek))
							
							oCTeItemStruct 				:= TCTeItemStruct():New()
							oCTeItemStruct:cChaveNFe	:= cChave
							oCTeItemStruct:cDoc			:= SF1->F1_DOC
							oCTeItemStruct:cSerie		:= SF1->F1_SERIE
							oCTeItemStruct:cFornece		:= SF1->F1_FORNECE
							oCTeItemStruct:cLoja		:= SF1->F1_LOJA
							
							/*buscar a tes de frete*/
							DbSelectArea("SD1")
							SD1->(DbSetOrder(1))
		
							If SD1->(DbSeek(xFilial('SD1')+SF1->F1_DOC+SF1->F1_SERIE+ SF1->F1_FORNECE+ SF1->F1_LOJA))
		
								DbSelectArea("SA5")
								SA5->(DbSetOrder(2))
								
								If SA5->(DbSeek(xFilial("SA5")+SD1->D1_COD+oCTeStruct:cFornece+oCTeStruct:cLoja))
									
									oCTeStruct:cTes  := SA5->A5_YTESFRE
									
								EndIf
								
							EndIf
							/**/
							
							oCTeStruct:oCTeItens:Add(oCTeItemStruct)
						Else
						
							cLogMsg := "Nota fiscal relacionada ao CTe não encontrado: Chave => "+ cChave + CRLF
							lRet	:= .F.	
							
						EndIf
						
					EndIf
					
				Next nI	
				
				
			Else
		
				cLogMsg := "Rementente não encontrado => "+ cCgc + CRLF
				lRet	:= .F.	
		
			EndIf			
		Else
		
			cLogMsg := "Fornecedor não encontrado => "+ cCgc + CRLF
			lRet	:= .F.	
		
		EndIf
	
	Else	
		
		cLogMsg := "Erro ao ler o arquivo XML." + CRLF
		lRet	:= .F.	
		
	EndIf
	
	
		
	If (lRet)
		oCTeResulStruct:Add(lRet, cLogMsg, oCTeStruct)
	Else
		oCTeResulStruct:Add(lRet, cLogMsg, Nil)
	EndIf
	
	::oCTeResulStruct := oCTeResulStruct

Return(oCTeResulStruct)



//classes struct

Class TCTeStruct from LongClassName

	Data cDoc
	Data cSerie
	Data cFornece
	Data cLoja
	Data cForneceEst
	
	Data cRemet
	Data cRemetLoja
	
	Data dDataEmissao
	Data cChave
	Data cTes
	Data cEspecie
	Data cCond
	
	Data nValorServico
	Data nBaseIcms
	Data nValorIcms
	
	Data lImpFor
	Data nAliqICMS
	Data oCTeItens

	Method New() Constructor

EndClass

Method New() Class TCTeStruct

	::cDoc 					:= ""
	::cSerie				:= ""
	::cFornece				:= ""
	::cLoja					:= ""
	::cRemet				:= ""
	::cRemetLoja			:= ""
	
	::dDataEmissao			:= Date()
	::cChave				:= ""
	::cTes					:= ""
	::cEspecie				:= "CTE"
	::cCond					:= ""
	
	::nValorServico			:= 0
	::nBaseIcms				:= 0
	::nValorIcms			:= 0
	::lImpFor				:= .F.
	::nAliqICMS				:= 0
	::oCTeItens	    		:= ArrayList():New()

Return()

Class TCTeItemStruct From LongClassName

	Data cChaveNFe
	Data cDoc
	Data cSerie
	Data cFornece
	Data cLoja
	
	Method New() Constructor

EndClass

Method New() Class TCTeItemStruct
	
	::cChaveNFe		:= ""
	::cDoc 			:= ""
	::cSerie		:= ""
	::cFornece		:= ""
	::cLoja			:= ""		
Return()

Class TCTeResulStruct From LongClassName

	Public Data lOk			as logical
	Public Data cMensagem	as character
	Public Data oResult	

	Public Method New() Constructor
	Public Method Add()

EndClass

Method New() Class TCTeResulStruct

	::lOk		:= .T.
	::cMensagem	:= ""
	::oResult	:= Nil
	
Return()

Method Add(lOk, cMensagem, oResult) Class TCTeResulStruct

	::lOk		:= lOk
	::cMensagem	+= cMensagem
	::oResult	:= oResult

Return()