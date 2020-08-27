/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ NFSTXT   ³ Autor ³ Heraildo C. de Freitas³ Data ³ 21/06/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ EXPORTA NOTAS FISCAIS DE SERVIÇO PARA ARQUIVO TXT PARA     ³±±
±±³          ³ IMPORTAÇÃO PELA PREFEITURA DE VIANA-ES                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

#include "rwmake.ch"
#include "topconn.ch"

user function nfstxt(_cnota,_cserie)                    

if _cnota==nil
	cperg:=pad("NFSTXT",len(sx1->x1_grupo))
	putsx1(cperg,"01","Da nota                       ","","","mv_ch1","C",09,0,,"G",,"   ",,,"mv_par01")
	putsx1(cperg,"02","Ate a nota                    ","","","mv_ch2","C",09,0,,"G",,"   ",,,"mv_par02")
	putsx1(cperg,"03","Da serie                      ","","","mv_ch3","C",03,0,,"G",,"   ",,,"mv_par03")
	putsx1(cperg,"04","Ate a serie                   ","","","mv_ch4","C",03,0,,"G",,"   ",,,"mv_par04")
	putsx1(cperg,"05","Local para gravação           ","","","mv_ch4","C",40,0,,"G",,"   ",,,"mv_par05")
	
	if pergunte(cperg,.t.) .and. msgyesno("Confirma exportação das notas fiscais?")
		_cdir:=alltrim(mv_par05)
		if right(_cdir,1)<>"\"
			_cdir+="\"
		endif
		
		processa({|| _exporta()},"Exporta NFS TXT")
		
	endif
else
	mv_par01:=_cnota
	mv_par02:=_cnota
	mv_par03:=_cserie
	mv_par04:=_cserie
	mv_par05:=getnewpar("MV_NFSTXT","c:\nfstxt\")
	
	_cdir:=alltrim(mv_par05)
	
	processa({|| _exporta()},"Exporta NFS TXT")
	
endif
return()

static function _exporta()
procregua(0)
incproc()

makedir(_cdir)

sf2->(dbsetorder(1))
sf2->(dbseek(xfilial("SF2")+mv_par01,.t.))
while ! sf2->(eof()) .and. sf2->f2_filial==xfilial("SF2") .and. sf2->f2_doc<=mv_par02
	
	if sf2->f2_serie>=mv_par03 .and. sf2->f2_serie<=mv_par04
		
		incproc("Exportando NF "+sf2->f2_doc)
		
		sa1->(dbsetorder(1))
		sa1->(dbseek(xfilial("SA1")+sf2->f2_cliente+sf2->f2_loja))
		_carq:="envio_"+alltrim(sm0->m0_cgc)+alltrim(sf2->f2_doc)+".txt"
		
		if file(_cdir+"\"+_carq)
			ferase(_cdir+"\"+_carq)
		endif
		
		_nhandle:=fcreate(_cdir+"\"+_carq,0)
		
		_nseq:=1
		
		// Registro Tipo 1 – Header do Arquivo
		fwrite(_nhandle,"1") // 1-Tipo do Registro
		fwrite(_nhandle,"106") // 2-Versão do Layout
		fwrite(_nhandle,pad(sm0->m0_inscm,26)) // 3-Inscrição Municipal do Prestador
		fwrite(_nhandle,"2") // 4-Indicador de CPF/CNPJ do Prestador
		fwrite(_nhandle,pad(sm0->m0_cgc,14)) // 5-CNPJ ou CPF do Prestador
		fwrite(_nhandle,"4") // 6-Optante pelo Simples
		fwrite(_nhandle,dtos(sf2->f2_emissao)) // 7-Data de Início do Período
		fwrite(_nhandle,dtos(sf2->f2_emissao)) // 8-Data de Fim do Período
		fwrite(_nhandle,strzero(1,5)) // 9-Quantidade de NFS-e informadas
		fwrite(_nhandle,"2") // 10-Quantidade de Casas Decimais para o Valor de Serviço
		fwrite(_nhandle,"2") // 11-Quantidade de Casas Decimais para a Quantidade de um Serviço
		fwrite(_nhandle,space(322)) // 12-Brancos
		fwrite(_nhandle,strzero(_nseq++,8)) // 13-Sequencial do registro
		fwrite(_nhandle,chr(13)+chr(10)) // QUEBRA DE LINHA
		
		// Registro Tipo 2 – Cabeçalho da NFS-e
		fwrite(_nhandle,"2") // 1-Tipo do Registro
		fwrite(_nhandle,strzero(val(sf2->f2_doc),20)) // 2-Seqüencial da NFS-e
		fwrite(_nhandle,dtos(sf2->f2_emissao)+strtran(sf2->f2_hora,":","")+"00") // 3-Data e Hora da NFS-e
		fwrite(_nhandle,if(sf2->f2_reciss=="1","R","N")) // 4-Tipo de Recolhimento
		fwrite(_nhandle,"T") // 5-Situação da Nota Fiscal
		fwrite(_nhandle,space(8)) // 6-Data de Cancelamento
		fwrite(_nhandle,strzero(val(tabela("AA",sa1->a1_est)),2)+sa1->a1_cod_mun) // 7-Município de prestação do serviço
		fwrite(_nhandle,strzero(sf2->f2_valbrut*100,15)) // 8-Valor Total dos Serviços
		fwrite(_nhandle,strzero(0,15)) // 9-Valor Total das Deduções
		fwrite(_nhandle,strzero(sf2->f2_valpis*100,15)) // 10-Valor da retenção do PIS
		fwrite(_nhandle,strzero(sf2->f2_valcofi*100,15)) // 11-Valor da retenção do COFINS
		fwrite(_nhandle,strzero(sf2->f2_valinss*100,15)) // 12-Valor da retenção do INSS
		fwrite(_nhandle,strzero(sf2->f2_valirrf*100,15)) // 13-Valor da retenção do IR
		fwrite(_nhandle,strzero(sf2->f2_valcsll*100,15)) // 14-Valor da retenção do CSLL
		fwrite(_nhandle,strzero(sf2->f2_valiss*100,15))  // 15-Valor do ISSQN
		fwrite(_nhandle,if(sm0->m0_codmun==strzero(val(tabela("AA",sa1->a1_est)),2)+sa1->a1_cod_mun,"M","F")) // 16-Local da Prestação
		fwrite(_nhandle,strzero(0,20)) // 17-Seqüencial da NFS-e à ser Substituída
		fwrite(_nhandle,strzero(0,15)) // 18-Outros Descontos
		fwrite(_nhandle,space(183)) // 19-Brancos
		fwrite(_nhandle,strzero(_nseq++,8)) // 20-Sequencial do registro
		fwrite(_nhandle,chr(13)+chr(10)) // QUEBRA DE LINHA
		
		// Registro Tipo 3 – Identificação do Tomador da NFS-e
		fwrite(_nhandle,"3") // 1-Tipo do Registro
		fwrite(_nhandle,strzero(val(sf2->f2_doc),20)) // 2-Seqüencial da NFS-e
		fwrite(_nhandle,if(sa1->a1_pessoa=="F","1","2")) // 3-Indicador de CPF/CNPJ do Tomador
		fwrite(_nhandle,pad(sa1->a1_cgc,14)) // 4-CNPJ,  CPF do Tomador
		fwrite(_nhandle,pad(sa1->a1_nome,50)) // 5-Nome do Tomador
		fwrite(_nhandle,pad(sa1->a1_nreduz,50)) // 6-Nome Fantasia
		fwrite(_nhandle,pad(fisgetend(sa1->a1_end,sa1->a1_est)[1],53)) // 7-Tipo de Endereço do Tomador / 8-Endereço do Tomador
		fwrite(_nhandle,pad(fisgetend(sa1->a1_end,sa1->a1_est)[3],10)) // 9-Número do Endereço do Tomador
		fwrite(_nhandle,pad(fisgetend(sa1->a1_end,sa1->a1_est)[4],20)) // 10-Complemento do Endereço do Tomador
		fwrite(_nhandle,pad(sa1->a1_bairro,30)) // 11-Bairro do Tomador
		fwrite(_nhandle,pad(sa1->a1_mun,50)) // 12-Cidade do Tomador
		fwrite(_nhandle,sa1->a1_est) // 13-UF do Tomador
		fwrite(_nhandle,sa1->a1_cep) // 14-CEP do Tomador
		fwrite(_nhandle,pad(sa1->a1_email,60)) // 15-E-Mail do Tomador
		fwrite(_nhandle,pad(sa1->a1_inscr,20)) // 16-Inscrição Estadual Tomador
		fwrite(_nhandle,space(2)) // 17-Brancos
		fwrite(_nhandle,strzero(_nseq++,8)) // 18-Sequencial do registro
		fwrite(_nhandle,chr(13)+chr(10)) // QUEBRA DE LINHA
		
		sd2->(dbsetorder(3))
		sd2->(dbseek(xfilial("SD2")+sf2->f2_doc+sf2->f2_serie))
		sc5->(dbsetorder(1))
		sc5->(dbseek(xfilial("SC5")+sd2->d2_pedido))
		
		// Registro Tipo 4 – Observação da NFS-e
		fwrite(_nhandle,"4") // 1-Tipo do Registro
		fwrite(_nhandle,strzero(val(sf2->f2_doc),20)) // 2-Seqüencial da NFS-e
		fwrite(_nhandle,pad(sc5->c5_mennota,255)) // 3-Observação da Nota
		fwrite(_nhandle,space(115)) // 4-Brancos
		fwrite(_nhandle,strzero(_nseq++,8)) // 5-Sequencial do registro
		fwrite(_nhandle,chr(13)+chr(10)) // QUEBRA DE LINHA
		
		while ! sd2->(eof()) .and.;
			sd2->d2_filial==xfilial("SD2") .and.;
			sd2->d2_doc==sf2->f2_doc .and.;
			sd2->d2_serie==sf2->f2_serie
			
			sb1->(dbsetorder(1))
			sb1->(dbseek(xfilial("SB1")+sd2->d2_cod))
			sc6->(dbsetorder(1))
			sc6->(dbseek(xfilial("SC6")+sd2->d2_pedido+sd2->d2_itempv))
			
			// Registro Tipo 5 – Descrição do Serviço Realizado
			fwrite(_nhandle,"5") 							// 1-Tipo do Registro
			fwrite(_nhandle,strzero(val(sf2->f2_doc),20)) 	// 2-Seqüencial da NFS-e
			fwrite(_nhandle,pad(sb1->b1_ycodsrv,4)) 		// 3-Código do serviço prestado
			//fwrite(_nhandle,pad(transform(sb1->b1_ycodsrv,"@R 99.99"),20)) // 4-Código Tributação Município
		
			If Len(alltrim(sb1->b1_ycodsrv)) == 3
				 fwrite(_nhandle,pad(transform(sb1->b1_ycodsrv,"@R 9.99"),20)) // 4-Código Tributação Município
			Else
				 fwrite(_nhandle,pad(transform(sb1->b1_ycodsrv,"@R 99.99"),20)) // 4-Código Tributação Município
			EndIf
		
			fwrite(_nhandle,strzero(sd2->d2_prcven*100,15)) // 5-Valor do Serviço
			fwrite(_nhandle,strzero(0,15)) // 6-Valor Dedução
			fwrite(_nhandle,strzero(sd2->d2_aliqiss*100,4)) // 7-Alíquota
			fwrite(_nhandle,pad(sd2->d2_um,20)) // 8-Unidade
			fwrite(_nhandle,strzero(sd2->d2_quant*100,8)) // 9-Quantidade
			fwrite(_nhandle,pad(sc6->c6_descri,255)) // 10-Descrição do Serviço
			fwrite(_nhandle,space(20)) // 11-Alvará
			fwrite(_nhandle,space(9)) // 12-Brancos
			fwrite(_nhandle,strzero(_nseq++,8)) // 13-Sequencial do registro
			fwrite(_nhandle,chr(13)+chr(10)) // QUEBRA DE LINHA
			
			sd2->(dbskip())
		end
		
		// Registro Tipo 6 – Indicador de Final de Arquivo
		fwrite(_nhandle,"6") // 1-Tipo do Registro
		fwrite(_nhandle,space(390)) // 2-Brancos
		fwrite(_nhandle,strzero(_nseq++,8)) // 13-Sequencial do registro
		fwrite(_nhandle,chr(13)+chr(10)) // QUEBRA DE LINHA
		
		fclose(_nhandle)
	endif
	
	sf2->(dbskip())
end
return()
