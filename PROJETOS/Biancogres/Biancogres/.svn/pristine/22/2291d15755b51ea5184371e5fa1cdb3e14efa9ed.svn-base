#include "rwmake.ch" 

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Wanisay
Programa  := BIA468
Empresa   := Biancogres Cerêmicas S/A
Data      := 
Uso       := Financeiro  
Aplicação := Altera Vendedor/Comissão de Titulos de RA
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

User Function BIA468()

Pergunte("BIA468")

DbSelectArea("SE1")
DbSetOrder(2)
IF DbSeek(xFilial("SE1")+MV_PAR06+MV_PAR07+MV_PAR01+MV_PAR02+MV_PAR03+"RA ")
	
	WHILE SE1->E1_PREFIXO == MV_PAR01 .AND. ;
		SE1->E1_NUM       == MV_PAR02 .AND. ;
		SE1->E1_PARCELA   == MV_PAR03 .AND. ;
		SE1->E1_TIPO      == "RA "    .AND. ;
		SE1->E1_CLIENTE   == MV_PAR06 .AND. ;
		SE1->E1_LOJA      == MV_PAR07 .AND. ;
		!Eof()
		
		IF SE1->E1_SALDO == SE1->E1_VALOR
			DbSelectArea("SA1")
			DbSetOrder(1)
			DbSeek(xFilial()+MV_PAR04+MV_PAR05,.T.)
			
			RecLock("SE1")
			Replace E1_CLIENTE WITH MV_PAR04
			Replace E1_LOJA    WITH MV_PAR05
			Replace E1_NOMCLI  WITH SA1->A1_NREDUZ
			Replace E1_YUFCLI  WITH SA1->A1_EST
			
			IF MV_PAR08 == 1				//BIANCOGRES
				Replace E1_VEND1  WITH SA1->A1_VEND
				Replace E1_VEND2  WITH SA1->A1_YVENDB2 
				Replace E1_VEND3  WITH SA1->A1_YVENDB3				
				Replace E1_COMIS1 WITH SA1->A1_COMIS
				Replace E1_COMIS2 WITH SA1->A1_YCOMB2 
				Replace E1_COMIS3 WITH SA1->A1_YCOMB3				
			ELSEIF MV_PAR08 == 2			//INCESA
				Replace E1_VEND1  WITH SA1->A1_YVENDI
				Replace E1_VEND2  WITH SA1->A1_YVENDI2 
				Replace E1_VEND3  WITH SA1->A1_YVENDI3				
				Replace E1_COMIS1 WITH SA1->A1_YCOMISI
				Replace E1_COMIS2 WITH SA1->A1_YCOMI2 
				Replace E1_COMIS3 WITH SA1->A1_YCOMI3
			ELSEIF MV_PAR08 == 3			//BELLACASA
				Replace E1_VEND1  WITH SA1->A1_YVENBE1
				Replace E1_VEND2  WITH SA1->A1_YVENBE2 
				Replace E1_VEND3  WITH SA1->A1_YVENBE3				
				Replace E1_COMIS1 WITH SA1->A1_YCOMBE1
				Replace E1_COMIS2 WITH SA1->A1_YCOMBE2
				Replace E1_COMIS3 WITH SA1->A1_YCOMBE3				
			ELSEIF MV_PAR08 == 4			//VITCER
				Replace E1_VEND1  WITH SA1->A1_YVENVT1
				Replace E1_VEND2  WITH SA1->A1_YVENVT2 
				Replace E1_VEND3  WITH SA1->A1_YVENVT3				
				Replace E1_COMIS1 WITH SA1->A1_YCOMVT1
				Replace E1_COMIS2 WITH SA1->A1_YCOMVT2
				Replace E1_COMIS3 WITH SA1->A1_YCOMVT3				
			ELSEIF MV_PAR08 == 5			//MUNDIALLI
				Replace E1_VEND1  WITH SA1->A1_YVENML1
				Replace E1_VEND2  WITH SA1->A1_YVENML2 
				Replace E1_VEND3  WITH SA1->A1_YVENML3				
				Replace E1_COMIS1 WITH SA1->A1_YCOMML1
				Replace E1_COMIS2 WITH SA1->A1_YCOMML2
				Replace E1_COMIS3 WITH SA1->A1_YCOMML3		
			ELSEIF MV_PAR08 == 6			//PEGASUS
				Replace E1_VEND1  WITH SA1->A1_YVENPEG
				Replace E1_COMIS1 WITH SA1->A1_YCOMPEG
			ELSEIF MV_PAR08 == 7			//VINILICO
				Replace E1_VEND1  WITH SA1->A1_YVENVI1
				Replace E1_COMIS1 WITH SA1->A1_YCOMVI1						
			ENDIF

			MsUnLock("SE1'")
			MSGBOX("Alteração do título realizada com sucesso!")
			
			DbSelectArea("SE5")
			DbSetOrder(7)
			DbSeek(xFilial()+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+MV_PAR06+MV_PAR07,.T.)
			IF !Found()
				MSGBOX("Não foi encontrado movimento bancário para este título!")
			ELSE
				
				WHILE SE5->E5_PREFIXO == SE1->E1_PREFIXO .AND. ;
					SE5->E5_NUMERO  == SE1->E1_NUM       .AND. ;
					SE5->E5_PARCELA == SE1->E1_PARCELA   .AND. ;
					SE5->E5_TIPO    == SE1->E1_TIPO      .AND. ;
					SE5->E5_CLIFOR  == MV_PAR06          .AND. ;
					SE5->E5_LOJA    == MV_PAR07          .AND. ;
					!EOF()
					
					IF MV_PAR06 <> SE5->E5_CLIFOR .OR. MV_PAR07 <> SE5->E5_LOJA
						DbSelectArea("SE5")
						DbSkip()
						Loop
					ENDIF
					
					RecLock("SE5")
					Replace E5_CLIFOR  WITH MV_PAR04
					Replace E5_LOJA    WITH MV_PAR05
					Replace E5_CLIENTE WITH MV_PAR04
					Replace E5_BENEF   WITH SA1->A1_NREDUZ
					MsUnLock("SE5")
					MSGBOX("Alteração da movimentação bancária realizada com sucesso!")
					
					DbSelectArea("SE5")
					DbSkip()
				END
			ENDIF
			
			DbSelectArea("SA1")
			RecLock("SA1")
			SA1->A1_SALDUP  :=  SA1->A1_SALDUP  + SE1->E1_VALOR
			SA1->A1_SALDUPM :=  SA1->A1_SALDUPM + SE1->E1_VALOR
			MsUnLock("SA1")
			MSGBOX("Alteração dos saldos do cliente realizada com sucesso!")
			
			DbSelectArea("SA1")
			DbSetOrder(1)
			DbSeek(xFilial()+MV_PAR06+MV_PAR07,.T.)
			RecLock("SA1")
			SA1->A1_SALDUP  :=  SA1->A1_SALDUP  - SE1->E1_VALOR
			SA1->A1_SALDUPM :=  SA1->A1_SALDUPM - SE1->E1_VALOR
			MsUnLock("SA1")
		ELSE
			MSGBOX("Esta RA já sofreu baixa, portanto não poderá ser alterada!")
		ENDIF
		
		DbSelectArea("SE1")
		DbSkip()
	END
ELSE
	MSGBOX("Não foi encontrado movimento bancário para este título!","STOP")
ENDIF

Return()