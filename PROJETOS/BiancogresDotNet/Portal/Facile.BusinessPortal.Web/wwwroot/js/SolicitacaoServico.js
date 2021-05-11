var table;

$(function () {
	$(":input").inputmask();
	$('.select2-select').select2();

	$("input.calc-quantidade").inputmask('currency', {
		"autoUnmask": true,
		radixPoint: ",",
		groupSeparator: ".",
		allowMinus: false,
		prefix: '',
		//digits: 2,
		digitsOptional: false,
		rightAlign: true,
		//unmaskAsNumber: true,
		removeMaskOnSubmit: true
	});

	var loopCheckItem = 0;
	table = $('#dt-registro').DataTable(
		{
			'columnDefs': [{ "orderable": false, "targets": 0 }],
			"order": [[0, "desc"]],
			orderCellsTop: true,
			fixedHeader: true,
			dom: "<'row mb-3'<'col-sm-12 col-md-6 d-flex align-items-center justify-content-start'B><'col-sm-12 col-md-6 d-flex align-items-center justify-content-end'l>>" +
				"<'row'<'col-sm-12'tr>>" +
				"<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7'p>>",
			buttons: [
				{
					text: '<i class="fal fa-plus mr-1"></i> Novo',
					className: 'btn btn-outline-primary waves-effect waves-themed',
					action: function (e, dt, node, config) {
						window.location.href = UrlBase + '/create'
					}
				}
			],
			"responsive": true,
			"processing": true,
			"serverSide": true,
			"ajax": {
				"url": "/Compra/SolicitacaoServico/DataTable",
				"type": "POST",
				"datatype": "json",
				"data": {
					FieldSearch: function () {
						return $('input[name=FieldSearch]').val()
					},
				},
			},
			"columns": [
				{
					"data": "numero", "name": "Numero"
				},
				{
					"data": "dataEmissao", "name": "dataEmissao"
				},
				{
					"data": "nomeSolicitanteReal", "name": "NomeSolicitanteReal"
				},
				{
					"data": "dataNecessidade", "name": "dataNecessidade"
				},
				{
					"data": "descricao", "name": "descricao"
				},
				{
					"data": "tipoServico", "name": "tipoServico"
				},
				{
					"data": "tipoVisita", "name": "tipoVisita"
				},
				{
					"data": "dataVisita", "name": "dataVisita"
				},
				{
					"data": "status", "name": "Status",
					"render": function (data, type, full, meta) {

						var classSpan = "badge-primary";
						if (full.status == 'Liberado Fornecedor') {
							classSpan = "badge-success";
						} 

						var html = '<h4><span class="badge ' + classSpan + '">' + full.status + '</span></h4>'
						return html;
					}
				},
				{
					"render": function (data, type, full, meta) {

						var html = ""

						html += '<div class="dropdown">																															';
						html += '	<a href="#" class="btn btn-default btn-icon waves-effect waves-themed" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">   ';
						html += '		<i class="ni ni-menu"></i>                                                                                                              ';
						html += '	</a>                                                                                                                                        ';
						html += '	<div class="dropdown-menu" x-placement="top-start" style="position: absolute; will-change: top, left; top: -201px; left: 0px;">             ';

						if (full.status == 'Aguardando') {
							html += '		<a class="dropdown-item"  href="../Compra/SolicitacaoServico/Edit/' + full.id + '" >Editar</a>																			';
                        }
						html += '		<a class="dropdown-item" href="../Compra/SolicitacaoServico/Details/' + full.id + '" >Detalhes</a>																		';

						if (full.quantFornecedor == 0) {
							html += '		<a class="dropdown-item btn-integrar-bizagi" href="javascript:void(0)" SolicitacaoServicoID="' + full.id + '" >Integrar BIZAGI</a>								';
						} else {
							if (full.status == 'Aguardando' || full.status == 'Liberado Fornecedor') {
								html += '		<a class="dropdown-item btn-liberar-fornecedor" href="javascript:void(0)" SolicitacaoServicoID="' + full.id + '" >Liberar Fornecedores</a>								';
								html += '		<a class="dropdown-item" href="../Compra/SolicitacaoServicoCotacao/Select/' + full.id + '" >Escolher Cotação</a>														';
							}
						}

						if (full.tipoServico == 'Contrato') {
							html += '		<a class="dropdown-item btn-medicao" href="javascript:void(0)" Tipo="1" SolicitacaoServicoID="' + full.id + '" >Medição</a>																		';
						} else if (full.tipoServico == 'Pedido') {
							html += '		<a class="dropdown-item btn-medicao" href="javascript:void(0)" Tipo="2" SolicitacaoServicoID="' + full.id + '" >Anexo Nota Fiscal</a>																		';
						}

						html += '		<a class="dropdown-item" href="../Compra/SolicitacaoServico/IndexHistorico/' + full.id + '" >Histórico</a>																		';

						html += '	</div>                                                                                                                                      ';
						html += '</div>';

						return html;
					}
				}
			],
			"lengthMenu": [[10, 20, 30, -1], [10, 20, 30, "All"]],
			"aaSorting": [],
			"oLanguage": {
				"oPaginate": {
					"sNext": ">",
					"sFirst": "<<",
					"sLast": ">>",
					"sPrevious": "<"
				},
				"sLengthMenu": "Mostrar:  _MENU_",
				"sZeroRecords": "Não há registros correspondentes foram encontrados",
				"sInfo": "Mostrando _START_ a _END_ de _TOTAL_ no total",
				"sInfoEmpty": "Mostrando 0 a 0 de 0 no total",
				"sInfoFiltered": "(filtrado das _MAX_ entradas totais)",
				"sSearch": "Filtrar: ",
				"sEmptyTable": "Não há dados disponíveis na tabela",
				"sLoadingRecords": "Carregando...",
				"sProcessing": "Processando..."
			},
		});

	var CamposFiltro = ['Numero', 'DataEmissao', 'NomeSolicitanteReal', 'DataNecessidade', "Descricao", 'TipoServico', 'TipoVisita', 'Data Visita','Status',''];
	$('#dt-registro thead tr').clone(false).appendTo('#dt-registro thead');

	$('#dt-registro thead tr:eq(1) th').each(function (i) {
		$(this).removeClass('sorting');

		if (CamposFiltro[i] != "") {
			var title = $(this).text();

			$(this).html('<div class="form-check-inline" style="width: 100%;"><div class="" style="width: 100%;"><input type="text" name="' + CamposFiltro[i] + '" class="form-control form-control-sm search" placeholder=""></div><div class="" ><div class="columnFilter filter-search" ><i class="fal fa-filter mr-1"></i></div></div>');

			$('input', this).on('keyup', function (e) {

				if (e.keyCode == 13) {
					FuncSearch(this, table);
				}

			});
		} else {
			$(this).html('');
		}

	});


	$('.filter-search').on('click', function () {
		FuncSearch(this, table);
	});

	$('.filter-close').on('click', function () {
		$(this).closest('th').find('input').val('');
		FuncSearch(table);
	});


	$('#dt-registro').on('click', 'a.btn-medicao', function () {
		var Id = $(this).attr('SolicitacaoServicoID');
		var Tipo = $(this).attr('Tipo');


		$('#preloader').removeClass('hide');
		$('#preloader div#status').html('Aguarde...');

		$.get(
			'/Compra/SolicitacaoServicoUtil/UsuarioMedicao',
			{ Id: Id },
			function (d) {
				
				$('#preloader').addClass('hide');

				if (d.ok) {
					if (Tipo == "1") {
						window.location = "../Compra/SolicitacaoServicoMedicao/CreateMedicao/" + Id
					} else {
						window.location = "../Compra/SolicitacaoServicoMedicaoUnica/CreateMedicao/" + Id
                    }
				} else {
					Swal.fire({
						type: "error",
						title: "",
						text: "Usuário não responsável pela medição",
					});
				}
								
			}
		);
	})


	$('#dt-registro').on('click', 'a.btn-liberar-integracao', function () {

		var Id = $(this).attr('SolicitacaoServicoID')
		Swal.fire(
			{
				text: "Deseja liberar integracao com bizagi?",
				type: "warning",
				showCancelButton: true,
				confirmButtonText: "Sim",
				cancelButtonText: "Não"
			}).then(function (result) {
				if (result.value) {

					$('#preloader').removeClass('hide');
					$('#preloader div#status').html('Aguarde...');

					$.get(
						'/Compra/SolicitacaoServico/IntegracaoBizagi',
						{ Id: Id },
						function (d) {
							var type = ""
							var text = ""

							$('#preloader').addClass('hide');

							if (d.ok) {
								type = "success";
								text = "Integração com bizagi liberada sucesso.";
							} else {
								type = "error"
								text = d.mensagem
							}

							table.ajax.reload();

							Swal.fire({
								type: type,
								title: "",
								text: text,
							});
						}
					);


				}
			});
	});

	$('#dt-registro').on('click', 'a.btn-liberar-fornecedor', function () {

		var Id = $(this).attr('SolicitacaoServicoID')
		Swal.fire(
			{
				text: "Deseja liberar cotações para fornecedores?",
				type: "warning",
				showCancelButton: true,
				confirmButtonText: "Sim",
				cancelButtonText: "Não"
			}).then(function (result) {
				if (result.value) {

					$('#preloader').removeClass('hide');
					$('#preloader div#status').html('Aguarde...');

					var formdata = new FormData($('#cadNovoFornecedor')[0]);

					$.get(
						'/Compra/SolicitacaoServico/EnviarEmailFornecedor',
						{Id:Id},
						function (d) {
							var type = ""
							var text = ""



							$('#preloader').addClass('hide');

							if (d.ok) {
								type = "success";
								text = "Email enviado com sucesso.";
							} else {
								type = "error"
								text = d.mensagem
							}

							table.ajax.reload();

							Swal.fire({
								type: type,
								title: "",
								text: text,
							});
						}
					);

					
				}
			});


	});

	$('#dt-registro').on('click', 'a.btn-integrar-bizagi', function () {

		var Id = $(this).attr('SolicitacaoServicoID')
		Swal.fire(
			{
				text: "Deseja liberar integração com BIZAGI?",
				type: "warning",
				showCancelButton: true,
				confirmButtonText: "Sim",
				cancelButtonText: "Não"
			}).then(function (result) {
				if (result.value) {

					$('#preloader').removeClass('hide');
					$('#preloader div#status').html('Aguarde...');

					$.get(
						'/Compra/SolicitacaoServico/LiberarIntegracaoBizagi',
						{ Id: Id },
						function (d) {
							var type = ""
							var text = ""

							$('#preloader').addClass('hide');

							if (d.ok) {
								type = "success";
								text = d.mensagem;
							} else {
								type = "error"
								text = d.mensagem
							}

							table.ajax.reload();

							Swal.fire({
								type: type,
								title: "",
								text: text,
							});
						}
					);


				}
			});


	});

	
	$('select[name=TipoVisita]').on('change', function () {
		var val = $(this).val();
		if (val == "1" || val == "2") {
			$('.habilita-data-visita').removeClass('hide');
			$('.habilitar-visita-fornecedor').removeClass('hide');
		} else {
			$('.habilita-data-visita').addClass('hide');
			$('.habilitar-visita-fornecedor').addClass('hide');
        }

	});

});


$(function () {

	
	$('.date-rangepicker').daterangepicker(
		{
			"timePicker": true,
			"timePicker24Hour": true,
			"timePickerSeconds": false,
			"autoApply": true,
			"singleDatePicker": true,
			"showDropdowns": true,
			"applyButtonClasses": "btn-default shadow-0",
			"cancelClass": "btn-success shadow-0",
		
			"locale":
			{
				format: 'DD/MM/YYYY hh:mm',
				applyLabel: 'Aplicar',
				cancelLabel: 'Cancelar',
			}
		}, function (start, end, label) {
		
	});

	$('.btn-novo-servico').on('click',
		function () {
			NovoServico();
		}
	);

	$('.btn-salvar-servico').on('click',
		function () {
			SalvarServico();
		}
	);

	$('#tabela-servico-item').on('click', '.btn-delete-servico-item',
		function (e) {
			$(this).closest('tr').remove();		
			e.stopPropagation();
		}
	);

	$('#tabela-servico-item').on('click', '.tr-linha-servico-item',
		function () {
			EditarServico(this);
		}
	);

	$('.btn-novo-fornecedor-solicitacao').on('click',
		function () {
			NovoFornecedorSolicitacao();
		}
	);

	$('.btn-salvar-fornecedor').on('click',
		function () {
			SalvarFornecedorSolicitacao();
		}
	);

	$('#tabela-fornecedor-item').on('click', '.btn-delete-fornecedor-item',
		function (e) {
			$(this).closest('tr').remove();
			e.stopPropagation();
		}
	);

	$('#tabela-fornecedor-item').on('click', '.tr-linha-fornecedor-item',
		function () {
			EditarFornecedor(this);
		}
	);

	
	$('input[name=customFile]').on('change', function () {
		var val = $(this).val();
		$(this).closest('div.custom-file').find('.nome-arquivo').remove();
		if (val != "") {
			$(this).closest('div.custom-file').append('<div class="nome-arquivo">' + val + '</div>');
		}
	});



	$('.btn-salvar-ss').on('click', function () {

		var TipoServico = $("select[name='TipoServico']").val();
		var ClasseValor = $("select[name='ClasseValorID'] option:selected").text();

		if ($("select[name='TipoServico']").val() == "") {
			alert("O campo 'Tipo Serviço' de obrigatório.");
			return;
		}

		if ($("select[name='TipoVisita']").val() == "") {
			alert("O campo 'Tipo Visita' de obrigatório.");
			return;
		}

		if ($("select[name='PrioridadeServicoID']").val() == "") {
			alert("O campo 'Prioridade' de obrigatório.");
			return;
		}

		if ($("input[name='DataNecessidade']").val() == "") {
			alert("O campo 'Data Necessidade' de obrigatório.");
			return;
		}

		if ($("select[name='ClasseValorID']").val() == "") {
			alert("O campo 'Classe de Valor' de obrigatório.");
			return;
		}

		if ($("select[name='SetorAprovacaoID']").val() == "") {
			alert("O campo 'Setor Aprovação' de obrigatório.");
			return;
		}

		if (TipoServico == '2' && ClasseValor.substring(0, 1) == '8') {
			if ($("select[name='ItemContaID']").val() == "") {
				alert("O campo 'Item Conta' de obrigatório.");
				return;
			}
			if ($("select[name='SubItemContaID']").val() == "") {
				alert("O campo 'Sub Item Conta' de obrigatório.");
				return;
			}
			if ($("select[name='ContratoID']").val() == "") {
				alert("O campo 'Contrato' de obrigatório.");
				return;
			}
		}

		if (!isValidDate($("input[name='DataNecessidade']").val())) {
			alert("O campo 'Data Necessidade' inválido.");
			return;
		}

		
		if ($("select[name='TipoServico']").val() == "1") {
			var el = $('#tabela-servico-item tbody tr');
			for (var i = 0; i < el.length; i++) {
				var DataInicio = $(el[i]).find('input[name="SolicitacaoServicoItem[' + (i)+'].DataInicioContrato"]').val();
				var DataFinal = $(el[i]).find('input[name="SolicitacaoServicoItem[' + (i) +'].DataFinalContrato"]').val();

				if (!isValidDate(DataInicio)) {
					alert("O campo 'Data Início Contrato' inválido, Linha: "+(i+1)+".");
					return;
				}
				if (!isValidDate(DataFinal)) {
					alert("O campo 'Data Final Contrato' inválido, Linha: "+(i+1)+".");
					return;
				}
			}
		}
		
		$('#preloader').removeClass('hide');
		$('#preloader div#status').html('Aguarde...');
		$("form[name=FormCad]").submit();
	});


	$('.btn-novo-fornecedor').on('click',
		function () {
			$('#modal-solicitacao-fornecedor').modal('hide');
			$('#modal-novo-fornecedor').modal('show');
		}
	);

	$('.btn-salvar-novo-fornecedor').on('click',
		function () {
			NovoFornecedor();
		}
	);

});



function NovoFornecedor() {

	if ($("form[name='cadNovoFornecedor'] input[name='CPFCNPJ']").val() == "") {
		alert("O campo 'CPF/CNPJ' de obrigatório.");
		return;
	}

	if ($("form[name='cadNovoFornecedor'] input[name='Social']").val() == "") {
		alert("O campo 'Razao Social' de obrigatório.");
		return;
	}

	if ($("form[name='cadNovoFornecedor'] input[name='Nome']").val() == "") {
		alert("O campo 'Nome' de obrigatório.");
		return;
	}

	if ($("form[name='cadNovoFornecedor'] input[name='Contato']").val() == "") {
		alert("O campo 'Contato' de obrigatório.");
		return;
	}

	if ($("form[name='cadNovoFornecedor'] input[name='Email']").val() == "") {
		alert("O campo 'E-mail' de obrigatório.");
		return;
	}

	if ($("form[name='cadNovoFornecedor'] input[name='Telefone']").val() == "") {
		alert("O campo 'Telefone' de obrigatório.");
		return;
	}

	if ($("form[name='cadNovoFornecedor'] input[name='CEP']").val() == "") {
		alert("O campo 'CEP' de obrigatório.");
		return;
	}

	if ($("form[name='cadNovoFornecedor'] input[name='UF']").val() == "") {
		alert("O campo 'UF' de obrigatório.");
		return;
	}

	if ($("form[name='cadNovoFornecedor'] input[name='Cidade']").val() == "") {
		alert("O campo 'Cidade' de obrigatório.");
		return;
	}
	
	$('#modal-novo-fornecedor').modal('hide');
	Swal.fire(
		{
			text: "Deseja salvar o fornecedor informado?",
			type: "warning",
			showCancelButton: true,
			confirmButtonText: "Sim",
			cancelButtonText: "Não"
		}).then(function (result) {
			if (result.value) {

				$('#preloader').removeClass('hide');
				$('#preloader div#status').html('Aguarde...');

				var formdata = new FormData($('#cadNovoFornecedor')[0]);

				$.ajax({
					type: 'POST',
					url: '/Compra/SolicitacaoServico/NovoFornecedor',
					data: formdata,
					processData: false,
					contentType: false
				}).done(function (d) {

					$('#preloader').addClass('hide');

					var type = ""
					var text = ""

					if (d.ok) {
						type = "success";
						text = "Fornecedor cadastrado com sucesso.";
					} else {
						type = "error"
						text = d.mensagem
					}

					
					Swal.fire({
						type: type,
						title: "",
						text: text,
					});

				});

			}
		});

}


function LimpaCamposServico() {
	$("form[name=cadSolicitacaoServico] select[name='ServicoID']").val('').trigger("change");
	$("form[name=cadSolicitacaoServico] input[name='ServicoDescricao']").val('');
	$("form[name=cadSolicitacaoServico] input[name='ServicoQuantidade']").val('');

	$("form[name=cadSolicitacaoServico] select[name='ServicoAplicacao']").val('').trigger("change");
	$("form[name=cadSolicitacaoServico] select[name='ServicoDriver']").val('').trigger("change");
	$("form[name=cadSolicitacaoServico] select[name='ServicoTag']").val('').trigger("change");
	$("form[name=cadSolicitacaoServico] select[name='ServicoArmazem']").val('').trigger("change");
	$("form[name=cadSolicitacaoServico] select[name='ServicoUnidadeMedicao']").val('').trigger("change");
	$("form[name=cadSolicitacaoServico] input[name='ServicoLinha']").val('');

	$("form[name=cadSolicitacaoServico] input[name='ServicoDataInicioContrato']").val('');
	$("form[name=cadSolicitacaoServico] input[name='ServicoDataFinalContrato']").val('');

	$("form[name=cadSolicitacaoServico] select[name='ServicoCodigoCliente']").val('').trigger("change");
	$("form[name=cadSolicitacaoServico] input[name='ServicoClassificaoContabil']").val('');

}

function NovoServico() {

	if ($("select[name='TipoServico']").val() == "") {
		alert("É necessário informar a 'Tipo Serviço' para adicionar um serviço.");
		return;
	}

	$('.tipo-servico-pedido').removeClass('hide');
	if ($("select[name='TipoServico']").val() == "2") {
		$('.tipo-servico-pedido').addClass('hide');
	}

	if ($("select[name='ClasseValorID']").val() == "") {
		alert("É necessário informar a 'Classe de Valor' para adicionar um serviço.");
		return;
	}
	
	LimpaCamposServico();
	$('#modal-solicitacao-servico').modal('show');
}

var LinhaServico = $('#tabela-servico-item tr').length - 1;
function SalvarServico() {

	var ServicoID = $("form[name=cadSolicitacaoServico] select[name='ServicoID']").val();
	var ServicoDescricao = $("form[name=cadSolicitacaoServico] input[name='ServicoDescricao']").val();
	var ServicoQuantidade = $("form[name=cadSolicitacaoServico] input[name='ServicoQuantidade']").val();
	var ServicoAplicacao = $("form[name=cadSolicitacaoServico] select[name='ServicoAplicacao']").val();
	var ServicoDriver = $("form[name=cadSolicitacaoServico] select[name='ServicoDriver']").val();
	var ServicoTag = $("form[name=cadSolicitacaoServico] select[name='ServicoTag']").val()||'';
	var ServicoArmazem = $("form[name=cadSolicitacaoServico] select[name='ServicoArmazem']").val();
	var ServicoLinha = $("form[name=cadSolicitacaoServico] input[name='ServicoLinha']").val();
	var ServicoUnidadeMedicao = $("form[name=cadSolicitacaoServico] select[name='ServicoUnidadeMedicao']").val();
	var ServicoDataInicioContrato = $("form[name=cadSolicitacaoServico] input[name='ServicoDataInicioContrato']").val();
	var ServicoDataFinalContrato = $("form[name=cadSolicitacaoServico] input[name='ServicoDataFinalContrato']").val();
	var ServicoCodigoCliente = $("form[name=cadSolicitacaoServico] select[name='ServicoCodigoCliente']").val();
	var ServicoClassificaoContabil = $("form[name=cadSolicitacaoServico] input[name='ServicoClassificaoContabil']").val();
	

	if (ServicoID == "") {
		alert("O campo 'Código' de obrigatório.");
		return;
	}

	if (ServicoDescricao == "") {
		alert("O campo 'Descrição' de obrigatório.");
		return;
	}

	if (ServicoQuantidade == "") {
		alert("O campo 'Quantidade' de obrigatório.");
		return;
	}

	if (ServicoAplicacao == "") {
		alert("O campo 'Aplicação' de obrigatório.");
		return;
	}

	
	if (ServicoDriver == "" || ServicoDriver == 'null' || ServicoDriver == null) {
		alert("O campo 'Driver' de obrigatório.");
		return;
	}

	if ($("select[name='TipoServico']").val() == "1") {
		if (ServicoDataInicioContrato == "" || ServicoDataFinalContrato == "") {
			alert("O campo 'Data Início Contrato' e 'Data Final Contrato' de obrigatório.");
			return;
		}
		if (ServicoDataInicioContrato.length != 10 || ServicoDataFinalContrato.length != 10) {
			alert("O campo 'Data Início Contrato' e 'Data Final Contrato' são inválidos. Exemplo formato correto: 01/01/2020.");
			return;
		}
		if (ServicoDataInicioContrato.length != 10 || ServicoDataFinalContrato.length != 10) {
			alert("O campo 'Data Início Contrato' e 'Data Final Contrato' são inválidos. Exemplo formato correto: 01/01/2020.");
			return;
		}
		
	} else {
		ServicoDataInicioContrato = ""
		ServicoDataFinalContrato = ""
	}

	if ($("select[name='ServicoUnidadeMedicao']").val() == "1") {
		var Quant = parseFloat(ServicoQuantidade.replace(",", "."));
		if (Quant != 1) {
			alert("O campo 'Quantidade' deve ser 1 para 'Unidade Medição=Percentual'");
			return;
		}
	}

	var ServicoAplicacaoDescricao = $("form[name=cadSolicitacaoServico] select[name='ServicoAplicacao'] option:selected").text();
	var ServicoArmazemDescricao = $("form[name=cadSolicitacaoServico] select[name='ServicoArmazem'] option:selected").text();
	var ServicoUnidadeMedicaoDescricao = $("form[name=cadSolicitacaoServico] select[name='ServicoUnidadeMedicao'] option:selected").text();

	var data = $("form[name=cadSolicitacaoServico] select[name='ServicoID']").select2('data');
	var ServicoCodigo = "";
	if (data.length > 0) {
		ServicoCodigo = data[0].codigo || data[0].text || '';
	}

	var data = $("form[name=cadSolicitacaoServico] select[name='ServicoDriver']").select2('data');
	var ServicoDriverCodigo = "";
	var ServicoDriverDescricao = "";

	if (data.length > 0) {
		ServicoDriverCodigo = data[0].codigo || data[0].text || '';
		ServicoDriverDescricao = data[0].text || '';
	}

	var data = $("form[name=cadSolicitacaoServico] select[name='ServicoTag']").select2('data');
	var ServicoTagCodigo = '';
	if (data.length > 0) {
		ServicoTagCodigo = data[0].codigo || data[0].text || '';
    }

	var LinhaID = LinhaServico;
	if (ServicoLinha != "") {
		LinhaID = parseInt(ServicoLinha,10);
	}

	
	var cols = "";	
	cols += "<td>";
	cols += "<input type='hidden' name='LinhaServico' id='' value='" + LinhaID + "'>												";
	cols += "<input type='hidden' name='SolicitacaoServicoItem[" + LinhaID +"].CodigoProduto' id='' value='" + ServicoCodigo + "' class='form-control' >						";
	cols += "<input type='hidden' name='SolicitacaoServicoItem[" + LinhaID +"].ProdutoID' id='' value='" + ServicoID + "' class='form-control' > " + ServicoCodigo + "			";
	cols += "<input type='hidden' name='SolicitacaoServicoItem[" + LinhaID +"].DataInicioContrato' id='' value='" + ServicoDataInicioContrato + "' class='form-control' >	";
	cols += "<input type='hidden' name='SolicitacaoServicoItem[" + LinhaID +"].DataFinalContrato' id='' value='" + ServicoDataFinalContrato + "' class='form-control' >	";
	cols += "<input type='hidden' name='SolicitacaoServicoItem[" + LinhaID + "].ClassificaoContabil' id='' value='" + ServicoClassificaoContabil  + "' class='form-control' >	";
	cols += "<input type='hidden' name='SolicitacaoServicoItem[" + LinhaID + "].CodigoCliente' id='' value='" + ServicoCodigoCliente + "' class='form-control' >	";

	cols += "</td>";

	cols += "<td><input type='hidden' name='SolicitacaoServicoItem[" + LinhaID +"].Descricao' id='' value='" + ServicoDescricao + "' class='form-control'>" + ServicoDescricao + "</td>";
	cols += "<td><input type='hidden' name='SolicitacaoServicoItem[" + LinhaID + "].Quantidade' id='' value='" + ServicoQuantidade + "' class='form-control'>" + ServicoQuantidade + "</td>";
	cols += "<td><input type='hidden' name='SolicitacaoServicoItem[" + LinhaID +"].AplicacaoID' id='' value='" + ServicoAplicacao + "' class='form-control'>" + ServicoAplicacaoDescricao + "</td>";

	cols += "<td>";
	cols += "<input type='hidden' name='SolicitacaoServicoItem[" + LinhaID +"].DriverID' id='' value='" + ServicoDriver + "' class='form-control'>";
	cols += "<input type='hidden' name='SolicitacaoServicoItem[" + LinhaID +"].DriverCodigo' id='' value='" + ServicoDriverCodigo + "' class='form-control'>" + ServicoDriverCodigo + "";
	cols += "<input type='hidden' name='SolicitacaoServicoItem[" + LinhaID + "].DriverDescricao' id='' value='" + ServicoDriverDescricao + "' class='form-control'>";
	cols += "</td>";

	cols += "<td>";
	cols += "<input type='hidden' name='SolicitacaoServicoItem[" + LinhaID +"].TAGID' id='' value='" + ServicoTag + "' class='form-control'>";
	cols += "<input type='hidden' name='SolicitacaoServicoItem[" + LinhaID +"].TagCodigo' id='' value='" + ServicoTagCodigo + "' class='form-control'>" + ServicoTagCodigo + "";
	cols += "</td>";

	cols += "<td><input type='hidden' name='SolicitacaoServicoItem[" + LinhaID +"].ArmazemID' id='' value='" + ServicoArmazem + "' class='form-control'>" + ServicoArmazemDescricao + "</td>";
	cols += "<td><input type='hidden' name='SolicitacaoServicoItem[" + LinhaID +"].UnidadeMedicao' id='' value='" + ServicoUnidadeMedicao + "' class='form-control'>" + ServicoUnidadeMedicaoDescricao + "</td>";

	cols += '<td class="text-right">';
	cols += '	<a style="z-index: 100;" href="javascript:void(0)" class="btn btn-icon fs-xl waves-effect waves-themed btn-delete-servico-item">';
	cols += '	<i class="fal fa-trash-alt color-fusion-300"></i>';
	cols += '	</a>';
	cols += '</td>';

	if (ServicoLinha == "") {
		var newRow = $("<tr style='cursor:pointer' class='tr-linha-servico-item'>");
		newRow.append(cols);
		$("#tabela-servico-item").append(newRow);
		LinhaServico++;
	} else {

		var el = $('#tabela-servico-item').find('input[name="LinhaServico"][value=' + ServicoLinha + ']').closest('tr');
		$(el).html(cols);
	}
	
	$('#modal-solicitacao-servico').modal('hide');	
}


function EditarServico(el) {

	LimpaCamposServico();

	$('.tipo-servico-pedido').removeClass('hide');
	if ($("select[name='TipoServico']").val() == "2") {
		$('.tipo-servico-pedido').addClass('hide');
	}

	var LinhaServico = $(el).find('input[name="LinhaServico"]').val();

	var IDServico = $(el).find('input[name="SolicitacaoServicoItem[' + LinhaServico +'].ProdutoID"]').val();
	var CodigoServico = $(el).find('input[name="SolicitacaoServicoItem[' + LinhaServico +'].CodigoProduto"]').val();
	var DescricaoServico = $(el).find('input[name="SolicitacaoServicoItem[' + LinhaServico +'].Descricao"]').val();
	var QuantidadeServico = $(el).find('input[name="SolicitacaoServicoItem[' + LinhaServico +'].Quantidade"]').val();
	var AplicacaoServico = $(el).find('input[name="SolicitacaoServicoItem[' + LinhaServico +'].AplicacaoID"]').val();
	var DriverServico = $(el).find('input[name="SolicitacaoServicoItem[' + LinhaServico +'].DriverID"]').val();
	var DriverCodigoServico = $(el).find('input[name="SolicitacaoServicoItem[' + LinhaServico + '].DriverCodigo"]').val();
	var DriverDescricaoServico = $(el).find('input[name="SolicitacaoServicoItem[' + LinhaServico + '].DriverDescricao"]').val();

	var TagServico = $(el).find('input[name="SolicitacaoServicoItem[' + LinhaServico +'].TAGID"]').val();
	var TagCodigoServico = $(el).find('input[name="SolicitacaoServicoItem[' + LinhaServico +'].TAGCodigo"]').val();

	var ArmazemServico = $(el).find('input[name="SolicitacaoServicoItem[' + LinhaServico +'].ArmazemID"]').val();
	var UnidadeMedicaoServico = $(el).find('input[name="SolicitacaoServicoItem[' + LinhaServico +'].UnidadeMedicao"]').val();

	var DataInicioContratoServico = $(el).find("input[name='SolicitacaoServicoItem[" + LinhaServico +"].DataInicioContrato']").val();
	var DataFinalContratoServico = $(el).find("input[name='SolicitacaoServicoItem[" + LinhaServico +"].DataFinalContrato']").val();

	var ClassificaoContabilServico = $(el).find("input[name='SolicitacaoServicoItem[" + LinhaServico + "].ClassificaoContabil']").val();
	var CodigoClienteServico = $(el).find("input[name='SolicitacaoServicoItem[" + LinhaServico + "].CodigoCliente']").val();

	
	$("form[name=cadSolicitacaoServico] select[name='ServicoID']").select2("trigger", "select", {
		data: { id: IDServico, text: CodigoServico, nome: DescricaoServico }
	});

	$("form[name=cadSolicitacaoServico] select[name='ServicoDriver']").select2("trigger", "select", {
		data: { id: DriverServico, text: DriverCodigoServico, descricao: DriverDescricaoServico, codigo: DriverCodigoServico }
	});

	$("form[name=cadSolicitacaoServico] select[name='ServicoTag']").select2("trigger", "select", {
		data: { id: TagServico, text: TagCodigoServico, codigo: TagCodigoServico, descricao: TagCodigoServico }
	});

	$("form[name=cadSolicitacaoServico] input[name='ServicoDescricao']").val(DescricaoServico);
	$("form[name=cadSolicitacaoServico] input[name='ServicoQuantidade']").val(QuantidadeServico);
	$("form[name=cadSolicitacaoServico] select[name='ServicoAplicacao']").val(AplicacaoServico).trigger('change');

	$("form[name=cadSolicitacaoServico] select[name='ServicoArmazem']").val(ArmazemServico).trigger('change');
	$("form[name=cadSolicitacaoServico] select[name='ServicoUnidadeMedicao']").val(UnidadeMedicaoServico).trigger('change');
	$("form[name=cadSolicitacaoServico] input[name='ServicoLinha']").val(LinhaServico);

	$("form[name=cadSolicitacaoServico] input[name='ServicoDataInicioContrato']").val(DataInicioContratoServico);
	$("form[name=cadSolicitacaoServico] input[name='ServicoDataFinalContrato']").val(DataFinalContratoServico);

	$("form[name=cadSolicitacaoServico] select[name='ServicoCodigoCliente']").select2("trigger", "select", {
		data: { id: CodigoClienteServico, text: CodigoClienteServico, codigo: CodigoClienteServico }
	});

	
	$("form[name=cadSolicitacaoServico] input[name='ServicoClassificaoContabil']").val(ClassificaoContabilServico);

	$('#modal-solicitacao-servico').modal('show');
}


function NovoFornecedorSolicitacao() {

	if ($("select[name='TipoVisita']").val() == "") {
		alert("É necessário informar a 'Tipo Visita' para adicionar um fornecedor.");
		return;
	}

	$("form[name=cadSolicitacaoFornecedor] select[name='FornecedorID']").val('').trigger("change");
	$("form[name=cadSolicitacaoFornecedor] input[name='FornecedorNome']").val('');
	$("form[name=cadSolicitacaoFornecedor] input[name='FornecedorVisita']").val('');
	$("form[name=cadSolicitacaoFornecedor] input[name='FornecedorLinha']").val('');
	
	$('#modal-solicitacao-fornecedor').modal('show');
}

var LinhaFornecedor = $('#tabela-fornecedor-item tr').length - 1;
function SalvarFornecedorSolicitacao() {

	var FornecedorID		= $("form[name=cadSolicitacaoFornecedor] select[name='FornecedorID']").val();
	var FornecedorNome		= $("form[name=cadSolicitacaoFornecedor] input[name='FornecedorNome']").val();
	var FornecedorVisita	= $("form[name=cadSolicitacaoFornecedor] select[name='FornecedorVisita']").val();
	var FornecedorLinha		= $("form[name=cadSolicitacaoFornecedor] input[name='FornecedorLinha']").val();
	var FornecedorVisitaDescricao = $("form[name=cadSolicitacaoFornecedor] select[name='FornecedorVisita'] option:selected").text();

	var data = $("form[name=cadSolicitacaoFornecedor] select[name='FornecedorID']").select2('data');
	var FornecedorCNPJ = "";
	if (data.length > 0) {
		FornecedorCNPJ = data[0].cpfcnpj || data[0].text || '';
	}

	if(FornecedorVisita == ""){
		FornecedorVisitaDescricao = "";
    }

	var LinhaID = LinhaFornecedor;
	if (FornecedorLinha != "") {
		LinhaID = parseInt(FornecedorLinha, 10);
	}

	var cols = "";
	cols += "<td>";
	cols += "<input type='hidden' name='LinhaFornecedor' id='' value='" + LinhaID + "'>";
	cols += "<input type='hidden' name='SolicitacaoServicoFornecedor[" + LinhaID +"].FornecedorCNPJ' id='' value='" + FornecedorCNPJ + "' class='form-control' >";
	cols += "<input type='hidden' name='SolicitacaoServicoFornecedor[" + LinhaID +"].FornecedorID' id='' value='" + FornecedorID + "' class='form-control' > " + FornecedorCNPJ + "";
	cols += "</td>";

	cols += "<td><input type='hidden' name='SolicitacaoServicoFornecedor[" + LinhaID +"].FornecedorNome' id='' value='" + FornecedorNome + "' class='form-control'>" + FornecedorNome + "</td>";
	cols += "<td><input type='hidden' name='SolicitacaoServicoFornecedor[" + LinhaID +"].AgendarVisita' id='' value='" + FornecedorVisita + "' class='form-control'>" + FornecedorVisitaDescricao + "</td>";

	cols += '<td class="text-right">';
	cols += '	<a style="z-index: 100;" href="javascript:void(0)" class="btn btn-icon fs-xl waves-effect waves-themed btn-delete-fornecedor-item">';
	cols += '	<i class="fal fa-trash-alt color-fusion-300"></i>';
	cols += '	</a>';
	cols += '</td>';

	if (FornecedorLinha == "") {
		var newRow = $("<tr style='cursor:pointer' class='tr-linha-fornecedor-item'>");
		newRow.append(cols);
		$("#tabela-fornecedor-item").append(newRow);
		LinhaFornecedor++;
	} else {
		var el = $('#tabela-fornecedor-item').find('input[name="LinhaFornecedor"][value=' + FornecedorLinha + ']').closest('tr');
		$(el).html(cols);
	}

	$('#modal-solicitacao-fornecedor').modal('hide');
}


function EditarFornecedor(el) {
	
	var LinhaFornecedor = $(el).find('input[name="LinhaFornecedor"]').val();

	var IDFornecedor = $(el).find('input[name="SolicitacaoServicoFornecedor[' + LinhaFornecedor + '].FornecedorID"]').val();
	var CNPJFornecedor = $(el).find('input[name="SolicitacaoServicoFornecedor[' + LinhaFornecedor +'].FornecedorCNPJ"]').val();
	var NomeFornecedor = $(el).find('input[name="SolicitacaoServicoFornecedor[' + LinhaFornecedor +'].FornecedorNome"]').val();
	var VisitaFornecedor = $(el).find('input[name="SolicitacaoServicoFornecedor[' + LinhaFornecedor +'].AgendarVisita"]').val();
	
	$('#modal-solicitacao-fornecedor').modal('show');

	$("form[name=cadSolicitacaoFornecedor] select[name='FornecedorID']").select2("trigger", "select", {
		data: { id: IDFornecedor, text: CNPJFornecedor, cpfcnpj: CNPJFornecedor, nome: NomeFornecedor }
	});

	$("form[name=cadSolicitacaoFornecedor] input[name='FornecedorNome']").val(NomeFornecedor);
	$("form[name=cadSolicitacaoFornecedor] input[name='FornecedorLinha']").val(LinhaFornecedor);
	$("form[name=cadSolicitacaoFornecedor] select[name='FornecedorVisita']").val(VisitaFornecedor);
}

/*

$('#dt-registro').on('click', 'a.btn-agendamento', function () {
	$('#modal-solicitacao-agendamento').modal('show');
	$('#cadSolicitacaoServico input[name=SolicitacaoServicoID]').val($(this).attr('SolicitacaoServicoID'));
});

$('.btn-salvar-agendamento').on('click', function () {

	$('#modal-solicitacao-agendamento').modal('hide');

	$('#preloader').removeClass('hide');
	$('#preloader div#status').html('Aguarde...');

	var formdata = new FormData($('#cadSolicitacaoServico')[0]);

	$.ajax({
		type: 'POST',
		url: '../Compra/SolicitacaoServico/SalvarAgendaFornecedor',
		data: formdata,
		processData: false,
		contentType: false
	}).done(function (d) {

		$('#preloader').addClass('hide');

		var type = ""
		var text = ""

		if (d.ok) {
			type = "success";
			text = "Fornecedor cadastrado com sucesso.";
		} else {
			type = "error"
			text = d.mensagem
		}

		Swal.fire({
			type: type,
			title: "",
			text: text,
		});

	});

})
*/