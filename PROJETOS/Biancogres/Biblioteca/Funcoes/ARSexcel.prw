#INCLUDE "protheus.ch" 
#INCLUDE "TOTVS.CH"
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±± ∫Programa: Classe ARSexcel  								 																	   										Data:   09/04/2014  ±±
±± ∫Autor: Artur Antunes Rainha Da Silveira                                                                                                            										±±
±± ∫Obs: FunÁ„o de exemplo no final do arquivo																										    									±±
±± ∫Email: silveiraartur@gmail.com																										    												±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±	Classe para geraÁ„o de planilha Excel em formato XML ou convertido para XLSX				                  																			±±
±±  																																													    ±±
±±  Metodos:																																												±±
±±   																																														±±
±±  ------------------------------------------------------------------------------------------------------------																		    ±±
±±  New																																														±±
±±    																																														±±
±±  Sintaxe: ARSexcel():New(lJob) 																																				    		±±
±±   																																														±±
±±  DescriÁ„o: MÈtodo construtor da classe																																					±±
±±    																																														±±
±±  Parametros: 																																											±±
±±  _________________________________________________________________________________																										±±
±±  | Nome   | Tipo    | DescriÁ„o                         | Default  | ObrigatÛrio |																										±±
±±  |--------------------------------------------------------------------------------  																										±±
±±  | lJob   | Logico  | Define se a geraÁ„o sera via Job  | .F.      | N„o         |																										±±
±±  |________|_________|___________________________________|__________|_____________|																										±±
±±    																																														±±
±±  ------------------------------------------------------------------------------------------------------------																		    ±±
±±  AddPlanilha()																																										    ±±
±±    																																														±±
±±  Sintaxe: ARSexcel():AddPlanilha(cTitulo,aColunas) 																																		±±
±±   																																														±±
±±  DescriÁ„o: Adiciona uma Worksheet (Planilha)																																			±±
±±    																																														±±
±±  Parametros: 																																											±±
±±  _____________________________________________________________________________________________																							±±
±±  | Nome   | Tipo    | DescriÁ„o                         | Default              | ObrigatÛrio |																							±±
±±  |--------------------------------------------------------------------------------------------																							±±
±±  |cTitulo | Caracter| Titulo do Worksheet			   | "Plan" + seguencia   | N„o         |																							±±
±±  |________|_________|___________________________________|_____________________ |_____________|																							±±
±±  |aColunas| Array   | Array simples com o espaÁamento   | Array de 40 posiÁıes | N„o         |																							±±
±±	|		 |		   | das colunas	                   | com valor 50         |             |																							±±
±±  |________|_________|___________________________________|______________________|_____________|																							±±
±±																																															±±
±±  ------------------------------------------------------------------------------------------------------------																		    ±±
±±  AddLinha()																																											    ±±
±±    																																														±±
±±  Sintaxe: ARSexcel():AddLinha(nAltura) 																																					±±
±±   																																														±±
±±  DescriÁ„o: Adiciona uma Linha																																							±±
±±    																																														±±
±±  Parametros: 																								 																			±±
±±  _________________________________________________________________________________																										±±
±±  | Nome   | Tipo    | DescriÁ„o                         | Default  | ObrigatÛrio |																										±±
±±  |--------------------------------------------------------------------------------																										±±
±±  |nAltura | numerico| Altura da linha adicionada		   | 15		  | N„o         |																										±±
±±  |________|_________|___________________________________|________________________|																										±±
±±																																															±±
±±  ------------------------------------------------------------------------------------------------------------									    									±±
±±  AddCelula()																																	    										±±
±±    																																														±±
±±  Sintaxe: ARSexcel():AddCelula(qConteudo,nDecimal,cAlinhamento,cFonte,nFonTam,cFonteCor,lNegrito,lItalico,cInterCor,lTopBor,lLeftBor,lBottomBor,lRightBor,lMescla,nIniMescla,nFimMescla)	±±
±±   																																														±±
±±  DescriÁ„o: Adiciona uma celula 																				 																			±±
±±    																																														±±
±±  Parametros: 																																											±±
±±  _____________________________________________________________________________________________________________________________															±±
±±  | Nome         | Tipo     | DescriÁ„o                         						   | Default              | ObrigatÛrio |															±±
±±  |----------------------------------------------------------------------------------------------------------------------------															±±
±±  |qConteudo     | Qualquer | Conteudo da celula   		      						   | Vazio				  | N„o         |															±±
±±  |______________|__________|____________________________________________________________|_____________________ |_____________|															±±
±±  |nDecimal      | Numerico | Quantidade de decimais para       						   | 0					  | N„o         |															±±
±±	|		       |		  | conteudo numerico	              						   | 			          |             |															±±
±±  |______________|__________|____________________________________________________________|______________________|_____________|															±±
±±  |cAlinhamento  | Caracter | Alinhamento do conteudo da celula:						   | "L"				  | N„o         |															±±
±±	|		       |		  | "R" = Right               	      						   | 			          |             |															±±
±±	|		       |		  | "L" = Left	    			      						   | 			          |             |															±±
±±	|		       |		  | "C" = Center		             						   |   			          |             |															±±
±±  |______________|__________|____________________________________________________________|______________________|_____________|															±±
±±  |cFonte		   | Caracter | Tipo de fonte do conteudo		  						   | "Arial" 			  | N„o         |															±±
±±  |______________|__________|____________________________________________________________|______________________|_____________|															±±
±±  |nFonTam	   | Numerico | Tamanho da fonte				  						   | 8					  | N„o         |															±±
±±  |______________|__________|____________________________________________________________|______________________|_____________|															±±
±±  |cFonteCor	   | Caracter | Cor da fonte. Deve ser informado o codigo da cor em HTML   | "000000"	 		  | N„o         |															±±
±±	|		       |		  | Referencias disponiveis em:	     						   | 			          |             |															±±
±±	|		       |		  | http://www.mxstudio.com.br/Conteudos/Dreamweaver/Cores.htm | 			          |             |															±±
±±  |______________|__________|____________________________________________________________|______________________|_____________|															±±
±±  |lNegrito	   | Logico   | Informa se o conteudo sera exibido em Negrito			   | .F.				  | N„o         |															±±
±±  |______________|__________|____________________________________________________________|______________________|_____________|															±±
±±  |lItalico	   | Logico   | Informa se o conteudo sera exibido em Italico			   | .F.				  | N„o         |															±±
±±  |______________|__________|____________________________________________________________|______________________|_____________|															±±
±±  |cInterCor	   | Caracter | Cor interior da Cecula. Deve ser informado o codigo da     | Vazio		 		  | N„o         |															±±
±±	|		       |		  | cor em HTML. Referencias disponiveis em:				   | 			          |             |															±±
±±	|		       |		  | http://www.mxstudio.com.br/Conteudos/Dreamweaver/Cores.htm | 			          |             |															±±
±±  |______________|__________|____________________________________________________________|______________________|_____________|															±±
±±  |lTopBor	   | Logico   | Informa se tera borda superior			  			       | .F.				  | N„o         |															±±
±±  |______________|__________|____________________________________________________________|______________________|_____________|															±±
±±  |lLeftBor	   | Logico   | Informa se tera borda a esquerda						   | .F.				  | N„o         |															±±
±±  |______________|__________|____________________________________________________________|______________________|_____________|															±±
±±  |lBottomBor	   | Logico   | Informa se tera borda inferior							   | .F.				  | N„o         |															±±
±±  |______________|__________|____________________________________________________________|______________________|_____________|															±±
±±  |lRightBor	   | Logico   | Informa se tera borda a direita							   | .F.				  | N„o         |															±±
±±  |______________|__________|____________________________________________________________|______________________|_____________|															±±
±±  |lMescla 	   | Logico   | Informa se a celula sera mesclada 					       | .F.				  | N„o         |															±±
±±  |______________|__________|____________________________________________________________|______________________|_____________|															±±
±±  |nIniMescla    | Numerico | Informa posiÁ„o inicial da Mescla  						   | 0					  | N„o         |															±±
±±  |______________|__________|____________________________________________________________|______________________|_____________|															±±
±±  |nFimMescla    | Numerico | Informa posiÁ„o final da Mescla  						   | 0					  | N„o         |															±±
±±  |______________|__________|____________________________________________________________|______________________|_____________|															±±
±±																																															±±
±±  ------------------------------------------------------------------------------------------------------------									    									±±
±±  SaveXml()																																	    										±±
±±    																																														±±
±±  Sintaxe: ARSexcel():SaveXml(cDestino,cNomeArq,lConvXlsx)																																±±
±±   																																														±±
±±  DescriÁ„o: Gera arquivo																						 																			±±
±±    																																														±±
±±  Parametros: 																																											±±
±±  _____________________________________________________________________________________________________________________________															±±
±±  | Nome         | Tipo     | DescriÁ„o                         						   | Default              | ObrigatÛrio |															±±
±±  |----------------------------------------------------------------------------------------------------------------------------															±±
±±  |cDestino	   | Caracter | Diretorio para gravaÁ„o do arquivo 						   | Pasta de arquivos    | N„o         |															±±
±±	|		       |		  |                	      						   			   | temporarios          |             |															±±
±±  |______________|__________|____________________________________________________________|_____________________ |_____________|															±±
±±  |cNomeArq      | Caracter | Nome do arquivo sem extens„o       						   | Sequencial aleatorio | N„o         |															±±
±±	|		       |		  | conteudo numerico	              						   | 			          |             |															±±
±±  |______________|__________|____________________________________________________________|______________________|_____________|															±±
±±  |lConvXlsx	   | Logico   | Se for True, converte o arquivo Xml para o formato 		   | .F.				  | N„o         |															±±
±±	|		       |		  | Pasta de Trabalho Excel (.Xlsx). Para que o mesmo seja 	   | 			          |             |															±±
±±	|		       |		  | convertido, È necessario que o processo n„o seja em Job e  | 			          |             |															±±
±±	|		       |		  | a estaÁ„o do Client tenha o Excel instalado 		 	   |   			          |             |															±±
±±	|		       |		  | (vers„o 2007 ou superior)								   |   			          |             |															±±
±±  |______________|__________|____________________________________________________________|______________________|_____________|															±±
±±																																															±±
±±																																															±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
*/
Class ARSexcel 

	Data cIniXML   
	Data cFimXML   
	Data cIniPlan  
	Data cFimPlan  
	Data cIniLin   
	Data cFimLin   
	Data lJob		
	Data aPlanilha 
	Data aLinha    
	Data aCelula    
	Data aStyle    

	Method New(lJob) Constructor
	Method AddPlanilha(cTitulo,aColuna,nLinCong) 
	Method AddLinha(nAltura) 
	Method AddCelula(qConteudo,nDecimal,cAlinhamento,cFonte,nFonTam,cFonteCor,lNegrito,lItalico,cInterCor,lTopBor,lLeftBor,lBottomBor,lRightBor,lMescla,nIniMescla,nFimMescla,cFormNum) 
	Method SaltaCelula(nSalta)
	Method SaveXml(cDestino,cNomeArq,lConvXlsx)

EndClass  



Method New(lJobAt) Class ARSexcel

	local cDtXml := SubStr(DTOS(Date()),1,4) + "-" + SubStr(DTOS(Date()),5,2) + "-" + SubStr(DTOS(Date()),7,2)	  
	Default lJobAt := .F.

	::cIniXML := '<?xml version="1.0"?>'+CRLF;
	+'<?mso-application progid="Excel.Sheet"?>'+CRLF;
	+'<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"'+CRLF;
	+' xmlns:o="urn:schemas-microsoft-com:office:office"'+CRLF;
	+' xmlns:x="urn:schemas-microsoft-com:office:excel"'+CRLF;
	+' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"'+CRLF;
	+' xmlns:html="http://www.w3.org/TR/REC-html40">'+CRLF;
	+' <DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">'+CRLF;
	+'  <Author>'+AllTrim(UsrFullName(__cUserId))+'</Author>'+CRLF;
	+'  <LastAuthor>'+AllTrim(UsrFullName(__cUserId))+'</LastAuthor>'+CRLF;
	+'  <Created>'+cDtXml+'T'+Time()+'Z</Created>'+CRLF;
	+'  <LastSaved>'+cDtXml+'T'+Time()+'T'+Time()+'Z</LastSaved>'+CRLF;
	+'  <Company>Microsoft</Company>'+CRLF;
	+'  <Version>14.00</Version>'+CRLF;
	+' </DocumentProperties>'+CRLF;
	+' <OfficeDocumentSettings xmlns="urn:schemas-microsoft-com:office:office">'+CRLF;
	+'  <AllowPNG/>'+CRLF;
	+' </OfficeDocumentSettings>'+CRLF;
	+' <ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel">'+CRLF;
	+'  <WindowHeight>7995</WindowHeight>'+CRLF;
	+'  <WindowWidth>20115</WindowWidth>'+CRLF;
	+'  <WindowTopX>240</WindowTopX>'+CRLF;
	+'  <WindowTopY>150</WindowTopY>'+CRLF;
	+'  <ProtectStructure>False</ProtectStructure>'+CRLF;
	+'  <ProtectWindows>False</ProtectWindows>'+CRLF;
	+' </ExcelWorkbook>'+CRLF 

	::cFimXML := '</Workbook>'+CRLF 

	::lJob 		 := lJobAt
	::aLinha  	 := {}
	::aPlanilha  := {}
	::aStyle  	 := {}
	::aCelula 	 := {}	

Return



Method AddPlanilha(cTitulo,aColuna,nLinCong) Class ARSexcel

	Local nx

	Default aColuna  := {50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50}
	Default nLinCong := 0

	if !empty(::aCelula) 
		if empty(::cIniLin) .and. empty(::cFimLin) 
			::cIniLin  := '   <Row ss:AutoFitHeight="0" ss:Height="15">'+CRLF
			::cFimLin  := '   </Row>'+CRLF
		endif
		AADD(::aLinha,{ {::cIniLin,::cFimLin},::aCelula } ) 
		::aCelula := {}
		::cIniLin := ""
		::cFimLin := ""
	endif

	if !empty(::aLinha) 
		AADD(::aPlanilha,{ {::cIniPlan,::cFimPlan},::aLinha } ) 
		::aLinha := {}
	endif

	Default cTitulo := 'Plan'+cvaltochar(len(::aPlanilha)+1)
	::cIniLin  := ''
	::cFimLin  := ''

	::cIniPlan  := ' <Worksheet ss:Name="'+cTitulo+'">'+CRLF;
	+'  <Table x:FullColumns="1" x:FullRows="1" ss:DefaultRowHeight="12">'+CRLF   

	for nx:= 1 to len(aColuna)
		::cIniPlan  +='   <Column ss:AutoFitWidth="0" ss:Width="'+cvaltochar(aColuna[nx])+'"/>'+CRLF
	next nx	  

	::cFimPlan  := '  </Table>'+CRLF
	::cFimPlan  += '  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">'+CRLF
	::cFimPlan  += '   <PageSetup>'+CRLF
	::cFimPlan  += '    <Header x:Margin="0.31496062000000002"/>'+CRLF
	::cFimPlan  += '    <Footer x:Margin="0.31496062000000002"/>'+CRLF
	::cFimPlan  += '    <PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024"'+CRLF
	::cFimPlan  += '     x:Right="0.511811024" x:Top="0.78740157499999996"/>'+CRLF
	::cFimPlan  += '   </PageSetup>'+CRLF

	if nLinCong > 0
		::cFimPlan  += '   <Unsynced/>'+CRLF
		::cFimPlan  += '   <Selected/>'+CRLF
		::cFimPlan  += '   <FreezePanes/>'+CRLF
		::cFimPlan  += '   <FrozenNoSplit/>'+CRLF
		::cFimPlan  += '   <SplitHorizontal>'+Alltrim(Str(nLinCong))+'</SplitHorizontal>'+CRLF
		::cFimPlan  += '   <TopRowBottomPane>'+Alltrim(Str(nLinCong))+'</TopRowBottomPane>'+CRLF
		::cFimPlan  += '   <ActivePane>2</ActivePane>'+CRLF
	endif

	::cFimPlan  += '   <ProtectObjects>False</ProtectObjects>'+CRLF
	::cFimPlan  += '   <ProtectScenarios>False</ProtectScenarios>'+CRLF
	::cFimPlan  += '  </WorksheetOptions>'+CRLF
	::cFimPlan  += ' </Worksheet>'+CRLF

return 



Method AddLinha(nAltura) Class ARSexcel

	Default nAltura := 15  

	if !empty(::aCelula) .or. !empty(::cIniLin) 
		if empty(::cIniLin) .and. empty(::cFimLin) 
			::cIniLin  := '   <Row ss:AutoFitHeight="0" ss:Height="15">'+CRLF
			::cFimLin  := '   </Row>'+CRLF
		endif
		AADD(::aLinha,{ {::cIniLin,::cFimLin},::aCelula } ) 
		::cIniLin  := ''
		::cFimLin  := ''
		::aCelula := {}
	endif

	::cIniLin  := '   <Row ss:AutoFitHeight="0" ss:Height="'+cvaltochar(nAltura)+'">'+CRLF
	::cFimLin  := '   </Row>'+CRLF

return



Method AddCelula(qConteudo,nDecimal,cAlinhamento,cFonte,nFonTam,cFonteCor,lNegrito,lItalico,cInterCor,lTopBor,lLeftBor,lBottomBor,lRightBor,lMescla,nIniMescla,nFimMescla,cFormNum) Class ARSexcel 

	local nStyle		:= 0 
	local cStyle		:= ''  
	local cType			:= ''  
	local cCelula		:= ''
	local nPosPlan		:= 0 
	local nPosLin		:= 0 
	Default	qConteudo	:= nil
	Default nDecimal	:= 0 
	Default cAlinhamento:= 'L' 
	Default cFonte 		:= 'Arial'
	Default nFonTam		:= 8
	Default	cFonteCor	:= '000000'
	Default lNegrito	:= .F.
	Default lItalico	:= .F.
	Default	cInterCor	:= ''
	Default lTopBor		:= .F.
	Default lLeftBor	:= .F.
	Default lBottomBor	:= .F. 
	Default lRightBor	:= .F.
	Default lMescla		:= .F.
	Default nIniMescla	:= 0
	Default nFimMescla  := 0 
	Default cFormNum    := ''

	Do case
		case upper(cAlinhamento) == 'R' 
		cAlinhamento := 'Right'
		case upper(cAlinhamento) == 'C' 
		cAlinhamento := 'Center'
		Otherwise
		cAlinhamento := 'Left'
	Endcase

	cType := valtype(qConteudo)
	if cType = 'N'
		qConteudo := alltrim( StrTran( str( qConteudo ),",","." ) )   
	endif 

	cFonteCor := StrTran(cFonteCor,'#','')
	cInterCor := StrTran(cInterCor,'#','') 

	//Adiciona estiloc					
	if (nStyle := ASCANX(::aStyle, {|x| cAlinhamento + cvaltochar(lTopBor) + cvaltochar(lLeftBor) + cvaltochar(lBottomBor) + cvaltochar(lRightBor) + cFonte + cvaltochar(nFonTam) + cFonteCor + cvaltochar(lNegrito) + cvaltochar(lItalico) + cInterCor + cType + cvaltochar(nDecimal) + cFormNum ;
	== x[1] + cvaltochar(x[2]) + cvaltochar(x[3]) + cvaltochar(x[4]) + cvaltochar(x[5]) + x[6] + cvaltochar(x[7]) + x[8] + cvaltochar(x[9]) + cvaltochar(x[10]) + x[11] + x[12] + cvaltochar(x[13]) + x[14] } ) ) == 0 

		nStyle  := iif(len(::aStyle)>0,len(::aStyle)+1,1)
		cStyle	:= 	   '	<Style ss:ID="s'+strzero(nStyle,3)+'">'+CRLF

		cStyle	+=	   '     <Alignment ss:Horizontal="'+cAlinhamento+'" ss:Vertical="Bottom"/>'+CRLF

		if lTopBor .or. lLeftBor .or. lBottomBor .or. lRightBor
			cStyle	+= '     <Borders>'+CRLF
			if lBottomBor
				cStyle	+= '      <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
			endif
			if lLeftBor 
				cStyle	+= '      <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
			endif
			if lRightBor
				cStyle	+= '      <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
			endif
			if lTopBor	
				cStyle	+= '      <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF
			endif
			cStyle	+= '     </Borders>'+CRLF
		endif	

		cStyle	+= 	   '     <Font ss:FontName="'+cFonte+'" x:Family="Swiss" ss:Size="'+cvaltochar(nFonTam)+'" ss:Color="#'+cFonteCor+'" '+iif(lNegrito,'ss:Bold="1"','')+' '+iif(lItalico,'ss:Italic="1"','')+' />'+CRLF
		if !empty(cInterCor) 
			cStyle	+= '     <Interior ss:Color="#'+cInterCor+'" ss:Pattern="Solid"/>'+CRLF
		endif

		Do case
			case cType == 'N'  
			cStyle	+= '     <NumberFormat ss:Format="#,##0'
			if nDecimal > 0 
				cStyle	+= '.'+strzero(0,nDecimal)  
			endif
			if !empty(cFormNum) .and. ValType(cFormNum) == 'C'    
				if upper(cFormNum) == 'P' 
					cStyle	+= '%'
				endif	
			endif	
			cStyle	+= '"/>'+CRLF
			case cType == 'D'  	
			cStyle	+= '     <NumberFormat ss:Format="Short Date"/>'+CRLF  
			case cType == 'C'  	
			cStyle	+= '     <NumberFormat ss:Format="@"/>'+CRLF
			Otherwise
			cStyle	+= '     <NumberFormat/>'+CRLF
		Endcase

		cStyle	+= 	   '	</Style>'+CRLF 

		AADD(::aStyle,{cAlinhamento,lTopBor,lLeftBor,lBottomBor,lRightBor,cFonte,nFonTam,cFonteCor,lNegrito,lItalico,cInterCor,cType,nDecimal,cFormNum,cStyle})
	endif	

	//adiciona celula
	Do Case    
		case Empty(qConteudo)
		cCelula	+=	'    <Cell '+iif(lMescla,'ss:Index="'+Alltrim(str(nIniMescla))+'" ss:MergeAcross="'+Alltrim(str(nFimMescla))+'"','')+' ss:StyleID="s'+strzero(nStyle,3)+'"/>'+CRLF	
		Case cType == 'N' 
		cCelula	+=	'    <Cell '+iif(lMescla,'ss:Index="'+Alltrim(str(nIniMescla))+'" ss:MergeAcross="'+Alltrim(str(nFimMescla))+'"','')+' ss:StyleID="s'+strzero(nStyle,3)+'"><Data ss:Type="Number">'+qConteudo+'</Data></Cell>'+CRLF	
		Case cType == "D" 
		cCelula	+=	'    <Cell '+iif(lMescla,'ss:Index="'+Alltrim(str(nIniMescla))+'" ss:MergeAcross="'+Alltrim(str(nFimMescla))+'"','')+' ss:StyleID="s'+strzero(nStyle,3)+'"><Data ss:Type="DateTime">'+Substr(Dtos(qConteudo),1,4)+ '-'+Substr(Dtos(qConteudo),5,2)+ '-' + Substr(Dtos(qConteudo),7,2) +'T00:00:00.000</Data></Cell>'+CRLF
		Otherwise
		cCelula	+=	'    <Cell '+iif(lMescla,'ss:Index="'+Alltrim(str(nIniMescla))+'" ss:MergeAcross="'+Alltrim(str(nFimMescla))+'"','')+' ss:StyleID="s'+strzero(nStyle,3)+'"><Data ss:Type="String">'+fTxtXML(qConteudo)+'</Data></Cell>'+CRLF								
	End Case

	AADD( ::aCelula, cCelula )

return    



Method SaltaCelula(nSalta) Class ARSexcel 
	local nr       := 0
	Default nSalta := 1 

	if ValType(nSalta) <> "N"
		nSalta := 1
	endif

	if nSalta > 0
		for nr:=1 to nSalta
			::AddCelula()
		next nr	
	endif 
return



Method SaveXml(cDestino,cNomeArq,lConvXlsx) Class ARSexcel  

	private lEnd		:= .F.
	private cArqDest 	:= ''
	Default cDestino	:= AllTrim(GetTempPath()) 
	Default cNomeArq	:= DTOS(Date())+StrTran(Time(),":","")  
	Default lConvXlsx	:= .F.
	cNomeArq += ".xml" 

	if !empty(::aCelula) 
		if empty(::cIniLin) .and. empty(::cFimLin) 
			::cIniLin  := '   <Row ss:AutoFitHeight="0" ss:Height="15">'+CRLF
			::cFimLin  := '   </Row>'+CRLF
		endif
		AADD(::aLinha,{ {::cIniLin,::cFimLin},::aCelula } ) 
		::aCelula := {}
		::cIniLin := ""
		::cFimLin := ""
	endif

	if !empty(::aLinha) 
		AADD(::aPlanilha,{ {::cIniPlan,::cFimPlan},::aLinha } ) 
		::aLinha := {}    
		::cIniPlan := ""
		::cFimPlan := ""
	endif  

	if ::lJob
		GeraXML(cDestino+cNomeArq,::aStyle,::aPlanilha,::cIniXML,::cFimXML,lEnd,.T.,lConvXlsx) 
		if !file(cArqDest) .and. !file(cDestino+cNomeArq)
			Conout("Erro ao criar o arquvio. Favor verificar a configura?o de acesso ao diretorio selecionado.")   	
		endif
	else
		Processa({ |lEnd| GeraXML(cDestino+cNomeArq,::aStyle,::aPlanilha,::cIniXML,::cFimXML,@lEnd,.F.,lConvXlsx) },"Aguarde...","Montando Planilha",.T.)
		if file(cArqDest)
			If ApOleClient("MsExcel")
				oExcelApp := MsExcel():New() 
				oExcelApp:SetVisible(.T.)
				oExcelApp:WorkBooks:Open(cArqDest) 
				oExcelApp:Destroy() 
			endif
		elseif file(cDestino+cNomeArq)
			If ApOleClient("MsExcel")
				oExcelApp := MsExcel():New() 
				oExcelApp:SetVisible(.T.)
				oExcelApp:WorkBooks:Open(cDestino+cNomeArq) 
				oExcelApp:Destroy() 
			endif
		else 
			MsgAlert("Erro ao criar o arquvio. Favor verificar a configura?o de acesso ao diretorio selecionado.","Atencao!")
		endif	
	endif

return    



//Tratamento para texto
Static Function fTxtXML(cString)
	Local cByte     := ""
	local ni        := 0
	Local s1		:= "·ÈÌÛ˙" + "¡…Õ”⁄" + "‚ÍÓÙ˚" + "¬ Œ‘€" + "‰ÎÔˆ¸" + "ƒÀœ÷‹" + "‡ËÏÚ˘" + "¿»Ã“Ÿ"  + "„ı√’" + "Á«" + "<>&*'" + '"'
	Local s2		:= "aeiou" + "AEIOU" + "aeiou" + "AEIOU" + "aeiou" + "AEIOU" + "aeiou" + "AEIOU"  + "aoAO" + "cC" + "     " + " "
	Local nPos   	:= 0
	Local cMaiorMin := "&lt;"
	Local cMenorMin := "&gt;"  
	Local cMaiorMai := "&LT;"
	Local cMenorMai := "&GT;"
	Local cRet   	:= ""
	local nByte 
	default cString := "" 

	If cMaiorMin $ cString .or. cMenorMin $ cString .or. cMaiorMai $ cString .or. cMenorMai $ cString 
		cString := strTran( cString, cMaiorMin, " " ) 
		cString := strTran( cString, cMenorMin, " " ) 
		cString := strTran( cString, cMaiorMai, " " ) 
		cString := strTran( cString, cMenorMai, " " )
	EndIf

	For ni := 1 To Len(cString)
		cByte := Substr(cString,ni,1)
		nByte := ASC(cByte)
		nPos  := At(cByte,s1)
		If nPos > 0
			cByte := Substr(s2,nPos,1)
		EndIf
		cRet += cByte
	Next 

Return(AllTrim(cRet))



Static function GeraXML(cNomeArq,aStyle,aPlanilha,cIniXML,cFimXML,lEnd,lJob,lConvXlsx) 

	local aAreaXml	 := GetArea() 
	local nHandle    := fCreate(cNomeArq) 
	local nTotItens	 := 0 
	local nContItens := 0 
	local cTempTxt	 := ""  
	local nLimitCarc := 1000000
	Local nCont
	Local nv
	Local nC
	Local nL
	Local nP

	ProcRegua(0)

	If nHandle == -1 
		if lJob
			ConOut("Aten?o","Erro ao criar o arquvio " + cNomeArq + ". Favor verificar a configura?o do micro.")
		else 
			MsgAlert("Aten?o","Erro ao criar o arquvio " + cNomeArq + ". Favor verificar a configura?o do micro.","Atencao!")
		endif
		RestArea(aAreaXml)
		Return
	EndIf 

	//FWrite(nHandle,cIniXML)
	cTempTxt += cIniXML 
	cTempTxt += '<Styles>'+CRLF 
	cTempTxt += '	<Style ss:ID="Default" ss:Name="Normal">'+CRLF  
	cTempTxt += '	 <Alignment ss:Vertical="Bottom"/>'+CRLF
	cTempTxt += '	 <Borders/>'+CRLF
	cTempTxt += '	 <Font ss:FontName="Arial" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>'+CRLF
	cTempTxt += '	 <Interior/>'+CRLF
	cTempTxt += '	 <NumberFormat/>'+CRLF
	cTempTxt += '	 <Protection/>'+CRLF
	cTempTxt += '	</Style>'+CRLF
	FWrite(nHandle,cTempTxt)
	cTempTxt := ""

	if !lJob //conta registros
		nTotItens := len(aStyle)
		for nCont:=1 to len(aPlanilha) 
			nTotItens += len(aPlanilha[nCont,2]) 
		next nCont
	endif     
	nTotItens += 1          
	ProcRegua(nTotItens)

	//Estilos
	for nv:=1 to len(aStyle)
		if (len(cTempTxt)+len(aStyle[nv,15])) > nLimitCarc
			FWrite(nHandle,cTempTxt)
			cTempTxt := ""
		endif 
		cTempTxt += aStyle[nv,15]
		if !lJob
			nContItens++  	
			IncProc("Montando Planilha...  - Status: " + IIF((nContItens/nTotItens)*100 <= 99, StrZero((nContItens/nTotItens)*100,2), STRZERO(99,2)) + "%")	
		endif      
	next nv	
	cTempTxt += '</Styles>'+CRLF
	FWrite(nHandle,cTempTxt) 
	cTempTxt := ""

	//sheet
	for nP:=1 to len(aPlanilha)

		if lEnd 
			Exit
		endif

		cTempTxt += aPlanilha[nP,1,1] //Inicio da planilha 

		for nL:=1 to len(aPlanilha[nP,2]) //adiciona linhas 

			if lEnd 
				Exit
			endif

			if (len(cTempTxt)+len(aPlanilha[nP,2,nL,1,1])) > nLimitCarc
				FWrite(nHandle,cTempTxt)
				cTempTxt := ""
			endif
			cTempTxt += aPlanilha[nP,2,nL,1,1] //Inicio da linha

			for nC:=1 to len(aPlanilha[nP,2,nL,2]) //adiciona celulas

				if (len(cTempTxt)+len(aPlanilha[nP,2,nL,2,nC])) > nLimitCarc
					FWrite(nHandle,cTempTxt)
					cTempTxt := ""
				endif 
				cTempTxt += aPlanilha[nP,2,nL,2,nC] 

			next nC

			if (len(cTempTxt)+len(aPlanilha[nP,2,nL,1,2])) > nLimitCarc
				FWrite(nHandle,cTempTxt)
				cTempTxt := ""
			endif  
			cTempTxt += aPlanilha[nP,2,nL,1,2] //Fim da linha

			if !lJob
				nContItens++  	
				IncProc("Montando Planilha...  - Status: " + IIF((nContItens/nTotItens)*100 <= 99, StrZero((nContItens/nTotItens)*100,2), STRZERO(99,2)) + "%")	
			endif
		next nL

		if (len(cTempTxt)+len(aPlanilha[nP,1,2])) > nLimitCarc
			FWrite(nHandle,cTempTxt)
			cTempTxt := ""
		endif  
		cTempTxt += aPlanilha[nP,1,2] //Fim da planilha

		FWrite(nHandle,cTempTxt)
		cTempTxt := ""

	next nP
	FWrite(nHandle,cFimXML) 
	fClose(nHandle) 

	if lEnd .and. file(cNomeArq)
		if lJob
			ConOut("Relatorio Cancelado pelo usuario")
		else 
			MsgAlert("Relatorio Cancelado pelo usuario","Atencao!")
		endif
		FErase(cNomeArq) 
	endif   

	if file(cNomeArq)
		if lConvXlsx      
			if lJob
				ConvertXlsx(cNomeArq,lJob)
			else
				Processa({ || ConvertXlsx(cNomeArq,lJob)},"Gerando arquivo, aguarde...","Planilha Excel") 
			endif		   	
		endif    
	endif		

	if !lJob
		nContItens++  	
		IncProc("Montando Planilha...  - Status: " + IIF((nContItens/nTotItens)*100 <= 99, StrZero((nContItens/nTotItens)*100,2), STRZERO(100,3)) + "%")	
	endif 

	RestArea(aAreaXml)
return     



static Function ConvertXlsx(cArqOri,lJob)
	Local nHandler 
	Local cVbs := ''
	Local cDrive := ''
	Local cDir   := ''
	Local cNome  := ''
	Local cExt   := '' 
	local cArqVbs := '' 
	local lContinua := .F.    
	if !lJob
		ProcRegua(0) 
	endif	
	if !empty(cArqOri) .and. ApOleClient('MsExcel') 
		lContinua := .T.
		SplitPath(cArqOri,@cDrive,@cDir,@cNome,@cExt)
		cArqDest := cDrive+cDir+cNome+".xlsx"
		cArqVbs := AllTrim(GetTempPath())+cNome+".vbs"
	endif
	cVbs := 'Dim objXLApp, objXLWb '+CRLF
	cVbs += 'Set objXLApp = CreateObject("Excel.Application") '+CRLF
	cVbs += 'objXLApp.Visible = False '+CRLF
	cVbs += 'Set objXLWb = objXLApp.Workbooks.Open("'+cArqOri+'") '+CRLF
	cVbs += 'objXLWb.SaveAs "'+cArqDest+'", 51 '+CRLF
	cVbs += 'objXLWb.Close (true) '+CRLF
	cVbs += 'Set objXLWb = Nothing '+CRLF
	cVbs += 'objXLApp.Quit '+CRLF
	cVbs += 'Set objXLApp = Nothing '+CRLF
	if lContinua
		nHandler := FCreate(cArqVbs)
		If nHandler <> -1 
			FWrite(nHandler, cVbs)
			FClose(nHandler)                                   
			if WaitRun('cscript.exe '+cArqVbs,0) == 0 
				if file(cArqDest)
					if file(cArqOri)
						FErase(cArqOri)
					endif
					if file(cArqVbs)
						FErase(cArqVbs)
					endif
				else
					lContinua := .F.
				endif
			else
				lContinua := .F.
			endif
		else
			lContinua := .F.	  	 
		endif
	endif 
	if !lContinua
		if file(cArqDest)
			FErase(cArqDest)
		endif
		if file(cArqVbs)
			FErase(cArqVbs)
		endif
	endif
Return              






user function xteste56()

	oExcel := ARSexcel():New()             

	oExcel:AddPlanilha('Planilha1',{90,90,90})

	oExcel:AddLinha(40)
	oExcel:AddCelula('Titulo Teste 1',0,'C','Arial',14,'#FF4040',.T.,.T.,'#9AFF9A',.T.,.T.,.T.,.T.,.T.,1,2) 

	oExcel:AddLinha(30)//salta linha   
	oExcel:AddLinha(30)
	oExcel:AddCelula('Nome',0,'C','Arial',10,'#0000FF',.T.,.F.,'#FF0000', .T., .T., .T.,.T.,.F.)
	oExcel:AddCelula('Data',0,'C','Arial',10,'#0000FF',.T.,.F.,'#FF0000', .T., .T., .T.,.T.,.F.)
	oExcel:AddCelula('Valor',0,'C','Arial',10,'#0000FF',.T.,.F.,'#FF0000', .T., .T., .T.,.T.,.F.)

	oExcel:AddLinha(30)
	oExcel:AddCelula('Pessoa1',0,'L','Times New Roman',12,'#000000',.F.,.F.,'#D3D3D3', .T., .T., .T.,.T.,.F.)   
	oExcel:AddCelula(ctod("02/04/2014"),0,'R','Times New Roman',12,'#000000',.F.,.F.,'#D3D3D3', .T., .T., .T.,.T.,.F.) 
	oExcel:AddCelula(4500.456,3,'R','Times New Roman',12,'#000000',.F.,.F.,'#D3D3D3', .T., .T., .T.,.T.,.F.)

	oExcel:AddLinha(30)
	oExcel:AddCelula('Pessoa2',0,'L','Times New Roman',12,'#000000',.F.,.F.,'#D3D3D3', .T., .T., .T.,.T.,.F.)   
	oExcel:AddCelula(ctod("10/04/2014"),0,'R','Times New Roman',12,'#000000',.F.,.F.,'#D3D3D3', .T., .T., .T.,.T.,.F.) 
	oExcel:AddCelula(450689,2,'R','Times New Roman',12,'#000000',.F.,.F.,'#D3D3D3', .T., .T., .T.,.T.,.F.)

	oExcel:AddLinha(30)
	oExcel:AddCelula('Pessoa3',0,'L','Times New Roman',12,'#000000',.F.,.F.,'#D3D3D3', .T., .T., .T.,.T.,.F.)   
	oExcel:AddCelula(ctod("11/04/2014"),0,'R','Times New Roman',12,'#000000',.F.,.F.,'#D3D3D3', .T., .T., .T.,.T.,.F.) 
	oExcel:AddCelula(5006.89,2,'R','Times New Roman',12,'#000000',.F.,.F.,'#D3D3D3', .T., .T., .T.,.T.,.F.)

	oExcel:AddLinha(30)
	oExcel:AddLinha(30)
	oExcel:AddLinha(30)
	oExcel:AddCelula('Pessoa4',0,'L','Times New Roman',12,'#000000',.F.,.F.,'#D3D3D3', .T., .T., .T.,.T.,.F.)   
	oExcel:AddCelula(ctod("13/04/2014"),0,'R','Times New Roman',12,'#000000',.F.,.F.,'#D3D3D3', .T., .T., .T.,.T.,.F.) 
	oExcel:AddCelula(55500.456,3,'R','Times New Roman',12,'#000000',.F.,.F.,'#D3D3D3', .T., .T., .T.,.T.,.F.)

	oExcel:AddLinha(30)
	oExcel:AddCelula('Pessoa5',0,'L','Times New Roman',12,'#000000',.F.,.F.,'#D3D3D3', .T., .T., .T.,.T.,.F.)   
	oExcel:AddCelula(ctod("16/04/2014"),0,'R','Times New Roman',12,'#000000',.F.,.F.,'#D3D3D3', .T., .T., .T.,.T.,.F.) 
	oExcel:AddCelula(660689,2,'R','Times New Roman',12,'#000000',.F.,.F.,'#D3D3D3', .T., .T., .T.,.T.,.F.)

	oExcel:AddLinha(30)
	oExcel:AddCelula('Pessoa6',0,'L','Times New Roman',12,'#000000',.F.,.F.,'#D3D3D3', .T., .T., .T.,.T.,.F.)   
	oExcel:AddCelula(ctod("19/04/2014"),0,'R','Times New Roman',12,'#000000',.F.,.F.,'#D3D3D3', .T., .T., .T.,.T.,.F.) 
	oExcel:AddCelula(78906.89,2,'R','Times New Roman',12,'#000000',.F.,.F.,'#D3D3D3', .T., .T., .T.,.T.,.F.)


	oExcel:AddPlanilha('Planilha2',{90,90,90})

	oExcel:AddLinha(40)
	oExcel:AddCelula('Titulo Teste 2',0,'C','Arial',14,'#FF4040',.T.,.T.,'#9AFF9A',.T.,.T.,.T.,.T.,.T.,1,2) 

	oExcel:AddLinha(30)//salta linha   
	oExcel:AddLinha(30)
	oExcel:AddCelula('Nome',0,'C','Arial',10,'#0000FF',.T.,.F.,'#FF0000', .T., .T., .T.,.T.,.F.)
	oExcel:AddCelula('Data',0,'C','Arial',10,'#0000FF',.T.,.F.,'#FF0000', .T., .T., .T.,.T.,.F.)
	oExcel:AddCelula('Valor',0,'C','Arial',10,'#0000FF',.T.,.F.,'#FF0000', .T., .T., .T.,.T.,.F.)

	oExcel:AddLinha(30)
	oExcel:AddCelula('Pessoa7',0,'L','Times New Roman',12,'#000000',.F.,.F.,'#D3D3D3', .T., .T., .T.,.T.,.F.)   
	oExcel:AddCelula(ctod("20/04/2014"),0,'R','Times New Roman',12,'#000000',.F.,.F.,'#D3D3D3', .T., .T., .T.,.T.,.F.) 
	oExcel:AddCelula(45165.456,3,'R','Times New Roman',12,'#000000',.F.,.F.,'#D3D3D3', .T., .T., .T.,.T.,.F.)

	oExcel:AddLinha(30)
	oExcel:AddCelula('Pessoa8',0,'L','Times New Roman',12,'#000000',.F.,.F.,'#D3D3D3', .T., .T., .T.,.T.,.F.)   
	oExcel:AddCelula(ctod("22/04/2014"),0,'R','Times New Roman',12,'#000000',.F.,.F.,'#D3D3D3', .T., .T., .T.,.T.,.F.) 
	oExcel:AddCelula(15619,2,'R','Times New Roman',12,'#000000',.F.,.F.,'#D3D3D3', .T., .T., .T.,.T.,.F.)

	oExcel:AddLinha(30)
	oExcel:AddCelula('Pessoa9',0,'L','Times New Roman',12,'#000000',.F.,.F.,'#D3D3D3', .T., .T., .T.,.T.,.F.)   
	oExcel:AddCelula(ctod("23/04/2014"),0,'R','Times New Roman',12,'#000000',.F.,.F.,'#D3D3D3', .T., .T., .T.,.T.,.F.) 
	oExcel:AddCelula(50156606.8,2,'R','Times New Roman',12,'#000000',.F.,.F.,'#D3D3D3', .T., .T., .T.,.T.,.F.)

	oExcel:AddLinha(30)//salta linha
	oExcel:AddLinha(30) //salta linha
	oExcel:AddLinha(30) 
	oExcel:AddCelula('Pessoa10',0,'L','Times New Roman',12,'#000000',.F.,.F.,'#D3D3D3', .T., .T., .T.,.T.,.F.)   
	oExcel:AddCelula(ctod("26/04/2014"),0,'R','Times New Roman',12,'#000000',.F.,.F.,'#D3D3D3', .T., .T., .T.,.T.,.F.) 
	oExcel:AddCelula(616500.456,3,'R','Times New Roman',12,'#000000',.F.,.F.,'#D3D3D3', .T., .T., .T.,.T.,.F.)

	oExcel:AddLinha(30)
	oExcel:AddCelula('Pessoa11',0,'L','Times New Roman',12,'#000000',.F.,.F.,'#D3D3D3', .T., .T., .T.,.T.,.F.)   
	oExcel:AddCelula(ctod("28/04/2014"),0,'R','Times New Roman',12,'#000000',.F.,.F.,'#D3D3D3', .T., .T., .T.,.T.,.F.) 
	oExcel:AddCelula(7897989,2,'R','Times New Roman',12,'#000000',.F.,.F.,'#D3D3D3', .T., .T., .T.,.T.,.F.)

	oExcel:AddLinha(30)
	oExcel:AddCelula('Pessoa12',0,'L','Times New Roman',12,'#000000',.F.,.F.,'#D3D3D3', .T., .T., .T.,.T.,.F.)   
	oExcel:AddCelula(ctod("30/04/2014"),0,'R','Times New Roman',12,'#000000',.F.,.F.,'#D3D3D3', .T., .T., .T.,.T.,.F.) 
	oExcel:AddCelula(7654606.89,2,'R','Times New Roman',12,'#000000',.F.,.F.,'#D3D3D3', .T., .T., .T.,.T.,.F.)


	oExcel:SaveXml("C:\","Arquivo_Teste",.f.) 

return

